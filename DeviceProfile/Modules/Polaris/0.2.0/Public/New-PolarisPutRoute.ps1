#
# Copyright (c) Microsoft. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.
#

<#
.SYNOPSIS
    Add web route with method PUT
.DESCRIPTION
    Wrapper for New-PolarisRoute -Method PUT
.PARAMETER Path
    Path (path/route/endpoint) of the web route to to be serviced.
.PARAMETER Scriptblock
    Scriptblock that will be triggered when web route is called.
.PARAMETER ScriptPath
    Full path and name of script that will be triggered when web route is called.
.PARAMETER Force
    Use -Force to overwrite any existing web route for the same path and method.
.PARAMETER Polaris
    A Polaris object
    Defaults to the script scoped Polaris
.EXAMPLE
    New-PolarisGetRoute -Path "helloworld" -Scriptblock { $Response.Send( 'Hello World' ) }
    To view results, assuming default port:
    Start-Polaris
    Invoke-WebRequest -Uri http://localhost:8080/helloworld -Method PUT
.EXAMPLE
    New-PolarisGetRoute -Path "helloworld" -ScriptPath D:\Scripts\Example.ps1
    To view results, assuming default port:
    Start-Polaris
    Invoke-WebRequest -Uri http://localhost:8080/helloworld -Method PUT
#>
function New-PolarisPutRoute {
    [CmdletBinding()]
    param(
        [Parameter( Mandatory = $True, Position = 0 )]
        [string]
        $Path,

        [Parameter( Mandatory = $True, Position = 1, ParameterSetName = 'Scriptblock' )]
        [scriptblock]
        $Scriptblock,

        [Parameter( Mandatory = $True, ParameterSetName = 'ScriptPath' )]
        [string]
        $ScriptPath,
        
        [switch]
        $Force,

        
        $Polaris = $Script:Polaris
    )

    switch ( $PSCmdlet.ParameterSetName ) {
        'Scriptblock' { New-PolarisRoute -Path $Path -Method "PUT" -Scriptblock $Scriptblock -Force:$Force }
        'ScriptPath' { New-PolarisRoute -Path $Path -Method "PUT" -ScriptPath  $ScriptPath  -Force:$Force }
    }
}

# SIG # Begin signature block
# MIIdjgYJKoZIhvcNAQcCoIIdfzCCHXsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUab+JeytqERec6gV9Th+dk/4Z
# CLSgghhqMIIE2jCCA8KgAwIBAgITMwAAAQJSCNjfQc3ntgAAAAABAjANBgkqhkiG
# 9w0BAQUFADB3MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4G
# A1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSEw
# HwYDVQQDExhNaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EwHhcNMTgwODIzMjAyMDIy
# WhcNMTkxMTIzMjAyMDIyWjCByjELMAkGA1UEBhMCVVMxCzAJBgNVBAgTAldBMRAw
# DgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24x
# LTArBgNVBAsTJE1pY3Jvc29mdCBJcmVsYW5kIE9wZXJhdGlvbnMgTGltaXRlZDEm
# MCQGA1UECxMdVGhhbGVzIFRTUyBFU046MkFENC00QjkyLUZBMDExJTAjBgNVBAMT
# HE1pY3Jvc29mdCBUaW1lLVN0YW1wIHNlcnZpY2UwggEiMA0GCSqGSIb3DQEBAQUA
# A4IBDwAwggEKAoIBAQC2TCUV6nZ6x6RdQhK0FefmGN60tvnJGam2IH0rI75ZRJd+
# ku+ozhQ5XW1soJo71KGZV9Lg3/K+cG/7alMsuVTelwPVrFIYTZy/oA0AT9PgHpiU
# DwUlm4HYqdxZsM0/id69PhJsCtEIJp3Npcc1HWbXX4oACsRQtLzDgo1sU+Ze1+Uk
# aTsWObxQbg6YuOkv04Dst4vGfbY+2vDeuRdadizN38Xx5wyLF1nXtsLGE9x6oRm5
# e5BihTGmnaoE5MtP5qX2ltdLfuamXlQnbGB3pmAfv7FyqNedCHJ816NIut+YjzMc
# e3zbz4PwLCmsn9y3gncAgk/wOphNZsZxf4CVd4pvAgMBAAGjggEJMIIBBTAdBgNV
# HQ4EFgQUqeK8hE8b0+/EfF+ECVsQiAFdNnQwHwYDVR0jBBgwFoAUIzT42VJGcArt
# QPt2+7MrsMM1sw8wVAYDVR0fBE0wSzBJoEegRYZDaHR0cDovL2NybC5taWNyb3Nv
# ZnQuY29tL3BraS9jcmwvcHJvZHVjdHMvTWljcm9zb2Z0VGltZVN0YW1wUENBLmNy
# bDBYBggrBgEFBQcBAQRMMEowSAYIKwYBBQUHMAKGPGh0dHA6Ly93d3cubWljcm9z
# b2Z0LmNvbS9wa2kvY2VydHMvTWljcm9zb2Z0VGltZVN0YW1wUENBLmNydDATBgNV
# HSUEDDAKBggrBgEFBQcDCDANBgkqhkiG9w0BAQUFAAOCAQEAFBWJj8orBQx/GeoX
# fUASC5yKFR3HAUNr0sL+a3V3ToU7quCp7AS7ZZnVmab/GxRojTArJmpi09WP0fsj
# nX5A36PnYSe2wRXQ81GVxhxHzMHp+fwsnAGtfq6rfR7M5ShjZBmo3R0gaqno9i0J
# iAC6qXqzmzI33k43QAFCS//lRbuTgl6KXEhDTqDjuLPd8bDJnDH1X6JbL8SelGi1
# a9/h3KqHGGYEUjWNq8uB5UGuCMZgpIfObW9ocuGVN1s6ZHuD1Hf/PpVB8u+nkwEs
# NwmEhZuZbWMd/4TnkQD54Tjw9GfFSLc8qWhl7C3oktJPlqS4oTqvAszGqjykBIQw
# teG3+jCCBf8wggPnoAMCAQICEzMAAAEDXiUcmR+jHrgAAAAAAQMwDQYJKoZIhvcN
# AQELBQAwfjELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNV
# BAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEoMCYG
# A1UEAxMfTWljcm9zb2Z0IENvZGUgU2lnbmluZyBQQ0EgMjAxMTAeFw0xODA3MTIy
# MDA4NDhaFw0xOTA3MjYyMDA4NDhaMHQxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpX
# YXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQg
# Q29ycG9yYXRpb24xHjAcBgNVBAMTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjCCASIw
# DQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBANGUdjbmhqs2/mn5RnyLiFDLkHB/
# sFWpJB1+OecFnw+se5eyznMK+9SbJFwWtTndG34zbBH8OybzmKpdU2uqw+wTuNLv
# z1d/zGXLr00uMrFWK040B4n+aSG9PkT73hKdhb98doZ9crF2m2HmimRMRs621TqM
# d5N3ZyGctloGXkeG9TzRCcoNPc2y6aFQeNGEiOIBPCL8r5YIzF2ZwO3rpVqYkvXI
# QE5qc6/e43R6019Gl7ziZyh3mazBDjEWjwAPAf5LXlQPysRlPwrjo0bb9iwDOhm+
# aAUWnOZ/NL+nh41lOSbJY9Tvxd29Jf79KPQ0hnmsKtVfMJE75BRq67HKBCMCAwEA
# AaOCAX4wggF6MB8GA1UdJQQYMBYGCisGAQQBgjdMCAEGCCsGAQUFBwMDMB0GA1Ud
# DgQWBBRHvsDL4aY//WXWOPIDXbevd/dA/zBQBgNVHREESTBHpEUwQzEpMCcGA1UE
# CxMgTWljcm9zb2Z0IE9wZXJhdGlvbnMgUHVlcnRvIFJpY28xFjAUBgNVBAUTDTIz
# MDAxMis0Mzc5NjUwHwYDVR0jBBgwFoAUSG5k5VAF04KqFzc3IrVtqMp1ApUwVAYD
# VR0fBE0wSzBJoEegRYZDaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9j
# cmwvTWljQ29kU2lnUENBMjAxMV8yMDExLTA3LTA4LmNybDBhBggrBgEFBQcBAQRV
# MFMwUQYIKwYBBQUHMAKGRWh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMv
# Y2VydHMvTWljQ29kU2lnUENBMjAxMV8yMDExLTA3LTA4LmNydDAMBgNVHRMBAf8E
# AjAAMA0GCSqGSIb3DQEBCwUAA4ICAQCf9clTDT8NJuyiRNgN0Z9jlgZLPx5cxTOj
# pMNsrx/AAbrrZeyeMxAPp6xb1L2QYRfnMefDJrSs9SfTSJOGiP4SNZFkItFrLTuo
# LBWUKdI3luY1/wzOyAYWFp4kseI5+W4OeNgMG7YpYCd2NCSb3bmXdcsBO62CEhYi
# gIkVhLuYUCCwFyaGSa/OfUUVQzSWz4FcGCzUk/Jnq+JzyD2jzfwyHmAc6bAbMPss
# uwculoSTRShUXM2W/aDbgdi2MMpDsfNIwLJGHF1edipYn9Tu8vT6SEy1YYuwjEHp
# qridkPT/akIPuT7pDuyU/I2Au3jjI6d4W7JtH/lZwX220TnJeeCDHGAK2j2w0e02
# v0UH6Rs2buU9OwUDp9SnJRKP5najE7NFWkMxgtrYhK65sB919fYdfVERNyfotTWE
# cfdXqq76iXHJmNKeWmR2vozDfRVqkfEU9PLZNTG423L6tHXIiJtqv5hFx2ay1//O
# kpB15OvmhtLIG9snwFuVb0lvWF1pKt5TS/joynv2bBX5AxkPEYWqT5q/qlfdYMb1
# cSD0UaiayunR6zRHPXX6IuxVP2oZOWsQ6Vo/jvQjeDCy8qY4yzWNqphZJEC4Omek
# B1+g/tg7SRP7DOHtC22DUM7wfz7g2QjojCFKQcLe645b7gPDHW5u5lQ1ZmdyfBrq
# UvYixHI/rjCCBgcwggPvoAMCAQICCmEWaDQAAAAAABwwDQYJKoZIhvcNAQEFBQAw
# XzETMBEGCgmSJomT8ixkARkWA2NvbTEZMBcGCgmSJomT8ixkARkWCW1pY3Jvc29m
# dDEtMCsGA1UEAxMkTWljcm9zb2Z0IFJvb3QgQ2VydGlmaWNhdGUgQXV0aG9yaXR5
# MB4XDTA3MDQwMzEyNTMwOVoXDTIxMDQwMzEzMDMwOVowdzELMAkGA1UEBhMCVVMx
# EzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoT
# FU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEhMB8GA1UEAxMYTWljcm9zb2Z0IFRpbWUt
# U3RhbXAgUENBMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAn6Fssd/b
# SJIqfGsuGeG94uPFmVEjUK3O3RhOJA/u0afRTK10MCAR6wfVVJUVSZQbQpKumFww
# JtoAa+h7veyJBw/3DgSY8InMH8szJIed8vRnHCz8e+eIHernTqOhwSNTyo36Rc8J
# 0F6v0LBCBKL5pmyTZ9co3EZTsIbQ5ShGLieshk9VUgzkAyz7apCQMG6H81kwnfp+
# 1pez6CGXfvjSE/MIt1NtUrRFkJ9IAEpHZhEnKWaol+TTBoFKovmEpxFHFAmCn4Tt
# VXj+AZodUAiFABAwRu233iNGu8QtVJ+vHnhBMXfMm987g5OhYQK1HQ2x/PebsgHO
# IktU//kFw8IgCwIDAQABo4IBqzCCAacwDwYDVR0TAQH/BAUwAwEB/zAdBgNVHQ4E
# FgQUIzT42VJGcArtQPt2+7MrsMM1sw8wCwYDVR0PBAQDAgGGMBAGCSsGAQQBgjcV
# AQQDAgEAMIGYBgNVHSMEgZAwgY2AFA6sgmBAVieX5SUT/CrhClOVWeSkoWOkYTBf
# MRMwEQYKCZImiZPyLGQBGRYDY29tMRkwFwYKCZImiZPyLGQBGRYJbWljcm9zb2Z0
# MS0wKwYDVQQDEyRNaWNyb3NvZnQgUm9vdCBDZXJ0aWZpY2F0ZSBBdXRob3JpdHmC
# EHmtFqFKoKWtTHNY9AcTLmUwUAYDVR0fBEkwRzBFoEOgQYY/aHR0cDovL2NybC5t
# aWNyb3NvZnQuY29tL3BraS9jcmwvcHJvZHVjdHMvbWljcm9zb2Z0cm9vdGNlcnQu
# Y3JsMFQGCCsGAQUFBwEBBEgwRjBEBggrBgEFBQcwAoY4aHR0cDovL3d3dy5taWNy
# b3NvZnQuY29tL3BraS9jZXJ0cy9NaWNyb3NvZnRSb290Q2VydC5jcnQwEwYDVR0l
# BAwwCgYIKwYBBQUHAwgwDQYJKoZIhvcNAQEFBQADggIBABCXisNcA0Q23em0rXfb
# znlRTQGxLnRxW20ME6vOvnuPuC7UEqKMbWK4VwLLTiATUJndekDiV7uvWJoc4R0B
# hqy7ePKL0Ow7Ae7ivo8KBciNSOLwUxXdT6uS5OeNatWAweaU8gYvhQPpkSokInD7
# 9vzkeJkuDfcH4nC8GE6djmsKcpW4oTmcZy3FUQ7qYlw/FpiLID/iBxoy+cwxSnYx
# PStyC8jqcD3/hQoT38IKYY7w17gX606Lf8U1K16jv+u8fQtCe9RTciHuMMq7eGVc
# WwEXChQO0toUmPU8uWZYsy0v5/mFhsxRVuidcJRsrDlM1PZ5v6oYemIp76KbKTQG
# dxpiyT0ebR+C8AvHLLvPQ7Pl+ex9teOkqHQ1uE7FcSMSJnYLPFKMcVpGQxS8s7Ow
# TWfIn0L/gHkhgJ4VMGboQhJeGsieIiHQQ+kr6bv0SMws1NgygEwmKkgkX1rqVu+m
# 3pmdyjpvvYEndAYR7nYhv5uCwSdUtrFqPYmhdmG0bqETpr+qR/ASb/2KMmyy/t9R
# yIwjyWa9nR2HEmQCPS2vWY+45CHltbDKY7R4VAXUQS5QrJSwpXirs6CWdRrZkocT
# dSIvMqgIbqBbjCW/oO+EyiHW6x5PyZruSeD3AWVviQt9yGnI5m7qp5fOMSn/DsVb
# XNhNG6HY+i+ePy5VFmvJE6P9MIIHejCCBWKgAwIBAgIKYQ6Q0gAAAAAAAzANBgkq
# hkiG9w0BAQsFADCBiDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24x
# EDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlv
# bjEyMDAGA1UEAxMpTWljcm9zb2Z0IFJvb3QgQ2VydGlmaWNhdGUgQXV0aG9yaXR5
# IDIwMTEwHhcNMTEwNzA4MjA1OTA5WhcNMjYwNzA4MjEwOTA5WjB+MQswCQYDVQQG
# EwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwG
# A1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSgwJgYDVQQDEx9NaWNyb3NvZnQg
# Q29kZSBTaWduaW5nIFBDQSAyMDExMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIIC
# CgKCAgEAq/D6chAcLq3YbqqCEE00uvK2WCGfQhsqa+laUKq4BjgaBEm6f8MMHt03
# a8YS2AvwOMKZBrDIOdUBFDFC04kNeWSHfpRgJGyvnkmc6Whe0t+bU7IKLMOv2akr
# rnoJr9eWWcpgGgXpZnboMlImEi/nqwhQz7NEt13YxC4Ddato88tt8zpcoRb0Rrrg
# OGSsbmQ1eKagYw8t00CT+OPeBw3VXHmlSSnnDb6gE3e+lD3v++MrWhAfTVYoonpy
# 4BI6t0le2O3tQ5GD2Xuye4Yb2T6xjF3oiU+EGvKhL1nkkDstrjNYxbc+/jLTswM9
# sbKvkjh+0p2ALPVOVpEhNSXDOW5kf1O6nA+tGSOEy/S6A4aN91/w0FK/jJSHvMAh
# dCVfGCi2zCcoOCWYOUo2z3yxkq4cI6epZuxhH2rhKEmdX4jiJV3TIUs+UsS1Vz8k
# A/DRelsv1SPjcF0PUUZ3s/gA4bysAoJf28AVs70b1FVL5zmhD+kjSbwYuER8ReTB
# w3J64HLnJN+/RpnF78IcV9uDjexNSTCnq47f7Fufr/zdsGbiwZeBe+3W7UvnSSmn
# Eyimp31ngOaKYnhfsi+E11ecXL93KCjx7W3DKI8sj0A3T8HhhUSJxAlMxdSlQy90
# lfdu+HggWCwTXWCVmj5PM4TasIgX3p5O9JawvEagbJjS4NaIjAsCAwEAAaOCAe0w
# ggHpMBAGCSsGAQQBgjcVAQQDAgEAMB0GA1UdDgQWBBRIbmTlUAXTgqoXNzcitW2o
# ynUClTAZBgkrBgEEAYI3FAIEDB4KAFMAdQBiAEMAQTALBgNVHQ8EBAMCAYYwDwYD
# VR0TAQH/BAUwAwEB/zAfBgNVHSMEGDAWgBRyLToCMZBDuRQFTuHqp8cx0SOJNDBa
# BgNVHR8EUzBRME+gTaBLhklodHRwOi8vY3JsLm1pY3Jvc29mdC5jb20vcGtpL2Ny
# bC9wcm9kdWN0cy9NaWNSb29DZXJBdXQyMDExXzIwMTFfMDNfMjIuY3JsMF4GCCsG
# AQUFBwEBBFIwUDBOBggrBgEFBQcwAoZCaHR0cDovL3d3dy5taWNyb3NvZnQuY29t
# L3BraS9jZXJ0cy9NaWNSb29DZXJBdXQyMDExXzIwMTFfMDNfMjIuY3J0MIGfBgNV
# HSAEgZcwgZQwgZEGCSsGAQQBgjcuAzCBgzA/BggrBgEFBQcCARYzaHR0cDovL3d3
# dy5taWNyb3NvZnQuY29tL3BraW9wcy9kb2NzL3ByaW1hcnljcHMuaHRtMEAGCCsG
# AQUFBwICMDQeMiAdAEwAZQBnAGEAbABfAHAAbwBsAGkAYwB5AF8AcwB0AGEAdABl
# AG0AZQBuAHQALiAdMA0GCSqGSIb3DQEBCwUAA4ICAQBn8oalmOBUeRou09h0ZyKb
# C5YR4WOSmUKWfdJ5DJDBZV8uLD74w3LRbYP+vj/oCso7v0epo/Np22O/IjWll11l
# hJB9i0ZQVdgMknzSGksc8zxCi1LQsP1r4z4HLimb5j0bpdS1HXeUOeLpZMlEPXh6
# I/MTfaaQdION9MsmAkYqwooQu6SpBQyb7Wj6aC6VoCo/KmtYSWMfCWluWpiW5IP0
# wI/zRive/DvQvTXvbiWu5a8n7dDd8w6vmSiXmE0OPQvyCInWH8MyGOLwxS3OW560
# STkKxgrCxq2u5bLZ2xWIUUVYODJxJxp/sfQn+N4sOiBpmLJZiWhub6e3dMNABQam
# ASooPoI/E01mC8CzTfXhj38cbxV9Rad25UAqZaPDXVJihsMdYzaXht/a8/jyFqGa
# J+HNpZfQ7l1jQeNbB5yHPgZ3BtEGsXUfFL5hYbXw3MYbBL7fQccOKO7eZS/sl/ah
# XJbYANahRr1Z85elCUtIEJmAH9AAKcWxm6U/RXceNcbSoqKfenoi+kiVH6v7RyOA
# 9Z74v2u3S5fi63V4GuzqN5l5GEv/1rMjaHXmr/r8i+sLgOppO6/8MO0ETI7f33Vt
# Y5E90Z1WTk+/gFcioXgRMiF670EKsT/7qMykXcGhiJtXcVZOSEXAQsmbdlsKgEhr
# /Xmfwb1tbWrJUnMTDXpQzTGCBI4wggSKAgEBMIGVMH4xCzAJBgNVBAYTAlVTMRMw
# EQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVN
# aWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNp
# Z25pbmcgUENBIDIwMTECEzMAAAEDXiUcmR+jHrgAAAAAAQMwCQYFKw4DAhoFAKCB
# ojAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYK
# KwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUBZ5YbsiRDnv8zGp0i5XptpAtUPgw
# QgYKKwYBBAGCNwIBDDE0MDKgFIASAE0AaQBjAHIAbwBzAG8AZgB0oRqAGGh0dHA6
# Ly93d3cubWljcm9zb2Z0LmNvbTANBgkqhkiG9w0BAQEFAASCAQAERjhgchI0NEL4
# QDpnZHGR5RngRlVJHfmBe2L0+E3EMLMutatjZfgkFWNj2HTFOQRGth/Vrf8m57J2
# oQlxB2iTRGuY0mjzuBwkMCuQWG42dq6UrT4pH1TIgy/DnFxnbChOPGPUAvpVC8A/
# kFXEk3CMqadAV045R2muLhZ4eA9EYcfWN17+hlKqxq1/zTIV78/LVRBBWZ8oFHKJ
# sm0k52ij5pX9Kl59/dPQxSOOIToFmMeSaYTfSidpjpa8NfHhDwovPzN4DumUmOCs
# 0sGXk1rY3zE8/28EBcY4zsDJlkgjOJ2thE7nhQP7EEF/v9JMS+sNXGCM7OxIBv9l
# sVitgtpEoYICKDCCAiQGCSqGSIb3DQEJBjGCAhUwggIRAgEBMIGOMHcxCzAJBgNV
# BAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4w
# HAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xITAfBgNVBAMTGE1pY3Jvc29m
# dCBUaW1lLVN0YW1wIFBDQQITMwAAAQJSCNjfQc3ntgAAAAABAjAJBgUrDgMCGgUA
# oF0wGAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMTgx
# MjA2MDM1NDUzWjAjBgkqhkiG9w0BCQQxFgQUb/tHlfjSewoEQAnruwWyTNw4sjgw
# DQYJKoZIhvcNAQEFBQAEggEAMBq0I/S3Wy04LSF3bpi5hkbKXGB2SOMjucH2YQaK
# o8j4E3V4142wyM5LL/i8LCP+Fj8L+4Cp3X4UFMoSOVBrXtQgOpTfX+rKDdnYiYqy
# xmDV1XpuJrTEBJlTcutkPjsMYUuNfTx7jvfiIeXKBVIRwzT/HplIInPlMERa6m2Q
# Ez7HdCV4/0a2MdBeAYJR7AjYs8XKo+BtdzxZInSwiZaUYq9FoJxWIjdTcIs6mYqs
# t7Z63KCNW0zKa8B0zPAomOltnt6iluJgt/8Cn2yymFUxTF8BVRsyQR0ICkwoGJTE
# ZIiU2chKyGOBhmp6kdcr+6bj74/9xHcNnxrQqREZgSLg4w==
# SIG # End signature block
