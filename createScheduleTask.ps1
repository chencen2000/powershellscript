#Requires -RunAsAdministrator

function  test {

    $Action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument '-ExecutionPolicy Bypass -NonInteractive -NoLogo -NoProfile -File "C:\projects\github\powershellscript\info.ps1"'
    $Trigger = New-ScheduledTaskTrigger -AtStartup 
    $Trigger.Repetition.Interval = "PT10M"
    $Settings = New-ScheduledTaskSettingsSet
    $Task = New-ScheduledTask -Action $Action -Trigger $Trigger -Settings $Settings
    Register-ScheduledTask -TaskName 'My PowerShell Script' -InputObject $Task -User "NT AUTHORITY\SYSTEM"
}

$Action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument '-ExecutionPolicy Bypass -NonInteractive -WindowStyle Hidden -NoLogo -NoProfile -File "C:\projects\github\powershellscript\info.ps1"'
$repeat = (New-TimeSpan -Minutes 5)
$Trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).Date -RepetitionInterval (New-TimeSpan -Minutes 5)
$Settings = New-ScheduledTaskSettingsSet
$t = Register-ScheduledTask -Action $Action -Trigger $Trigger -TaskName "test" -Description "test powershell" -Settings $Settings
Start-ScheduledTask -InputObject $t
