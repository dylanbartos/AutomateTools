<#
.SYNOPSIS
Open-ATDiskCleanSetup simply opens the cleanmgr.exe configuration and saves the values under configuration number 7.
The configuration number can be modified.
.PARAMETER CfgNum
Allows you to change the configuration settings to save as a different value.
.EXAMPLE
Opens the configuration settings at the default value of 7:
    Open-ATDiskCleanSetup
.EXAMPLE 
Opens the configuration settings as a user specified value of 3:
    Open-ATDiskCleanSetup -CfgNum 3
#>
Function Open-ATDiskCleanSetup{
    param(
        [int]$CfgNum = 7
    )

    # Starting CLI output for technican interaction.
    Write-Host "`n              ** MICROSOFT DISK CLEANUP CONFIGURATION **`n"

    # Running cleanmgr.exe if available.
    Try{
        cleanmgr /sageset:$CfgNum

        # CLI output that runs on success.
        Write-Host "Status: Success!" -ForegroundColor Green
        Write-Host "`n"
        Write-Host "You have opened the configuration for the Microsoft Disk Cleanup utility.`n"
        Write-Host "1. Select all options you wish to clean on an automated schedule. It's"
        Write-Host "   recommended that all options be selected with the exception of error"
        Write-Host "   logs.`n"
        Write-Host "2. When all desired options have been selected, please click 'ok' to save"
        Write-Host "   the configuration.`n"
        Write-Host "3. In the Connectwise Automate computer management screen enable the"
        Write-Host "   option to automate scheduled disk cleanups. This option is located in:`n"
        Write-Host "	Extra Data Fields > Disk Cleanup > Automate Cleanups" -ForegroundColor Yellow
    }Catch{
        # Cli output given if error occurs with cleanmgr.exe.
        Write-Host "Status: FAIL`n" -ForegroundColor Magenta
        Write-Host "cleanmgr.exe could not be found.`n"
        Write-Host "If you are configuring Disk Cleanup for a Server 2008 or 2012 you might need"
        Write-Host "to manually configure cleanmgr and set it's path within the environment"
        Write-Host "variables.`n"
        Write-Host "Directions on how to do this can be found here. However, it is not recommended"
        Write-Host "to install the Desktop Experience role on servers.`n"
        Write-Host "Article: https://support.appliedi.net/kb/a110/how-to-enable-the-disk-cleanup-tool-on-windows-server-2008-r2.aspx"
    }
}


<#
.SYNOPSIS
Start-ATDiskCleanup runs cleanmgr.exe at the default preconfigured settings of 7 and returns a timestamp.
The configuration number can be modified.
.PARAMETER CfgNum
Allows you to change the configuration settings to save as a different value.
.EXAMPLE
Runs cleanmgr.exe and uses the preconfigured settings assigned to configuration 7:
    Start-ATDiskCleanup
.EXAMPLE 
Runs cleanmgr.exe and uses the preconfigured settings assigned to configuration 3:
    Start-ATDiskCleanup -CfgNum 3
.LINK
https://github.com/WesScott000/AutomateTools
#>
Function Start-ATDiskCleanup{
    param(
        [int]$CfgNum = 7
    )
    # Running disk cleanup on preconfigured settings.
    cleanmgr /sagerun:$CfgNum | Out-Null

    # Add timestamp for script run.
    [DateTime] $ScriptRun = Get-Date
    Return $ScriptRun
}