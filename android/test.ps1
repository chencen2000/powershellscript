$wd="C:\projects\temp"
# $adb="C:\Tools\Android\platform-tools\adb.exe"
function Get-DeviceMakerModel {
    $p = Start-Process -FilePath $adb -WorkingDirectory $wd -ArgumentList "shell getprop" -RedirectStandardOutput (Join-Path -Path $wd -ChildPath "stdout.txt") -PassThru -NoNewWindow
    $p.WaitForExit()

}

$x = Join-Path -path $PSScriptRoot -ChildPath "AndroidDevice.ps1" 
# $x = Join-Path -path $PSScriptRoot -ChildPath "AndroidModule.ps1" 
$m = Import-Module $x -PassThru
# if($null -ne $m){
#     # Set-Adb "C:\Tools\adb\adb.exe"
#     Set-AndroidParameters -adb "C:\Tools\adb\adb.exe" -apk "C:\ProgramData\Futuredial\CMC\phonedll\PST_ARD_UNIVERSAL_USB_FD\resource\fdbox721.apk"
#     $x = Read-AndroidDeviceStatus "ZY2227TXHF"
#     $x = Read-AndroidDeviceProperty "ZY2227TXHF"
#     Remove-Module -Name AndroidModule
# }

if($null -ne $m){
    $dev = [AndroidDevice]::new("C:\Tools\adb\adb.exe")
    $x = $dev.getDeviceStatus()
    if($x -eq "device"){
        if(-not $dev.checkApk("com.futuredial.fdbox721")){
            $x = $dev.installApk("C:\ProgramData\Futuredial\CMC\phonedll\PST_ARD_UNIVERSAL_USB_FD\resource\fdbox721.apk")
        }
        $x = $dev.getDeviceProperties()
        $y = $dev.getDevicePropertiesFromApk()
    }

    $dev=$null
    Remove-Module $m.Name
}

