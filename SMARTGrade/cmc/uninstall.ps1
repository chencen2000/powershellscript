param(
	[string]$dir
)

#Requires -RunAsAdministrator

if ([System.String]::IsNullOrEmpty($dir)) {
    Write-Output "the target dir is missing."
    $dir=Read-Host "Please enter the target dir"
}

Write-Output "target dir: $dir"

if (Test-Path $dir) {
    # remove folder c:\programdata\futuredial
    $x = [System.IO.Path]::Combine([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::CommonApplicationData),"Futuredial")
    if (Test-Path $x){
        Remove-Item -Recurse -Force $x
    }
    # remove shortcut
    $x=[System.IO.Path]::Combine([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::CommonStartup),"SMARTGradeDownlaoder.lnk")
    Remove-Item $x
    $x=[System.IO.Path]::Combine([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::CommonDesktopDirectory),"SMARTGrade.lnk")
    Remove-Item $x
    # cleam APSTHOME
    [System.Environment]::SetEnvironmentVariable("APSTHOME","", [System.EnvironmentVariableTarget]::Machine)
    Remove-Item -Recurse -Force $dir
}

