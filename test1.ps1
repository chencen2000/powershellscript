Import-Module PsIni
$local = Get-IniContent D:\BZVisualInspect\UserData\Mission\UsedPhone\MissionManager.ini
$local_list=[System.Collections.ArrayList]@()
$productNum = $local["productnum"]["num"]
for($i=0; $i -lt $productNum; $i++){
    $typeNum = $local["product$i"]["TypeNum"]
    for($j=0; $j -lt $typeNum; $j++){
        $colorNum=$local["product$i"]["Type_$($j)_ColorNum"]
        for($k=0;$k -lt $colorNum; $k++){
            $kk="$($local["product$i"]["Productname"])-$($local["product$i"]["Type_$($j)_Name"])-$($local["product$i"]["Type_$($j)_ColorNo_$($k)_Name"])-$($local["product$i"]["Type_$($j)_ColorNo_$($k)_Version"])"
            $local_list.Add($kk)| Out-Null
            Write-Host $kk
        }
    }
}

$inicontent= Get-IniContent D:\BZVisualInspect\UserData\Mission\UsedPhone\MissionManager_test.ini
$productNum = $inicontent["productnum"]["num"]
$deploy_list=[System.Collections.ArrayList]@()
for($i=0; $i -lt $productNum; $i++){
    $typeNum = $inicontent["product$i"]["TypeNum"]
    for($j=0; $j -lt $typeNum; $j++){
        $colorNum=$inicontent["product$i"]["Type_$($j)_ColorNum"]
        for($k=0;$k -lt $colorNum; $k++){
            $kk="$($inicontent["product$i"]["Productname"])-$($inicontent["product$i"]["Type_$($j)_Name"])-$($inicontent["product$i"]["Type_$($j)_ColorNo_$($k)_Name"])-$($inicontent["product$i"]["Type_$($j)_ColorNo_$($k)_Version"])"
            $deploy_list.Add($kk) | Out-Null
            Write-Host $kk
        }
    }
}

Write-Host "local info:"
Write-Host $local_list
Write-Host "deploy info:"
Write-Host $deploy_list
Compare-Object -ReferenceObject $local_list -DifferenceObject $deploy_list