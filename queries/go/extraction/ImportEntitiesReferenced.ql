import go
import CryptoCustom
// import utils

from ImportMembers e
where exists(Name n | n = e.getAReference() | fileIsCoreMember(n.getFile()))
select e as entity,
e.getEntityQLType() as entityType, 
e.getPackageName() as entityPackage,
"Source" as referenceType, 
e.getFileName() as referenceLocation,
e.getLineNum() as lineNum1