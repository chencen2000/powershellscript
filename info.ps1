$logfn=Join-Path -Path D:\test -ChildPath ((Get-Date).ToString("yyyyMMdd")+".log")
Start-Transcript -Path $logfn -Append

Stop-Transcript