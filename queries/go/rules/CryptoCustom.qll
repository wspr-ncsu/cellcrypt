private import go
// private import semmle.go.dataflow.internal.DataFlowImpl
import utils
import free5gc.Free5GC
// import semmle.go.dataflow.DataFlow

module CryptoCustom{
    class CryptoPackages extends Package{
        CryptoPackages(){
            getBasePackageFromImport(this).matches(["hash"
                ,"crypto"
                ,"crypto/%"
                ,"golang.org/x/crypto/%"
                ,"hash/%"
                ,"github.com/aead/cmac"
                ,"github.com/free5gc/nas/security/snow3g"
                ,"github.com/free5gc/nas/security/zuc"
                ,"github.com/free5gc/nas/security"
                ,"github.com/free5gc/util/ueauth"
                ,"github.com/free5gc/util/milenage"
                ,"github.com/omec-project/UeauCommon"
                ,"github.com/omec-project/nas/security"
                ,"github.com/cespare/xxhash/v2"
                ,"github.com/omec-project/nas/security/snow3g"
                ,"github.com/aead/cmac"
                ,"github.com/omec-project/milenage"
                ,"github.com/omec-project/util_3gpp/suci"
                ,"github.com/bronze1man/radius"
                ,"github.com/emakeev/milenage"
        ])
        }
    }

    class InsecureAlgPackages extends Package {
        InsecureAlgPackages(){
            this.getPath().matches([
                "crypto/des"
                ,"crypto/rc4"
                ,"golang.org/x/crypto/blowfish"
                ,"golang.org/x/crypto/cast5"
                ,"golang.org/x/crypto/tea"
                ,"golang.org/x/crypto/xtea"
    
            ])
            or getBasePackageFromImport(this).matches([
                "crypto/des"
                ,"crypto/rc4"
                ,"golang.org/x/crypto/blowfish"
                ,"golang.org/x/crypto/cast5"
                ,"golang.org/x/crypto/tea"
                ,"golang.org/x/crypto/xtea"
    
            ])
        }
    }
    
    class InsecureHashPackages extends Package {
        InsecureHashPackages(){
            this.getPath().matches([
                "crypto/sha1"
                ,"crypto/md5"
                ,"golang.org/x/crypto/MD4"
                ,"golang.org/x/crypto/ripemd160"
            ])
            or getBasePackageFromImport(this).matches([
                "crypto/sha1"
                ,"crypto/md5"
                ,"golang.org/x/crypto/MD4"
                ,"golang.org/x/crypto/ripemd160"
    
            ])
        }
    }    

    class GenericCipherCall extends DataFlow::CallNode {
        GenericCipherCall(){
            exists(Function f | f.getPackage() instanceof CryptoPackages
            | this = f.getACall()
            )
        }

        DataFlow::Node getBlockArg(){
            result = this.getArgument(_)
            and result.getType().hasQualifiedName("crypto/cipher", "Block")
        }

        DataFlow::Node getByteSliceArg(){
            exists(int i |
            result = this.getArgument(i)
            and result.getType() instanceof ByteSliceType
            )
        }
    }

    class NewCipherCall extends GenericCipherCall{
        NewCipherCall(){this.getTarget().hasQualifiedName("crypto/cipher", any(string s | s.matches("New%")))}

        DataFlow::Node getIVArg(){
            // All the crypto/cipher w/ IVs have it at arg index 1
            result = this.getArgument(1)
            and result.getType() instanceof ByteSliceType 
        }
    }

    class FunctionWithIV extends Function {
        int iv_index;
        FunctionWithIV(){
            (this.getName() = ["NewCBCEncrypter",
                        "NewCFBEncrytper",
                        "NewCTR",
                        "NewOFB"]
                and iv_index = 2)
            or exists(Parameter p | getAParameter() = p and p.getName().matches(["iv%","IV","Iv","vector","vect","ivec"]) 
                | iv_index = p.getIndex())
        }

        int getIVIndex(){
            result = iv_index
        }
    }


    class FunctionWithNonce extends Function {
        int nonce_index;
        FunctionWithNonce(){
            (this.getName() = ["Seal"]
                and nonce_index = 2)
            or exists(Parameter p | getAParameter() = p and p.getName().matches(["%nonce%", "rand","_rand",]) | nonce_index = p.getIndex())
        }
    

        int getNonceIndex(){
            result = nonce_index
        }
    }

    class FunctionWithKey extends Function {
        int key_index;
        FunctionWithKey(){
            this.getPackage().getPath().regexpMatch("(crypto|golang.org/x/crypto)/.*")
                and this.getName().matches(["NewCipher", 
                                            "NewTripleDESCipher",
                                            "NewSaltedCipher",
                                            "ExpandKey",
                                            "HChaCha20",
                                            "NewUnauthenticatedCipher",
                                            "NewCipherWithRounds",
                                            ""])
                and key_index = 0
            or
            this.hasQualifiedName("crypto/hmac", ["New"]) and key_index = 1
            or
            this.hasQualifiedName("golang.org/x/crypto/chacha20poly1305", ["New","NewX"]) and key_index = 0
            or
            this.hasQualifiedName("golang.org/x/crypto/hkdf",["Expand", "Extract", "New"]) and key_index = 1
            or
            this.hasQualifiedName("golang.org/x/crypto/nacl/%",["Sum", "Verify"]) and key_index = 1
            or
            this.hasQualifiedName("golang.org/x/crypto/salsa20", "XORKeyStream") and key_index = 3
            or
            this.hasQualifiedName("golang.org/x/crypto/salsa20/salsa", "XORKeyStream") and key_index = 3
            or
            this.hasQualifiedName("golang.org/x/crypto/salsa20/salsa", "HSalsa20") and key_index = 2
            or
            this.getName() = "GetKDFValue" and key_index = 0
        }
        int getKeyIndex(){
            result = key_index
        }
    }

    class RANDFunction extends Function{
        Parameter rand;
        int rand_index;

        RANDFunction(){
            this.getName().matches(["Milenage%", "milenage%"]) 
            and rand = this.getAParameter() 
            and rand.getName().matches(["rand","_rand","rand_"])
            and rand_index = rand.getIndex()
        }

        int getRandIndex(){
            result = rand_index
        }

        Parameter getRand(){
            result = rand
        }
    }

    class HandlerFunction extends Function{
        HandlerFunction(){
            this instanceof Free5GC::CoreHandlers
        }
    }
    
    class RANDSink extends DataFlow::Node {
        RANDSink(){
            // Regular RAND functions
            ( exists(DataFlow::CallNode c | c.getTarget() instanceof CryptoCustom::RANDFunction
            | this = c.getArgument(c.getTarget().(CryptoCustom::RANDFunction).getRandIndex()))
            )
            or
            // KDF where the first byte in the array needs to be 0x6B
            exists(CallExpr c | c.getTarget().getName() = "GetKDFValue" and
                                c.getArgument(1).(ValueExpr).getGlobalValueNumber().toString() = "\"6B\""
                            | this.asExpr() = c.getArgument(4))
        }
    }
}

