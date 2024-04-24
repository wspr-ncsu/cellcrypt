import go
import CryptoCustom
// import utils

from ImportMembers e
select e as entity,
e.getEntityQLType() as entityType, 
e.getPackageName() as entityPackage,
"Source" as referenceType, 
e.getFileName() as referenceLocation,
e.getLineNum() as lineNum