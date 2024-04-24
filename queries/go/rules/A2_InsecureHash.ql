import go
import utils
import CryptoCustom

/**
 * @name A2_InsecureSymmetric
 * @id a2-go
 * @kind problem
 * @problem.severity warning
 */

from CryptoCustom::InsecureHashPackages p, CallExpr c
where c.getTarget().getPackage() instanceof CryptoCustom::InsecureHashPackages 
and fileIsCoreMember(c.getFile())
select c as finding, 
"Insecure Hash Alg Found", 
c.getLocation().toString() as location, 
"Location"