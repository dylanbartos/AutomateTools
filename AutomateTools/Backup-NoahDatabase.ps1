<#
.SYNOPSIS
Remove-NoahBackups removes backup files created by the Noah 4 system.
.DESCRIPTION
This command removes backup files from the default Noah backup location. You can specify an alternate path to the backup files if they are not in a default directory.
Optionally, you can specify the age of the files you wish to remove and retain a minimum number of backup copies, despite the age.
.PARAMETER Path
Specifies the path to the Noah 4 backups, if they are not in the default location of: C:\ProgramData\Himsa\Noah\Backup\Database
.PARAMETER Threshold
Specifies the age in days of the backups that you wish to remove. The deafult value is 90 days.
.PARAMETER Keep
Specifies the number of backup files you wish to keep regardless of the age. The default value is 3.
.PARAMETER CliOutput
Set this value to $True if you would like to see the output from the command.
.EXAMPLE
Remove-NoahBackups -Threshold 15 -Keep 1 -CliOutput $True
This command will remove all backups older than 15 days, keep 1 file at a minimum disregarding it's age, and output the result of the command.
.LINK
https://github.com/WesScott000/AutomateTools
#>

Function Backup-NoahDatabase{
    param(
        $Destination = "C:\AutomateTools\Backups"
    )

    # Key variables.
    [string] $BackupFolder = $Destination + ("NoahDB_" + (Get-Date -UFormat "%Y-%m-%d") + "\")
    [string] $DBPath = (${env:ProgramFiles(x86)} + "\Common Files\HIMSA Shared\")
    [string] $NOAHCfg = "NOAHCfgDatabase.sdf"
    [string] $NOAHCore = "NOAHDatabaseCoreSqlCompact.sdf"

    # Breaks down the supplied path; tests and reconstructs to make the folders in the file system.
    Push-FileStructure -Path $BackupFolder

    # Stops Noah services.
    Stop-Service -Name NoahClient, NoahServer

    # Get file hashes from source files.
    $CfgSourceHash = Get-FileHash ($DBPath + $NOAHCfg)
    $CoreSourceHash  = Get-FileHash ($DBPath + $NOAHCore)

    # Copy databases to desigranted backup folder.
    Copy-Item ($DBPath + $NOAHCfg) -Destination $BackupFolder
    Copy-Item ($DBPath + $NOAHCore) -Destination $BackupFolder

    # Get file hashes from copied files.
    $CfgDestHash = Get-FileHash ($BackupFolder + $NOAHCfg)
    $CoreDestHash  = Get-FileHash ($BackupFolder + $NOAHCore)

    # Compares file hashes to make sure they match
    $CfgHashMatch = $CfgSourceHash.hash -eq $CfgDestHash.hash
    $CoreHashMatch = $CoreSourceHash.hash -eq $CoreDestHash.hash

    # Stops Noah services.
    Start-Service -Name NoahClient, NoahServer

    # Output to confirm file copy accuracy
    Write-Host "$NOAHCfg hash match: $CfgHashMatch"
    Write-Host "$NOAHCore hash match: $CoreHashMatch"

}