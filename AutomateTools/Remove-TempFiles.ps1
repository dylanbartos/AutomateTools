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

    Try{
        cleanmgr /sageset:1
        Write-Host "The Disk Cleanup utility configuration is now open!`n"
        Write-Host "Here is a listing of options typically selected:"
        Write-Host " [x] Temporary Setup Files"
        Write-Host " [x] Old ChkDsk Files"
        Write-Host " [x] Setup Log Files"
        Write-Host " [x] Windows Update Cleanup"
        Write-Host " [x] Windows Defender AntiVirus"
        Write-Host " [x] Windows Upgrade Log Files"
        Write-Host " [x] Downloaded Program Files"
        Write-Host " [x] Temporary Internet Files"
        Write-Host " [x] Files Discarded By Windows Upgrade"
        Write-Host " [x] Windows ESD INstallation Files"
        Write-Host " [x] Previous Windows Installation(s)"
        Write-Host " [x] Recycle Bin"
        Write-Host " [x] Retail Demo Offline Content"
        Write-Host " [x] Update Package Backup Files"
        Write-Host " [x] Temporary Files"
        Write-Host " [x] Temporary Windows Installation Files"
        Write-Host "`nAfter selecting the desired options, automated disk cleanups can be scheduled:"
        Write-Host " - Automatically through flagging the Dick Celanup EDF in ConnectWise Automate."
        Write-Host " - Manually through Task Scheduler using 'cleanmgr /sagerun:1' command."

    }Catch{
        Write-Host "CleanMgr.exe was not found on this system or is not listed in the environment variables."
    }
}


Function Run-DiskCleanup{
    param(
        [int]$CfgNum = 0
    )
    cleanmgr /sagerun:$CfgNum
}