import cpp
import semmle.code.cpp.dataflow.new.DataFlow
// import semmle.code.cpp.dataflow.new.DataFlow2 as HandlerFlow
import semmle.code.cpp.dataflow.new.TaintTracking
import semmle.code.cpp.dataflow.new.TaintTracking2
import CryptoCustom

// ConfigSig for Handler to Key Source flow, used for partialFlow query. 
// Testing purposes, unsure of functionality

/**
 * @name A6_RandomKey_ArgToArg
 * @id a6-argtoarg-cpp
 * @kind problem
 * @problem.severity warning
 */


module RandomKeyFlowSig implements DataFlow::ConfigSig {
    predicate isSource(DataFlow::Node node) {
        node instanceof KeySink
    }
    
    predicate isSink(DataFlow::Node node) {
        node instanceof KeySink
        // or
        // exists(DataFlow::IndirectExprNode n, KeySink r | r.asExpr() = n.asIndirectExpr() | node = n)
    }

    predicate isBarrier(DataFlow::Node barrier){
        barrier = DataFlow::exprNode(any(PRNGFunction f).getACallToThisFunction())
        or
        barrier.asDefiningArgument() = any(PRNGFunction f).getACallToThisFunction().getAnArgument()
    }
}

// module HandlerFlowConfig = TaintTracking::Global<HandlerFlowSig>;
module RandomKeyConfig = TaintTracking::Global<RandomKeyFlowSig>;

from DataFlow::Node src, DataFlow::Node sink
where RandomKeyConfig::flow(src, sink) and not src = sink
select src as sourceNode, 
src.getLocation().toString() as sourceLoc,
sink as sinkNode, 
sink.getLocation().toString() as sinkLoc