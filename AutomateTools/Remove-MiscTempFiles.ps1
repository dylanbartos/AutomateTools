<#
.SYNOPSIS
Remove-MiscTempFiles removes files of the type and location specified from locations.
.DESCRIPTION
This tool should not be used in production as it's too powerful and there are a few strange bugs with enumerating the sub directories.
.EXAMPLE
This will remove all .log files in the C:\Windows\Logs\CBS\ folder that are older than 13 days and does not recurse through subdirectories.
Each file deleted must have a full file path that matches "C:\Windows\Logs\CBS\*.log".
    Remove-Files -Path "C:\Windows\Logs\CBS\" -FileType "*.log" -Age 14 -ValidationString "C:\Windows\Logs\CBS\*.log"
.EXAMPLE
This will iterate through all user downloads folders and remove all .scl files greater than or equal to one day in age.
Each file deleted must have a full file path that matches "C:\users\*\Downloads\*.scl".
    Remove-Files -Path "C:\users\*\Downloads\" -FileType "*.scl" -Age 1 -ValidationString "C:\users\*\Downloads\*.scl"
.EXAMPLE
This will remove all files in all subdirectories for the location "C:\Temp":
    Remove-Files -Path "C:\Temp\" -FileType "*.*" -Recurse $True -ValidationString "C:\Temp\*.*"
.LINK
https://github.com/WesScott000/AutomateTools
#>
Function Remove-MiscTempFiles {
    param(
        [Parameter(Mandatory=$True)]
        $Path,
        [Parameter(Mandatory=$True)]
        [string] $FileType,
        [bool] $Recurse = $False,
        [int] $Age = 0,
        [Parameter(Mandatory=$True)]
        $ValidationString
    )

    # Exit if path to location does not exist.
    If(!(Test-Path $Path)){
        Exit
    }

    # Getting path and date objects.
    $Path = Get-Item $Path
    [datetime] $TDate = (Get-Date).AddDays(-$Age)

    # Getting contents if recursion is specified.
    If($Recurse -eq $True){
        $Contents = Get-ChildItem -Path $Path.FullName -Recurse | Where-Object {($_.Extension -like $FileType)} 
    }

    # Getting contents where recursion is not required.
    Else{
        $Contents = Get-ChildItem -Path $Path.FullName | Where-Object {($_.Extension -like $FileType)}
    }

    # Enumerating contents and removing only those that share the same full path pattern specified.
    ForEach($c in $Contents){
        If($c.fullname -like $ValidationString){
        # Only outputs file names for now; pending further testing.
            $c #| Remove-Item
        }
    }
}


<#
.SYNOPSIS
Open-DiskCleanSetup simply opens the cleanmgr.exe configuration and saves the values under configuration number 7.
The configuration number can be modified.
.PARAMETER CfgNum
Allows you to change the configuration settings to save as a different value.
.EXAMPLE
Opens the configuration settings at the default value of 7:
    Open-DiskCleanSetup
.EXAMPLE 
Opens the configuration settings as a user specified value of 3:
    Open-DiskCleanSetup -CfgNum 3
.LINK
https://github.com/WesScott000/AutomateTools
#>
Function Open-DiskCleanSetup{
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
Run-DiskCleanup runs cleanmgr.exe at the default preconfigured settings of 7 and returns a timestamp.
The configuration number can be modified.
.PARAMETER CfgNum
Allows you to change the configuration settings to save as a different value.
.EXAMPLE
Runs cleanmgr.exe and uses the preconfigured settings assigned to configuration 7:
    Run-DiskCleanup
.EXAMPLE 
Runs cleanmgr.exe and uses the preconfigured settings assigned to configuration 3:
    Run-DiskCleanup -CfgNum 3
.LINK
https://github.com/WesScott000/AutomateTools
#>
Function Run-DiskCleanup{
    param(
        [int]$CfgNum = 7
    )
    # Running disk cleanup on preconfigured settings.
    cleanmgr /sagerun:$CfgNum | Out-Null

    # Add timestamp for script run.
    [DateTime] $ScriptRun = Get-Date
    Return $ScriptRun
}