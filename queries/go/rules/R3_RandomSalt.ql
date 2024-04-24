import go
// import semmle.code.cpp.dataflow.DataFlow
// import semmle.code.cpp.dataflow.TaintTracking
import semmle.go.dataflow.DataFlow
// import semmle.go.dataflow.TaintTracking
import CryptoCustom

/**
 * @name A5_UniqueSalt_VarToArg
 * @id a5-vartoarg-go
 * @kind problem
 * @problem.severity warning
 */
module UniqueSaltSig implements DataFlow::ConfigSig {

    predicate isSource(DataFlow::Node node) {
        node.getType() = any(SaltSink i).getSaltArg().getType()
        or
        exists(DataFlow::Node sinktype | sinktype.getType() = any(SaltSink i).getSaltArg().getType() 
            and (node.asExpr() = any(DeclaredVariable v).getDeclaration()
            or node.asExpr() = any(DeclaredVariable v).getInit()) | DataFlow::localFlow(node, sinktype) 
                                    and not node.getType() = sinktype.getType())
    }
    
    predicate isSink(DataFlow::Node node) {
        node = any(SaltSink s).getSaltArg()
    }

    predicate isBarrier(DataFlow::Node barrier){
        barrier = any(DataFlow::CallNode c | c.getTarget().hasQualifiedName("crypto/rand", _) | c.getAnArgument())
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

module UniqueSaltConfig = TaintTracking::Global<UniqueSaltSig>;

// import UniqueSaltConfig::PathGraph

// Finds flow from FunctionWithIV to FunctionWithIV without new randomization or an assignment,
// filters out src = sink
from DataFlow::Node source, DataFlow::Node sink
where UniqueSaltConfig::flow(source, sink)
select source as sourceNode, 
source.asExpr().getLocation().toString() as sourceLoc,
sink as sinkNode, 
sink.asExpr().getLocation().toString() as sinkLoc