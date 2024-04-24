import go

// from ImportSpec is, string s
// where s = is.getPath().regexpReplaceAll("github.com/omec-project/(amf|smf|ausf|pcf|udm|udr|upf|nssf|nrf)/", "")
// and not s.matches(["consumer","eventexposure","producer",""])
// select is.getPath().regexpReplaceAll("github.com/omec-project/(amf|smf|ausf|pcf|udm|udr|upf|nssf|nrf)/", "")


// from ImportSpec is, string s
// where (not is.getPath().regexpMatch("^github.com/omec-project/(?>amf|smf|ausf|pcf|udm|udr|upf|nssf|nrf)") and s = is.getPath())
// or
// (s=is.getPath().regexpReplaceAll("^github.com/omec-project/(?>amf|smf|ausf|pcf|udm|udr|upf|nssf|nrf)/(.+\\..+/.*)", ""))
// select s

from ImportSpec is, string s
where 
(not is.getPath().regexpMatch("^github.com/(?>omec-project|free5gc)/(?>amf|smf|ausf|pcf|udm|udr|upf|nssf|nrf)/.*") and s = is.getPath())
or
(s=is.getPath().regexpReplaceAll("^github.com/(?>omec-project|free5gc)/(?>amf|smf|ausf|pcf|udm|udr|upf|nssf|nrf)/", ""))

select s