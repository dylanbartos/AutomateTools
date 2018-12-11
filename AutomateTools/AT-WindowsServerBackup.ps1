<#
.SYNOPSIS
Get-WBStats collects information from Windows Server Backup and outputs the data as a file.
.DESCRIPTION
This command exports Windows Server Backup data as a file. Therefore, you must have the Windows Server Backup feature 
installed. Additionally, you must also save the file to a valid file location and specify the file name and type.
Additionally, you may also optionally output the collected data to the CLI window.
.PARAMETER FilePath
Accepts the full path of the desired output file. Must include full path, filename, and extension.
.PARAMETER OutputType
Accepts 'xml', 'clixml', or 'csv' depending on the desired output result. Set to 'xml' by default.
.PARAMETER Delimiter
Accepts and delimiter to be used with 'csv' output. Set to ',' by default.
.PARAMETER Threshold
Sets the threshold used to check event logs for backup errors. Accepts any integer from 0 to 31.
.PARAMETER CliOutput
Accepts $True or $False. Setting to $True will output data results to the CLI.
.EXAMPLE
This is the most basic form of the command. The results will be xml data stored in the file as specified:
    Get-WBStats -FilePath "C:\Logs\WBStatsResults.xml"
.EXAMPLE
This command will run as the previous example but also output the data to the CLI on completion:
    Get-WBStats -FilePath "C:\Logs\WBStatsResults.xml" -CliOutput $True
.EXAMPLE
This command will output a file that contains clixml data, checking the Windows Server Backup event logs for errors during the last 14 days.
    Get-WBStats -FilePath "C:\Logs\WBStatsResults.xml" -OutputType clixml -Threshold 14
.EXAMPLE
This command will output a file that contains comma seperated values and replace the commas with a vertical pipe delimiter:
    Get-WBStats -FilePath "C:\Logs\WBStatsResults.csv" -OutputType csv -Delimiter " | "
.LINK
https://github.com/WesScott000/AutomateTools
#>

Function Get-WBStats {
    param(
        [Parameter(Mandatory=$True)]
        [string] $FilePath,
        [string] $LogPath = "C:\AutomateTools\Logs\",
        [string] $LogName = "WindowsServerBackup.log",
        [int] $LogGrooming = 180,
        [ValidateSet("Xml", "CliXml", "Csv")]
        [string] $OutputType = "Xml",
        $Delimiter = ",",
        [ValidateRange(0,31)]
        [int] $Threshold = 1,
        [bool] $CliOutput = $False
    )

    Function New-WBLogEntry{
        param(
            [string] $EntryText,
            $File = "C:\AutomateTools\Logs\WindowsServerBackup.log",
            [string] $Date
        )
        $Line = "[" + $Date + "] " + $EntryText
        Add-Content $File $Line
    }

    If(((Get-Command Get-WBSummary*).count -eq 0) -Or ((Get-Command Get-WBSUmmary*) -eq $Null)){
        Add-PSSnapIn Windows.ServerBackup
    }

    $WBPolicy = Get-WBPolicy
    $WBSummary = Get-WBSummary

    [DateTime] $ScriptRun = Get-Date
    [DateTime] $LastSuccess = $WBSummary.LastSuccessfulBackupTime
    [DateTime] $NextJob = $WBSummary.NextBackupTime

    $LastJob = New-TimeSpan -Start $LastSuccess -End $ScriptRun
    $Age = [math]::Round(($LastJob.Days) + (($LastJob.Hours) / 24), 2)
    $PreviousJob = Get-WBJob -Previous 1
    $JobRunTime = New-TimeSpan -Start $PreviousJob.StartTime -End $PreviousJob.EndTime
    $BackupType = (Get-WBBackupTarget -Policy $WBPolicy).TargetType
    $Scope = $WBPolicy.VolumesToBackup -join ", "

    $ErrorLogs = (Get-WinEvent Microsoft-Windows-Backup |
        Where-Object {($_.LevelDisplayName -like 'Error') -and ($_.TimeCreated -ge ($ScriptRun).AddDays(-$Threshold))})
    $BackupStatus = "Normal"
    If(($Age -gt $Threshold) -Or ($ErrorLogs.count -gt 0)){
        $BackupStatus = "Error"
    }

    $FullPath = $LogPath + $LogName
    If(!(Test-Path $LogPath)){
        New-Item -Path $LogPath -ItemType Directory
        New-Item -Path $FullPath -ItemType File
    }
    Else{
        $c = Get-Content $FullPath
        If($c.count -gt $LogGrooming){
            $c | Select -Last $LogGrooming | Out-File $File
        }
    }

    $LogEntry = "Backup Job Status = {0}; Last Job = {1}; Backup Age = {2}; Error count = {3};" `
        -f $BackupStatus.ToUpper(), $LastSuccess, $Age, $ErrorLogs.Count
    If($ErrorLogs.Count -gt 0){
        ForEach($e in $ErrorLogs){
            New-WBLogEntry -EntryText $e.message -Date ($e.TimeCreated | Get-Date -f s)
        }
    }
    New-WBLogEntry -EntryText $LogEntry -Date ($ScriptRun | Get-Date -Format s)  | Out-Null

    $Data = @{
        ScriptRun = $ScriptRun | Get-Date -Format s
        Archive = $WBSummary.NumberOfVersions
        LastSuccess = $LastSuccess | Get-Date -Format s
        LastJobRunTime = $JobRunTime
        LastBackupAge = $Age
        NextJob = $NextJob | Get-Date -Format s
        Scope = $Scope
        BackupType = $BackupType
        EventLogErrors = $ErrorLogs.Count
        BackupStatus = $BackupStatus
    }
    
    Try {
        If($OutputType -eq "CliXml"){
            $Data | Export-Clixml -Path $FilePath
        }
        ElseIf($OutputType -eq "Csv"){
            Out-PlainCsv -FilePath $FilePath -Delimiter $Delimiter -Data $Data
        }
        Else{
            Out-PlainXML -FilePath $FilePath -Data $Data
        }
    } Catch {
        Write-Host "`n[!] There was a problem saving the output file. It's possible that:
        - The file path does not exit.
        - You don't have permissions to write to the file path."
    }

    If($CliOutput -eq $True){
        $Data
    }
}