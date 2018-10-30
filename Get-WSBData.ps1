# Storing native command output as objects
$WBPolicy = Get-WBPolicy
$WBSummary = Get-WBSummary

# Getting datesfor script execution, last successful job, and next scheduled job
[DateTime] $ScriptRun = Get-Date
[DateTime] $LastSuccess = $WBSummary.LastSuccessfulBackupTime
[DateTime] $NextJob = $WBSummary.NextBackupTime

# Determining the age of the last successful backup
$LastJob = New-TimeSpan -Start ($LastSuccess) -End (Get-Date)
$Age = [math]::Round(($LastJob.Days) + (($LastJob.Hours) / 24), 2)

# Getting the backup target type and scope of backup job
$BackupType = (Get-WBBackupTarget -Policy $WBPolicy).TargetType
$Scope = $WBPolicy.VolumesToBackup -join ", "

# Getting all error logs for the time specified
$WBErrors = (Get-WinEvent Microsoft-Windows-Backup |
    Where-Object {($_.LevelDisplayName -like 'Error') -and ($_.TimeCreated -ge (get-date).AddDays(-1))})


###############################
# Output for testing purposes #
Write-Host "`nScript Run Timestamp: "$ScriptRun
Write-Host "Last Success: " $LastSuccess
Write-Host "Next Job: "$NextJob
Write-Host "Backup Type: "$BackupType
Write-Host "Scope: $Scope"
Write-Host "Backup Age: $Age Days"
Write-Host "`nThe following errors were found in the log: `n" 
$WBErrors