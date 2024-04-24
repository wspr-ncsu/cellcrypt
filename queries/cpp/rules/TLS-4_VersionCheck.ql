import cpp
import CryptoCustom


from string s, string loc
where exists(EnumConstantAccess e, FunctionCall c | c.getTarget().getName().matches(["SSL_set_min_proto_version", "SSL_CTX_set_min_proto_version", "ssl_ctx_set_proto_versions"])
    and 
    not c.getArgument(_).toString().toInt() < 771 
    | s = "Invalid TLS Versions Disabled" and loc = c.getLocation().toString())
    or
    exists(EnumConstantAccess ssl, 
            EnumConstantAccess tls1, EnumConstantAccess tls11 |
            ssl.getTarget().toString().matches("SSL_OP_NO_SSL%") 
            and tls1.getTarget().toString() = "TLS_OP_NO_TLSv1"
            and tls11.getTarget().toString() = "TLS_OP_NO_TLSv1_1" | s = "Invalid TLS Versions Disabled" and loc = ssl.getLocation().toString())
select s as finding, 
"This is a Negative Result", 
loc as location, 
"Location"
