import go
import utils
import CryptoCustom


/**
 * @name A3_InsecureSymmetric
 * @id a3-go
 * @kind problem
 * @problem.severity warning
 */

from CallExpr f
where (f.getTarget().getName().matches("Generate%Key%") 
        and f.getTarget().getPackage().getName().matches("crypto/rsa")
        and f.getArgument(1).getIntValue() < 2048/8)
    or f.getTarget().hasQualifiedName("crypto/dsa", _)
select f as finding, 
"Insecure Asymm Usage",
f.getLocation().toString() as location,
"Location"