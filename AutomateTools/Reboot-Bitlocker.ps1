<#
.SYNOPSIS
This command initiates a remote reboot which includes a single-reboot suspension of Bitlocker.
*Warning* The reboot is forced.
.EXAMPLE
Reboot-Bitlocker
.LINK
https://github.com/WesScott000/AutomateTools
#>

Function Reboot-Bitlocker {
    [regex]$rx = "[O][n]"
    $BitlockerStatus = (manage-bde -status "C:")[11]
    if ($rx.Match($BitlockerStatus).Success -eq $True){
        Suspend-Bitlocker -MountPoint "C:" -RebootCount 1
        Restart-Computer -Force
    }
    Else {
        Restart-Computer -Force
    }
}
