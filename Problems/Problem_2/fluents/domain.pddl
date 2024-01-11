(define (domain industrial_manufacturing)
	(:requirements
		:strips
		:typing		
		:negative-preconditions
		:equality
		:adl
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
		durable

		valve bolt durable - supply
		tool - durable

		robotic_agent
		carrier
		
	)

	(:constants
		warehouse - location
	)
	(:functions
		(load ?c -carrier)
		(max_capacity ?c -carrier) 
		
	)

	(:predicates
		(adjacent ?l1 - location ?l2 - location)
		(belong ?ws - work_station ?l - location)

		(assigned ?ws - work_station ?d - durable)
		(dissociate ?d - durable)

		(full ?b - box ?s - supply)
		(empty ?b - box)


		(loaded ?b - box ?r - robotic_agent)
		(unloaded ?b - box)

		(occupied ?r - robotic_agent ?b - box)
		(free ?r - robotic_agent)

		(at_box ?b - box ?l - location)
		(at_robot ?r - robotic_agent ?l - location)
		(at_supply ?s - supply ?l - location)

		(delivered ?s - supply ?ws - work_station)

		(is_durable ?d - durable)

		;if a carrier is attached to robot r 
		(attached ?c - carrier r? - robotic_agent)

		;where the carrier is
		(at_carrier ?c - carrier ?l - lcoation)

		;if carrier is free to be taken by a robot 
		(attachable ?c - carrier)

		;robot does not have any carrier
		(unattached ?r)

		;obj in the carrier
		(carried ?b ?c)

		;box can be putted on a carrier
		(loadable ?b)


	)

	; Moves a free robot between two locations, if it is not already there. If has a carrier attached move it also
	(:action move_free_robot
		:parameters (?r - robotic_agent ?from ?to - location)
		:precondition (and
			(not (= ?from ?to))
			(adjacent ?from ?to)
			(unattached ?r)
			(at_robot ?r ?from) 
			(free ?r)
		)

		:effect (and
			(at_robot ?r ?to)
			(not (at_robot ?r ?from))
			
			
		)
	)
	(:action move_robot_with_carrier
		:parameters(?r - robotic_agent ?from ?to - location ?c - carrier)
		:precondition(and
						;location conditions 
						(not (= ?from ?to))
						(adjacent ?from ?to)

						;robot conditions
						(at_robot ?r ?from)
						(free ?r)
						(not (unattached ?r))
						(free ?r)

						;carrier conditions
						(attached ?c ?r)
						(at_carrier ?c ?from)
						(not (attachable ?c))

						;before moving back we have to empty our cargo
						(when (> (load ?c) 0)
							(not (= ?to warehouse))
						)
										
		)
		
		:effect(and
					;robot effect
					(not (at_robot ?r ?from))
					(at_robot ?r ? to)

					;carrier effects
					(not (at_carrier ?c ?from))
					(at_carrier ?c ?to)

					;move each box in the carrier attached to the robot
					(forall (?b box)
						(when (carried ?b ?c)
							and(
								(not (at_box ?b ?from))
								(at_box ?b ?to)
							)
						)
					)
		)
	
	)


	(:action detach_carrier
		:parameters(?r - robotic_agent ?c - carrier)
		:precondition (attached ?c ?r)
		:effect (and
					(not (attached ?c ?r))
					(unattached ?r)
					(attachable ?c)
		)
	
	
	)

	(:action attach_carrier
		:parameters(?r - robotic_agent ?c -carrier ?l - location)
		:precondition(and 
						;carrier and robot same position
						(at_robot ?r ?l)
						(at_carrier ?c ?l)
						
						(free ?r)

						;is it possible to attach the carrier and the robot has not already one
						(unattached ?r)
						(attachable ?c)					
		)
		:effect(and
				(not (unattached ?r))
				(not (attachable ?c))
				(attached ?c ?r)
				
		)
	
	
	)


	;cart must be detached from the robot in order to be loaded or unloaded
	(:action load_carrier
		:parameters(?r - robotic_agent ?l - location ?b - box ?c - carrier )
		:precondition (and
						(at_robot ?r ?l)
						(at_box ?b ?l)
						(at_carrier ?c ?l)
						(unattached ?r)
						(occupied ?r ?b)
						
						;(not (empty ?b))
						(attachable ?c)
						(< (load ?c) (max_capacity ?c))
						(loadable ?b)
											
		)
		:effect( and
					;load the box in to the carrier
					(not (loadable ?b))
					(carried ?b ?c)
					(increase (load ?c) 1)

					(not (occupied ?r ?b))
					(free ?r)					
					
					(unloaded ?b)
					(not (loaded ?b ?r))


		)
	
	
	)

	(:action deliver_supply
		:parameters (?r - robotic_agent ?b - box ?s - supply ?ws - work_station ?l - location ?c - carrier)
		:precondition (and
			(not (delivered ?ws ?s))
			(belong ?ws ?l)
			(at_robot ?r ?l)
			(at_box ?b ?l)
			(at_supply ?s ?l)
			(at_carrier ?c ?l)
			
			(unattached ?r)
			(attachable ?c)

			(carried ?b ?c)

			(occupied ?r ?b)
			(loaded ?b ?r)
			(full ?b ?s)
			(or
				(and (is_durable ?s) (dissociate ?s))
				(not (is_durable ?s))	
			)
		)

		:effect (and
			(delivered ?s ?ws)
			(empty ?b)
			(loadable ?b)
			(not (carried ?b ?c))
			(decrease (load ?c) 1)
			(not (full ?b ?s))
			(at_supply ?s ?l)
			(when
				(is_durable ?s)
				
				(and 
					(assigned ?s ?ws)
					(not (dissociate ?s))
				)
			)
		)
	)









	



	; Robot picks up a specific unloaded box
	(:action occupy_robot
		:parameters (?r - robotic_agent ?b - box ?l - location)
		:precondition (and
			(at_robot ?r ?l)
			(free ?r)
			(at_box ?b ?l)
			(unloaded ?b)
		)

		:effect (and
			(occupied ?r ?b)
			(not(free ?r))
			(loaded ?b ?r)
			(not (unloaded ?b))
		)
	)

	; Robot puts back the loaded box
	(:action free_robot
		:parameters (?r - robotic_agent ?b - box ?l - location)
		:precondition (and
			(at_robot ?r ?l) 
			(occupied ?r ?b)
			(at_box ?b ?l)
			(loaded ?b ?r)
		)
	
		:effect (and
			(free ?r)
			(not (occupied ?r ?b))
			(unloaded ?b)
			(not (loaded ?b ?r))
		)
	)

	; Fill a box with a specific supply
	(:action fill_box
		:parameters (?r - robotic_agent ?b - box ?s - supply)
		:precondition (and
			(at_robot ?r warehouse)
			(at_box ?b warehouse)
			(at_supply ?s warehouse)
			(occupied ?r ?b)
			(loaded ?b ?r)
			(empty ?b)
		)

		:effect (and
			(full ?b ?s)
			(not (empty ?b))
		)
	)

	; ; Empty a box containing a specific supply
	(:action empty_box
		:parameters (?r - robotic_agent ?b - box ?s - supply ?l - location)
		:precondition (and
			(at_robot ?r ?l)
			(at_box ?b ?l)
			(at_supply ?s ?l)
			(occupied ?r ?b)
			(loaded ?b ?r)
			(full ?b ?s)
		)	

		:effect (and
			(empty ?b)
			(not (full ?b ?s))
		)
	)

	; Delivery a specific supply to a specific work station
	

	; Some specific supplies are durable (or not consumable)
	; this means that their usage must be shared among the different work stations
	; beacuse of that we need to dissociate them from the work station that uses them
	; meaning that the robot can recover the supply from the work station and
	; bring it back to the warehouse or to another work station
	(:action release_supply
		:parameters (?r - robotic_agent ?b - box ?d - durable ?ws - work_station ?l - location)
		:precondition (and
			(belong ?ws ?l)
			(at_robot ?r ?l)
			(at_box ?b ?l)
			(at_supply ?d ?l)
			(assigned ?d ?ws)
			(occupied ?r ?b)
			(loaded ?b ?r)
			(empty ?b)
		)

		:effect (and
			(full ?b ?d)
			(not (empty ?b))
			(not (assigned ?s ?ws))
			(dissociate ?d)
		)
	)	
)




