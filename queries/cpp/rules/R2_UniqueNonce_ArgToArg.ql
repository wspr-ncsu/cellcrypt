import cpp
// import semmle.code.cpp.dataflow.DataFlow
// import semmle.code.cpp.dataflow.TaintTracking
import semmle.code.cpp.ir.dataflow.DataFlow
import semmle.code.cpp.ir.dataflow.TaintTracking
import CryptoCustom

/**
 * @name A4b_UniqueNonce_ArgToArg
 * @id a4c-argtoarg-cpp
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
        // or 
        // exists(DataFlow::IndirectExprNode n, NonceSink r | r.asExpr() = n.asIndirectExpr() | node = n)
    }

    predicate isBarrier(DataFlow::Node barrier){
        barrier = DataFlow::exprNode(any(PRNGFunction f).getACallToThisFunction())
        or
        barrier instanceof AssignmentNode
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
source.getLocation().toString() as sourceLoc,
sink as sinkNode, 
sink.getLocation().toString() as sinkLoc