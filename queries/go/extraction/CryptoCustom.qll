private import go
// private import semmle.go.dataflow.internal.DataFlowImpl
import utils

class CryptoPackages extends Package{
    CryptoPackages(){
        getBasePackageFromImport(this) = ["hash"
            ,"crypto/aes"
            ,"crypto/cipher"
            ,"crypto/elliptic"
            ,"crypto/hmac"
            ,"crypto/md5"
            ,"crypto/rand"
            ,"crypto/rsa"
            ,"crypto/sha1"
            ,"crypto/sha256"
            ,"crypto/subtle"
            ,"crypto/tls"
            ,"crypto/x509/pkix"
            ,"crypto/x509"
            ,"crypto/ecdsa"
            ,"crypto"
            ,"github.com/golang-jwt/jwt"
            ,"golang.org/x/crypto/curve25519"
            ,"golang.org/x/crypto/sha3"
            ,"golang.org/x/oauth2"
            // ,"golang.org/x/sys/unix"
            ,"hash/crc32"
            ,"hash/fnv"
            ,"math/rand"
            ,"math/big"
            ,"github.com/aead/cmac"
            ,"github.com/free5gc/nas/security/snow3g"
            ,"github.com/free5gc/nas/security/zuc"
            ,"github.com/free5gc/nas/security"
            // ,"github.com/free5gc/util/idgenerator"
            ,"github.com/free5gc/util/ueauth"
            // ,"git.cs.nctu.edu.tw/calee/sctp"
            // ,"github.com/google/uuid"
            ,"github.com/free5gc/util/milenage"
            ,"github.com/omec-project/UeauCommon"
            // ,"github.com/omec-project/idgenerator"
            ,"github.com/omec-project/nas/security"
            ,"github.com/cespare/xxhash/v2"
            ,"github.com/omec-project/nas/security/snow3g"
            ,"github.com/aead/cmac"
            ,"github.com/golang-jwt/jwt"
            // ,"git.cs.nctu.edu.tw/calee/sctp"
            // ,"github.com/google/uuid"
            ,"github.com/omec-project/milenage"
            ,"github.com/omec-project/util_3gpp/suci"
            ,"github.com/bronze1man/radius"
            ,"google.golang.org/grpc/credentials/insecure"
            ,"google.golang.org/grpc/internal/credentials"
            ,"github.com/emakeev/milenage"
            ,"github.com/gin-gonic/gin"
            ,"github.com/omec-project/http2_util"
            ,"github.com/free5gc/http2_util"]
    }
}


class ImportMembers extends Entity {
    ImportMembers(){
        this.getPackage() instanceof CryptoPackages
    }

    string getPackageName(){
        result = getBasePackageFromImport(this.getPackage())
    }

    string getEntityQLType(){
        if this.getAQlClass() = "Method" then result = "Method"
        else if this.getAQlClass() = "DeclaredFunction" then result = "DeclaredFunction"
        else if this.getAQlClass() = "Function" then result = "Function"
        else if this.getAQlClass() = "Field" then result = "Field"
        else if this.getAQlClass() = "Variable" then result = "Variable"
        else if this.getAQlClass() = "StructLit" then result = "StructLit"
        else if this.getAQlClass() = "Constant" then result = "Constant"
        else if this.getAQlClass() = "DeclaredConstant" then result = "DeclaredConstant"
        else if this.getAQlClass() = "Type" then result = "Type"
        else if this.getAQlClass() = "DeclaredType" then result = "DeclaredType"
        else if this.getAQlClass() = "Label" then result = "Label"
        else if this.getAQlClass() = "DeclaredVariable" then result = "DeclaredVariable"
        else result = "Entity"
    }

    string getFileName(){
        if exists(File f | this.getDeclaration().getFile() = f) then 
            result = stripNFPath(this.getDeclaration().getFile().getRelativePath())
        else
            result = "Built-in"
    }

    // string getFileNameSDCore(){
    //     if exists(File f | this.getDeclaration().getFile() = f) then 
    //     result = stripNFPathSDCore(this.getDeclaration().getFile().getRelativePath())
    // else
    //     result = "Built-in"
    // }

    int getLineNum(){
        if exists(Location l | this.getDeclaration().getLocation() = l) then
            result = this.getDeclaration().getLocation().getStartLine()
        else
            result = -1
    }

    // Type getMembership(){
    //     result = this.(Field).getDeclaringType()
    //     or result = this.(Method).getReceiverType()
    //     or result = this.(Constant)
    // }

    
}