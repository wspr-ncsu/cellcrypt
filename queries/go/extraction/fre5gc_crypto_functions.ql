import go
import utils

from Field f, Type t, Entity e, Function fc
where e.hasQualifiedName("hash", _)
and fileIsCoreMember(e.getAReference().getFile())
select e, e.getAReference()