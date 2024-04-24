
import go

predicate fileIsCoreMember(File f){
    if f.getRelativePath().regexpMatch(".*/.+\\..+/.*") then ( 
        f.getRelativePath().regexpMatch(".*/.+\\..+/fre5gc/.*") 
    )
    else any()
}


from ImportSpec is, string s
where 
((not is.getPath().regexpMatch("^github.com/(?>omec-project|free5gc)/(?>amf|smf|ausf|pcf|udm|udr|upf|nssf|nrf|go-upf|n3iwf)/.*") and s = is.getPath())
or
(s=is.getPath().regexpReplaceAll("^github.com/(?>omec-project|free5gc)/(?>amf|smf|ausf|pcf|udm|udr|upf|nssf|nrf|go-upf|n3iwf)/", "")))
and s = "hash"
and fileIsCoreMember(is.getFile())
select s, is, is.getFile().getRelativePath()