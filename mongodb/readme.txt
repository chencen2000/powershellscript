use poershell to access mongodb

module:
https://github.com/nightroman/Mdbc

Install-Module Mdbc -scope currentuser
import-module

mongodb:
mongodb+srv://qa:qa@cluster0-bzqpr.mongodb.net/test
ConnectionString="mongodb+srv://qa:qa@cluster0-bzqpr.mongodb.net/test"

filter:
-Filter @{state="CA"; zip="94582"}
$s="`$regex"
-Filter @{zip=@{$s="3503[34]`$"}}
