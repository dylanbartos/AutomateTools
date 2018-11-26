Function Remove-TempFiles{

    Function Remove-Files {
        param(
            $Path,
            [string] $FileType = "*.*",
            [bool] $Recurse = $False,
            [int] $Age = 0,
            [Parameter(Mandatory=$True)]
            $ValidationString
        )

        If(!(Test-Path $Path)){
            Exit
        }

        $Path = Get-Item $Path
        [datetime] $TDate = (Get-Date).AddDays(-$Age)

        If($Recurse -eq $True){
            $Contents = Get-ChildItem -Path $Path.FullName -Recurse | Where-Object {($_.Extension -like $FileType)} 
        }

        Else{
            $Contents = Get-ChildItem -Path $Path.FullName | Where-Object {($_.Extension -like $FileType)}
        }

        ForEach($c in $Contents){
            If($c.fullname -like $ValidationString){
                $c | Remove-Item
            }
        }
    }

# List of specific temp locations
Remove-Files -Path ("C:\Windows\temp\") -Recurse $True -ValidationString "C:\Windows\temp\*"
Remove-Files -Path ("C:\Windows\Logs\CBS\") -FileType "*.log" -Age 14 -ValidationString "C:\Windows\Logs\CBS\*.log"
Remove-Files -Path ("C:\users\*\AppData\Local\Temp\") -FileType "*.*" -ValidationString "C:\users\*\AppData\Local\Temp\*"
Remove-Files -Path ("C:\users\*\Downloads\") -FileType "*.scl" -ValidationString "C:\users\*\Downloads\*.scl"
}

Function Open-DiskCleanSetup{

    Write-Host "`n              ** MICROSOFT DISK CLEANUP CONFIGURATION **`n"

    Try{
        cleanmgr /sageset:7

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


Function Run-DiskCleanup{
    param(
        [int]$CfgNum = 7
    )
    [DateTime] $ScriptRun = Get-Date
    cleanmgr /sagerun:$CfgNum | Out-Null
    Return $ScriptRun
}