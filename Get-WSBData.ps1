# Storing native command output as objects
$WBPolicy = Get-WBPolicy
$WBSummary = Get-WBSummary

# Getting dates for script execution, last successful backup, and next scheduled backup
[DateTime] $ScriptRun = Get-Date
[DateTime] $LastSuccess = Get-Date $WBSummary.LastSuccessfulBackupTime
[DateTime] $NextJob = Get-Date $WBSummary.NextBackupTime
$LastJobRun = New-TimeSpan -Start ($LastSuccess) -End (Get-Date)
$JobTimeFull = New-timeSpan -Start ($NextJob) -End ($LastSuccess).AddDays(1)

$BackupType = (Get-WBBackupTarget -Policy (Get-WBPolicy)).TargetType
$JobTime = [math]::Round($JobTimeFull.TotalMinutes, 2)
$Scope = (($WBPolicy | Select -Property VolumesToBackup | FT -HideTableHeaders | Out-String).trim()) -replace '[{}]', ''
$Age = [math]::Round(($LastJobRun.days + ($LastJobRun.hours / 24)), 2)
$WBErrors = (Get-WinEvent Microsoft-Windows-Backup | Where-Object {($_.LevelDisplayName -like 'Error') -and ($_.TimeCreated -ge (get-date).AddDays(-1))})

# Output for testing purposes

Write-Host "`nScript run timestamp: "$ScriptRun
Write-Host "Last Success: " $LastSuccess
Write-Host "Next Job: "$NextJob
Write-Host "Backup type: "$BackupType
Write-Host "The job ran for: $JobTime minutes"
Write-Host "Scope: $Scope"
Write-Host "Backup Age: $Age"
Write-Host "`nThe following errors were found in the log: `n" 
$WBErrors