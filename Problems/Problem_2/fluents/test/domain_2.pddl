(define (domain industrial_manufacturing)
	(:requirements
		:adl
		:negative-preconditions
		:conditional-effects
		:existential-preconditions
		:universal-preconditions
        :fluents
	)

	(:types
		location
		work_station

		box
		supply

		valve bolt durable tool - supply
        counter
        carrier
		robotic_agent
	)
    

	(:constants
		warehouse - location
        cnt - counter
	)

	(:predicates
		(adjacent ?l1 - location ?l2 - location)
		(at ?o - (either work_station box supply robotic_agent carrier) ?l - location)

		(full ?b - box ?s - supply)
		(empty ?b - box)
		
		(loaded ?r - robotic_agent ?b - box)
		(free ?r - robotic_agent)

		(locked ?o - (either box supply))

       
        (on_cart ?b - box ?c - carrier)

		(delivered ?s - supply ?ws - work_station)

        (attached ?c - carrier ?r - robotic_agent)
        (with_cart ?r - robotic_agent)
        (with_robot ?c - carrier)
	)
    
    (:functions
        (loaded_volume ?c - carrier)
		(max_capacity ?c - carrier) 
        (warehouse_passage ?r - robotic_agent)
        (passages ?cn - counter )

    )

	; Moves a robot between two locations, if it is not already there
	(:action move_free_robot
		:parameters (?r - robotic_agent ?from ?to - location)
		:precondition (and
            (free ?r)
            (not (with_cart ?r))
			(not (= ?from ?to))
			(adjacent ?from ?to)
			(at ?r ?from) 
		)

		:effect (and
			(at ?r ?to)
			(not (at ?r ?from))
		)
	)
    
    (:action move_robot_with_cart
        :parameters (?r - robotic_agent ?c - carrier ?from ?to - location)
        :precondition (and
            (free ?r) ;robot is not holding anything
            (not (= ?from ?to))
            (adjacent ?from ?to)
            (at ?r ?from)

            (at ?c ?from)
            (attached ?c ?r)
        )
        :effect (and 
            (not (at ?r ?from))
            (not (at ?c ?from))

            (at ?c ?to)
            (at ?c ?to)
            (when (= ?to warehouse)
                (increase (passages cnt) 1)
            )

                
        )            
    )    
    

    (:action attach_cart
        :parameters(?c - carrier ?r - robotic_agent)
        :precondition(and
            (not (with_cart ?r))
            (not (with_robot ?c))
            (free ?r) ;robot is not holding anything
        )
        :effect (and
            (attached ?c ?r)
            (with_cart ?r)
            (with_robot ?c)
        )
    )

    (:action detach_cart
        :parameters(?c - carrier ?r - robotic_agent)
        :precondition(and
            (attached ?c ?r)
        )
        :effect(and
            (not (with_cart ?r))
            (not (with_robot ?c))
            (not (attached ?c ?r))
        )
    )

    (:action load_cart
        :parameters(?r - robotic_agent ?c - carrier ?b - box ?l - location)
        :precondition (and
            (at ?r ?l) ;everithing is in the same spot
            (at ?c ?l)         

            (loaded ?r ?b) ;has the robot the box

            (not (with_cart ?r)) ;both cart and robot are free
            (not (with_robot ?c)) ;this one could be optional

            (< (loaded_volume ?c) (max_capacity ?c))
        )
        :effect (and
            (not (loaded ?r ?b))
            (free ?r)
            (on_cart ?b ?c)
            (not (locked ?b))

            (increase (loaded_volume ?c) 1)
        )
    )

    (:action pick_box_from_carrier
        :parameters (?r - robotic_agent ?c - carrier ?b - box ?l - location)
        :precondition(and 
            (at ?r ?l) ;everithing is in the same spot
            (at ?c ?l) 
            
            (not (with_cart ?r)) ;both cart and robot are free
            (not (with_robot ?c)) ;this one could be optional

            (free ?r) ;robot is not holding anything

            (on_cart ?b ?c)
        ) 
        :effect(and
            (locked ?b)
            (not (free ?r))
            (loaded ?r ?b)
            (decrease (loaded_volume ?c) 1)       
            (not (on_cart ?b ?c))         
        )
    )


	; Robot picks up a specific unloaded box
	(:action load_robot
		:parameters (?r - robotic_agent ?b - box ?l - location)
		:precondition (and
			(at ?r ?l)
			(free ?r)
			(at ?b ?l)
			(not (locked ?b))
            (not (with_cart ?r))
		)

		:effect (and
			(loaded ?r ?b)
			(not (free ?r))
			(locked ?b)
			(not (at ?b ?l))
		)
	)

	; Robot puts down the loaded box
	(:action free_robot
		:parameters (?r - robotic_agent ?b - box ?l - location)
		:precondition (and
			(at ?r ?l) 
			(loaded ?r ?b)
		)
	
		:effect (and
			(free ?r)
			(not (loaded ?r ?b))
			(not (locked ?b))
			(at ?b ?l)
		)
	)

	; Fill a box with a specific supply
	(:action fill_box
		:parameters (?r - robotic_agent ?b - box ?s - supply)
		:precondition (and
			(at ?r warehouse)
			(at ?s warehouse)
			(loaded ?r ?b)
			(empty ?b)
			(not (locked ?s))
		)

		:effect (and
			(full ?b ?s)
			(not (empty ?b))
			(not (at ?s warehouse))
			(locked ?s)
		)
	)

	; Empty a box containing a specific supply
	(:action empty_box
		:parameters (?r - robotic_agent ?b - box ?s - supply ?l - location)
		:precondition (and
			(at ?r ?l)
			(loaded ?r ?b)
			(full ?b ?s)
		)	

		:effect (and
			(empty ?b)
			(not (full ?b ?s))
			(at ?s ?l)
			(not (locked ?s))
		)
	)

	; Delivery a specific supply to a specific work station
	(:action deliver_supply
		:parameters (?r - robotic_agent ?b - box ?s - supply ?ws - work_station ?l - location)
		:precondition (and
			(not (delivered ?s ?ws))
			(at ?ws ?l)
			(at ?r ?l)
			(loaded ?r ?b)
			(full ?b ?s)
		)

		:effect (and
			(delivered ?s ?ws)
			(empty ?b)
			(not (full ?b ?s))
			(at ?s ?l)
			(not (locked ?s))
		)
	)
)
