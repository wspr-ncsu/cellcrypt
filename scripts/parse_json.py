import json
import os
import sys
from dataclasses import dataclass
import dataclasses

class EnhancedJSONEncoder(json.JSONEncoder):
        def default(self, o):
            if dataclasses.is_dataclass(o):
                return dataclasses.asdict(o)
            return super().default(o)


@dataclass
class Reference:
    entName: str
    entType: str
    package: str
    refString: str
    file: str
    line: int


if not os.path.exists(sys.argv[-1]) or os.path.splitext(sys.argv[-1])[1] != ".json":
    print("No JSON file given or JSON does not have .json extensions")
    exit()


with open(sys.argv[1], "r") as f:
# with open(path, "r") as f:
    data = json.load(f)
    
    # print(data) 


# Get counts
types = {}
refs = []

# print(len(data.values()["#select"]["tuples"]))
for res in data.values():
    res_hold = {}
    try:
        res_hold = res["#select"]["tuples"]
    except KeyError:
        res_hold = res["tuples"]
    print(len(res))
    # print(res)
    for x in res_hold:
        entName = ""
        if x[0] is dict:
            entName = x[0]["label"]
        else:
            entName = x[0]
        entType = x[1]
        package = x[2]
        
        refString  = ""
        if x[3] is dict:
            refString = str(x[3]["label"]).replace("selection of ", "")
        else:
            refString = str(x[3]).replace("selection of ", "")
        
        if x[4] is dict:
            file = x[4]["label"]
        else:
            file = x[4]
        # file = x[4]
        line = x[5]
        
        newRef = Reference(
            entName=entName,
            entType=entType,
            package=package,
            refString=refString,
            file=file,
            line=line
        )
        
        if newRef not in refs:
            refs.append(newRef)
            if entType in types:
                types[entType] += 1 
            else:
                types[entType] = 1
        # print('a')

print(len(refs))
print(types)  

if "-n" in sys.argv:
    newName = "aggregated_"+sys.argv[-1].split(".")[0]+".json"
    with open(newName, "w") as out:
        json.dump(refs, out, cls=EnhancedJSONEncoder)