import requests

def resolveWithAPI(domain, problem):
        data = {'domain': domain,
            'problem': problem}
        resp = requests.post('http://solver.planning.domains/solve',
                 verify=False, json=data).json()
        try:
            return '\n'.join([act['name'] for act in resp['result']['plan']])
        except:
            try:
                 return '\n'.join([act for act in resp['result']['plan']])
            except:
                 return resp['result']['error']

domain = f"domain.pddl"
problem = f"problem.pddl"

domain = open(domain, 'r').read()
problem = open(problem, 'r').read()
steps = resolveWithAPI(domain, problem)
print("> Plan length: " + str(len(steps.split("\n"))) + " steps.\n")
for i, step in enumerate(steps.split("\n")):
    print(f"{i+1}. {step}")
