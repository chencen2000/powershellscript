
write-host $PSScriptRoot
$x=Join-Path -Path $PSScriptRoot -ChildPath "dcModule.ps1"
$m = Import-Module $x -PassThru
# Get-Module
# test
$x= Read-Database cmc
$x= Read-Collection cmc test2
Remove-Module $m