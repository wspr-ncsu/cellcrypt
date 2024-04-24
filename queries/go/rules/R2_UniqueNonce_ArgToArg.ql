import go
// import semmle.code.cpp.dataflow.DataFlow
// import semmle.code.cpp.dataflow.TaintTracking
import semmle.go.dataflow.DataFlow
// import semmle.go.dataflow.TaintTracking
import CryptoCustom

/**
 * @name A4b_UniqueNonce_ArgToArg
 * @id a4c-argtoarg-go
 * @kind problem
 * @problem.severity warning
 */
module UniqueNonceSig implements DataFlow::ConfigSig {
    // UniqueNonceSig() { this = "UniqueNonceSig" }
    
    // Sources and Sinks are the same, the Nonce parameters of FunctionWithNonce or corresponding FunctionCall arguments
    // if a definition isn't found.
    // Filter of source != sink (for 0 step flow) is in query
    predicate isSource(DataFlow::Node node) {
        node instanceof NonceSink
    }
    
    predicate isSink(DataFlow::Node node) {
        node instanceof NonceSink
    }

    predicate isBarrier(DataFlow::Node barrier){
        barrier = any(DataFlow::CallNode c | c.getTarget().hasQualifiedName("crypto/rand", _) | c.getAnArgument())
        or
        any(Assignment a).assigns(barrier.asExpr(), any(Expr e | not exists(e.getExactValue()))) 
    }
}

class NonceSink extends DataFlow::Node {
    NonceSink(){exists(DataFlow::CallNode c | c.getTarget() instanceof CryptoCustom::FunctionWithNonce
        | this = c.getArgument(c.getTarget().(CryptoCustom::FunctionWithNonce).getNonceIndex()))
}
}

module UniqueNonceConfig = TaintTracking::Global<UniqueNonceSig>;

// import UniqueNonceConfig::PathGraph

// Finds flow from FunctionWithNonce to FunctionWithNonce without new randomization or an assignment,
// filters out src = sink
from DataFlow::Node source, DataFlow::Node sink
where UniqueNonceConfig::flow(source, sink)
and not source = sink
select source as sourceNode, 
source.asExpr().getLocation().toString() as sourceLoc,
sink as sinkNode, 
sink.asExpr().getLocation().toString() as sinkLoc