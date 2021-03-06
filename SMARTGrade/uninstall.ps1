$path = [System.Environment]::CurrentDirectory
if(-not [System.String]::IsNullOrEmpty($PSScriptRoot)){
    $path = $PSScriptRoot
}
$logfn=Join-Path -Path $path -ChildPath ((Get-Date).ToString("yyyyMMdd")+".log")
Start-Transcript -Path $logfn -Append

### kill download process first
$x = Get-Process -Name "HydraDownloaderUI","HydraDownloader","hydraDeploy"
if($null -ne $x){
    Stop-Process -InputObject $x
}

$x = Join-Path ([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::CommonDesktopDirectory)) "SMARTGrade.lnk"
if(Test-Path $x){
    Remove-Item -Path $x
}
$x = Join-Path ([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::CommonStartup)) "SMARTGradePreparation.lnk"
if(Test-Path $x){
    Remove-Item -Path $x
}
$apsthome=$env:apsthome
if (Test-Path $apsthome) {
    Remove-Item -Recurse -Force -Path $apsthome
}
$x=[System.IO.Path]::Combine($env:ProgramData, "FutureDial")
Remove-Item -Recurse -Force -Path $x
Stop-Transcript