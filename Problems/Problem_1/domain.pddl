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
	)

	(:constants
		warehouse - location
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
	)

	; Moves a free robot between two locations, if it is not already there
	(:action move_free_robot
		:parameters (?r - robotic_agent ?from ?to - location)
		:precondition (and
			(not (= ?from ?to))
			(adjacent ?from ?to)
			(at_robot ?r ?from) 
			(free ?r)
		)

		:effect (and
			(at_robot ?r ?to)
			(not (at_robot ?r ?from))
		)
	)

	; Moves a robot keeping an empty box between two locations, if it is not already there
	(:action move_empty_robot
		:parameters (?r - robotic_agent ?b - box ?from ?to - location)
		:precondition (and
			(not (= ?from ?to))
			(adjacent ?from ?to)
			(at_robot ?r ?from)
			(occupied ?r ?b)
			(at_box ?b ?from)
			(loaded ?b ?r)
			(empty ?b)
		)

		:effect (and
			(at_robot ?r ?to)
			(not (at_robot ?r ?from))
			(at_box ?b ?to)
			(not (at_box ?b ?from))
		)
	)

	; Moves an occupied robot between two locations, if it is not already there
	(:action move_occupied_robot
		:parameters (?r - robotic_agent ?b - box ?s - supply ?from ?to - location)
		:precondition (and
			(not (= ?from ?to))
			(adjacent ?from ?to)
			(at_robot ?r ?from)
			(occupied ?r ?b)
			(at_box ?b ?from)
			(loaded ?b ?r)
			(full ?b ?s)
			(at_supply ?s ?from)
		)

		:effect (and
			(at_robot ?r ?to)
			(not (at_robot ?r ?from))
			(at_box ?b ?to)
			(not (at_box ?b ?from))
			(at_supply ?s ?to)
			(not (at_supply ?s ?from))
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

	; Robot puts down the loaded box
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
	(:action deliver_supply
		:parameters (?r - robotic_agent ?b - box ?s - supply ?ws - work_station ?l - location)
		:precondition (and
			(not (delivered ?ws ?s))
			(belong ?ws ?l)
			(at_robot ?r ?l)
			(at_box ?b ?l)
			(at_supply ?s ?l)
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
