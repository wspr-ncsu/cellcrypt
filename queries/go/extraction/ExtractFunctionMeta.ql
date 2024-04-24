import go
// import semmle.go.dataflow.DataFlow
import CryptoCustom
import utils
// DataFlow::Node getArgumentsList(DataFlow::CallNode c){
//     result = rank[1](DataFlow::Node n | )
    
// }

from ImportMembers i, DataFlow::CallNode f, Type type, DataFlow::ArgumentNode arg, Type argType, int argIndex,
string s, string argString
where 
i.getEntityQLType().matches(["DeclaredFunction","Method","Function"]) and
exists(Function func | f = func.getACall() and i = func | fileIsCoreMember(f.getFile()))
and if exists(f.getReceiver()) then (s = f.getReceiver().toString() and type = f.getReceiver().getType()) else (s = "None" and type instanceof NilLiteralType)
and arg = f.getAnArgument() and argType = arg.getType()
and arg.argumentOf(f.asExpr(), argIndex)
and if arg.asExpr() instanceof SelectorExpr then 
            (argString = arg.asExpr().(SelectorExpr).getBase().toString() + "." + arg.asExpr().(SelectorExpr).getSelector().toString())
        else argString = arg.toString()
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
,arg.toString() as argument
,argString as argumentString
,argType.toString() as argumentType
,argIndex.toString() as argumentIndex
// ,paraName as parameterName
// ,paraType as parameterType
// ,f.getAnArgument().getExactValue()