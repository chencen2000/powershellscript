$wd="C:\Tools\adb"
$adb="C:\Tools\adb\adb.exe"

$p = Start-Process -FilePath $adb -WorkingDirectory $wd -ArgumentList @("devices") -RedirectStandardOutput (Join-Path -Path $wd -ChildPath "stdout.txt") -PassThru
$p.WaitForExit()
Write-Host $p.ExitCode

$p = Start-Process -FilePath $adb -WorkingDirectory $wd -ArgumentList @("shell","am","start",("com.android.settings/.Settings$"+"PrivacySettingsActivity")) -RedirectStandardOutput (Join-Path -Path $wd -ChildPath "stdout.txt") -PassThru
$p.WaitForExit()
Write-Host $p.ExitCode
