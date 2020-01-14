$fn=[System.IO.Path]::Combine($env:APPDATA, "Futuredial", "FDAcorn.exe")
Start-Process -FilePath $fn -ArgumentList "-UpdateEnv" -Wait