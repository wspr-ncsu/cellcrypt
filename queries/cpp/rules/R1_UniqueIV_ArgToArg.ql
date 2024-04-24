import cpp
// import semmle.code.cpp.dataflow.DataFlow
// import semmle.code.cpp.dataflow.TaintTracking
import semmle.code.cpp.ir.dataflow.DataFlow
import semmle.code.cpp.ir.dataflow.TaintTracking
import CryptoCustom
/*
* @name A4b_UniqueIV_ArgToArg
* @id a4b-argtoarg-cpp
* @kind problem
* @problem.severity warning
*/

/**
 * @name PathScratch
 * @kind path-problem
 * @problem.severity warning
 */
module UniqueIVSig implements DataFlow::ConfigSig {
    // UniqueIVSig() { this = "UniqueIVSig" }
    
    // Sources and Sinks are the same, the IV parameters of FunctionWithIV or corresponding FunctionCall arguments
    // if a definition isn't found.
    // Filter of source != sink (for 0 step flow) is in query
    predicate isSource(DataFlow::Node node) {
        node instanceof IVSink
    }
    
    predicate isSink(DataFlow::Node node) {
        node instanceof IVSink
        // or 
        // exists(DataFlow::IndirectExprNode n, IVSink r | r.asExpr() = n.asIndirectExpr() | node = n)
    }

    predicate isBarrier(DataFlow::Node barrier){
        barrier = DataFlow::exprNode(any(PRNGFunction f).getACallToThisFunction())
        or
        barrier instanceof AssignmentNode
        or
        barrier.asDefiningArgument() = any(PRNGFunction f).getACallToThisFunction().getAnArgument()
    }
}

module UniqueIVConfig = TaintTracking::Global<UniqueIVSig>;

// import UniqueIVConfig::PathGraph

// Finds flow from FunctionWithIV to FunctionWithIV without new randomization or an assignment,
// filters out src = sink
from DataFlow::Node source, DataFlow::Node sink
where UniqueIVConfig::flow(source, sink)
and not source = sink
select source as sourceNode, 
source.getLocation().toString() as sourceLoc,
sink as sinkNode, 
sink.getLocation().toString() as sinkLoc