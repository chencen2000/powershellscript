if( -not (Test-Path $env:APSTHOME)){
    Write-Host "No APSTHOME set."
    exit 1
}

$logfn=Join-Path -Path $env:APSTHOME -ChildPath ("Deploy-{0}.log" -f (Get-Date).ToString("yyyyMMdd"))
Start-Transcript -Path $logfn -Append

# import psini module
$x=Import-Module ([System.IO.Path]::combine($env:APSTHOME, "Modules", "PsIni")) -PassThru
if($null -eq $x){
    Write-Host "Fail to load INI module."
    exit 1
}

<###
$env:APSTHOME\FDAutoUpdate.ini
[config]
status=12 
###>
$x = Get-IniContent -FilePath (Join-Path -Path $env:APSTHOME -ChildPath "FDAutoUpdate.ini")
if(($null -eq $x) -or (-not $x.Contains("config")) -or (-not $x["config"].Contains("status")) -or ($x["config"]["status"] -ne 12)){
    exit 12
}

$x=[System.IO.Path]::Combine($env:ProgramData,"FutureDial","FDDownloadTools","SyncStatus.json")
$syncstatus = Get-Content $x | ConvertFrom-Json
$clientStatus = Get-Content (Join-Path -Path $env:APSTHOME -ChildPath "clientstatus.json") | ConvertFrom-Json

if($null -eq $syncstatus.deviceprofile ){
    Write-Host "Device profile element not found in $x"
    Start-CMCDeploy
    exit 1
}
if($syncstatus.deviceprofile.filelist.Count -eq 0){
    Write-Host "Device profile element has no more items in $x"
    Start-CMCDeploy
    exit 1
}


$x=[System.IO.Path]::Combine($env:APSTHOME,"UserData", "Mission", "UsedPhone")
New-Item -Path $x -ItemType Directory 
$missionManagerIni=Join-Path -Path $x -ChildPath "MissionManager.ini"
$dp_local=[ordered]@{}
if(Test-Path $missionManagerIni){
    $dp_local=Get-IniContent $missionManagerIni
}
Write-Host ($dp_local | Out-String)
if( $dp_local.Contains("productNum")){
    Write-Host ($dp_local["productNum"] | Out-String)
}
else{
    $dp_local["ProductNum"] = [ordered]@{"Num"=0}
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
        $m = $dp_local["Product$productIndex"]["Type_$($i)_Name"]
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
    return $num
}
function Add-DeviceModel($productIndex, $info){
    $num = $dp_local["Product$productIndex"]["TypeNum"] -as [int]
    $dp_local["Product$productIndex"]["Type_$($num)_ID"] = $num
    $dp_local["Product$productIndex"]["Type_$($num)_Name"] = $info["Model"]
    $dp_local["Product$productIndex"]["Type_$($num)_Width"] = $info["Width"]
    $dp_local["Product$productIndex"]["Type_$($num)_Height"] = $info["Height"]
    $dp_local["Product$productIndex"]["Type_$($num)_Thick"] = $info["Thick"]
    $dp_local["Product$productIndex"]["Type_$($num)_ColorNum"] = 0
    $dp_local["Product$productIndex"]["TypeNum"]=$num+1
    return $num
}
function Add-DeviceMaker($info){
    $num = $dp_local["ProductNum"]["Num"] -as [int]
    $np=[ordered]@{}
    $np["ProductID"] = $num
    $np["ProductName"] = $info["Maker"]
    $np["TypeNum"]=0
    $dp_local.Add("Product$num", $np)
    # $dp_local["Product$productIndex"]["ProductID"] = $num
    # $dp_local["Product$productIndex"]["ProductName"] = $info["Maker"]
    # $dp_local["Product$productIndex"]["TypeNum"]=0
    $dp_local["ProductNum"]["Num"]=$num+1
    return $num
}
function Restore-DeviceProfile ($dppackage){
    Write-Host "Restore-DeviceProfile: $($dppackage)"
    $readableid=""
    if(Test-Path $dppackage){
        $temp = Join-Path -Path $env:TEMP -ChildPath "dptemp"
        Remove-Item -Recurse -Force $temp
        Expand-Archive -Path $dppackage -DestinationPath $temp
        $info = Get-IniContent (Join-Path -Path $temp -ChildPath "info.ini")
        Write-Host ($info["information"] | Out-String)
        $readableid=$info["information"]["readableid"]
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
                $idx=Add-DeviceModel $maker.index $info["information"]
                Add-DeviceColor $maker.index $idx $info["information"]
            }
        }
        else{
            # not foun need create new one
            $i1=Add-DeviceMaker $info["information"]
            $idx=Add-DeviceModel $i1 $info["information"]
            Add-DeviceColor $i1 $idx $info["information"]
        }
        # copy the content
        $src = [System.IO.Path]::Combine($temp, "resource","*")
        $x=[System.IO.Path]::Combine($env:APSTHOME,"UserData", "Mission", "UsedPhone")
        Copy-Item -Recurse -Force -Path $src -Destination $x
    }
    return $readableid
}
function Find-SectionByReadableId ($readableid){
    $ret=$null
    foreach($i in $syncstatus.deviceprofile.filelist){
        if($i.readableid -eq $readableid){
            $ret=$i
            break
        }
    }
    return $ret
}

function Start-CMCDeploy(){
    $x=[System.IO.Path]::Combine($env:ProgramData,"FutureDial","FDAcorn.exe")
    Copy-Item -Path (Join-Path -Path $env:APSTHOME -ChildPath "FDAcorn.exe") -Destination $x -Force
    if(Test-Path $x){
        Start-Process -FilePath $x -ArgumentList "UpdateEnv" -Wait -NoNewWindow     
    }
}
Write-Host "Script root = $PSScriptRoot"
$downloadTemp=[System.IO.Path]::Combine($env:ProgramData, "FutureDial", "FDDownloadTools", "DownloadTemp")
$dpfolder=Join-Path $downloadTemp -ChildPath "deviceprofile"
Write-Host "Device profile download path = $dpfolder"
# $dps=[ArrayList]@()

<#
if( Test-Path $dpfolder){
    $dp_packages=Get-ChildItem -Path $dpfolder
    Write-Host "Device profile packages = $dp_packages"
    if($dp_packages.Count -gt 0){
        foreach($fn in $dp_packages){
            $id = Restore-DeviceProfile $fn
            $r = Find-SectionByReadableId $id
            if($null -ne $r){
                $r.psobject.Properties.Remove("url")
                $clientStatus.sync.status.deviceprofile.filelist += $r
                # $dps.Add($r)
                $syncstatus.deviceprofile.filelist -= $r
                Remove-Item -Path $fn.FullName -Force
            }
        }
        # Out-IniFile -FilePath 
        Remove-Item -Path $missionManagerIni -Force
        Out-IniFile -FilePath $missionManagerIni -InputObject $dp_local -Encoding ASCII
        # foreach($i in $clientStatus.sync.status.deviceprofile.filelist){
        #     $dps.Add($i)
        # }
        # $clientStatus.sync.status.deviceprofile.filelist =  $dps
        # $x = convertto-json $clientStatus -Depth 8 | Out-File -FilePath (Join-Path -Path $env:APSTHOME -ChildPath "ClientStatus.json") -Encoding utf8
        $x = convertto-json $clientStatus -Depth 8
        [System.IO.File]::WriteAllText((Join-Path -Path $env:APSTHOME -ChildPath "ClientStatus.json"), $x)
    }    
}
#>
foreach($dp in $syncstatus.deviceprofile.filelist){
    $fn = Split-Path $dp.url -Leaf
    $fn=[System.IO.Path]::Combine([System.String[]]@($env:ProgramData,"FutureDial","FDDownloadTools","DownloadTemp","deviceprofile", $fn))
    Restore-DeviceProfile $fn
    $dp.psobject.Properties.Remove("url")
    $clientStatus.sync.status.deviceprofile.filelist += $dp
    Remove-Item -Path $fn -Force    
}
Remove-Item -Path $missionManagerIni -Force
Out-IniFile -FilePath $missionManagerIni -InputObject $dp_local -Encoding ASCII
$x = convertto-json $clientStatus -Depth 8
[System.IO.File]::WriteAllText((Join-Path -Path $env:APSTHOME -ChildPath "ClientStatus.json"), $x)
$syncstatus.deviceprofile.filelist=@()
$x = convertto-json $syncstatus -Depth 8
[System.IO.File]::WriteAllText(([System.IO.Path]::Combine($env:ProgramData,"FutureDial","FDDownloadTools","SyncStatus.json")), $x)

# start deploy
Start-CMCDeploy
# $x=[System.IO.Path]::Combine($env:ProgramData,"FutureDial","FDAcorn.exe")
# Copy-Item -Path (Join-Path -Path $env:APSTHOME -ChildPath "FDAcorn.exe") -Destination $x -Force
# if(Test-Path $x){
#     Start-Process -FilePath $x -ArgumentList "UpdateEnv" -Wait -NoNewWindow 
# }
Stop-Transcript
