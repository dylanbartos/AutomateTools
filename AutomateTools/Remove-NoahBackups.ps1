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
        [string] $Path = "C:\ProgramData\Himsa\Noah\Backup\Database",
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