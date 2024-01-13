to run with fluents use metric-ff: planutils install metric-ff

simple comand:
planutils run metric-ff ./domain.pddl ./problem.pddl

Possible commands:

    OPTIONS   DESCRIPTIONS

    -p <str>    Path for operator and fact file
    -o <str>    Operator file name
    -f <str>    Fact file name

    -r <int>    Random seed [used for random restarts; preset: 0]

    -s <int>    Search configuration [preset: s=5]; '+H': helpful actions pruning
        0     Standard-FF: EHC+H then BFS (cost minimization: NO)
        1     BFS (cost minimization: NO)
        2     BFS+H (cost minimization: NO)
        3     Weighted A* (cost minimization: YES)
        4     A*epsilon (cost minimization: YES)
        5     EHC+H then A*epsilon (cost minimization: YES)
    -w <num>    Set weight w for search configs 3,4,5 [preset: w=5]

    -C          Do NOT use cost-minimizing relaxed plans for options 3,4,5

    -b <float>  Fixed upper bound on solution cost (prune based on g+hmax); active only with cost minimization

to pass the commands:
    planutils activate
    metric-ff ./domain.pddl ./problem.pddl -s <int>