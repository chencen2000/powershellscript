$x = Import-Module Mdbc
if($null -eq $x){
    exit 1
}

Connect-Mdbc -ConnectionString "mongodb+srv://qa:qa@cluster0-bzqpr.mongodb.net/test"
$dbs=Get-MdbcDatabase
$db = Get-MdbcDatabase -Name "mydb"
$cols=Get-MdbcCollection -Database $db
$col = Get-MdbcCollection -Name "mycol" -Database $db
$count=Get-MdbcData -Collection $col -Count
$x=Get-MdbcData -Collection $col -Filter @{name="chris"}