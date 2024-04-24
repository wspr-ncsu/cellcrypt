import utils
import pandas as pd
import matplotlib.pyplot as plt
from os import path
import sys

# Test
# utils.runQueryBatch("queries","test_queries",db="o5gs_db",output="o5gstest")
# test = utils.processByDb(db="o5gstest")
# print(test)

db_list = {"o5gs": ["cpp", "o5gs_db", "Open5GS"],
           "oai": ["cpp", "oai_db/cpp", "OAI-5G"],
           "free5gc": ["go", "full_free5gc_with_deps", "Free5gc"],
           "sdcore": ["go", "sd_core_w_deps/go", "SD-Core"],
           "nextepc": ["cpp", "nextepc_db/cpp", "NextEPC"],
           "srsran": ["cpp", "srsran_db", "SRSRan"],
           "oai4g": ["cpp", "oai4g_db/cpp", "OAI-LTE"]
           }



def runAll():
    for k,v in db_list.items():
        if v[0] == "cpp":
            query_path = path.join("queries","cpp","rules")
        elif v[0] == "go":
            query_path = path.join("queries","go","rules")
        else:
            print("Invalid query path in db_list: "+v[0])
            continue
        utils.runQueryBatch(query_path, db=v[1], output=k)
        results = utils.processByDb(db=k)
        makePlots(results, v[2])


def analyzeExistingResults(path):
    for k,v in db_list.items():
        results = utils.processByDb(db=k, path=path)
        makePlots(results, v[2])


def makePlots(results, title):
    # plots
    flow_bar = utils.plotFlowByDb(results, db=title)
    check_bar = utils.plotCheckByDb(results, db=title)
    
    if flow_bar != 0:
        flow_bar.figure.savefig(path.join(utils.getGraphDir(), title+"_flow_bar"+utils.now+".png"))
    if check_bar != 0:
        check_bar.figure.savefig(path.join(utils.getGraphDir(), title+"_check_bar"+utils.now+".png"))

def main():
    n = len(sys.argv)

    if n != 1:
        if sys.argv[1] == "--analyze":
            try:
                path.exists(sys.argv[2])
            except FileNotFoundError:
                print("Invalid Path. Usage: python run.py [--analyze <path_to_results>]")
                exit()
            except IndexError:
                print("No path argument found. Usage: python run.py [--analyze <path_to_results>]")
                exit()
            analyzeExistingResults(sys.argv[2])
        else:
            print("Usage: python run.py [--analyze <path_to_results>]")
            exit()
    else:
        runAll()

if __name__ == "__main__":
    main()

