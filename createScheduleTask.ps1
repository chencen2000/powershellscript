$Action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument '-ExecutionPolicy Bypass -NonInteractive -NoLogo -NoProfile -File "D:\projects\repos\powershellscript\info.ps1"'
$Trigger = New-ScheduledTaskTrigger -AtStartup 
$Trigger.Repetition.Interval = "PT10M"
$Settings = New-ScheduledTaskSettingsSet
$Task = New-ScheduledTask -Action $Action -Trigger $Trigger -Settings $Settings
Register-ScheduledTask -TaskName 'My PowerShell Script' -InputObject $Task -User "NT AUTHORITY\SYSTEM"

