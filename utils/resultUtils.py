import json
from dataclasses import dataclass
from xmlrpc.client import boolean
import utils
from pathlib import Path
import pandas as pd
import os
import re


@dataclass
class CryptoFlowResult:
    type: str
    results: list
    resultCount: int
    uniqueSinkCount: int
    uniqueSinks: list
    uniqueSourceCount: int
    uniqueSources: list
    uniqueSrcSink: list
    uniqueSrcSinkCount: int
    
    def graph_results(self):
        return {
            'resultCount': self.resultCount,
            'uniqueSinkCount': self.uniqueSinkCount,
            'uniqueSourceCount': self.uniqueSourceCount,
            'uniqueSrcSinkCount': self.uniqueSrcSinkCount
        }

@dataclass
class CryptoFlowTuple:
    sourceNode: str
    sourceLoc: str
    sinkNode: str
    sinkLoc: str

@dataclass
class CryptoCheckResult:
    type: str
    results: list
    resultCount: int
    uniqueResultCount: int
    
    def graph_results(self):
        return {
            'resultCount': self.resultCount,
            'uniqueResultCount': self.uniqueResultCount
        }

@dataclass 
class CryptoCheckTuple:
    name: str
    msg: str
    loc: str


def open_results_file(f):
    with open(f, 'r') as f:
        data = json.load(f)

    return data['#select']['tuples']



sink_filters = [
                # r'free5gc/NFs/ausf/internal/sbi/producer/functions.go',
                # r'free5gc/NFs/amf/internal/context/amf_ue.go',
                # r'NFs/n3iwf/internal/ngap/handler/handler.go',
                # r'NFs/n3iwf/pkg/ike/handler/handler.go',
                # r'nextepc/src/mme/mme_context.c',
                # r'nextepc/src/mme/emm_build.c',
                # r'OAI/oai-cn5g-upf-vpp/vpp/src/vnet/vxlan-gbp/decap.c',
                # r'OAI/oai-cn5g-upf-vpp/vpp/src/vppinfra/hash.h',
                # r'usr/include/c\+\+/9/bits/hashtable.h',
                # r'OAI/oai-cn5g-upf-vpp/vpp/src/vnet/ipsec/esp_encrypt.c:(943|925|521)', #iv_sz 
                # r'file://:0:0:0:0',
                # r'ike/handler/security.go@391', # Does Randomize
                # # r'n3iwf/internal/ngap/handler/handler.go@1595', # Does Randomize
                # # r'ike/handler/handler.go@229', # Does Randomize
                # # r'ike/handler/handler.go@1187', # Does Randomize
                # # r'ike/handler/handler.go@1543', # Does Randomize
                # r'ike/handler/security.go@267', # Decrypt
                # r'/open5gs/tests/', # test files
                # r'nextepc/lib/core/test', # test files
                # r'aper/marshal.go', # not crypto
                # r'srsran/lib/test/',
                # r'/test/',
                # r'/tests/',
                # r'metrics.c',
                # r'lib/sbi/message.c',
                # r'open5gs\/.+\/\w*-*context.c',
                # r'nextepc/src/mme/emm_build.c',
                # r'nextepc/src/mme/mme_context.c',
                # r'nextepc/src/pcrf/pcrf_context.c',
                # r'open5gs/lib/sbi/conv.c',
                # r'oai-cn5g-upf-vpp/vpp/src/vnet/interface_funcs.h',
                # r'oai-cn5g-upf-vpp/vpp/src/vlib/node_funcs.h',
                # r'vpp/src/vnet/ipsec/esp_decrypt.c',
                # r'vpp/src/vnet/ip/ip.h',
                # r'vpp/src/vlib/buffer_funcs.h',
                # r'usr/include/c\+\+/7/bits/hashtable_policy.h',
                # r'var/tmp/bazel/external/com_google_absl/absl/container/internal/raw_hash_map.h',
                # r'var/tmp/bazel/external/com_github_grpc_grpc/src/core/ext/transport/binder/server/binder_server.cc',
                # r'var/tmp/bazel/external/com_google_absl/absl/container/internal/raw_hash_set.h',
                # r'usr/include/c\+\+/7/ext/new_allocator.h',
                # r'usr/include/c\+\+/7/bits/hashtable.h',
                # r'bronze1man/radius/packet.go',
                # r'github.com/lib/pq/scram/scram.go',
                # r'open5gs/.*context.c' # hash sink in open5gs
                # r'/github.com/golang-jwt/jwt/hmac.go', # Hash not keyed crypto'
                # r'OAI/oai-cn5g-upf-vpp/vpp/src/vppinfra/bihash_template.h',
                # r'OAI/oai-cn5g-upf-vpp/vpp/src/vppinfra/mhash.h',
                # r'OAI/oai-cn5g-upf-vpp/vpp/src/vnet/vxlan-gbp/decap.c'
                # r'nextepc/src/mme/nas_security.c:41',
                # r'nextepc\/.+\/\w*-*context.c',
                # r'nas_security.c:41',
                # r'github.com/ugorji/go/codec/encode.go',
                # r'github.com/ugorji/go/codec/decode.go',
                
                ]

source_filters = [
                #   r'NFs/n3iwf/internal/ngap/handler/handler.go',
                #   r'NFs/n3iwf/pkg/ike/handler/3gpp_types.go',
                #   r'NFs/n3iwf/pkg/ike/handler/handler.go',
                #   r'NFs/n3iwf/pkg/ike/handler/send.go',
                #   r'NFs/n3iwf/pkg/ike/message/message.go',
                #   r'OAI/oai-cn5g-amf/src/amf-app/amf_n[12].cpp', #in from network
                #   r'OAI/oai-cn5g-smf/src/smf_app/smf_pfcp_association.cpp', #in from network
                #   r'file://:0:0:0:0',
                #   r'/open5gs/tests/', # test files
                #   r'nextepc/lib/core/test', # test files
                #   r'github.com/ugorji/', # source not in core
                #   r'/var/tmp/bazel/external', # temp library files, add on src filter in case legit sink
                #   r'/usr/include/', # library files, should not be src
                #   r'/github.com/lib/pq/', # external project sdcore
                #   r'/github.com/aead/',
                #   r'/github.com/klauspost',
                #   r'/github.com/cespare/',
                #   r'srsran/lib/test/',
                #   r'/test/',
                #   r'/tests/',
                #   r'metrics.c',
                #   r'lib/core/ogs-strings.c',
                #   r'usr/include',
                #   r'aper/marshal.go',
                #   r'ngap/ngapConvert/IpAddress.go',
                #   r'/github.com/(omec-project|free5gc)/nas/nasMessage/.*',# incoming from NAS network 
                #   r'/github.com/(omec-project|free5gc)/nas/nasConvert/.*',# Conversions
                #   r'/github.com/(omec-project|free5gc)/nas/nasType/.*',# Incoming from Network
                #   r'/gmm/handler.go',# Incoming from Network
                #   r'/gmm/message/build.go', # Message crafting to send to UE
                #   r'github.com/(omec-project|free5gc)/openapi/client.go', # Misc message operations not related to crypto
                #   r'github.com/(omec-project|free5gc)/openapi/N.+_.+/.+\.go', #incoming from network
                #   r'gmm/handler.go', # incoming from network
                #   r'free5gc/NFs/amf/internal/context/amf_ue.go', # incoming from network
                #   r'free5gc/openapi/client.go',
                #   r'github.com/free5gc/aper/marshal.go',
                #   r'github.com/free5gc/nas/nasMessage/NAS_.+\.go',
                #   r'internal/gmm/handler.go',
                #   r'internal/gmm/message/build.go',
                #   r'internal/gmm/sm.go',
                #   r'internal/ngap/handler.go',
                #   r'github.com/(omec-project|free5gc)/nas/nasMessage/N.+_.+/.+\.go',
                #   r'github.com/aead/cmac/',
                #   r'ngap/handler/handler.go:',
                #   r'ike/handler/3gpp_types.go',
                #   r'ike/handler/handler.go',
                #   r'ike/message/message.go',
                #   r'ike/service/service.go',
                #   r'srsran/lib/src/pdcp/pdcp_entity_base.cc',
                  ]

same_file_filters = [
                    # r'lib/freeDiameter-1.2.1', # freeDiameter library intrafunction stuff
                    #  r'src/hss/milenage.c',
                    #  r'src/mme/mme_context.c',
                    #  r'mme/snow_3g.c',
                    #  r'src/mme/zuc.c',
                    #  r'lib/crypt/snow-3g.c',
                    #  r'lib/crypt/zuc.c',
                    #  r'/freeDiameter/',
                    #  r'5gaka/authentication_algorithms_with_5gaka.cpp',
                    #  r'udm_app/udm_app.cpp',
                    #  r'srsran/lib/src/common/liblte_security.cc',
                    #  r'src/common/liblte_security.cc',
                    #  r'golang-jwt/jwt/hmac.go',
                    #  r'radius/packet.go',
                    #  r'github.com/(omec-project|free5gc)/nas/security/security.go', # Filters out intermediates in free5gc
                    #  r'free5gc/NFs/n3iwf/pkg/ike/handler/security.go', # Filters intermediates free5gc
                    #  r'github.com/(omec-project|free5gc)/util/milenage/milenage.go', # Filters intermediates
                    #  r'generate_auth_data.go', #Filters intermediates
                    #  r'suci.go', # Filters intermediates
                    #  r'zuc.c', # Filter intermediates multiple
                    #  r'milenage.c', # Filter
                    #  r'hss_auc.c',
                    #  r'snow_3g.c',
                    #  r'authentication_algorithms_with_5gaka.cpp',
                    #  r'srsran/srsepc/src/hss/hss.cc',
                     ]


check_loc_filters = [
                    #  r'/usr/include', # file not in core/don't care if exists in library
                    #  r'/var/tmp/bazel/external/',
                    #  r'/tests/',
                    #  r'/test/',
                    #  r'metrics.c',
                    #  r'srsran/lib/include/srsran/asn1/nas_5g_msg.h'
                ]

# Filter sinks out, quicker than doing in CodeQL for now. result[3] should be sinkLoc

def filterSink(result):
    for x in sink_filters:
        if re.search(x, result[3]):
            return True
    return False


# Filter sources out, quicker than doing in CodeQL for now. result[1] should be sourceLoc
def filterSource(result):
    for x in source_filters:
        if re.search(x, result[1]):
            return True
    return False


def filterCheck(result):
    for x in check_loc_filters:
        if re.search(x, result[2]):
            return True
    return False


# filter src/sink pairs in files identified as having intra-function flows which are not of interest

def filterSameFile(result):
    for x in same_file_filters:
        if re.search(x, result[1]) and re.search(x, result[3]):
            return True
    return False

# Filter src/sink pairs that are within 3 lines of each other (Will also filter src == sink)

def filterClose(result):
    # handle a weird thing with SSL library in o5gs
    if result[1] == "file://:0:0:0:0":
        return False
    if abs(int(result[1].split(":")[2]) - int(result[3].split(":")[2])) <= 3 \
    and result[1].split(":")[1] == result[3].split(":")[1]:
        return True
    return False


def checkResultType(file):
    with open(file, 'r') as f:
        data = json.load(f)
        type = data["#select"]["columns"][0]["name"]
    if type == "sourceNode":
        return "flow"
    elif type == "finding":
        return "check"
    else:
        return "typeError"

def getFlowResult(file):
    result = CryptoFlowResult (
        type = "Flow",
        results=[],
        resultCount=0,
        uniqueSinkCount=0,
        uniqueSinks=[],
        uniqueSourceCount=0,
        uniqueSources=[],
        uniqueSrcSink=[],
        uniqueSrcSinkCount=0
    )
    tuples = open_results_file(file)
    
    # Deserialize results into dataclass objects and add to list
    # While we are doing that, also get other data
    unique_sink=[]
    unique_src=[]
    
    # Unique src/sink has to happen after
    
    for r in tuples:
        if filterSink(r) or filterSource(r) or filterSameFile(r) or filterClose(r):
            continue
        else:
            temp = CryptoFlowTuple (
                sourceNode=r[0]["label"],
                sourceLoc=str.replace(r[1], "file:///", "").replace(".go@", ".go:"),
                sinkNode=r[2]["label"],
                sinkLoc=str.replace(r[3], "file:///", "").replace(".go@", ".go:")
            )
            if temp.sinkLoc == temp.sourceLoc:
                continue
            elif not temp.sourceLoc == "file://:0:0:0:0" \
            and abs(int(temp.sourceLoc.split(":")[1]) - int(temp.sinkLoc.split(":")[1])) <= 3 \
            and temp.sourceLoc.split(":")[0] == temp.sinkLoc.split(":")[0]:
                continue
            if temp.sourceLoc not in unique_src:
                unique_src.append(temp.sourceLoc)
            if temp.sinkLoc not in unique_sink:
                unique_sink.append(temp.sinkLoc)
            
            result.results.append(temp)
    
    # Unique src/sink
    for x in result.results:
        if (x.sourceLoc, x.sinkLoc) not in result.uniqueSrcSink:
            result.uniqueSrcSink.append((x.sourceLoc, x.sinkLoc))
    
    result.uniqueSinks = unique_sink
    result.uniqueSources = unique_src
    result.uniqueSinkCount = len(unique_sink)
    result.uniqueSourceCount = len(unique_src)
    result.uniqueSrcSinkCount = len(result.uniqueSrcSink)
    result.resultCount = len(result.results)
    
    return result

def getCheckResult(file):
    print(file)
    result = CryptoCheckResult (
        type = "Check",
        results=[],
        resultCount=0,
        uniqueResultCount=0
    )
    tuples = open_results_file(file)
    unique = []
    
    for r in tuples:
        name = ""
        if filterCheck(r):
            continue
        try:
            name=r[0]["label"]
        except:
            name=r[0]
        temp = CryptoCheckTuple (
            name=name,
            msg=r[1],
            loc=str.replace(r[2], "home/kvenglis/dev/5g_core_builds/", "").replace("file:///", "").replace(".go@", ".go:")
        )
        if temp.loc not in unique:
            unique.append(temp.loc)
        
        result.results.append(temp)
    
    result.resultCount = len(result.results)
    result.uniqueResultCount = len(unique)
    
    return result


def processByDb(db="", path=""):
    if path=="":
        path=utils.getOutputDir()
    results = {}
    for file in Path(path).glob("*.json"):
        if "processed" in file.stem:
            continue
        # print(file)
        filesplit=file.stem.split('_')
        if len(filesplit) < 2:
            continue
        if filesplit[0] == db:
            name = '_'.join(filesplit[1:])
            # results[name] = {}
            type = checkResultType(file)
            # print("Type:" + type)
            if type == "flow":
                results[name] = getFlowResult(file)
            elif type == "check":
                results[name] = getCheckResult(file)
    
    # print(results)
    filename = db + "_processed_"+utils.now+".json"
    out_path = os.path.join(utils.getProccessedDir(), filename)
    with open(out_path, 'w') as f:
        json_data = json.dumps(results, cls=utils.EnhancedJSONEncoder, default=utils.dumper, indent=4)
        f.write(json_data)
    
    return results

            
def plotFlowByDb(data, db=""):
    df_data = {}
    for k,v in data.items():
        if v.type=="Flow":
            df_data[k]=v
    if len(df_data) == 0:
        return 0
    
    df_sorted = {key: value for key, value in sorted(df_data.items())}
    # df = pd.DataFrame.from_records([s.graph_results() for s in data.values() if s.type=="Flow"], index=[x for x in data.keys() if data[x].type="Flow"])
    df = pd.DataFrame.from_records([s.graph_results() for s in df_sorted.values()], index=df_sorted.keys())
    plot = df.plot.bar(rot=0, title=db+" Flow Results", figsize=(12,8))
    for x in plot.containers:
        plot.bar_label(x, padding=5, rotation=90)
    plot.set_xticks(plot.get_xticks(), plot.get_xticklabels(), rotation=45, horizontalalignment='right')
    plot.figure.set_tight_layout(True)
    return plot

def plotCheckByDb(data, db=""):
    df_data = {}
    for k,v in data.items():
        if v.type=="Check":
            df_data[k]=v
    
    if len(df_data) == 0:
        return 0
    
    df_sorted = {key: value for key, value in sorted(df_data.items())}
            
    # df = pd.DataFrame.from_records([s.graph_results() for s in data.values() if s.type=="Check"], index=data.keys())
    df = pd.DataFrame.from_records([s.graph_results() for s in df_sorted.values()], index=df_sorted.keys())
    plot = df.plot.bar(rot=0, title=db+" Check Results", figsize=(12,8))
    for x in plot.containers:
        plot.bar_label(x, padding=5, rotation=90)
    plot.set_xticks(plot.get_xticks(), plot.get_xticklabels(), rotation=45, horizontalalignment='right')
    plot.figure.set_tight_layout(True)
    return plot