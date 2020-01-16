$logfn=Join-Path -Path $env:APSTHOME -ChildPath ("Deploy-{0}.log" -f (Get-Date).ToString("yyyyMMdd"))
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
$x=[System.IO.Path]::Combine($env:ProgramData, "FutureDial")
Remove-Item -Recurse -Force -Path $x
Stop-Transcript