import go
// import semmle.code.cpp.dataflow.DataFlow
// import semmle.code.cpp.dataflow.TaintTracking
import semmle.go.dataflow.DataFlow
// import semmle.go.dataflow.TaintTracking
import CryptoCustom

/**
 * @name A4b_UniqueIV_VarToArg
 * @id a4b-vartoarg-go
 * @kind problem
 * @problem.severity warning
 */


module UniqueIVSig implements DataFlow::ConfigSig {
    // UniqueIVSig() { this = "UniqueIVSig" }
    
    // Sinks are defined as nodes with the same type as the IVSink, which is the IV parameter of the 
    // target crypto function

    // Initial results having sources with local flow to nodes with the same type was messy
    // and duplicated results (since it found each node on the way to the node with same type)
    predicate isSource(DataFlow::Node node) {
        node.getType() = any(IVSinks i).getType()
        or
        exists(DataFlow::Node sinktype | sinktype.getType() = any(IVSinks i).getType() 
            and (node.asExpr() = any(DeclaredVariable v).getDeclaration()
            or node.asExpr() = any(DeclaredVariable v).getInit()) | DataFlow::localFlow(node, sinktype) 
                                    and not node.getType() = sinktype.getType())
        and not node instanceof DataFlow::ArgumentNode
    }
    
    predicate isSink(DataFlow::Node node) {
        node instanceof IVSinks
    }

    // Barriers are 
    predicate isBarrier(DataFlow::Node barrier){

        barrier = any(DataFlow::CallNode c | c.getTarget().hasQualifiedName("crypto/rand", _) | c.getAnArgument())
        or
        any(Assignment a).assigns(barrier.asExpr(), any(Expr e | not exists(e.getExactValue()))) 
    }
}

class IVSinks extends DataFlow::Node {
    IVSinks(){ 
        exists(DataFlow::CallNode c | c.getTarget() instanceof CryptoCustom::FunctionWithIV and 
            not c.getTarget().getPackage().getName() = "codec"
            | this = c.getArgument(c.getTarget().(CryptoCustom::FunctionWithIV).getIVIndex()))
            or this = any(CryptoCustom::NewCipherCall c).getIVArg()
    }
}

module UniqueIVConfig = TaintTracking::Global<UniqueIVSig>;

// import UniqueIVConfig::PathGraph

from DataFlow::Node source, DataFlow::Node sink
where UniqueIVConfig::flow(source, sink)
select source as sourceNode, 
source.asExpr().getLocation().toString() as sourceLoc,
sink as sinkNode, 
sink.asExpr().getLocation().toString() as sinkLoc