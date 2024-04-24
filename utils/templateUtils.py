import os
from pathlib import Path
from string import Template

# TODO: Change templating to Jinja/other tool
import utils

root = os.path.dirname(os.path.abspath("5GErrQl.py"))

def buildPredicate(type="", name="", vars="", code="", oride=False):

    sub = {
        'type': type,
        'name': name,
        'vars': vars,
        'code': code,
        'override': "override" if oride else ""
    }
    pred = ""
    template = findTemplate('predicate')
    with open(template, 'r') as qltmp:
        src = Template(qltmp.read())
        pred = src.substitute(sub)
    return pred

def buildPathQuery():
    return

def buildClass(name="", extends=False, extensions="", definition="", pred=None, vars="", imports=None):
    pred = [""] if pred is None else pred
    imports = [""] if imports is None else imports
    sub = {
        'name': name,
        'extends': " extends " if extends else "",
        'extensions': extensions,
        'definition': definition,
        'predicates': '\n'.join(pred),
        'vars': vars,
        'imports': '\n'.join(imports)
    }
    template = findTemplate('class')
    with open(template, 'r') as qltmp:
        src = Template(qltmp.read())
        cls = src.substitute(sub)
    return cls


# Pass code in order in array
def generateQueryFile(filename, code=[]):
    output = os.path.join(utils.findQueryFolder(), filename)
    with open(output, 'w') as f:
        for thing in code:
            f.write(thing+"\n")
    return

def generateLibraryFile(filename, code=[]):
    output = os.path.join(utils.findTargetFolder(), filename)
    with open(output, 'w') as f:
        for thing in code:
            f.write(thing+"\n")
    return



def findTemplate(template):
    for path in Path(root).rglob(template+'.qltmp'):
        # print(path)
        return path