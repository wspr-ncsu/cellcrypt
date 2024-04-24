import os
from pathlib import Path
from string import Template
from subprocess import run

from multiprocessing import cpu_count
from psutil import virtual_memory
import utils.templateUtils

## TODO: Change these variables to CLI inputs
root = os.path.dirname(os.path.abspath("run.py"))
env = os.environ.copy()
user = os.getlogin()
path = os.path.join(root, "ql_results", utils.today)
graph_path = os.path.join(path, "graphs")
proc_path = os.path.join(path, "processed")

## CodeQL path for VM
codeql_path = os.path.join("/home/"+user+"/", ".local", "codeql-home", "codeql", "codeql")
codeql_lib_path = "/home/"+user+"/.local/codeql-home/codeql-repo/:/home/"+user+"/dev/cellular_crypto_analysis/queries/"
ram = int(virtual_memory().total/1024/1024 - 8000)
threads=cpu_count() - 2
# codeql_path = os.path.join("~", ".local", "bin", "codeql")


def findQueryFolder(*args):
    return os.path.join(root, *args)

def findTargetFolder(*args):
    return os.path.join(root, *args)


def findDatabase(db):
    db_glob = os.path.join(db, '.')
    for path in Path(os.path.join(utils.root, "ql_dbs")).rglob(db_glob):
        return path

    # just try it from root, TODO actually handle error
    return os.path.join(root, db)

def findBqrs(qname, db):
    for path in Path(findDatabase(db)).rglob(qname+".bqrs"):
        return path

def checkOutputDir():
    try:    
        os.mkdir(path)
    except FileExistsError:
        # print("Result Dir exists")
        pass
    try:    
        os.mkdir(graph_path)
    except FileExistsError:
        # print("Graph dir exists")
        pass
    try:    
        os.mkdir(proc_path)
    except FileExistsError:
        # print("Processed dir exists")
        pass


def runQuery(db="", query="", output="", format="json"):
    db_path = findDatabase(db)
    # print(db_path)
    qpath = os.path.join(findQueryFolder(), query)
    out_path = os.path.join(root, "ql_results", output+'.'+format)

    checkOutputDir()
    # make sarif dir if ! exist
    cmd = f'{codeql_path} database run-queries --warnings=hide --ram={ram} --threads={threads} --additional-packs={codeql_lib_path} {db_path} {qpath}'
    run(cmd,  shell=True, env=os.environ.copy())
    # TODO check analyze output for errors and report
    bqrs = findBqrs(query.split('.')[0])
    # print(bqrs)
    cmd = f'{codeql_path} bqrs decode {bqrs} --output={out_path} --format={format}'
    run(cmd, shell=True, env=os.environ.copy())

    if os.path.exists(out_path):
        return out_path
    return 70 # Int error code? Message? TODO decide how to communicate error


def runQueryBatch(*path, db="", output="", format="json"):
    db_path = findDatabase(db)
    # print(db_path)
    qpath = os.path.join(findQueryFolder(*path))

    checkOutputDir()
    # make sarif dir if ! exist
    cmd = f'{codeql_path} database run-queries --warnings=hide --ram={ram} --threads={threads} --additional-packs={codeql_lib_path} {db_path} {qpath}'
    run(cmd,  shell=True, env=os.environ.copy())
    # TODO check analyze output for errors and report
    for query in Path(qpath).glob("*.ql"):
        bqrs = findBqrs(query.stem, db)
        # print(bqrs)
        out_path = os.path.join(getOutputDir(), output + "_" + query.stem + "_results"+'.'+format)
        cmd = f'{codeql_path} bqrs decode {bqrs} --output={out_path} --format={format}'
        run(cmd, shell=True, env=os.environ.copy())
        # print(bqrs)
        # print(out_path)
    if os.path.exists(out_path):
        return out_path
    return 70 # Int error code? Message? TODO decide how to communicate error


def getOutputDir():
    out_path = path
    checkOutputDir()
    return out_path

def getGraphDir():
    out_path = graph_path
    checkOutputDir()
    return out_path

def getProccessedDir():
    out_path = proc_path
    checkOutputDir()
    return out_path