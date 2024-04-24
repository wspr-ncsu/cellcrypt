private import cpp
private import semmle.code.cpp.dataflow.new.DataFlow
private import lib.OAI
private import lib.O5gs
class CryptoHeaders extends HeaderFile{

    CryptoHeaders(){
        this.getShortName().matches(["ogs-crypt"
        ,"ogs-rand"
        ,"ogs-crypt"
        ,"ogs-aes"
        ,"ogs-aes-cmac"
        ,"ogs-sha1"
        ,"ogs-sha1-hmac"
        ,"ogs-sha2"
        ,"ogs-sha2-hmac"
        ,"milenage"
        ,"snow-3g"
        ,"zuc"
        ,"kasumi"
        ,"ogs-kdf"
        ,"ecc"
        ,"asn_random_fill"
        ,"crypto"
        ,"hmac"
        ,"ecdsa"
        ,"%hash%"
        ,"mhash"
        ,"xxhash"
        ,"random_buffer"
        ,"random_generator"
        ,"%sha256%"
        ,"%aes%"
        ,"%snow3g%"
        ,"cmac"
        ,"SpookyHashV1"
        ,"SpookyHashV2"
        ,"random"
        ,"md5"
        ,"sha1"
        ,"sha2"
        ,"ridemd160"
        ,"nas_algorithms"
        ,"nas_security_context"
        ,"nrf_jwt"
        ,"jwt%"
        ,"nas_lib"
        ,"random"
        ,"crypto"
        ,"%tls%"
        ,"%jwt%"
        ,"%ssl%"
        ,"%oauth%"
        // ,"snow"
        ,"rand"
        ,"%suci%"
        ,"%radius%"
        ,"%nas%"
        ,"%rc4%"
        ,"%xtea%"
        ,"%zuc%"
        ,"%rsa%"
        ,"%pki%"
        ,"%dsa%"

        
    ])

    }
}

class ImportMembers extends Declaration {
    ImportMembers(){
        this.getFile() instanceof CryptoHeaders
    }

    // string getPackageName(){
    //     result = getBasePackageFromImport(this.getPackage())
    // }

    // string getEntityQLType(){
    //     if this.getAQlClass() = "Method" then result = "Method"
    //     else if this.getAQlClass() = "DeclaredFunction" then result = "DeclaredFunction"
    //     else if this.getAQlClass() = "Function" then result = "Function"
    //     else if this.getAQlClass() = "Field" then result = "Field"
    //     else if this.getAQlClass() = "Variable" then result = "Variable"
    //     else if this.getAQlClass() = "StructLit" then result = "StructLit"
    //     else if this.getAQlClass() = "Constant" then result = "Constant"
    //     else if this.getAQlClass() = "DeclaredConstant" then result = "DeclaredConstant"
    //     else if this.getAQlClass() = "Type" then result = "Type"
    //     else if this.getAQlClass() = "DeclaredType" then result = "DeclaredType"
    //     else if this.getAQlClass() = "Label" then result = "Label"
    //     else if this.getAQlClass() = "DeclaredVariable" then result = "DeclaredVariable"
    //     else result = "Entity"
    // }

    // string getFileName(){
    //     if exists(File f | this.getDeclaration().getFile() = f) then 
    //         result = stripNFPath(this.getDeclaration().getFile().getRelativePath())
    //     else
    //         result = "Built-in"
    // }

    // // string getFileNameSDCore(){
    // //     if exists(File f | this.getDeclaration().getFile() = f) then 
    // //     result = stripNFPathSDCore(this.getDeclaration().getFile().getRelativePath())
    // // else
    // //     result = "Built-in"
    // // }

    // int getLineNum(){
    //     if exists(Location l | this.getDeclaration().getLocation() = l) then
    //         result = this.getDeclaration().getLocation().getStartLine()
    //     else
    //         result = -1
    // }

    // // Type getMembership(){
    // //     result = this.(Field).getDeclaringType()
    // //     or result = this.(Method).getReceiverType()
    // //     or result = this.(Constant)
    // // }

    
}

class FunctionWithIV extends Function {
    Parameter iv;
    FunctionWithIV(){
        exists(Parameter p | getAParameter() = p and p.getName().matches(["iv%","IV","Iv","vector","vect","ivec"]) | iv = p)
    }

    Parameter getIV(){
        result = iv
    }
}

class FunctionWithNonce extends Function{
    Parameter nonce;

    FunctionWithNonce(){
        exists(Parameter p | getAParameter() = p and p.getName().matches(["%nonce%", "rand","_rand",]) | nonce = p)
    }

    Parameter getNonce(){
        result = nonce
    }
}

class FunctionWithSQN extends Function {
    Parameter sqn;

    FunctionWithSQN(){
        exists(Parameter p | getAParameter() = p and p.getName().matches(["sqn", "SQN", "seq"]) | sqn = p)
    }

    Parameter getSQN(){
        result = sqn
    }
}

class FunctionWithSalt extends Function {
    Parameter salt;

    FunctionWithSalt(){
        exists(Parameter p | getAParameter() = p and p.getName().matches(["salt", "SALT", ""]) | salt = p)
    }

    Parameter getSalt(){
        result = salt
    }
}

// Class defining set of PRNG functions considered to be PRNG. DOES NOT currently filter for crypto safe/unsafe
class PRNGFunction extends Function {
    PRNGFunction(){
        getName().regexpMatch(["ogs_rand\\w*", 
                                // "\\w{0,3}rand\\w*", 
                                // "\\w{0,3}srand\\w*", 
                                "\\w{0,3}arc4\\w+",
                                "\\w{0,6}gmp\\w+rand\\w*"])
    }
}

class AssignmentNode extends DataFlow::Node {
    
    Variable var;
    // VariableAccess access;


    // Class containing nodes that can assign to a variable. These include built-in Assignments with
    // the variable as the receiver and operator= calls with the variable as the receiver.
    AssignmentNode(){
        this.asExpr() = var.getAnAssignment()
        or
        // A function call to operator=, with the assignment node being the call and the var being the qualifier.
        // Searches the qualifier and it's AST children for VariableAccess to var
        exists(FunctionCall call | call.getTarget().getName() = "operator=" 
                | var.getAnAccess() = call.getQualifier().getAChild*()
                and this.asExpr() = call)
    }


    Variable getVariable(){
        result = var
    }

}

class FunctionWithKey extends Function{
    Parameter key;

    FunctionWithKey(){
        exists(Parameter p | getAParameter() = p and p.getName().matches(["%key%","k","secret","k_","_k%"]) | key = p)    
    }

    Parameter getKey(){
        result = key
    }
}

class InsecureHashName extends string {
    InsecureHashName(){
        this = ["SHA1",
                "MD5",
                "MD4",
                "RIPEMD"]
    }
}

class InsecureSymmetricName extends string {
    InsecureSymmetricName(){
        this = ["xtea",
                "cast5",
                "DES",
                "RC4",
                "blowfish",
                "tea"]
    }
}

class InsecureModeName extends string {
    InsecureModeName(){
        this = ["ECB"]
    }
}


// Sinks are IV parameters of FunctionWithIV or the node corresponding to the IV parameter argument
// of a function without a found definition (usually built-ins, default system libraries)
class SaltSink extends DataFlow::Node {
    SaltSink(){ 
        this.asParameter() = any(FunctionWithSalt f).getSalt()
        or
        exists(FunctionWithSalt f | 
            // (not f.hasDefinition()) |
            this.asExpr() = f.getACallToThisFunction().getArgument(f.getSalt().getIndex()))  }
}

class IVSink extends DataFlow::Node {
    IVSink(){ 
        // this.asParameter() = any(FunctionWithIV f).getIV()
        // or
        exists(FunctionWithIV f | 
            // (not f.hasDefinition()) |
            this.asExpr() = f.getACallToThisFunction().getArgument(f.getIV().getIndex()))  }
}

class NonceSink extends DataFlow::Node {
    NonceSink(){ 
        // this.asParameter() = any(FunctionWithNonce f).getNonce()
        // or
        exists(FunctionWithNonce f | 
            // (not f.hasDefinition()) |
            this.asExpr() = f.getACallToThisFunction().getArgument(f.getNonce().getIndex()))  }
}

class KeySink extends DataFlow::Node {
    KeySink(){
        // this.asParameter() = any(FunctionWithKey f).getKey()
        // or
        exists(FunctionWithKey f | 
            // (not f.hasDefinition()) |
            this.asExpr() = f.getACallToThisFunction().getArgument(f.getKey().getIndex())
        | (f.getFile() instanceof CryptoHeaders
        //OAI KDF and F Functions
        or this.asParameter().getFunction().getName().matches(["kdf",
                                                                "f1",
                                                                "f1star",
                                                                "f2345",
                                                                "f5star",
                                                                "annex_a_4_33501",
                                                                 "%milenage%",
                                                                 "ogs_kdf%"])
        )
        )
    }
}


class HandlerFunction extends Function {
    HandlerFunction(){
        (
        this = any(OAI::CoreHandlers c).asFunction() or this.getName() = any(OAI::CoreHandlers c).getName()
        )
        or
        (
        this = any(O5GS::CoreHandlers c).asFunction() or this.getName() = any(O5GS::CoreHandlers c).getName()
        )
    }
}

// Functions using RAND that are NOT the common KDF (milenage, etc)
class RANDFunction extends Function {
    Parameter rand;
    RANDFunction(){
        // OAI kdf
        this.getName() = "kdf" and rand = this.getParameter(2)
        // Don't do this here, filter out by 0x6B at dataflow sink
        // and this.getACallToThisFunction().getArgument(2).(ArrayExpr).
        
        // OAI f1*, f2345, f5*
        or
        this.getName().matches(["f1star","f2345","f5star","f1"]) 
        and (rand = this.getParameter(2) or rand = this.getParameter(1)) 
        and (rand.getName().matches(["rand","_rand","rand_"].toUpperCase())
            or rand.getName().matches(["rand","_rand","rand_"].toLowerCase()))
        
        // OAI annex_a_4_33501
        or
        this.getName().matches("annex_a_4_33501") and rand = this.getParameter(3)
        
        // O5gs milenage functions
        or
        this.getName().matches("%milenage%") 
        and rand = this.getAParameter() 
        and (rand.getName().matches(["rand","_rand","rand_"].toUpperCase()) 
            or rand.getName().matches(["rand","_rand","rand_"].toLowerCase())
            )

        // O5gs kdf functions
        or
        this.getName().matches("ogs_kdf%")
        and rand = this.getAParameter() 
        and (rand.getName().matches(["rand","_rand","rand_"].toUpperCase()) 
            or rand.getName().matches(["rand","_rand","rand_"].toLowerCase())
            )
        // O5gs auc_sqn (re-use/retrans of RAND), redundant because it uses milenage,
        // here so I don't think I forgot it
        // or
        // this.getName().matches("ogs_auc_sqn")
        // and rand=this.getParameter(2)
    }


    Parameter getRand(){
        result = rand
    }
}

// Common KDF functions where the value of the first byte in the array needs to be checked for 0x6B 

class KDFFunction extends Function {
    Parameter rand;
    KDFFunction(){
        // OAI KDF
        this.getName() = "kdf" and rand = this.getParameter(2)
        // O5gs KDF
        or
        this.getName() = "ogs_kdf_common" and rand = this.getParameter(2)
    }


    Parameter getRand(){
        result = rand
    }
}


class RANDSink extends DataFlow::Node {
    RANDSink(){
        // Regular RAND functions
        (
        // this.asParameter() = any(RANDFunction f).getRand()
        // or
        exists(RANDFunction f |
            this.asExpr() = f.getACallToThisFunction().getArgument(f.getRand().getIndex()))
        )
        or
        // KDF where the first byte in the array needs to be 0x6B
        exists(FunctionCall f, ArrayExpr e, AssignExpr assign | e.getArrayOffset().toString() = "0" 
            and e.getArrayBase() = f.getArgument(2).(VariableAccess).getTarget().getAnAccess()
            and f.getTarget() instanceof KDFFunction
            and  assign.getLValue() = e and assign.getRValue().getValue() = "108"
        | this.asExpr() = f.getArgument(2))
    }
}