
param (
    [Parameter()]
    [int]
    $port
)

if($port -eq 0){
    $port = 8080
}

$x=[System.IO.Path]::Combine($PSScriptRoot, "Modules", "Polaris")
$y=Import-Module -Name $x -Force -PassThru
if($null -eq $y){
    Write-Host "Fail to load Polaris Module."
    exit 1
}
New-PolarisGetRoute -path "/" -Scriptblock{
    $Response.Send('Device Manager Running!');
}

New-PolarisGetRoute -path "/deviceprofilelist" -ScriptPath .\Scripts\handle_deviceprofilelist.ps1

$own=$false
$quit=[System.Threading.EventWaitHandle]::new($false, [System.Threading.EventResetMode]::AutoReset, "DeviceManagerServer", [ref]$own)
$app = Start-Polaris -Port $port
# $quit.WaitOne()
while($app.Listener.IsListening){
    # Wait-Event callbackcomplete
    if($quit.WaitOne(10)){
        break
    }
}
Stop-Polaris 