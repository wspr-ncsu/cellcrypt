import go
// import semmle.code.cpp.dataflow.DataFlow
// import semmle.code.cpp.dataflow.TaintTracking
import semmle.go.dataflow.DataFlow
// import semmle.go.dataflow.TaintTracking
import CryptoCustom
/**
 * @name A4c_UniqueNonce_VarToArg
 * @id a4c-vartoarg-go
 * @kind problem
 * @problem.severity warning
 */
module UniqueNonceSig implements DataFlow::ConfigSig {
    // UniqueNonceSig() { this = "UniqueNonceSig" }
    
    // Sinks are defined as nodes with the same type as the NonceSink, which is the nonce parameter of the 
    // target crypto function

    // Initial results having sources with local flow to nodes with the same type was messy
    // and duplicated results (since it found each node on the way to the node with same type)
    predicate isSource(DataFlow::Node node) {
        node.getType() = any(NonceSink i).getType()
        or
        exists(DataFlow::Node sinktype | sinktype.getType() = any(NonceSink i).getType() 
            and (node.asExpr() = any(DeclaredVariable v).getDeclaration()
            or node.asExpr() = any(DeclaredVariable v).getInit()) | DataFlow::localFlow(node, sinktype) 
                                    and not node.getType() = sinktype.getType())
        and not node instanceof DataFlow::ArgumentNode
    }
    
    predicate isSink(DataFlow::Node node) {
        node instanceof NonceSink
    }

    // Barriers are 
    predicate isBarrier(DataFlow::Node barrier){
        barrier = any(DataFlow::CallNode c | c.getTarget().hasQualifiedName("crypto/rand", _) | c.getAnArgument())
        or
        any(Assignment a).assigns(barrier.asExpr(), any(Expr e | not exists(e.getExactValue()))) 
    }
}

// Sinks are nonce parameters of FunctionWithNonce or the node corresponding to the nonce parameter argument
// of a function without a found definition (usually built-ins, default system libraries)
class NonceSink extends DataFlow::Node {
    NonceSink(){exists(DataFlow::CallNode c | c.getTarget() instanceof CryptoCustom::FunctionWithNonce
        | this = c.getArgument(c.getTarget().(CryptoCustom::FunctionWithNonce).getNonceIndex()))
}
}

module UniqueNonceConfig = TaintTracking::Global<UniqueNonceSig>;

// import UniqueNonceConfig::PathGraph

from DataFlow::Node source, DataFlow::Node sink
where UniqueNonceConfig::flow(source, sink)
select source as sourceNode, 
source.asExpr().getLocation().toString() as sourceLoc,
sink as sinkNode, 
sink.asExpr().getLocation().toString() as sinkLoc