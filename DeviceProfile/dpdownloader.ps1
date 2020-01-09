$logfn=Join-Path -Path D:\test -ChildPath ("dpd_"+(Get-Date).ToString("yyyyMMdd")+".log")
Start-Transcript -Path $logfn -Append
Import-Module Microsoft.PowerShell.Security
$passcode=ConvertTo-SecureString "cmc1234!" -AsPlainText -Force
$dcuser=New-Object System.Management.Automation.PSCredential("cmc", $passcode)
$machineName=$env:COMPUTERNAME
Write-Host "Start get device profile list for machine $machineName"

# $q=@{filter=(@{uuid="SMARTGrade_Test011"} | ConvertTo-Json -Compress)}
$dps=$null
$q=@{filter=(@{uuid="SMARTGrade_Test01"} | ConvertTo-Json -Compress)}
$res=Invoke-RestMethod -Uri http://dc.futuredial.com/cmc/SG_Machines/ -Credential $dcuser -Body $q
if ($res._returned -gt 0){
    if($res._embedded.doc.Length -gt 0){
        $dps=$res._embedded.doc[0].DeviceProfiles
    }
}

if($null -ne $dps){
    foreach($dp in $dps){
        Write-Host $dp.uuid
    }
}
Stop-Transcript