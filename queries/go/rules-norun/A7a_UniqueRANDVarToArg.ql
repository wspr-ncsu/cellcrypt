import go
// import semmle.code.cpp.dataflow.DataFlow
// import semmle.code.cpp.dataflow.TaintTracking
import semmle.go.dataflow.DataFlow
// import semmle.go.dataflow.TaintTracking
import CryptoCustom

/**
 * @name A7_UniqueRAND_VarToArg
 * @id a7-vartoarg-go
 * @kind problem
 * @problem.severity warning
 */
module UniqueRANDSig implements DataFlow::ConfigSig {
    // RandomKeySig() { this = "RandomKeySig" }
    
    // Sinks are defined as nodes with the same type as the IVSink, which is the IV parameter of the 
    // target crypto function

    // Initial results having sources with local flow to nodes with the same type was messy
    // and duplicated results (since it found each node on the way to the node with same type)
    predicate isSource(DataFlow::Node node) {
        (node.getType() = any(CryptoCustom::RANDSink i).getType()
        or
        exists(DataFlow::Node sinktype | sinktype.getType() = any(CryptoCustom::RANDSink i).getType() 
            and (node.asExpr() = any(DeclaredVariable v).getDeclaration()
            or node.asExpr() = any(DeclaredVariable v).getInit()) | DataFlow::localFlow(node, sinktype) 
                                    and not node.getType() = sinktype.getType())
        )
        and not exists(HandlerFlowConfig config, DataFlow::Node sink | config.hasFlowTo(sink) and node = sink)
        and not node instanceof DataFlow::ArgumentNode
    }
    
    predicate isSink(DataFlow::Node node) {
        node instanceof CryptoCustom::RANDSink
    }

    // Barriers are 
    predicate isBarrier(DataFlow::Node barrier){

        barrier = any(DataFlow::CallNode c | c.getTarget().hasQualifiedName("crypto/rand", _) | c.getAnArgument())
    }
}

class HandlerFlowConfig extends TaintTracking2::Configuration{
    HandlerFlowConfig(){this = "HandlerFlowConfig"}

    override predicate isSource(DataFlow::Node node){
        node.asParameter() = any(CryptoCustom::HandlerFunction f).getAParameter()
    }

    override predicate isSink(DataFlow::Node node){
        node.getType() = any(CryptoCustom::RANDSink i).getType()
        or
        exists(DataFlow::Node sinktype | sinktype.getType() = any(CryptoCustom::RANDSink i).getType() 
            and (node.asExpr() = any(DeclaredVariable v).getDeclaration()
            or node.asExpr() = any(DeclaredVariable v).getInit()) | DataFlow::localFlow(node, sinktype) 
                                    and not node.getType() = sinktype.getType())
    }

}

module UniqueRANDConfig = TaintTracking::Global<UniqueRANDSig>;

// import UniqueRANDConfig::PathGraph


from DataFlow::Node source, DataFlow::Node sink
where UniqueRANDConfig::flow(source, sink) and not source = sink
select source as sourceNode, 
source.asExpr().getLocation().toString() as sourceLoc,
sink as sinkNode, 
sink.asExpr().getLocation().toString() as sinkLoc