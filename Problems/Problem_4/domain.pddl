(define (domain industrial_manufacturing)
	(:requirements :strips :typing :durative-actions :equality :numeric-fluents :duration-inequalities)


	(:types
		location
		work_station

		box
		supply

		valve bolt durable tool - supply
        
        carrier
		robotic_agent
	)
    

	(:constants
		warehouse - location
       
    )
    (:functions
        (loaded_volume ?c - carrier)
		(max_capacity ?c - carrier) 
        
        

    )

    (:predicates
		(adjacent ?l1 - location ?l2 - location)
		(at_l ?o - (either work_station box supply robotic_agent carrier) ?l - location)

		(full ?b - box ?s - supply)
		(empty ?b - box)
		
		(loaded ?r - robotic_agent ?b - box)
		(free ?r - robotic_agent)

		(locked ?o - (either box supply))
        (unlocked ?o - (either box supply))
        (not_in_action ?r - robotic_agent)
        (on_cart ?b - box ?c - carrier)

		(delivered ?s - supply ?ws - work_station)

        (attached ?c - carrier ?r - robotic_agent)
        (free_from_cart ?r - robotic_agent)
        (free_from_robot ?c - carrier)
	)

    (:durative-action move
        :parameters (?r - robotic_agent ?c - carrier ?from ?to - location)
        :duration
            (= ?duration 2)
        :condition (and
                (over all (free ?r)) ;robot is not holding anything
                (over all (adjacent ?from ?to))
                (over all (at_l ?r ?from))
                (over all (at_l ?c ?from))
                (over all (attached ?c ?r))
                (at start (not_in_action ?r))
            )

        :effect (and 
            (at start (not (not_in_action ?r)))
            (at end (not_in_action ?r))
            (at end (not (at_l ?r ?from)))
            (at end (not (at_l ?c ?from)))

            (at end (at_l ?c ?to))
            (at end (at_l ?r ?to))
                           
        )            
	)

    (:durative-action attach_cart
        :parameters (?c - carrier ?r - robotic_agent ?l - location)      
        :duration (= ?duration 1)          
        :condition (and            
            (over all (at_l ?r ?l))
            (over all (at_l ?c ?l))
            (over all (free_from_cart ?r))
            (over all (free_from_robot ?c))            
            (over all (free ?r)) ;robot is not holding anything
            (at start  (not_in_action ?r))
            (over all (free ?r))
        )
        
        :effect (and
            (at start (not (not_in_action ?r)))
            (at end  (not_in_action ?r))

            (at end (attached ?c ?r))
            (at end (not (free_from_cart ?r)))
            (at end (not (free_from_robot ?c)))
        )
    )

    (:durative-action detach_cart
        :parameters(?c - carrier ?r - robotic_agent)
        :duration (= ?duration 1)
        :condition(and
            (over all (attached ?c ?r))
            (at start  (not_in_action ?r))
        )
        :effect(and
            (at start (not (not_in_action ?r)))
            (at end (not_in_action ?r))
            (at end (free_from_cart ?r))
            (at end (free_from_robot ?c))
            (at end (not (attached ?c ?r)))
			           
        )
    )

    (:durative-action load_cart
        :parameters(?r - robotic_agent ?c - carrier ?b - box ?l - location)
        :duration (= ?duration 3)
        :condition (and
            (over all (at_l ?r ?l)) ;everithing is in the same spot
            (over all (at_l ?c ?l))         

            (over all (loaded ?r ?b)) ;has the robot the box

            ;(over all (free_from_cart ?r))
            ;(over all (free_from_robot ?c))

            (over all (< (loaded_volume ?c) (max_capacity ?c)))
            (at start (not_in_action ?r))
        )
        
        :effect (and
            (at end (not (loaded ?r ?b)))
            (at end (free ?r))
            (at end (on_cart ?b ?c))
            (at end (not (locked ?b)))
            (at end (unlocked ?b))
            (at start (not (not_in_action ?r)))
            (at end  (not_in_action ?r))

            (at end (increase (loaded_volume ?c) 1))
        )
    )

    (:durative-action pick_box_from_carrier
        :parameters (?r - robotic_agent ?c - carrier ?b - box ?l - location)
        :duration (= ?duration 1)
        :condition(and 
            (over all (at_l ?r ?l)) ;everithing is in the same spot
            (over all (at_l ?c ?l))             
            ;(over all (free_from_cart ?r))
            ;(over all (free_from_robot ?c)) ;this one could be optional
            (over all (attached ?c ?r))
            (over all (free ?r)) ;robot is not holding anything
            (over all (on_cart ?b ?c))
            (at start (not_in_action ?r))
            
        ) 
        
        :effect(and
            (at end (locked ?b))
            (at end (not (unlocked ?b)))
            (at end (not (free ?r)))
            (at end (loaded ?r ?b))
            (at end (decrease (loaded_volume ?c) 1))       
            (at end (not (on_cart ?b ?c)))     
            (at start (not (not_in_action ?r)))
            (at end (not_in_action ?r))    
        )
    )

    ; Robot picks up a specific unloaded box
	(:durative-action load_robot
		:parameters (?r - robotic_agent ?b - box ?l - location)
		:duration (= ?duration 2)
		:condition (and
			(over all (at_l ?r ?l))
			(over all (free ?r))
			(over all (at_l ?b ?l))
			
			(over all (unlocked ?b))
            ;(over all (free_from_cart ?r))
            (at start  (not_in_action ?r))
            
		)
        
		:effect (and
            (at start (not (not_in_action ?r)))
            (at end (not_in_action ?r))
			(at end (loaded ?r ?b))
			(at end (not (free ?r)))
			(at end (locked ?b))
            (at end (not (unlocked ?b)))
			(at end (not (at_l ?b ?l)))
		)
	)

    ; Robot puts down the loaded box
	(:durative-action free_robot
		:parameters (?r - robotic_agent ?b - box ?l - location)
		:duration (= ?duration 1)
		:condition (and
			(over all (at_l ?r ?l))
			(over all (loaded ?r ?b))
            (at start (not_in_action ?r))
		)
       
		:effect (and
			(at end (free ?r))
			(at end (not (loaded ?r ?b)))
			(at end (not (locked ?b)))
            (at end (unlocked ?b))
			(at end (at_l ?b ?l))
            (at start (not (not_in_action ?r)))
            (at end  (not_in_action ?r))
		)
	)

    ; Fill a box with a specific supply
	(:durative-action fill_box
		:parameters (?r - robotic_agent ?b - box ?s - supply)
		:duration (= ?duration 1)
		:condition (and
			(over all (at_l ?r warehouse))
			(over all (at_l ?s warehouse))
			(over all (loaded ?r ?b))
			(over all (empty ?b))                                                                                                                                                     
			(over all (unlocked ?s))
            ;(over all (free_from_cart ?r))
            ;(over all (attached ?c ?r))
			(at start (not_in_action ?r))
		)
        
		:effect (and
			(at end (full ?b ?s))
			(at end (not (empty ?b)))
			(at end (not (at_l ?s warehouse)))
			(at end (locked ?s))
            (at end (not (unlocked ?s)))
            (at start (not (not_in_action ?r)))
            (at end  (not_in_action ?r))
		)
	)

    ; Empty a box containing a specific supply
	(:durative-action empty_box
		:parameters (?r - robotic_agent ?b - box ?s - supply ?l - location)
		:duration (= ?duration 1)
		:condition (and
			(over all (at_l ?r ?l))
			(over all (loaded ?r ?b))
            ;(over all (free_from_cart ?r))
			(over all (full ?b ?s))
            (at start (not_in_action ?r))
           
		)	        
		:effect (and
            (at start (not (not_in_action ?r)))
            (at end (not_in_action ?r))
			(at end (empty ?b))
			(at end (not (full ?b ?s)))
			(at end (at_l ?s ?l))
			(at end (not (locked ?s)))
            (at end (unlocked ?s))
	    )
    )

    ; Delivery a specific supply to a specific work station
	(:durative-action deliver_supply_from_cart
		:parameters (?r - robotic_agent ?b - box ?s - supply ?ws - work_station ?l - location ?c -carrier)
		:duration (= ?duration 2)
		:condition (and
			;(not (delivered ?s ?ws))
			(over all (at_l ?ws ?l))
			(over all (at_l ?r ?l))
            (over all (at_l ?c ?l))
			;(over all (loaded ?r ?b))
			(at start (not_in_action ?r))
            ;(attached ?c ?r)
            (over all (on_cart ?b ?c))
            (over all (full ?b ?s))
		)
		:effect (and
			(at end (delivered ?s ?ws))
			(at end (empty ?b))
			(at end (not (full ?b ?s)))
			(at end (at_l ?s ?l))
			(at end (not (locked ?s)))
            (at end (unlocked ?s))
            (at start (not (not_in_action ?r)))
            (at end  (not_in_action ?r))
		)
		)
	)


)