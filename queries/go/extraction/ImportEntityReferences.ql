import go
import CryptoCustom
// import utils

from ImportMembers e, Name ref
where ref = e.getAReference()
and fileIsCoreMember(ref.getFile())
// and e.getEntityQLType() = "Entity"
select e as entity,
e.getEntityQLType() as entityType, 
e.getPackageName() as entityPackage,
ref as reference, 
ref.getFile() as referenceLocation,
ref.getLocation().getStartLine() as lineNum