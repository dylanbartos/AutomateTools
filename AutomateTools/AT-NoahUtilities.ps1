<#
.SYNOPSIS
This is a simple command that finds and returns the Noah version number.
.EXAMPLE
Get-NoahVersion
This command returns the version of the Noah application.
.LINK
https://github.com/dylanbartos/AutomateTools
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
.LINK
https://github.com/dylanbartos/AutomateTools
#>

Function Remove-NoahBackups{
    param(
        [string] $Path = ($env:ProgramData + "\Himsa\Noah\Backup\Database"),
        [int] $Threshold = 90,
        [int] $Keep = 3
    )

    $TDate = (Get-Date).AddDays(-$Threshold)
    $Directories = Get-ChildItem $Path | Where-Object { $_.LastWriteTime -lt $TDate } | Select -Last 1000 -Skip $Keep
    $BackupsDeleted = 0

    ForEach ($Directory in $Directories){
        IF ($Directory.Name -Match "[2][0]\d\d(-)\d\d(-)\d\d( )\d\d(.)\d\d(.)\d\d"){
            Remove-Item -Path ($Path + "\" + $Directory) -Force -Recurse -ErrorAction Ignore
            $BackupsDeleted += 1
        }
    }
}