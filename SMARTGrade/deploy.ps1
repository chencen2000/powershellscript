if( -not (Test-Path $env:APSTHOME)){
    Write-Host "No APSTHOME set."
    exit 1
}

$logfn=Join-Path -Path $env:APSTHOME -ChildPath ("Deploy-{0}.log" -f (Get-Date).ToString("yyyyMMdd"))
Start-Transcript -Path $logfn -Append

$x=Import-Module ([System.IO.Path]::combine($env:APSTHOME, "Modules", "PsIni")) -PassThru
if($null -eq $x){
    Write-Host "Fail to load INI module."
    exit 1
}

$x=[System.IO.Path]::Combine($env:APSTHOME,"UserData", "Mission", "UsedPhone")
New-Item -Path $x -ItemType Directory 
$x=Join-Path -Path $x -ChildPath "MissionManager.ini"
$dp_local=[ordered]@{}
if(Test-Path $x){
    $dp_local=Get-IniContent $x
}
Write-Host ($dp_local | Out-String)
if( $dp_local.Contains("productNum")){
    Write-Host ($dp_local["productNum"] | Out-String)
}

function Find-DeviceMaker($maker){
    $found = $false
    $idx=0
    $num = $dp_local["ProductNum"]["Num"] -as [int]
    for($i=0; $i -lt $num; $i++){
        $m = $dp_local["Product$i"]["ProductName"]
        if($m -eq $maker){
            $found=$true
            $idx=$i
            break
        }
    }
    return @{found=$found; index=$idx}
}
function Find-DeviceModel($productIndex, $model){
    $found = $false
    $idx=0
    $num = $dp_local["Product$productIndex"]["TypeNum"] -as [int]
    for($i=0; $i -lt $num; $i++){
        $m = $dp_local["Product$i"]["Type_$($i)_Name"]
        if($m -eq $model){
            $found=$true
            $idx=$i
            break
        }
    }
    return @{found=$found; index=$idx}
}
function Find-DeviceColor($productIndex,$modelIndex, $color){
    $found = $false
    $idx=0
    $num = $dp_local["Product$productIndex"]["Type_$($modelIndex)_ColorNum"] -as [int]
    for($i=0; $i -lt $num; $i++){
        $m = $dp_local["Product$productIndex"]["Type_$($modelIndex)_ColorNo_$($i)_Name"]
        if($m -eq $color){
            $found=$true
            $idx=$i
            break
        }
    }
    return @{found=$found; index=$idx}
}
function Add-DeviceColor($productIndex, $modelIndex, $info){
    $num = $dp_local["Product$productIndex"]["Type_$($modelIndex)_ColorNum"] -as [int]
    $dp_local["Product$productIndex"]["Type_$($modelIndex)_ColorNo_$($num)_ID"] = $num
    $dp_local["Product$productIndex"]["Type_$($modelIndex)_ColorNo_$($num)_Name"] = $info["Color"]
    $dp_local["Product$productIndex"]["Type_$($modelIndex)_ColorNo_$($num)_BGTwice"] = $false;
    $dp_local["Product$productIndex"]["Type_$($modelIndex)_ColorNum"] = $num+1
}
function Restore-DeviceProfile ($dppackage){
    Write-Host "Restore-DeviceProfile: $($dppackage.Fullname)"
    if($dppackage.Exists){
        $temp = Join-Path -Path $env:TEMP -ChildPath "dptemp"
        Remove-Item -Recurse -Force $temp
        Expand-Archive -Path $dppackage.FullName -DestinationPath $temp
        $info = Get-IniContent (Join-Path -Path $temp -ChildPath "info.ini")
        Write-Host ($info["information"] | Out-String)
        $maker=Find-DeviceMaker $info["information"]["maker"]
        if($maker.found){
            # found model
            $model = Find-DeviceModel $maker.index $info["information"]["model"]
            if($model.found){
                # found model
                $color = Find-DeviceColor $maker.index $model.index $info["information"]["color"]
                if($color.found){
                    # found color
                    # just copy the content to folder
                }
                else{
                    # not found need create new color
                    Add-DeviceColor $maker.index $model.index $info["information"]
                }
            }
            else{
                # not found need create new model

            }
        }
        else{
            # not foun need create new one
        }

    }
}


Write-Host "Script root = $PSScriptRoot"
$downloadTemp=[System.IO.Path]::Combine($env:ProgramData, "FutureDial", "FDDownloadTools", "DownloadTemp")
$dpfolder=Join-Path $downloadTemp -ChildPath "deviceprofile"
Write-Host "Device profile download path = $dpfolder"

if( Test-Path $dpfolder){
    $dp_packages=Get-ChildItem -Path $dpfolder
    Write-Host "Device profile packages = $dp_packages"
    if($dp_packages.Count -gt 0){
        foreach($fn in $dp_packages){
            Restore-DeviceProfile $fn
        }
        # Out-IniFile -FilePath 
    }
}


Stop-Transcript
