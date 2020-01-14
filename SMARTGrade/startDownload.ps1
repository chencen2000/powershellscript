$fn=Join-Path -Path $env:APSTHOME -ChildPath "FDAcorn.exe"
Start-Process -FilePath $fn -ArgumentList "-StartDownload"