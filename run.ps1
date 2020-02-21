$cd = $PSScriptRoot
Write-Output $cd
$fn = [System.IO.Path]::Combine($cd, "SMARTGrade", "cmc", "clientstatus.json")
if( Test-Path $fn){
    $x = Get-Content $fn | ConvertFrom-Json
    Add-Member -InputObject $x.client -NotePropertyName macaddr -NotePropertyValue "123"
    Write-Host ($x | ConvertTo-Json -Depth 4)
    Out-File -FilePath test.txt -InputObject ($x | ConvertTo-Json -Depth 4)    
}