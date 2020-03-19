function Set-Username {
    $a = "cmc:cmc1234!"
    # $a="chrisqa:chrisqa1234!"
    return @{Authorization="Basic $([System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($a)))"}
}

function Read-Database {
    param (
        [String]$db
    )
    $header = Set-Username
    $header.Add("Content-Type","application/json")
    $x=Invoke-RestMethod -Uri http://dc.futuredial.com/$db -Headers $header
    return $x
}

function Read-Collection {
    param (
        [String]$db,
        [String]$col
    )
    $header = Set-Username
    $header.Add("Content-Type","application/json")
    $x=Invoke-RestMethod -Uri http://dc.futuredial.com/$db/$col -Headers $header
    return $x
}