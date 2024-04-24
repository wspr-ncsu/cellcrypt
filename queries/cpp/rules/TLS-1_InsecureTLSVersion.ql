import cpp
import CryptoCustom




from EnumConstantAccess e, InsecureSymmetricName sym, InsecureHashName hash
where e.getTarget().toString().matches("%TLS%"+sym.toUpperCase()+"%")
    or e.getTarget().toString().matches("%TLS%"+hash.toUpperCase()+"%")
select e as finding, 
"Insecure TLS Cipher Found", 
e.getLocation().toString() as location, 
"Location"