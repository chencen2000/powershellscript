$logfn=Join-Path -Path D:\projects -ChildPath ((Get-Date).ToString("yyyyMMdd")+".log")
Start-Transcript -Path $logfn -Append

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

Stop-Transcript