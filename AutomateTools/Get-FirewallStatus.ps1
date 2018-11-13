<#
.SYNOPSIS
This command checks firewall profiles status and returns a value determinant upon the result of ALL profiles. In this scenario, one false = false result and all true = true result.
.EXAMPLE
Get-FirewallStatus
This command returns the value of the overall firewall status.
Output Options:
Enabled
:Public:Private:Domain: (disabled profiles)
.LINK
https://github.com/WesScott000/AutomateTools
#>

Function Get-FirewallStatus {
    #Get boolean values for all 3 profiles
    $Public = $(Get-NetFirewallProfile -Name Public).Enabled
    $Private = $(Get-NetFirewallProfile -Name Private).Enabled
    $Domain = $(Get-NetFirewallProfile -Name Domain).Enabled
    $Disabled = ":"

    #Compare values to each other
    If ($Public -eq $Private -eq $Domain -eq "True") {
        #Firewall is enabled.
        Write-Output "Enabled"
    }
    If ($Public -ne "True"){
        #Firewall is disabled on Public
        $Disabled = "$($Disabled)Public:"
    }
    If ($Private -ne "True"){
        #Firewall is disabled on Private
        $Disabled = "$($Disabled)Private:"
    }
    If ($Domain -ne "True"){
        #Firewall is disabled on Domain
        $Disabled = "$($Disabled)Domain:"
    }
    If ($Disabled -ne ":"){
        Write-Output $Disabled
    }
}