import go
import semmle.go.dataflow.DataFlow
// import semmle.go.dataflow.TaintTracking
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
        exists(DataFlow::CallNode c, Assignment a | c.getTarget().hasQualifiedName("math/rand", _)
        and a.getRhs().getAChild*() = c.asExpr() | node = c
        )

        
        

        // node.asExpr() = any(FunctionCall c | c.getTarget().getName() = "gen_rand" | c.getArgument(0))
        

        // and not node.asExpr() instanceof PointerDereferenceExpr
    }
    
    predicate isSink(DataFlow::Node node) {

        // any(DataFlow::Node n | n.toString() = "rand indirection" ) = node
        // node = any(DataFlow::Node n | n.getFunction().getName() = "gen_rand")
        
        // node.asExpr() = any(FunctionCall c | c.getTarget().getName() = "gen_rand" | c.getArgument(0))
        node instanceof ComboSink 
        // or 
        // exists(DataFlow::IndirectExprNode n, ComboSink r | r.asExpr() = n.asIndirectExpr() | node = n)
        // // any()
    }

    // Barriers are 
    // predicate isBarrier(DataFlow::Node barrier){
    //     // none()
    //     barrier = DataFlow::exprNode(any(PRNGFunction f).getACallToThisFunction())
    //     or
    //     barrier.asDefiningArgument() = any(PRNGFunction f).getACallToThisFunction().getAnArgument()
    // }
}

class KeySink extends DataFlow::Node {
    KeySink(){ 
        exists(DataFlow::CallNode c | c.getTarget() instanceof CryptoCustom::FunctionWithKey
            | this = c.getArgument(c.getTarget().(CryptoCustom::FunctionWithKey).getKeyIndex()))
    }
}


class SaltSink extends DataFlow::CallNode {
    int salt_index;
    SaltSink(){ 
        getTarget().hasQualifiedName("golang.org/x/crypto/argon2", _) and salt_index = 1
        or
        getTarget().hasQualifiedName("golang.org/x/crypto/blowfish", "NewSaltedCipher") and salt_index = 1
        or
        getTarget().hasQualifiedName("golang.org/x/crypto/hkdf", ["Extract","New"]) and salt_index = 2
        or
        getTarget().hasQualifiedName("golang.org/x/crypto/openpgp", ["Iterated", "Salted"]) and salt_index = 3
        or
        getTarget().hasQualifiedName("golang.org/x/crypto/pbkdf2", "Key") and salt_index = 1
        or
        getTarget().hasQualifiedName("golang.org/x/crypto/scrypt", "Key") and salt_index = 1
        or
        exists(Function f, Parameter p | f.getAParameter() = p and p.getName().matches("%salt%") 
            | salt_index = p.getIndex() and this = f.getACall()) 
    }

    int getSaltIndex(){ result = salt_index }

    DataFlow::Node getSaltArg(){
        result = this.getArgument(salt_index)
    }
}

class ComboSink extends DataFlow::Node {
    ComboSink() {
        this instanceof CryptoCustom::RANDSink
        or 
        this instanceof IVSinks
        or
        this instanceof SaltSink
        or
        this instanceof KeySink
        or
        this instanceof NonceSink
    }
} 

class NonceSink extends DataFlow::Node {
    NonceSink(){exists(DataFlow::CallNode c | c.getTarget() instanceof CryptoCustom::FunctionWithNonce
        | this = c.getArgument(c.getTarget().(CryptoCustom::FunctionWithNonce).getNonceIndex()))
}
}

class IVSinks extends DataFlow::Node {
    IVSinks(){ 
        exists(DataFlow::CallNode c | c.getTarget() instanceof CryptoCustom::FunctionWithIV
            | this = c.getArgument(c.getTarget().(CryptoCustom::FunctionWithIV).getIVIndex()))
            or this = any(CryptoCustom::NewCipherCall c).getIVArg()
    }
}

module UniqueIVConfig = TaintTracking::Global<UniqueIVSig2>;

// import UniqueIVConfig::PathGraph

from DataFlow::Node source, DataFlow::Node sink
where UniqueIVConfig::flow(source, sink) and not source = sink
select source as sourceNode, 
source.asExpr().getLocation().toString() as sourceLoc,
sink as sinkNode, 
sink.asExpr().getLocation().toString() as sinkLoc
// sink.asIndirectExpr()