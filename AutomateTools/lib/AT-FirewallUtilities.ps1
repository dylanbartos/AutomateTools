<#
.SYNOPSIS
This command checks firewall profiles status and returns a value determinant upon the result of ALL profiles. In this scenario, one false = false result and all true = true result.
.EXAMPLE
Get-ATFirewallStatus
This command returns the value of the overall firewall status.
Tested OS: Win10, Win7, SBS 2011
Output Options:
Enabled
:Public:Private:Domain: (disabled profiles)
#>

Function Get-ATFirewallStatus {
    #Define Regex value and retrieve firewall status
    #netsh returns an array, the 'State' (ON or OFF) line is [3]. This was used to decrease regex false positive surface.
    [regex]$rx = "[O][N]"
    $netshPublic = $(netsh advfirewall show publicprofile)[3]
    $netshPrivate = $(netsh advfirewall show privateprofile)[3]
    $netshDomain = $(netsh advfirewall show domainprofile)[3]
    $Disabled = ":"

    #Match the netsh state value against regex to determine ON = True and OFF = False
    $Public = $rx.Match($netshPublic).Success
    $Private = $rx.Match($netshPrivate).Success
    $Domain = $rx.Match($netshDomain).Success

    #Compare values to each other
    If ($Public -eq $Private -eq $Domain -eq "ON") {
        #Firewall is enabled.
        Write-Output "Enabled"
    }
    If ($Public -ne "ON"){
        #Firewall is disabled on Public
        $Disabled = "$($Disabled)Public:"
    }
    If ($Private -ne "ON"){
        #Firewall is disabled on Private
        $Disabled = "$($Disabled)Private:"
    }
    If ($Domain -ne "ON"){
        #Firewall is disabled on Domain
        $Disabled = "$($Disabled)Domain:"
    }
    If ($Disabled -ne ":"){
        Write-Output $Disabled
    }
}