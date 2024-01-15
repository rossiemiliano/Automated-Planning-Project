; -------------------------------------------------------------------------------------------------------------------------------------
; We had to rewrite the either in predicates because it is not supported by the planners tested
; Write the condition one at time, as described in the official documentation https://planning.wiki/ref/pddl21/domain#durative-actions
; OPTIC planner does not support :negative-preconditions. Please refer to the no_negative_preconditions folder for the modified version
; These planners supports :numeric-fluents, that's why we rewrite the domain and the problem to take advantage of it
; -------------------------------------------------------------------------------------------------------------------------------------

(define (domain domain4) 
    (:requirements :strips :typing :durative-actions :equality :negative-preconditions :numeric-fluents)

    ; --- TYPES ---
    (:types
        person robotic_agent location box carrier supply - object
        food medicine tools - supply
    )

    ; --- PREDICATES ---
    (:predicates
        (located_at_robot ?r - robotic_agent ?l - location)
        (located_at_box ?b - box ?l - location)
        (located_at_supply ?s - supply ?l - location)
        (located_at_person ?p - person ?l - location)
        (located_at_carrier ?c - carrier ?l - location)

        (box_on_carrier ?b - box ?c - carrier)
        (box_loaded ?b - box)
        (box_is_empty ?b - box)
        (box_with_supply ?b - box ?s - supply)
        (carrier_has_no_robot ?c - carrier)
        (robot_has_no_carrier ?r - robotic_agent)
        (robot_carrier_attached ?r - robotic_agent ?c - carrier)
    
        (delivered ?p - person ?s - supply)

        (delivery_OR_refactored ?p1 ?p2 - person ?food1 ?food2 - food)
    )

    ; --- FUNCTIONS ---
    (:functions
        (num_boxes ?c - carrier)
    )

    ; --- DURATIVE ACTIONS ---
    ; move the robot
    (:durative-action move_robot
        :parameters (?r - robotic_agent ?l1 ?l2 - location)
        :duration (= ?duration 5)
        :condition (and 
                        (at start (located_at_robot ?r ?l1))
                        (over all (robot_has_no_carrier ?r))
                        (over all (not (= ?l1 ?l2)))
        )
        :effect (and 
                    (at start (not (located_at_robot ?r ?l1)))
                    (at end (located_at_robot ?r ?l2))
        )
    )

    ; move a robot with a carrier attached
    (:durative-action move_robot_with_carrier
        :parameters (?r - robotic_agent ?c - carrier ?l1 ?l2 - location)
        :duration (= ?duration 7)
        :condition (and 
                        (at start (located_at_robot ?r ?l1))
                        (at start (located_at_carrier ?c ?l1))
                        (over all (robot_carrier_attached ?r ?c))
                        (over all (not (= ?l1 ?l2)))
            )
        :effect (and 
                    (at start (not (located_at_robot ?r ?l1)))
                    (at start (not (located_at_carrier ?c ?l1)))
                    (at end (located_at_robot ?r ?l2))
                    (at end (located_at_carrier ?c ?l2))
        )
    )

    ; attach a carrier to a robot
    (:durative-action attach_carrier_to_robot
        :parameters (?r - robotic_agent ?l1 - location ?c - carrier)
        :duration (= ?duration 2)
        :condition (and 
                        (at start (carrier_has_no_robot ?c)) 
                        (at start (robot_has_no_carrier ?r))
                        (over all (= (num_boxes ?c) 0)) ; assumption that the carrier is initially empty or is cleaned from all boxes by external actors
                        (over all (located_at_robot ?r ?l1)) 
                        (over all (located_at_carrier ?c ?l1))
        )
        :effect (and 
                    (at start (not (carrier_has_no_robot ?c))) 
                    (at end (not (robot_has_no_carrier ?r))) ; needed otherwise the robot fill the box AND attach the carrier in parallel. Not plausibile in real-world scenario
                    (at end (robot_carrier_attached ?r ?c))
        )
    )

    ; detach a carrier from a robot
    (:durative-action detach_carrier_from_robot
        :parameters (?r - robotic_agent ?l1 - location ?c - carrier)
        :duration (= ?duration 2)
        :condition (and 
                        (at start (robot_carrier_attached ?r ?c)) 
                        (over all (= (num_boxes ?c) 0))
                        (over all (located_at_robot ?r ?l1)) 
        )
        :effect (and 
                    (at start (not (robot_carrier_attached ?r ?c)))
                    (at end (carrier_has_no_robot ?c)) 
                    (at end (robot_has_no_carrier ?r))
        )
    )

    ; load box on the carrier
    (:durative-action load_box_on_carrier
        :parameters (?c - carrier ?b - box ?l - location ?r - robotic_agent)
        :duration (= ?duration 3)
        :condition (and 
                        (at start (located_at_box ?b ?l))
                        (at start (not (box_loaded ?b)))
                        (at start (not (box_on_carrier ?b ?c)))
                        (at start (< (num_boxes ?c) 4))
                        (over all (located_at_carrier ?c ?l))
                        (over all (located_at_robot ?r ?l))
        )
        :effect (and 
                    (at start (not (located_at_box ?b ?l)))
                    (at end (box_on_carrier ?b ?c))
                    (at end (box_loaded ?b))
                    (at end (increase (num_boxes ?c) 1))
        )
    )

    ; unload box from carrier
    (:durative-action unload_box_from_carrier
        :parameters (?c - carrier ?b - box ?l - location ?r - robotic_agent)
        :duration (= ?duration 3)
        :condition (and 
                        (at start (box_on_carrier ?b ?c))
                        (at start (box_loaded ?b))
                        (over all (located_at_carrier ?c ?l))
                        (over all (located_at_robot ?r ?l))
        )
        :effect (and 
                    (at start (located_at_box ?b ?l))
                    (at end (not (box_on_carrier ?b ?c)))
                    (at end (not (box_loaded ?b)))
                    (at end (decrease (num_boxes ?c) 1))
        )
    )

    ; fill the box with a supply. The box is required to not be on a carrier to be filled
    (:durative-action fill_box
        :parameters (?r - robotic_agent ?l1 - location ?b - box ?s - supply)
        :duration (= ?duration 4)
        :condition (and 
                        (at start (located_at_supply ?s ?l1)) 
                        (at start (box_is_empty ?b)) 
                        (at start (not (box_loaded ?b)))
                        (over all (located_at_robot ?r ?l1)) 
                        (over all (located_at_box ?b ?l1))
                        (over all (not (robot_has_no_carrier ?r))) ; needed otherwise the robot fill the box AND attach the carrier in parallel. Not plausibile in real-world scenario
        )
        :effect (and 
                    (at start (not (located_at_supply ?s ?l1))) 
                    (at start (not (box_is_empty ?b)))
                    (at end (box_with_supply ?b ?s)) 
        )
    )
    
    ; deliver the supply to the person. The box is required to not be on a carrier to have its supply delivered
    (:durative-action deliver
        :parameters (?r - robotic_agent ?l1 - location ?p - person ?s - supply ?b - box)
        :duration (= ?duration 3)
        :condition (and 
                        (at start (box_with_supply ?b ?s)) 
                        (at start (not (box_is_empty ?b))) 
                        (at start (not (box_loaded ?b)))
                        (over all (located_at_robot ?r ?l1)) 
                        (over all (located_at_person ?p ?l1)) 
                        (over all (located_at_box ?b ?l1)) 
        )
        :effect (and 
                    (at start (not (box_with_supply ?b ?s))) 
                    (at end (delivered ?p ?s)) 
                    (at end (box_is_empty ?b))
        )
    )

    ; --- DUMMY DURATIVE ACTIONS ---
    ; they are dummy/virtual actions that don't represent any real-world task or activity
    ; actions needed for the unsupported ":disjunctive-preconditions" of the planners tested
    ; it is important to add a very small duration action otherwise it does not appear in the final plan
    
    (:durative-action delivery_OR_refactored_possible_action1
        :parameters (?p1 ?p2 - person ?food1 ?food2 - food)
        :duration (= ?duration 0.1) ; instantaneous action
        
        :condition (and 
                        (at start (delivered ?p1 ?food1))
                        (at start (delivered ?p2 ?food2))
        )
        :effect (and
                    (at end (delivery_OR_refactored ?p1 ?p2 ?food1 ?food2))
        )
    )

   (:durative-action delivery_OR_refactored_possible_action2
        :parameters (?p1 ?p2 - person ?food1 ?food2 - food)
        :duration (= ?duration 0.1) ; instantaneous action
        :condition (and 
                        (at start (delivered ?p1 ?food2))
                        (at start (delivered ?p2 ?food1))
        )
        :effect (and
                    (at end (delivery_OR_refactored ?p1 ?p2 ?food1 ?food2))
        )
    )
)