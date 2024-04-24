import cpp
import CryptoCustom

from EnumConstantAccess e
where e.getTarget().toString() = "SSL_VERIFY_NONE"
    or e.getTarget().toString() = "GN_VERIFY_DISABLE_CA_SIGN"
    or exists(FunctionCall c | c.getArgument(_) = e 
        and e.getTarget().toString() = "CURLOPT_SSL_VERIFYPEER" 
        and c.getArgument(_).getValue().toInt() = 0)
select e as finding, 
"Disabled TLS Cert Check Found", 
e.getLocation().toString() as location, 
"Location"