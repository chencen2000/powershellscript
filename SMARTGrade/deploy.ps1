if( -not (Test-Path $env:APSTHOME)){
    Write-Host "No APSTHOME set."
    exit 1
}

$logfn=Join-Path -Path $env:APSTHOME -ChildPath ("Deploy-{0}.log" -f (Get-Date).ToString("yyyyMMdd"))
Start-Transcript -Path $logfn -Append
function deploy-deviceprofile ($dppackage){
    if(Test-Path $dppackage){
        $temp = Join-Path -Path $env:TEMP -ChildPath "dptemp"
        Remove-Item -Recurse -Force $temp
        Expand-Archive -Path $dppackage -DestinationPath $temp
        $info = Get-IniContent (Join-Path -Path $temp -ChildPath "info.ini")
        Write-Host $info

    }
}


Write-Host "Script root = $PSScriptRoot"
$downloadTemp=[System.IO.Path]::Combine($env:ProgramData, "FutureDial", "FDDownloadTools", "DownloadTemp")
$dpfolder=Join-Path $downloadTemp -ChildPath "deviceprofile"
Write-Host "Device profile download path = $dpfolder"

$x=Import-Module ([System.IO.Path]::combine($env:APSTHOME, "Modules", "PsIni")) -PassThru
if($null -eq $x){
    Write-Host "Fail to load INI module."
    exit 1
}

if( Test-Path $dpfolder){
    $dp_packages=Get-ChildItem -Path $dpfolder
    Write-Host "Device profile packages = $dp_packages"
    foreach($fn in $dp_packages){
        deploy-deviceprofile $fn
    }
}


Stop-Transcript
