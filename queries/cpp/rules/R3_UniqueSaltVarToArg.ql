import cpp
// import semmle.code.cpp.dataflow.DataFlow
// import semmle.code.cpp.dataflow.TaintTracking
import semmle.code.cpp.ir.dataflow.DataFlow
import semmle.code.cpp.ir.dataflow.TaintTracking
import CryptoCustom

/**
 * @name A5_UniqueSalt_VarToArg
 * @id a5-vartoarg-cpp
 * @kind problem
 * @problem.severity warning
 */
module UniqueSaltSig implements DataFlow::ConfigSig {
    // UniqueSaltSig() { this = "UniqueSaltSig" }
    
    // Sinks are defined as nodes with the same type as the IVSink, which is the IV parameter of the 
    // target crypto function

    // Initial results having sources with local flow to nodes with the same type was messy
    // and duplicated results (since it found each node on the way to the node with same type)
    predicate isSource(DataFlow::Node node) {
        node.getType() = any(SaltSink i).getType()
        or
        exists(DataFlow::Node sinktype | sinktype.getType() = any(SaltSink i).getType()
            and node.asExpr() = any(LocalVariable v).getInitializer().getExpr()
            | DataFlow::localFlow(node, sinktype) and not node.getType() = sinktype.getType())
    }
    
    predicate isSink(DataFlow::Node node) {
        node instanceof SaltSink
        // or 
        // exists(DataFlow::IndirectExprNode n, SaltSink r | r.asExpr() = n.asIndirectExpr() | node = n)
    }

    // Barriers are 
    predicate isBarrier(DataFlow::Node barrier){
        barrier = DataFlow::exprNode(any(PRNGFunction f).getACallToThisFunction())
        or
        barrier.asDefiningArgument() = any(PRNGFunction f).getACallToThisFunction().getAnArgument()
    }
}


module UniqueSaltConfig = TaintTracking::Global<UniqueSaltSig>;

// import UniqueSaltConfig::PathGraph

from DataFlow::Node source, DataFlow::Node sink
where UniqueSaltConfig::flow(source, sink)
select source as sourceNode, 
source.getLocation().toString() as sourceLoc,
sink as sinkNode, 
sink.getLocation().toString() as sinkLoc