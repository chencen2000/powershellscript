<#PSScriptInfo

.VERSION 2020.2.25.1

.GUID 3bb10ee7-38c1-41b9-88ea-16899164fc19

.AUTHOR cchen@futuredial.com

.COMPANYNAME Futuredial

.COPYRIGHT

.TAGS

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES

.PRIVATEDATA

#>

<#

.DESCRIPTION
 CMC delpoyment script file.

#>
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

function Start-CMCDeploy(){
    $x=[System.IO.Path]::Combine($env:ProgramData,"FutureDial","FDAcorn.exe")
    Copy-Item -Path (Join-Path -Path $env:APSTHOME -ChildPath "FDAcorn.exe") -Destination $x -Force
    if(Test-Path $x){
        $x = Start-Process -FilePath $x -ArgumentList "-UpdateEnv" -PassThru -NoNewWindow     
        if($null -ne $x){
            $x.WaitForExit()
        }
    }
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
if(($syncstatus.deviceprofile.filelist.Count -eq 0) -and ($syncstatus.deviceprofile.deletelist.Count -eq 0)){
    Write-Host "Device profile element has no more items in $x"
    Start-CMCDeploy
    exit 1
}

$MissionFolder=[System.IO.Path]::Combine($env:APSTHOME,"UserData", "Mission")
# $MissionFolder = C:\projects\temp\Mission
New-Item -Path $MissionFolder -ItemType Directory 
$UsedPhone=Join-Path -path $MissionFolder -ChildPath "UsedPhone"
#New-Item -Path $UsedPhone -ItemType Directory 
# $missionManagerIni=Join-Path -Path $x -ChildPath "MissionManager.ini"
# $dp_local=[ordered]@{}
# if(Test-Path $missionManagerIni){
#     $dp_local=Get-IniContent $missionManagerIni
# }
# Write-Host ($dp_local | Out-String)
# if( $dp_local.Contains("productNum")){
#     Write-Host ($dp_local["productNum"] | Out-String)
# }
# else{
#     $dp_local["ProductNum"] = [ordered]@{"Num"=0}
# }
$dp_local=[ordered]@{}
$dp_local["ProductNum"] = [ordered]@{"Num"=0}

function Get-LocalDeviceProfile($path) {
    $ret = @()
    $info_files = @(Get-ChildItem -Path $path -Filter "info.ini" -Recurse)
    foreach($i in $info_files){
        $info = Get-IniContent $i.FullName
        $ret += $info.information
    }
    return $ret
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

function Remove-LocalDeviceProfile ($dpinfo) {
    $folder = $dpinfo["folder"]
    if([System.String]::IsNullOrEmpty($folder)) {
        $folder = "UsedPhone"
    }
    $x="{0}-{1}-{2}" -f  $dpinfo["maker"],$dpinfo["model"],$dpinfo["color"]
    $t=[System.IO.Path]::Combine($MissionFolder, $folder, $x)
    Remove-Item -Path $t -Recurse -Force
}
function Copy-LocalDeviceProfile ($dppackage){
    $ret=$null
    if(Test-Path $dppackage){
        $temp = Join-Path -Path $env:TEMP -ChildPath "dptemp"
        Remove-Item -Recurse -Force $temp
        Expand-Archive -LiteralPath $dppackage -DestinationPath $temp -Force
        $info = Get-IniContent (Join-Path -Path $temp -ChildPath "info.ini")
        $ret=$info["information"]
        $key="{0}-{1}-{2}" -f  $ret["maker"],$ret["model"],$ret["color"]
        $src = [System.IO.Path]::Combine($temp, "resource",$key)
        $folder = $ret["folder"]
        if([System.String]::IsNullOrEmpty($folder)) {
            $folder = "UsedPhone"
        }            
        # $x=[System.IO.Path]::Combine($env:APSTHOME,"UserData", "Mission", "UsedPhone")
        $target = Join-Path -Path $MissionFolder -ChildPath $folder
        New-Item -Path $target -ItemType Directory 
        Copy-Item -Recurse -Force -Path $src -Destination $target
        # $x="$($ret["maker"])-$($ret["model"])-$($ret["color"])"
        # copy info.ini
        Copy-Item -path (Join-Path -Path $temp -ChildPath "info.ini") -Destination (Join-Path -Path $target -ChildPath $key)
        # copy schema file, from resource folder to $env:APSTHOME,"UserData", "Mission", "UsedPhone", Schema\{maker}\{model}\Light-{maker}-{model}-{color}.ini
        $src = [System.IO.Path]::Combine($temp, "resource",("Light-{0}.ini" -f $key))
        $target = [System.IO.Path]::Combine([string[]]@($MissionFolder, $folder, "Schema", $ret["maker"], $ret["model"]))
        New-Item -Path $target -ItemType Directory 
        Copy-Item -Path $src -Destination $target
    }
    return $ret
}

function Save-DeviceProfileIni ($dpdata, $folder) {
    ## generate ini 
    foreach($i in $dpdata){
        # $maker=$i["maker"]
        # $model=$i["model"]
        # $color=$i["color"]
        $maker=Find-DeviceMaker $i["maker"]
        if($maker.found){
            # found model
            $model = Find-DeviceModel $maker.index $i["model"]
            if($model.found){
                # found model
                $color = Find-DeviceColor $maker.index $model.index $i["color"]
                if($color.found){
                    # found color
                    # just copy the content to folder
                }
                else{
                    # not found need create new color
                    Add-DeviceColor $maker.index $model.index $i
                }
            }
            else{
                # not found need create new model
                $idx=Add-DeviceModel $maker.index $i
                Add-DeviceColor $maker.index $idx $i
            }
        }
        else{
            # not foun need create new one
            $i1=Add-DeviceMaker $i
            $idx=Add-DeviceModel $i1 $i
            Add-DeviceColor $i1 $idx $i
        }
    }
    # $fn = Join-Path -Path $UsedPhone -ChildPath "MissionManager.ini"
    $fn = [System.IO.Path]::Combine($MissionFolder, $folder, "MissionManager.ini")
    Remove-Item -Path $fn -Force
    Out-IniFile -FilePath $fn -InputObject $dp_local -Encoding ASCII    
}

Write-Host "Script root = $PSScriptRoot"
$downloadTemp=[System.IO.Path]::Combine($env:ProgramData, "FutureDial", "FDDownloadTools", "DownloadTemp")
$dpfolder=Join-Path $downloadTemp -ChildPath "deviceprofile"
Write-Host "Device profile download path = $dpfolder"
# $dps=[ArrayList]@()

$dp_local_info=New-Object System.Collections.ArrayList($null)
$x = Get-LocalDeviceProfile $MissionFolder
if($null -ne $x){
    $dp_local_info.AddRange($x)
}

if($syncstatus.deviceprofile.deletelist.Count -gt 0){
    # the device profile removed from server, need to be delete from local.
    foreach($i in $syncstatus.deviceprofile.deletelist){
        $x=@($dp_local_info | Where-Object {$_.readableid -eq $i})
        if($null -ne $x) {
            ## remove the folder
            foreach($j in $x){
                Remove-LocalDeviceProfile $j
                $dp_local_info.Remove($j)
            }
        }
        # remove it from clientstatus
        $x = @($clientStatus.sync.status.deviceprofile.filelist | Where-Object {$_.readableid -eq $i})
        if($null -ne $x){
            foreach($j in $x){
                $clientStatus.sync.status.deviceprofile.filelist = $clientStatus.sync.status.deviceprofile.filelist -ne $j
            }
        }
    }
}

if($syncstatus.deviceprofile.filelist.Count -gt 0){
    # the device profile added from server, need to be add to local.
    foreach($i in $syncstatus.deviceprofile.filelist){
        # find exists by readableid
        $rid = $i.readableid
        $x=@($dp_local_info | Where-Object {$_.readableid -eq $rid})
        foreach($j in $x){
            Remove-LocalDeviceProfile $j
            $dp_local_info.Remove($j)
        }
        # copy
        $fn = Split-Path $i.url -Leaf
        $fn=[System.IO.Path]::Combine([System.String[]]@($env:ProgramData,"FutureDial","FDDownloadTools","DownloadTemp","deviceprofile", $fn))
        $x=Copy-LocalDeviceProfile $fn
        if($null -ne $x){
            # $dp_local_info.Add($x)
            $i.psobject.Properties.Remove("url")
            $x = @($clientStatus.sync.status.deviceprofile.filelist | Where-Object {$_.readableid -eq $rid})
            foreach($j in $x) {
                $clientStatus.sync.status.deviceprofile.filelist = $clientStatus.sync.status.deviceprofile.filelist -ne $j
            }
            $clientStatus.sync.status.deviceprofile.filelist += $i
        }
        Remove-Item -Path $fn -Force    
    }
}

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
<#
foreach($dp in $syncstatus.deviceprofile.filelist){
    $fn = Split-Path $dp.url -Leaf
    $fn=[System.IO.Path]::Combine([System.String[]]@($env:ProgramData,"FutureDial","FDDownloadTools","DownloadTemp","deviceprofile", $fn))
    Restore-DeviceProfile $fn
    $dp.psobject.Properties.Remove("url")
    $clientStatus.sync.status.deviceprofile.filelist += $dp
    Remove-Item -Path $fn -Force    
}
#>
# Remove-Item -Path $missionManagerIni -Force
# Out-IniFile -FilePath $missionManagerIni -InputObject $dp_local -Encoding ASCII
# Save-DeviceProfileIni $dp_local_info
## save ini for each folder
$folders =@( Get-ChildItem -Path $MissionFolder -Directory)
foreach($f in $folders){
    $dp_local=[ordered]@{}
    $dp_local["ProductNum"] = [ordered]@{"Num"=0}
    $dp_local_info=New-Object System.Collections.ArrayList($null)
    $x = Get-LocalDeviceProfile $f.FullName
    if($null -ne $x){
        Save-DeviceProfileIni $x $f.Name
    }
    else{
        Remove-Item -Path (Join-Path -Path $f.FullName -ChildPath "MissionManager.ini") -Force
    }
}

$x = convertto-json $clientStatus -Depth 8
[System.IO.File]::WriteAllText((Join-Path -Path $env:APSTHOME -ChildPath "ClientStatus.json"), $x)
$syncstatus.deviceprofile.deletelist=@()
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
