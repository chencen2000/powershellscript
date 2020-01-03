# powershellscript

https://raw.githubusercontent.com/chencen2000/powershellscript/master/test.xml


Run powershell script from cmd

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/chencen2000/powershellscript/master/test.ps1'))"

run powershell script from powershell

Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/chencen2000/powershellscript/master/test.ps1'))

serial no:
356209ef-42b5-460f-8711-2a5bbc9a3d7f

