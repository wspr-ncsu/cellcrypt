import cpp
// import semmle.code.cpp.dataflow.DataFlow
// import semmle.code.cpp.dataflow.TaintTracking
import semmle.code.cpp.ir.dataflow.DataFlow
import semmle.code.cpp.ir.dataflow.TaintTracking
import CryptoCustom

/**
 * @name A4b_UniqueIV_VarToArg
 * @id a4b-vartoarg-cpp
 * @kind problem
 * @problem.severity warning
 */
module UniqueIVSig2 implements DataFlow::ConfigSig {
    // UniqueIVSig() { this = "UniqueIVSig" }
    
    // Sinks are defined as nodes with the same type as the IVSink, which is the IV parameter of the 
    // target crypto function

    // Initial results having sources with local flow to nodes with the same type was messy
    // and duplicated results (since it found each node on the way to the node with same type)
    predicate isSource(DataFlow::Node node) {
        exists(FunctionCall c, AssignExpr a | c.getTarget().getName().matches("%rand%") 
        and  c.getTarget().findRootCause().getFile().getBaseName() = "stdlib.h"
        and a.getRValue().getAChild*() = c | node= DataFlow::exprNode(c)
        )
        or
        exists(FunctionCall c, AssignExpr a | c.getTarget().getName().matches("%rand%") 
        and  c.getTarget().findRootCause().getFile().getBaseName() = "gmp-x86_64.h"
        and a.getRValue().getAChild*() = c | node= DataFlow::exprNode(c)
        )

        // and not node.asExpr() instanceof PointerDereferenceExpr
    }
    
    predicate isSink(DataFlow::Node node) {
        node instanceof ComboSink 
        or 
        exists(DataFlow::IndirectExprNode n, ComboSink r | r.asExpr() = n.asIndirectExpr() | node = n)
    }

    predicate isBarrier(DataFlow::Node barrier){
        // none()
        barrier = DataFlow::exprNode(any(PRNGFunction f).getACallToThisFunction())
        or
        barrier.asDefiningArgument() = any(PRNGFunction f).getACallToThisFunction().getAnArgument()
    }
}

class ComboSink extends DataFlow::Node {
    ComboSink() {
        this instanceof RANDSink
        or 
        this instanceof IVSink
        or
        this instanceof SaltSink
        or
        this instanceof KeySink
        or
        this instanceof NonceSink
    }
} 


module UniqueIVConfig = TaintTracking::Global<UniqueIVSig2>;

// import UniqueIVConfig::PathGraph

from DataFlow::Node source, DataFlow::Node sink
where UniqueIVConfig::flow(source, sink) and not source = sink
select source as sourceNode, 
source.getLocation().toString() as sourceLoc,
sink as sinkNode, 
sink.getLocation().toString() as sinkLoc