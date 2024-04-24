import cpp
import semmle.code.cpp.dataflow.new.DataFlow
// import semmle.code.cpp.dataflow.new.DataFlow2 as HandlerFlow
import semmle.code.cpp.dataflow.new.TaintTracking
import semmle.code.cpp.dataflow.new.TaintTracking2
import CryptoCustom

// ConfigSig for Handler to Key Source flow, used for partialFlow query. 
// Testing purposes, unsure of functionality

/**
 * @name A6_RandomKey_VarToArg
 * @id a6-vartoarg-cpp
 * @kind problem
 * @problem.severity warning
 */



module HandlerFlowSig implements DataFlow::ConfigSig {

    predicate isSource(DataFlow::Node node) {
        node.asParameter() = any(HandlerFunction h).getAParameter()
    }
    
    predicate isSink(DataFlow::Node node) {
        node.getType() = any(KeySink ks).getType()
    }

    predicate isBarrier(DataFlow::Node barrier){
        none()
    }
}

// Traditional TaintTracking Configuration for excluding nodes from a handler

class HandlerFlowConfiguration extends TaintTracking2::Configuration {

    HandlerFlowConfiguration(){this = "HandlerFlowConfiguration"}

    override predicate isSource(DataFlow::Node node) {
        node.asParameter() = any(HandlerFunction h).getAParameter()
        or
        node.asExpr() = any(HandlerFunction h).getACallToThisFunction().getAnArgument()
    }
    
    override predicate isSink(DataFlow::Node node) {
        (node.getType() = any(KeySink i).getType()
        or
        exists(DataFlow::Node sinktype | sinktype.getType() = any(KeySink i).getType()
            and node.asExpr() = any(LocalVariable v).getInitializer().getExpr()
            | DataFlow::localFlow(node, sinktype) and not node.getType() = sinktype.getType())
        )
    }

    // predicate isBarrier(DataFlow::Node barrier){
    //     none()
    // }
}

module RandomKeyFlowSig implements DataFlow::ConfigSig {
    predicate isSource(DataFlow::Node node) {
        (node.getType() = any(KeySink i).getType()
        or
        exists(DataFlow::Node sinktype | sinktype.getType() = any(KeySink i).getType()
            and node.asExpr() = any(LocalVariable v).getInitializer().getExpr()
            | DataFlow::localFlow(node, sinktype) and not node.getType() = sinktype.getType())
        )
        and not exists(HandlerFlowConfiguration config | config.hasFlowTo(node))
        // Limit weird function to function call findings
        and not exists(FunctionCall c | c.getArgument(_) = node.asExpr())
        // and not node.asExpr() instanceof PointerDereferenceExpr

    }
    
    predicate isSink(DataFlow::Node node) {
        node instanceof KeySink
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