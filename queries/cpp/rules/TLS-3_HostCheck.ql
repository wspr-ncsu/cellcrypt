import cpp
import CryptoCustom

from EnumConstantAccess e
where e.getTarget().toString() = "SSL_VERIFY_NONE"
    or e.getTarget().toString() = "GN_VERIFY_DISABLE_CRL_CHECK%"
    or exists(FunctionCall c | c.getArgument(_) = e 
        and e.getTarget().toString() = "CURLOPT_SSL_VERIFYHOST" 
        and c.getArgument(_).getValue().toInt() = 0)
select e as finding, 
"Disabled TLS Host Check Found", 
e.getLocation().toString() as location, 
"Location"