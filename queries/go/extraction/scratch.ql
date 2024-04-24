import go
import CryptoCustom
// import utils

// from ImportMembers e, Name ref
// where ref = e.getAReference()
// and fileIsCoreMember(ref.getFile())
// select e, ref, e.getEntityQLType(), e.getPackageName(), ref.getFile(), ref.getLocation().getStartLine()

// from ImportMembers e
// where not exists(Ident i | e.getDeclaration() = i)
// select e, e.getPackageName(), e.getFile()

// from DataFlow::CallNode c, ImportMembers i
// where c = i.(DeclaredFunction).getACall()
// and fileIsCoreMember(c.getFile())
// select 
// c.getFile()
class InsecureAlgPackages extends Package {
    InsecureAlgPackages(){
        this.getPath().matches([
            "crypto/des"
            ,"crypto/rc4"
            ,"golang.org/x/crypto/blowfish"
            ,"golang.org/x/crypto/cast5"
            ,"golang.org/x/crypto/tea"
            ,"golang.org/x/crypto/xtea"
            ,"crypto/sha1"
            ,"crypto/md5"
            ,"golang.org/x/crypto/MD4"
            ,"golang.org/x/crypto/ripemd160"

        ])
    }
}

from DataFlow::Node n
where n.(DataFlow::CallNode).getTarget().getName() = "NewCipher"
// and n.(DataFlow::CallNode).getTarget().getParameter(_).getName()="key"
select n