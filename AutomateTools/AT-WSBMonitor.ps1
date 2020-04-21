Function New-ATWBLogEntry{
    param(
        [string] $EntryText,
        $File = "C:\AutomateTools\Logs\WSBLog.log",
        [string] $Date
    )
    $Line = "[" + $Date + "] " + $EntryText
    Add-Content $File $Line
}

<#
.SYNOPSIS
Get-ATWBStats collects information from Windows Server Backup and outputs the data as a file.
.DESCRIPTION
This command exports Windows Server Backup data as a file. Therefore, you must have the Windows Server Backup feature 
installed. Additionally, you must also save the file to a valid file location and specify the file name and type.
Additionally, you may also optionally output the collected data to the CLI window.
.PARAMETER FilePath
Accepts the full path of the desired output file. Must include full path, filename, and extension.
.PARAMETER LogPath
Accepts the path to the folder in which the log file will be stored. Must include a trailing slash.
.PARAMETER LogName
The file name of the log file you will create.
.PARAMETER LogGrooming
Specifies the maximum number of log entries. Oldest entries are removed.
.PARAMETER Threshold
Sets the threshold used to check event logs for backup errors. Accepts any integer from 0 to 31.
#>

Function Get-ATWBStats {
    param(
        [string] $FilePath = "C:\AutomateTools\Temp\WSBResult.xml",
        [string] $LogPath = "C:\AutomateTools\Logs\",
        [string] $LogName = "WSBLog.log",
        [int] $LogGrooming = 180,
        [ValidateRange(0,31)]
        [int] $Threshold = 1
    )

    If(((Get-Command Get-WBSummary*).count -eq 0) -Or ($Null -eq (Get-Command Get-WBSUmmary*))){
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
            $c | Select-Object -Last $LogGrooming | Out-File $File
        }
    }

    $LogEntry = "Backup Job Status = {0}; Last Job = {1}; Backup Age = {2}; Event Log Errors = {3};" `
        -f $BackupStatus.ToUpper(), $LastSuccess, $Age, $ErrorLogs.Count
    If($ErrorLogs.Count -gt 0){
        ForEach($e in $ErrorLogs){
            New-ATWBLogEntry -EntryText $e.message -Date ($e.TimeCreated | Get-Date -f s)
        }
    }
    New-ATWBLogEntry -EntryText $LogEntry -Date ($ScriptRun | Get-Date -Format s)  | Out-Null

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
        Out-ATPlainXML -FilePath $FilePath -Data $Data
    } Catch {
        Return "[ERROR] Unable to write XML data to file."
    }
}