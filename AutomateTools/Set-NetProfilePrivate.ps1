<#
.SYNOPSIS
This command detects the network profile of the currently connected NIC and sets the profile to Private IF it is Public. It does not change domains.
.EXAMPLE
Set-NetProfile
.LINK
https://github.com/WesScott000/AutomateTools
#>

Function Set-NetProfilePrivate{
    #Gets currently connected network profiles
    $net = Get-NetConnectionProfile -IPv4Connectivity "Internet" -NetworkCategory "Public" -ErrorAction SilentlyContinue
    if ($net -eq $Null){
        Write-Host "No public profiles are connected. Unable to switch."
    }Else{
        $net.NetworkCategory = "Private"
        Set-NetConnectionProfile -InputObject $net
        Write-Host "Set profile to Private."
    }
}