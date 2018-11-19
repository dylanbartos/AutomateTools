<#
.SYNOPSIS
This command resets network interfaces using the winsock reset functionality. This command also reboots the computer. 
.EXAMPLE
Reset-Network
.LINK
https://github.com/WesScott000/AutomateTools
#>

Function Reset-Winsock {
    netsh winsock reset
    Reboot-Bitlocker
}
