## load local info.ini
Import-Module PsIni

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

$dp_local=[ordered]@{}
$dp_local["ProductNum"] = [ordered]@{"Num"=0}
$local = @()
$path="C:\\projects\\temp\\UsedPhone"
$info_files = @(Get-ChildItem -Path $path -Filter "info*.ini" -Recurse)
foreach($i in $info_files){
    $info = Get-IniContent $i.FullName
    $local += $info.information
}

## generate ini 
foreach($i in $local){
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

