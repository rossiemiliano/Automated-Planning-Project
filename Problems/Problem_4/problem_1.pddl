(define (problem industrial_manufacturing)
	(:domain industrial_manufacturing)

	(:objects 
		location1 location2 location3 location4 - location

		work_station1 work_station2 work_station3 work_station4 - work_station

		; at this stage of the project one box is enough
		; because we have just one robot and we assume 
		;the action of loading and unloading is instantaneous
		box1 box2 box3 - box

		valve1 valve2 - valve
		bolt1 bolt2 - bolt
		tool1 tool2 - tool
		carrier1  - carrier 
		;carrier2 - carrier
		robot1  - robotic_agent
		robot2 - robotic_agent

	)

	(:init
		; locations
		(adjacent warehouse location2)

		(adjacent location1 location2)

		(adjacent location2 warehouse)
		(adjacent location2 location1)
		(adjacent location2 location3)
		(adjacent location2 location4)

		(adjacent location3 location2)

		(adjacent location4 location2)

		; work stations
		(at_l work_station1 location1)
		(at_l work_station2 location3)
		(at_l work_station3 location4)
		(at_l work_station4 location4)

		; boxes
		(at_l box1 warehouse)
		(empty box1)
        (unlocked box1)

		(at_l box2 warehouse)
		(empty box2)
        (unlocked box2)

		(at_l box3 warehouse)
		(empty box3)
        (unlocked box3)

		; robots
		(at_l robot1 warehouse)
		(free robot1)
        (free_from_cart robot1)
        (not_in_action robot1)

		(at_l robot2 warehouse)
        (free robot2)
		(free_from_cart robot2)
		(not_in_action robot2)
        
        
       
		
		(= (passages cnt) 0)

		; carriers
		(at_l carrier1 warehouse)
		(= (loaded_volume carrier1) 0)
		(= (max_capacity carrier1) 2)
        (free_from_robot carrier1)

		;(at_l carrier2 warehouse)
		;(= (loaded_volume carrier2) 0)
		;(= (max_capacity carrier2) 2)
        ;(free_from_robot carrier2)

		; supplies
		(at_l valve1 warehouse)
        (unlocked valve1)
		(at_l valve2 warehouse)
        (unlocked valve2)

		(at_l bolt1 warehouse)
        (unlocked bolt1)
		(at_l bolt2 warehouse)
        (unlocked bolt2)

		(at_l tool1 warehouse)
        (unlocked tool1)
		(at_l tool2 warehouse)
        (unlocked tool2)
	)

	(:goal (and
	 		;;WE CANNOT USE exists not supported
			;(exists (?v - valve) (delivered ?v work_station1))
            (delivered valve1 work_station1)
            (delivered tool1 work_station1)
	        ;(exists (?t - tool) (delivered ?t work_station1))
			;(at_l carrier1 location3)
			
			

			;(exists (?b - bolt) (delivered ?b work_station1))		
			;(exists (?t - tool) (delivered ?t work_station4))
			(delivered bolt1 work_station1)
			(delivered tool2 work_station4)

			;(exists (?b - bolt) (delivered ?b work_station3))
			;(delivered bolt2 work_station3)
			;(forall (?r - robotic_agent) 
			;	(and 
			;		(not (with_cart ?r))
			;		(free ?r)
			;		(at_l ?r warehouse)
			;	)
			;)
			;(forall (?c - carrier) 
			;	(and 				
			;		(at_l ?c warehouse)				
			;	)
			;)
		)
	)
	;(:metric minimize (+ (total-time) (passages cnt)))
	(:metric minimize (total-time))
)