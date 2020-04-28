<#
.SYNOPSIS
Reset-Winsock command resets network interfaces using the winsock reset functionality. This command also reboots the computer. 
.EXAMPLE
Reset-Winsock
.LINK
https://github.com/dylanbartos/AutomateTools
#>

Function Reset-Winsock {
    netsh winsock reset
    Reboot-Bitlocker
}

<#
.SYNOPSIS
This command detects the network profile of the currently connected NIC and sets the profile to Private IF it is Public. It does not change domains.
.EXAMPLE
Set-ATNetProfilePrivate
#>

Function Set-ATNetProfilePrivate{
    #Gets currently connected network profiles
    $net = Get-NetConnectionProfile -IPv4Connectivity "Internet" -NetworkCategory "Public" -ErrorAction SilentlyContinue
    if ($Null -eq $net){
        Write-Host "No public profiles are connected. Unable to switch."
    }Else{
        $net.NetworkCategory = "Private"
        Set-NetConnectionProfile -InputObject $net
        Write-Host "Set profile to Private."
    }
}

<#
.SYNOPSIS
Test-ATPing will ping a set of URIs and log failures.
.EXAMPLE
#Mandatory Parameters = URI
#Script will only write to file/host when ping fails with date/timestamp
#URI = 192.168.0.1
#URI = www.google.com

#Example Command
#Test-ATPing "www.google.com", "192.168.0.1", "SVR-01"
#>

Function Test-ATPing {
    param (
        [Parameter(Mandatory=$True, Position=0)] [string[]] $URIs
    )

    If ((Test-Path "C:\AutomateTools\Logs") -eq $False) {
        New-Item -Path "C:\AutomateTools\Logs" -ItemType "Directory"
    }

    While ($True){
        foreach ($URI in $URIs) {
            If ((Test-Connection $URI -Quiet -Count 1) -eq $False){
                Add-Content -Path "C:\AutomateTools\Logs\PingTest.log" -Value (Get-Date)
                Write-Host (Get-Date)
                Add-Content -Path "C:\AutomateTools\Logs\PingTest.log" -Value "[FAILED] Ping to $URI." 
                Write-Host "[FAILED] Ping to $URI."
            }        
        }
    }
}