<#
.SYNOPSIS
Backup-NoahDatabase makes a copy of the primary Noah database.
.DESCRIPTION
This command stops the Noah services and copies the default database to the default location of "C:\AutomateTools\Backups\ in a time stamped folder.
.PARAMETER Destination
Specifies an alternative path to save the backup database.
.LINK
https://github.com/WesScott000/AutomateTools
#>

Function Backup-NoahDatabase{
    param(
        $Destination = "C:\AutomateTools\Backups\"
    )

    # Key variables.
    [string] $BackupFolder = $Destination + "NoahDBBackup\"
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


<#
.SYNOPSIS
Backup-NoahModCfg creates a copy of the Noah module manifest.
.PARAMETER Destination
Specifies an alternative path to save the backup database.
.LINK
https://github.com/WesScott000/AutomateTools
#>

Function Backup-NoahModCfg{
    param(
        $Destination = "C:\AutomateTools\Backups\"
    )

    Push-FileStructure -Path $Destination

    [string] $ModConfig = "ClientSettings.xml"
    [string] $Path = ($env:ProgramData + "\HIMSA\Noah\")
    [string] $BackupFolder = $Destination + ("NoahModConfigBackup\")
    
    Copy-Item ($Path + $ModConfig) -Destination $BackupFolder
}