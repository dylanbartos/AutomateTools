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
        [ValidateSet("Xml", "CliXml", "Csv")]
        [string] $OutputType = "Xml",
        $Delimiter = ",",
        [ValidateRange(0,31)]
        [int] $Threshold = 1,
        [bool] $CliOutput = $False
    )

    # Added the Windows Server Backup module if not present
    If((Get-Command Get-WBSummary*).count -eq 0){
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
    
    Try {
        # Output data to XML format, determined by user input
        If($OutputType -eq "CliXml"){
            $Data | Export-Clixml -Path $FilePath
        }
        # Output data to CSV format, determined by user input
        ElseIf($OutputType -eq "Csv"){
            Out-PlainCsv -FilePath $FilePath -Delimiter $Delimiter -Data $Data
        }
        # Default output
        Else{
            Out-PlainXML -FilePath $FilePath -Data $Data
        }
        # Output result in the event of an output error
    } Catch {
        Write-Host "`n[!] There was a problem saving the output file. It's possible that:
        - The file path does not exit.
        - You don't have permissions to write to the file path."
    }

    # Output data to console if flagged for CLI output
    If($CliOutput -eq $True){
        $Data
    }
}