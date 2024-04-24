import cpp
import CryptoCustom

from CryptoHeaders h, Function s, Element e
where s.getADeclaration().getFile() = h
and e = s.getACallToThisFunction()
and not e.getFile() instanceof HeaderFile
select s as entity
,"Function" as entityType
,h.getBaseName() as entityPackage
,e as reference
,e.getFile() as referenceLocation
,e.getLocation().getStartLine() as lineNum