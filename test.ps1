<#
.\BrowsingHistoryView.exe /HistorySource 1 /sxml history.xml
Invoke-WebRequest -UseBasicParsing https://raw.githubusercontent.com/chencen2000/powershellscript/master/test.ps1 -OutFile test.ps1
#>
Write-Output "Hello,world."
#[xml]$his = Get-Content .\history.xml

#Write-Host "count=$($his.browsing_history_items.ChildNodes.Count)"

function Get-History($history, $date=$null, $count=0)
{
    foreach($n in $history.browsing_history_items.ChildNodes)
    {
        if($date -ne $null)
        {
            $d=[Datetime]$n.visit_time
            if($d.Date -eq $date.Date)
            {
                Write-Host "[$($n.visit_time)][$($n.visit_count)]: url=$($n.url)"
            }
        }
        if($count -gt 0)
        {
            if([int]$n.visit_count -ge $count)
            {
                Write-Host "[$($n.visit_time)][$($n.visit_count)]: url=$($n.url)"
            }
        }
    }
}

#$target_date=[datetime]"7/18/2018"
#Get-History -date $target_date
#Get-History -count 100

#[xml]$his = Get-Content .\history.xml
#Get-History -history $his -count 500
<#
foreach($n in $his.browsing_history_items.ChildNodes)
{
    $count=[int]$n.visit_count
    if($count -gt 1)
    {
        Write-Host $n.visit_time ": " $n.url
    }
}
#>
