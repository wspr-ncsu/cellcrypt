import cpp
import CryptoCustom

/**
 * @name A2_InsecureSymmetric
 * @id a2-cpp
 * @kind problem
 * @problem.severity warning
 *  * Looks for references to insecure hash functions as defined in CryptoCustom
 */

from InsecureHashName hashname, FunctionCall c, string target
where c.getTarget().getName() = target  
and (target.matches("%"+hashname.toLowerCase()+"%") or target.matches("%"+hashname.toUpperCase()+"%"))
and not c.getTarget().getName().matches("%destroy%")
and c.getTarget().getFile() instanceof CryptoHeaders
select c as finding, 
"Insecure Hash Alg Found", 
c.getLocation().toString() as location, 
"Location"