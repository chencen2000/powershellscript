Import-Module Microsoft.PowerShell.Security
$passcode=ConvertTo-SecureString "cmc1234!" -AsPlainText -Force
$dcuser=New-Object System.Management.Automation.PSCredential("cmc", $passcode)

function get_alldocuments($collName){
    $data=[System.Collections.ArrayList]@()
    $pagesize=1000
    $q=@{page=0; pagesize=$pagesize}
    do{
        $q["page"] +=1
        $res=Invoke-RestMethod "http://dc.futuredial.com/cmc/$collName" -Credential $dcuser -Body $q
        if($null -ne $res){
            if($res._returned -gt 0){
                $data.AddRange($res._embedded.doc)
            }
            if($res._returned -lt $pagesize){
                break;
            }

        }
    } while($true);
    # $data | convertto-json | Out-Host
    return $data
}
# $x=@{key="value";key2="values"}
# $Response.Json(($x|ConvertTo-Json))
Write-Host $Request.Query
$all_data=get_alldocuments "SG_GeneralDPInfo"
$Response.Json(($all_data|ConvertTo-Json))