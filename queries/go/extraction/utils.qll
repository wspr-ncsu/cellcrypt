private import go

predicate fileIsCoreMember(File f){
    if f.getRelativePath().regexpMatch(".+/.+\\..+/.*") then ( 
        f.getRelativePath().regexpMatch(".+/.+\\..+/(free5gc|omec-project)/.*") 
    )
    else any()
}

string getBasePackageFromImport(Package p){
exists(string s |
(not p.getPath().regexpMatch("^github.com/(?>omec-project|free5gc)/(?>amf|smf|ausf|pcf|udm|udr|upf|nssf|nrf|go-upf|n3iwf)/.*") and s = p.getPath())
or
(s=p.getPath().regexpReplaceAll("^github.com/(?>omec-project|free5gc)/(?>amf|smf|ausf|pcf|udm|udr|upf|nssf|nrf|go-upf|n3iwf)/", ""))
| result = s)
}

bindingset[s]
string stripNFPath(string s){
    if s.regexpMatch("(?:^NFs/\\w+/.*)") then
        result = s.regexpReplaceAll("(?:^NFs/\\w+/)", "")
    else if s.regexpMatch("(?:^sd-core/\\w+/.*)") then
        result = s.regexpReplaceAll("(?:^sd-core/\\w+/)", "")
    else
        result = s
}

string getPath(File f){
    if exists(f.getRelativePath()) then result = f.getRelativePath().toString()
    else result = f.getAbsolutePath().toString()
}

// bindingset[s]
// string stripNFPathSDCore(string s){
//     result = s.regexpReplaceAll("(?:^sd-core/\\w+/)", "")
// }

predicate isDefineNode(DataFlow::Node node){

    // Checks if node is a child of a DefineStmt update, or in other words
    // is a direct child of an :=
    exists(DefineStmt ds, DataFlow::PostUpdateNode p | 
        ds.getAChildExpr() = p.getPreUpdateNode().asExpr()
        | node = p.getASuccessor()) 
}