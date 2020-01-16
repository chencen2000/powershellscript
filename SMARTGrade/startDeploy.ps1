$fn=[System.IO.Path]::Combine($env:PROGRAMDATA, "Futuredial", "FDAcorn.exe")
Start-Process -FilePath $fn -ArgumentList "-UpdateEnv" -Wait