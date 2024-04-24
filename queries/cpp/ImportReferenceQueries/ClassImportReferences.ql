import cpp
import CryptoCustom

from CryptoHeaders h, Class s, Element e
where s.getADeclaration().getFile() = h
and e = s.getATypeNameUse()
and not e.getFile() instanceof HeaderFile
and not s instanceof Struct
select s as entity
,"Class" as entityType
,h.getBaseName() as entityPackage
,e as reference
,e.getFile() as referenceLocation
,e.getLocation().getStartLine() as lineNum