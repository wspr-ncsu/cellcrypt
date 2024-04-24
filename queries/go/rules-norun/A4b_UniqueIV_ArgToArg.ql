import go
// import semmle.code.cpp.dataflow.DataFlow
// import semmle.code.cpp.dataflow.TaintTracking
import semmle.go.dataflow.DataFlow
// import semmle.go.dataflow.TaintTracking
import CryptoCustom

/*
* @name A4b_UniqueIV_ArgToArg
* @id a4b-argtoarg-go
* @kind problem
* @problem.severity warning
*/
module UniqueIVSig implements DataFlow::ConfigSig {
    // UniqueIVSig() { this = "UniqueIVSig" }
    
    // Sources and Sinks are the same, the IV parameters of FunctionWithIV or corresponding FunctionCall arguments
    // if a definition isn't found.
    // Filter of source != sink (for 0 step flow) is in query
    predicate isSource(DataFlow::Node node) {
        node instanceof IVSinks
    }
    
    predicate isSink(DataFlow::Node node) {
        node instanceof IVSinks
    }

    predicate isBarrier(DataFlow::Node barrier){

        barrier = any(DataFlow::CallNode c | c.getTarget().hasQualifiedName("crypto/rand", _) | c.getAnArgument())
        or
        any(Assignment a).assigns(barrier.asExpr(), any(Expr e | not exists(e.getExactValue()))) 
    }
}

class IVSinks extends DataFlow::Node {
    IVSinks(){ 
        exists(DataFlow::CallNode c | c.getTarget() instanceof CryptoCustom::FunctionWithIV
            | this = c.getArgument(c.getTarget().(CryptoCustom::FunctionWithIV).getIVIndex()))
            or this = any(CryptoCustom::NewCipherCall c).getIVArg()
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
source.asExpr().getLocation().toString() as sourceLoc,
sink as sinkNode, 
sink.asExpr().getLocation().toString() as sinkLoc