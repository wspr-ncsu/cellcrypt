import go
// import semmle.code.cpp.dataflow.DataFlow
// import semmle.code.cpp.dataflow.TaintTracking
import semmle.go.dataflow.DataFlow
// import semmle.go.dataflow.TaintTracking
import CryptoCustom

/**
 * @name A6_RandomKey_VarToArg
 * @id a6-vartoarg-go
 * @kind problem
 * @problem.severity warning
 */
module RandomKeySig implements DataFlow::ConfigSig {
    // RandomKeySig() { this = "RandomKeySig" }
    
    // Sinks are defined as nodes with the same type as the IVSink, which is the IV parameter of the 
    // target crypto function

    // Initial results having sources with local flow to nodes with the same type was messy
    // and duplicated results (since it found each node on the way to the node with same type)
    predicate isSource(DataFlow::Node node) {
        (node.getType() = any(KeySink i).getType()
        or
        exists(DataFlow::Node sinktype | sinktype.getType() = any(KeySink i).getType() 
            and (node.asExpr() = any(DeclaredVariable v).getDeclaration()
            or node.asExpr() = any(DeclaredVariable v).getInit()) | DataFlow::localFlow(node, sinktype) 
                                    and not node.getType() = sinktype.getType())
        )
        and not exists(HandlerFlowConfig config, DataFlow::Node sink | config.hasFlowTo(sink) and node = sink)
        and not node instanceof DataFlow::ArgumentNode
    }
    
    predicate isSink(DataFlow::Node node) {
        node instanceof KeySink
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
        node.getType() = any(KeySink i).getType()
        or
        exists(DataFlow::Node sinktype | sinktype.getType() = any(KeySink i).getType() 
            and (node.asExpr() = any(DeclaredVariable v).getDeclaration()
            or node.asExpr() = any(DeclaredVariable v).getInit()) | DataFlow::localFlow(node, sinktype) 
                                    and not node.getType() = sinktype.getType())
    }

}

class KeySink extends DataFlow::Node {
    KeySink(){ 
        exists(DataFlow::CallNode c | c.getTarget() instanceof CryptoCustom::FunctionWithKey
            | this = c.getArgument(c.getTarget().(CryptoCustom::FunctionWithKey).getKeyIndex()))
    }
}

module RandomKeyConfig = TaintTracking::Global<RandomKeySig>;

// import RandomKeyConfig::PathGraph

from DataFlow::Node src, DataFlow::Node sink
where RandomKeyConfig::flow(src, sink) and not src = sink
select src as sourceNode, 
src.asExpr().getLocation().toString() as sourceLoc,
sink as sinkNode, 
sink.asExpr().getLocation().toString() as sinkLoc