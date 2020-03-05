$wd="C:\Tools\adb"
$adb="C:\Tools\adb\adb.exe"

function Get-UIXml() {
    $p = Start-Process -FilePath $adb -WorkingDirectory $wd -ArgumentList "shell uiautomator dump /data/local/tmp/dump.xml" -RedirectStandardOutput (Join-Path -Path $wd -ChildPath "stdout.txt") -PassThru -NoNewWindow
    $p.WaitForExit()
    Write-Host $p.ExitCode
    $x = Join-Path -Path $wd -ChildPath "dump.xml"
    $p = Start-Process -FilePath $adb -WorkingDirectory $wd -ArgumentList "pull /data/local/tmp/dump.xml $x" -RedirectStandardOutput (Join-Path -Path $wd -ChildPath "stdout.txt") -PassThru -NoNewWindow
    $p.WaitForExit()           
    [xml]$ret=Get-Content $x
    return $ret
}

$p = Start-Process -FilePath $adb -WorkingDirectory $wd -ArgumentList "devices" -RedirectStandardOutput (Join-Path -Path $wd -ChildPath "stdout.txt") -PassThru -NoNewWindow
$p.WaitForExit()
Write-Host $p.ExitCode

$p = Start-Process -FilePath $adb -WorkingDirectory $wd -ArgumentList "shell am start com.android.settings/com.android.settings.Settings\`$PrivacySettingsActivity" -RedirectStandardOutput (Join-Path -Path $wd -ChildPath "stdout.txt") -PassThru -NoNewWindow
$p.WaitForExit()
Write-Host $p.ExitCode

# $p = Start-Process -FilePath $adb -WorkingDirectory $wd -ArgumentList "shell uiautomator dump /data/local/tmp/dump.xml" -RedirectStandardOutput (Join-Path -Path $wd -ChildPath "stdout.txt") -PassThru
# $p.WaitForExit()
# Write-Host $p.ExitCode
# $x = Join-Path -Path $wd -ChildPath "dump.xml"
# $p = Start-Process -FilePath $adb -WorkingDirectory $wd -ArgumentList "pull /data/local/tmp/dump.xml $x" -RedirectStandardOutput (Join-Path -Path $wd -ChildPath "stdout.txt") -PassThru
# $p.WaitForExit()
# Write-Host $p.ExitCode
# [xml]$y = Get-Content $x
# first page
$y = Get-UIXml
$n = $y.SelectSingleNode("//node[@text='Factory data reset']")
if($null -eq $n) {
    Write-Host "Cannot find [Factory data reset] button"
    exit 1
}
Write-Host "Find [Factory data reset] button: $($n.bounds)"
if($n.bounds -match "\[(\d+),(\d+)\]\[(\d+),(\d+)\]"){
    $x1=$Matches.1 -as [int]
    $y1=$Matches.2 -as [int]
    $x1 += 10
    $y1 += 10
    $p = Start-Process -FilePath $adb -WorkingDirectory $wd -ArgumentList "shell input tap $($x1) $($y1)" -RedirectStandardOutput (Join-Path -Path $wd -ChildPath "stdout.txt") -PassThru -NoNewWindow
    $p.WaitForExit()   
}        

# second page
$y = Get-UIXml
$n = $y.SelectSingleNode("//node[@text='RESET PHONE']")
if($null -eq $n) {
    Write-Host "Cannot find [RESET PHONE] button"
    exit 1
}
Write-Host "Find [RESET PHONE] button: $($n.bounds)"
if($n.bounds -match "\[(\d+),(\d+)\]\[(\d+),(\d+)\]"){
    $x1=$Matches.1 -as [int]
    $y1=$Matches.2 -as [int]
    $x1 += 10
    $y1 += 10
    $p = Start-Process -FilePath $adb -WorkingDirectory $wd -ArgumentList "shell input tap $($x1) $($y1)" -RedirectStandardOutput (Join-Path -Path $wd -ChildPath "stdout.txt") -PassThru -NoNewWindow
    $p.WaitForExit()   
}        

# third page
$y = Get-UIXml
$n = $y.SelectSingleNode("//node[@text='DELETE ALL']")
if($null -eq $n) {
    Write-Host "Cannot find [DELETE ALL] button"
    exit 1
}
Write-Host "Find [DELETE ALL] button: $($n.bounds)"
if($n.bounds -match "\[(\d+),(\d+)\]\[(\d+),(\d+)\]"){
    $x1=$Matches.1 -as [int]
    $y1=$Matches.2 -as [int]
    $x1 += 10
    $y1 += 10
    $p = Start-Process -FilePath $adb -WorkingDirectory $wd -ArgumentList "shell input tap $($x1) $($y1)" -RedirectStandardOutput (Join-Path -Path $wd -ChildPath "stdout.txt") -PassThru -NoNewWindow
    $p.WaitForExit()   
}        
