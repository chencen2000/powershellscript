param(
    [Parameter(Mandatory = $false)]
    $serialno,
    [Parameter(Mandatory = $false)]
    $target
)

if ((Test-Path $env:APSTHOME) -And (Test-Path (Join-Path $env:APSTHOME -ChildPath "config.ini")) ) {
    Write-Host "Already installed."
    exit 0
}

#Requires -RunAsAdministrator

function Get-Downloader {
    param (
        [string]$url
    )
    
    $downloader = new-object System.Net.WebClient
    
    $defaultCreds = [System.Net.CredentialCache]::DefaultCredentials
    if ($defaultCreds -ne $null) {
        $downloader.Credentials = $defaultCreds
    }
    
    $ignoreProxy = $env:chocolateyIgnoreProxy
    if ($ignoreProxy -ne $null -and $ignoreProxy -eq 'true') {
        Write-Debug "Explicitly bypassing proxy due to user environment variable"
        $downloader.Proxy = [System.Net.GlobalProxySelection]::GetEmptyWebProxy()
    }
    else {
        # check if a proxy is required
        $explicitProxy = $env:chocolateyProxyLocation
        $explicitProxyUser = $env:chocolateyProxyUser
        $explicitProxyPassword = $env:chocolateyProxyPassword
        if ($explicitProxy -ne $null -and $explicitProxy -ne '') {
            # explicit proxy
            $proxy = New-Object System.Net.WebProxy($explicitProxy, $true)
            if ($explicitProxyPassword -ne $null -and $explicitProxyPassword -ne '') {
                $passwd = ConvertTo-SecureString $explicitProxyPassword -AsPlainText -Force
                $proxy.Credentials = New-Object System.Management.Automation.PSCredential ($explicitProxyUser, $passwd)
            }
    
            Write-Debug "Using explicit proxy server '$explicitProxy'."
            $downloader.Proxy = $proxy
    
        }
        elseif (!$downloader.Proxy.IsBypassed($url)) {
            # system proxy (pass through)
            $creds = $defaultCreds
            if ($creds -eq $null) {
                Write-Debug "Default credentials were null. Attempting backup method"
                $cred = get-credential
                $creds = $cred.GetNetworkCredential();
            }
    
            $proxyaddress = $downloader.Proxy.GetProxy($url).Authority
            Write-Debug "Using system proxy server '$proxyaddress'."
            $proxy = New-Object System.Net.WebProxy($proxyaddress)
            $proxy.Credentials = $creds
            $downloader.Proxy = $proxy
        }
    }
    
    return $downloader
}
    
function Download-String {
    param (
        [string]$url
    )
    $downloader = Get-Downloader $url
        
    return $downloader.DownloadString($url)
}
        
function Download-File {
    param (
        [string]$url,
        [string]$file
    )
    #Write-Output "Downloading $url to $file"
    $downloader = Get-Downloader $url
        
    $downloader.DownloadFile($url, $file)
}    

function Get-FtpDir ($url) {
    $request = [System.Net.FtpWebRequest]::Create($url)
    $request.Credentials = New-Object System.Net.NetworkCredential("fd_clean", "fd_clean340!")
    $request.Method = [System.Net.WebRequestMethods+FTP]::ListDirectory
    $request.UseBinary = $true
    #    $passcode=ConvertTo-SecureString "fd_clean340!" -AsPlainText -Force
    #    $user=New-Object System.Net.NetworkCredential("fd_clean", $passcode) 
    #    if ($credentials) { $request.Credentials = $user }
    $response = $request.GetResponse()
    $reader = New-Object IO.StreamReader $response.GetResponseStream() 
    $ret = $reader.ReadToEnd()
    $reader.Close()
    $response.Close()
    return $ret
}


function FtpDownloadFile ($url, $file) {
    $ret = $false
    try {
        $request = [System.Net.FtpWebRequest]::Create($url)
        $request.Credentials = New-Object System.Net.NetworkCredential("fd_clean", "fd_clean340!")
        $request.Method = [System.Net.WebRequestMethods+FTP]::DownloadFile
        $request.UseBinary = $true
        #    $passcode=ConvertTo-SecureString "fd_clean340!" -AsPlainText -Force
        #    $user=New-Object System.Net.NetworkCredential("fd_clean", $passcode) 
        #    if ($credentials) { $request.Credentials = $user }
        $response = $request.GetResponse()
        $reader = $response.GetResponseStream()
        $LocalFile = New-Object IO.FileStream ($file, [IO.FileMode]::Create)
        [byte[]]$ReadBuffer = New-Object byte[] 10240
        do {
            $ReadLength = $reader.Read($ReadBuffer, 0, 10240)
            $LocalFile.Write($ReadBuffer, 0, $ReadLength)
        }
        while ($ReadLength -ne 0)
        $LocalFile.Close()
        $reader.Close()
        $response.Close()
        $ret = $true
    }
    catch {
        Write-Host $_.Exception.Message
    }
    return $ret
}

if ([System.String]::IsNullOrEmpty($serialno)) {
    $serialno = Read-Host "Enter CMC serial number"
    if ([System.String]::IsNullOrEmpty($serialno)) {
        Write-Host "Missing serial number. Exit."
        exit 1
    }
}
if ([System.String]::IsNullOrEmpty($target)) {
    $target = Read-Host "Enter the target folder: by default is (D:\projects\temp)"
    if ([System.String]::IsNullOrEmpty($target)) {
        $target = "D:\projects\temp"
    }
}
mkdir $target


# $url="https://raw.githubusercontent.com/chencen2000/powershellscript/master/test.ps1"
# $x=Download-String $url
# iex $x
# $unzip=Join-Path $target -ChildPath "7za.exe"
# Download-File 'https://chocolatey.org/7za.exe' $unzip

$x = Get-FtpDir "ftp://ftp8.futuredial.com/SmartGrading"
# Write-Host $x
$file = Join-Path $target "cmc.zip"
$x = "ftp://ftp8.futuredial.com/SmartGrading/{0}/cmc.zip" -f $serialno
$ok = FtpDownloadFile $x $file
if (! $ok) {
    FtpDownloadFile "ftp://ftp8.futuredial.com/SmartGrading/cmc.zip" $file
}
if (-not (Test-Path $file)) {
    Write-Host "Fail to download CMC from server."
    exit 2
}

try {
    $shellApplication = new-object -com shell.application
    $zipPackage = $shellApplication.NameSpace($file)
    $destinationFolder = $shellApplication.NameSpace($target)
    $destinationFolder.CopyHere($zipPackage.Items(), 0x10)
}
catch {
    throw "Unable to unzip package using built-in compression. Set `$env:chocolateyUseWindowsCompression = 'false' and call install again to use 7zip to unzip. Error: `n $_"
}

Remove-Item -Path $file -Force
$x = @{_id = $serialno } 
$x = $x | ConvertTo-Json -Compress
$ok = Invoke-WebRequest -UseBasicParsing -Uri "https://ps.futuredial.com/profiles/clients/_find?criteria=$x"
Write-Host $ok.Content

$file = Join-Path $target "fdcheckserial.exe"
if (Test-Path $file) {
    $x = Start-Process -WorkingDirectory $target -FilePath $file -ArgumentList @("-s", $serialno, "-d", $target) -Wait -PassThru
    Write-Host "error code: $($x.ExitCode)"
    if (!($x.ExitCode -eq 0)) {
        Write-Host "Fail to download config. error code: $($x.ExitCode)"
    }
}

$x = Join-Path ([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::CommonDesktopDirectory)) "SMARTGrade.lnk"
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($x)
$Shortcut.TargetPath = """$(Join-Path $target -ChildPath "AviaUI.exe")"""
$Shortcut.IconLocation = Join-Path $target -ChildPath "icon2.ico"
$Shortcut.WorkingDirectory = """$($target)"""
$Shortcut.Save()
$x = Join-Path ([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::CommonStartup)) "SMARTGradePreparation.lnk"
$Shortcut = $WshShell.CreateShortcut($x)
$Shortcut.TargetPath = """$(Join-Path $target -ChildPath "FDAcorn.exe")"""
$Shortcut.Arguments = "-StartDownLoad"
$Shortcut.IconLocation = Join-Path $target -ChildPath "icon1.ico"
$Shortcut.WorkingDirectory = """$($target)"""
$Shortcut.Save()

$x = Join-Path ([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::CommonApplicationData())) "FutureDial"
mkdir $x
[System.Environment]::SetEnvironmentVariable("APSTHOME", $target, [System.EnvironmentVariableTarget]::Machine)
Set-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -Name EnableLUA -Value 0
Write-Host "Restart the computer to start the download."
cmd /c pause
Restart-Computer
exit 0