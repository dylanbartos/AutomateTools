<#
.SYNOPSIS
Get-WBStats collects information from Windows Server Backup and outputs the data into the format specified.
.DESCRIPTION

.PARAMETER FilePath

.PARAMETER OutputType

.PARAMETER Delimiter

.PARAMETER Threshold

.EXAMPLE

.LINK
https://github.com/WesScott000/AutomateTools
#>

Function Get-WBStats {
    param(
        [string] $FilePath = "C:\WBStats.xml",
        [ValidateSet("Xml", "CliXml", "Csv", "Cli")]
        [string] $OutputType = "Xml",
        $Delimiter = ",",
        [int] $Threshold = 1
    )

    # Added the Windows Server Backup module if not present
    If((Get-Command Get-WBSummary*).count -eq $Null){
        Add-PSSnapIn Windows.ServerBackup
    }

    # Storing native command output as objects
    $WBPolicy = Get-WBPolicy
    $WBSummary = Get-WBSummary

    # Getting datesfor script execution, last successful job, and next scheduled job
    [DateTime] $ScriptRun = Get-Date
    [DateTime] $LastSuccess = $WBSummary.LastSuccessfulBackupTime
    [DateTime] $NextJob = $WBSummary.NextBackupTime

    # Determining the age of the last successful backup
    $LastJob = New-TimeSpan -Start $LastSuccess -End $ScriptRun
    $Age = [math]::Round(($LastJob.Days) + (($LastJob.Hours) / 24), 2)

    # Calculating the duration of the last backup job
    $PreviousJob = Get-WBJob -Previous 1
    $JobRunTime = New-TimeSpan -Start $PreviousJob.StartTime -End $PreviousJob.EndTime

    # Getting the backup target type and scope of backup job
    $BackupType = (Get-WBBackupTarget -Policy $WBPolicy).TargetType
    $Scope = $WBPolicy.VolumesToBackup -join ", "

    # Getting all error logs for the threshold specified
    $ErrorLogs = (Get-WinEvent Microsoft-Windows-Backup |
        Where-Object {($_.LevelDisplayName -like 'Error') -and ($_.TimeCreated -ge ($ScriptRun).AddDays(-$Threshold))})
    [int] $EventLogErrors = $ErrorLogs.Count

    # Setting status to 'error' if backup age is above threshold or error were detected in that time frame
    $BackupStatus = "Normal"
    If(($Age -gt $Threshold) -Or ($EventLogErrors -gt 0)){
        $BackupStatus = "Error"
    }

    # Setting data in a hash table for output
    $Data = @{
        ScriptRun = $ScriptRun
        LastSuccess = $LastSuccess
        LastJobRunTime = $JobRunTime
        LastBackupAge = $Age
        NextJob = $NextJob
        Scope = $Scope
        BackupType = $BackupType
        EventLogErrors = $EventLogErrors
        BackupStatus = $BackupStatus
    }

    # Output data to XML format, determined by user input
    If($OutputType -eq "CliXml"){
        $Data | Export-Clixml -Path $FilePath
    }
    ElseIf($OutputType -eq "Csv"){
        Out-PlainCsv -FilePath $FilePath -Delimiter $Delimiter -Data $Data
    }
    ElseIf($OutputType -eq "Cli"){
        $Data
    }
    Else{
        Out-PlainXML -FilePath $FilePath -Data $Data
    }
}