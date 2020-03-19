class AndroidDevice {
    [string] $adb
    [string] $serialno

    AndroidDevice(){
        $this.adb = Join-Path -Path $env:APSTHOME -childpath "adb.exe"
        $this.serialno = ""
    }
    AndroidDevice($adb){
        $this.adb = $adb
        $this.serialno = ""
    }
    AndroidDevice($adb, $serialno){
        $this.adb = $adb
        $this.serialno = "-s $serialno"
    }

    [string] getDeviceStatus(){
        $temp =New-TemporaryFile
        $p = Start-Process -FilePath $this.adb -ArgumentList "$($this.serialno) get-state" -RedirectStandardOutput $temp -PassThru -NoNewWindow 
        $p.WaitForExit()
        $x = Get-Content $temp
        Remove-Item $temp
        return $x
    }

    [hashtable] getDeviceProperties(){
        $temp =New-TemporaryFile
        $p = Start-Process -FilePath $this.adb -ArgumentList "$($this.serialno) shell getprop" -RedirectStandardOutput $temp -PassThru -NoNewWindow 
        $p.WaitForExit()
        $x = Get-Content $temp
        Remove-Item $temp
        $r = @{}
        foreach($i in $x){
            if($i -match "^\[(\S+)\]: \[(\S+)\]$"){
                $r.Add($Matches[1], $Matches[2])
            }
        }
        return $r
    }
    
    [bool] installApk([string]$apk){
        $r = $false
        if(Test-Path $apk) {
            $temp =New-TemporaryFile
            $p = Start-Process -FilePath $this.adb -ArgumentList "$($this.serialno) install -r $($apk)" -RedirectStandardOutput $temp -PassThru -NoNewWindow 
            $p.WaitForExit()
            $x = Get-Content $temp
            if($x -eq "success"){
                $r = $true
            }
            Remove-Item $temp
        }
        return $r
    }

    [bool] checkApk([string]$apk){
        $ret=$false
        $temp =New-TemporaryFile
        $p = Start-Process -FilePath $this.adb -ArgumentList "$($this.serialno) shell pm list packages" -RedirectStandardOutput $temp -PassThru -NoNewWindow 
        $p.WaitForExit()
        $x = Get-Content $temp
        Remove-Item $temp
        if($x -match $apk){
            $ret=$true
        }
        return $ret
    }
    [hashtable] getDevicePropertiesFromApk(){
        $p = Start-Process -FilePath $this.adb -ArgumentList "$($this.serialno) shell am start -n com.futuredial.fdbox721/.fdbox721Activity --es task GetInfo --es result phoneinfo.txt" -PassThru -NoNewWindow 
        $p.WaitForExit()
        $done = $false
        while( -not $done){
            $temp =New-TemporaryFile
            $p = Start-Process -FilePath $this.adb -ArgumentList "$($this.serialno) shell ls /data/data/com.futuredial.fdbox721/files/phoneinfo.txt" -RedirectStandardOutput $temp -PassThru -NoNewWindow 
            $p.WaitForExit()
            $x = Get-Content $temp
            Remove-Item $temp
            if($x -match "No such file") {
                Start-Sleep -Seconds 2
            }
            else{
                $done = $true
            }
        }
        $temp =New-TemporaryFile
        $p = Start-Process -FilePath $this.adb -ArgumentList "$($this.serialno) shell cat /data/data/com.futuredial.fdbox721/files/phoneinfo.txt" -RedirectStandardOutput $temp -PassThru -NoNewWindow 
        $p.WaitForExit()
        $x = Get-Content $temp
        Remove-Item $temp
        $r = @{}
        foreach($i in $x){
            if($i -match "^(\S+)=(\S+)$"){
                $r.Add($Matches[1], $Matches[2])
            }
        }
        return $r
    }
}