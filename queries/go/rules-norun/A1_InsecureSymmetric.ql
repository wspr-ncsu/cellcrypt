import go
import utils

/**
 * @name A1_InsecureSymmetric
 * @id a1-go
 * @kind problem
 * @problem.severity warning
 */

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
    }
}

from InsecureAlgPackages p, CallExpr c
where c.getTarget().getPackage() instanceof InsecureAlgPackages
and fileIsCoreMember(c.getFile())
select c as finding, 
"Insecure Symmetric Alg Found", 
c.getLocation().toString() as location, 
"Location"