import os
import json
import utils
from pathlib import Path


path=utils.getOutputDir()
results = {}
for file in Path(path).glob("*.json"):
    if "processed" in file.stem:
        continue
    # print(file)
    filesplit=file.stem.split('_')
    if len(filesplit) < 2:
        continue
    with open(file, 'r') as f:
        data = json.load(f)
        count = len(data["#select"]["tuples"])
        results[file.stem] = count
        
sorted = {key: value for key, value in sorted(results.items())}
for k,v in sorted.items():
    print(k + ": " + str(v))