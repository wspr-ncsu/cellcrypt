import cpp
import CryptoCustom

from CryptoHeaders h, Struct s, Element e, string hStr
where s.getADeclaration().getFile() instanceof CryptoHeaders
and
hStr = s.getADeclaration().getFile().getBaseName()
and e = s.getATypeNameUse()
and not e.getFile() instanceof HeaderFile
select s as entity
,"Struct" as entityType
,hStr as entityPackage
,e as reference
,e.getFile() as referenceLocation
,e.getLocation().getStartLine() as lineNum