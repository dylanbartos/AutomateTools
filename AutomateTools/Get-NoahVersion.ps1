<#
.SYNOPSIS
This is a simple command that finds and returns the Noah version number.
.EXAMPLE
Get-NoahVersion
This command returns the version of the Noah application.
.LINK
https://github.com/WesScott000/AutomateTools
#>

Function Get-NoahVersion{

    # Creates a RexEx and content object.
    [regex] $rx = "\d(.)[1-99](.)[1-99](.)\d\d\d\d"
    [string] $Content = Get-Content ($env:ProgramData + "\HIMSA\Noah\NoahSettings.xml")

    # Pulls the matching content from the RegEx object.
    $rx.match($Content).value
}


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

Function Remove-NoahBackups{
    param(
        [string] $Path = ($env:ProgramData + "\Himsa\Noah\Backup\Database"),
        [int] $Threshold = 90,
        [int] $Keep = 3,
        [bool] $CliOutput = $False
    )

    # Getting files within the specified date range within the specified folder.
    $TDate = (Get-Date).AddDays(-$Threshold)
    $Directories = Get-ChildItem $Path | Where-Object { $_.LastWriteTime -lt $TDate } | Select -Last 1000 -Skip $Keep
    $BackupsDeleted = 0

    # Iterates through the files and removes those that match the naming convention of the NOAH 4 backup files.
    ForEach ($Directory in $Directories){
        IF ($Directory.Name -Match "[2][0]\d\d(-)\d\d(-)\d\d( )\d\d(.)\d\d(.)\d\d"){
            Remove-Item -Path ($Path + "\" + $Directory) -Force -Recurse -ErrorAction Ignore
            $BackupsDeleted += 1
        }
    }

    # Optional output for the CLI.
    If($CliOutput = $True){
        $Directories = Get-ChildItem $Path
        $BackupCount = ($Directories | Measure-Object).count + $BackupsDeleted

        Write-Host "Noah backups: $BackupCount found. $BackupsDeleted removed."
    }
}


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