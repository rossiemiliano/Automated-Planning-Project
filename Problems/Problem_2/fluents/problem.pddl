(define (problem industrial_manufacturing)
	(:domain industrial_manufacturing)

	(:objects 
		location1 location2 location3 location4 - location
		work_station1 work_station2 work_station3 work_station4 work_station5 work_station6 work_station7 - work_station

		box1 - box	; at this stage of the project one box is enough, because we have just one robot and we assume the action of loading and unloading is instantaneous
		valve1 valve2 valve3 - valve
		bolt1 bolt2 bolt3 - bolt
		tool1 tool2 - tool
		carrier1 - carrier
		robot1 - robotic_agent
	)

	(:init
		; locations
		(adjacent warehouse location1)
		(adjacent warehouse location2)
		(adjacent warehouse location3)
		(adjacent warehouse location4)

		(adjacent location1 warehouse)
		(adjacent location2 warehouse)
		(adjacent location3 warehouse)
		(adjacent location4 warehouse)

		; work stations
		(belong work_station1 location1)
		(belong work_station2 location1)
		(belong work_station3 location2)
		(belong work_station4 location3)
		(belong work_station5 location3)
		(belong work_station6 location4)
		(belong work_station7 location4)

		; boxes
		(empty box1)
		(unloaded box1)
		(at_box box1 warehouse)

		; robots
		(free robot1)
		(at_robot robot1 warehouse)
		(unattached robot1)

		;carriers
		(at_carrier carrier1 warehouse)
		(= (max_capacity carrier1) 3)
		(= (load carrier1) 0)
		(attachable carrier1)

		; supplies
		(at_supply valve1 warehouse)
		(at_supply valve2 warehouse)
		(at_supply valve3 warehouse)
	
		(at_supply bolt1 warehouse)
		(at_supply bolt2 warehouse)
		(at_supply bolt3 warehouse)

		(loadable valve1)
		(loadable valve2)
		(loadable valve3)

		(loadable bolt1)
		(loadable bolt2)
		(loadable bolt3)

		(loadable tool1)
		(loadable tool2)


		(at_supply tool1 warehouse)
		(is_durable tool1)
		(dissociate tool1)

		(at_supply tool2 warehouse)
		(is_durable tool2)
		(dissociate tool2)
	)

	(:goal (and
		(and
			(exists (?v - valve) (delivered ?v work_station1))
			(exists (?b - bolt) (delivered ?b work_station1))		
			(exists (?t - tool) (delivered ?t work_station1))
		)

		(and
			(exists (?b - bolt) (delivered ?b work_station5))		
			(exists (?t - tool) (delivered ?t work_station5))
		)

		(exists (?b - bolt) (delivered ?b work_station3))
		(exists (?v - valve) (delivered ?v work_station6))
		(exists (?t - tool) (delivered ?t work_station7))
	
		(forall (?t - tool) 
			(and 
				(dissociate ?t)
			)
		)
		(forall (?c - carrier)
			(and
				(attachable ?c)
				(at_carrier ?c warehouse)
				(= (load ?c) 0)
			)
		)	
		(forall (?r - robotic_agent) 
			(and 
				(free ?r)
				(unattached ?r)
				(at_robot ?r warehouse)
			)
		)

		(forall (?b - box) 
			(and
				(empty ?b)
				(unloaded ?b)
				(loadable ?b)
				(at_box ?b warehouse)
			)
		)
	)
)
)

