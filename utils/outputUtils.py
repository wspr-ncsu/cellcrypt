import json
from dataclasses import dataclass
from os import path
import utils
from dataclass_csv import DataclassWriter

root = path.dirname(path.abspath("run.py"))

def dumper(obj):
    try:
        return obj.toJSON()
    except:
        return obj.__dict__

class EnhancedJSONEncoder(json.JSONEncoder):
        def default(self, o):
            if dataclasses.is_dataclass(o):
                return dataclasses.asdict(o)
            return super().default(o)
