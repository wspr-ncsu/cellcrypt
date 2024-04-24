import go
// import semmle.go.dataflow.DataFlow
import CryptoCustom
import utils
// DataFlow::Node getArgumentsList(DataFlow::CallNode c){
//     result = rank[1](DataFlow::Node n | )
    
// }

from ImportMembers i, DataFlow::CallNode f, Type type,
string s
where 
i.getEntityQLType().matches(["DeclaredFunction","Method","Function"]) and
exists(Function func | f = func.getACall() and i = func | fileIsCoreMember(f.getFile()))
and if exists(f.getReceiver()) then (s = f.getReceiver().toString() and type = f.getReceiver().getType()) else (s = "None" and type instanceof NilLiteralType)
and f.getNumArgument() = 0
and not i.getName().matches(["Error", "Close"]) 
// and paraName = i.(DeclaredFunction).getParameter(argIndex).toString()
// and paraType = i.(DeclaredFunction).getParameterType(argIndex)
select
i.getQualifiedName() as functionQualifiedName
// ,i.getAReference()
,f.toString() as call
,f.getStartLine() as callLine
,getPath(f.getFile()) as callFile
,s.toString() as receiver
,type.toString() as receiverType
// ,type.getQualifiedName()
,"None" as argument
,"N/A" as argumentString
,"N/A" as argumentType
,"N/A" as argumentIndex
// ,paraName as parameterName
// ,paraType as parameterType
// ,f.getAnArgument().getExactValue()
