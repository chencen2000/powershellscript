# $logfn=Join-Path -Path D:\test -ChildPath ((Get-Date).ToString("yyyyMMdd")+".log")
# Start-Transcript -Path $logfn -Append

# Stop-Transcript
if( [System.Diagnostics.EventLog]::SourceExists("test") -eq $false) {
    New-EventLog -LogName Application -Source "test"
}
Write-EventLog -logname "Application" -Source "test" -EventId 1 -EntryType Information -Message "it is $([system.datetime]::now.tostring())"