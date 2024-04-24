import go
import semmle.go.dataflow.DataFlow
import CryptoCustom
import utils

class EmptyParameter extends Parameter {
    EmptyParameter(){exists(Parameter p, Function m | m.getParameter(0) = p and m.getName() = "action" 
     and (p.getFunction().getFile().getStem() = "amf" 
            or p.getFunction().getFile().getRelativePath().matches("%amf/main.go")) 
        | this = p)}
    
    override Type getType(){
        result instanceof NilLiteralType
    }

    override int getIndex(){
        result = -2
    }

    override string toString(){
        result = "No Parameters"
    }
}

Parameter getArgumentsList(ImportMembers i){
    if exists(Parameter p | p = i.(DeclaredFunction).getAParameter()) then
        result = i.(DeclaredFunction).getAParameter()
    else
     result instanceof EmptyParameter
    
}


string getComment(ImportMembers i){
    if exists(i.(DeclaredFunction).getFuncDecl().getDocumentation()) then (
        result = concat(string s | s = i.(DeclaredFunction).getFuncDecl().getDocumentation().getComment(_).getText())
    ) else result = "No Doc Comment"
    
}


from ImportMembers i, Parameter p, DataFlow::CallNode f, int index
where 
exists(Function func | f = func.getACall() and i = func | fileIsCoreMember(f.getFile()))
and p = getArgumentsList(i)
and index = p.getIndex()
select
i.getQualifiedName() as functionQualifiedName
// i.(DeclaredFunction).getParameterType(_).toString()
,getComment(i) as comment
,p.toString() as paraName
,p.getType().toString() as paraType
,index.toString() as paraIndex