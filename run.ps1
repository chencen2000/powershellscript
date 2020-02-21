$x = @{_id = "521eb3dd-47f0-40ef-9b54-30466dfe6cc7" } 
$x = $x | ConvertTo-Json -Compress
$q = @{criteria=$x}
$ok = Invoke-RestMethod -UseBasicParsing -Uri "https://ps.futuredial.com/profiles/clients/_find" -Body $q
if(($ok.ok -eq 1) -and ($ok.results.Length -eq 1) ){
    $c=@{}
    $ok.results[0] | Get-Member -MemberType *Property | % {
        $c.($_.name) = $ok.results[0].($_.name); 
    } 
    $c.Add("company", $c["companyid"])
    $c.Add("site", $c["siteid"])
    $c.Add("pcname", [System.Environment]::MachineName)
    $c.Add("macaddr", (Get-CimInstance -class Win32_ComputerSystemProduct).uuid)
    $req = @{client=$c; sync=@{status=@{}}; protocol="3.0"}
    $s = $req | ConvertTo-Json
    Write-Output $s
    $res = Invoke-RestMethod -UseBasicParsing -Method Post -uri "http://cmcqa.futuredial.com/ws/update/" -Body $s -ContentType "application/json"
    $s = $res | ConvertTo-Json 
    Write-Output $s
}