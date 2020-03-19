$script:adb = ""
$Script:apk = ""
$script:sn = ""

function Set-AndroidParameters {
    param (
        [String] $adb,
        [String] $apk,
        [String] $serialno
    )
    $script:adb=$adb
    $Script:apk=$apk
    $script:sn = $serialno
}
function Install-AndroidApk {
    param (
        [String] $apk
    )
    if( Test-Path -Path $apk){
        $p = Start-Process -FilePath $script:adb -ArgumentList "" 
    }
}
function Read-AndroidDeviceStatus {
    param (
        [string] $serialno
    )
    $temp =New-TemporaryFile
    $p = Start-Process -FilePath $script:adb -ArgumentList "-s $($serialno) get-state" -RedirectStandardOutput $temp -PassThru -NoNewWindow 
    $p.WaitForExit()
    $x = Get-Content $temp
    Remove-Item $temp
    return $x
}

function Read-AndroidDeviceProperty {
    param (
        [string] $serialno
    )
    $temp =New-TemporaryFile
    $p = Start-Process -FilePath $script:adb -ArgumentList "-s $($serialno) shell getprop" -RedirectStandardOutput $temp -PassThru -NoNewWindow 
    $p.WaitForExit()
    $x = Get-Content $temp
    Remove-Item $temp
    $r = @{}
    foreach($i in $x){
        if($i -match "^\[(\S+)\]: \[(\S+)\]$"){
            $r.Add($Matches[1], $Matches[2])
        }
    }
    return $r
}