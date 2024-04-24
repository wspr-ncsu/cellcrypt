import cpp

import CryptoCustom


/**
 * @name A1_InsecureSymmetric
 * @id a1-cpp
 * @kind problem
 * @problem.severity warning
 * Looks for references to insecure symmetric functions as defined in CryptoCustom
 */

from InsecureSymmetricName sym, FunctionCall c, string target
where c.getTarget().getName() = target  
and (target.matches("%"+sym.toLowerCase()+"%") or target.matches("%"+sym.toUpperCase()+"%"))
and not c.getTarget().getName().matches("%destroy%")
and c.getTarget().getFile() instanceof CryptoHeaders
select c as finding, 
"Insecure Symmetric Alg Found", 
c.getLocation().toString() as location, 
"Location"