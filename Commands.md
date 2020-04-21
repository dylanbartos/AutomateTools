# Commands
This file serves as a repository for each command in AutomateTools and includes a brief description and example usage.
[Brackets] serve as examples of real input, they are not valid parameters.

### AT-Install.ps1
Installs the AutomateTools software. Requires Administrator privleges. You must edit the file when hosting to include the archive address of the AutomateTools package. Amazon S3 works great for this.
On your own workstation, download the file and open an admin powershell session. Set your directory to the location of the downloaded script and "./AT-Install.ps1". This works great for local testing. For wide-scale automated deployments, host the AT-Install.ps1 file just as you would host the AutomateTools archive and run the below command in an admin session.

Invoke-WebRequest -Uri [https://example.com/AT-Install.ps1] -OutFile "~\Downloads\AT-Install.ps1"; cd "~\Downloads"; ./AT-Install.ps1; Remove-Item "~\Downloads\AT-Install.ps1"

### Get-ATWBStats
Pulls data from the event logs and WB cmdlets on WindowsServerBackup operations, writes to file using New-ATWBLogEntry.

Get-ATWBStats -FilePath [OptionalAlternateIfSpecified] -LogPath [OptionalAlternateIfSpecified] -LogName [OptionalAlternateIfSpecified] -LogGrooming [int][OptionalAlternateIfSpecified] -Threshold [int][OptionalAlternateIfSpecified]

### New-ATWBLogEntry
Writes data from Get-ATWBStats to a log file. This log file can then be used for data extraction with ConnectWise Automate.

New-ATWBLogEntry -EntryText "Hello World" -File [OptionalAlternateIfSpecified] -Date [WBLogDatestamp]

### Remove-ATLabTech
Used to completely remove the LabTech agent by utilizing the universal uninstaller package.

Remove-ATLabTech -Uri [https://example.com/UniversalUninstaller.exe]

### Remove-ATScreenConnect
Used to completely remove a specified ScreenConnect installation. Must have the ID (found in parentheses of the installation display name).

Remove-ATScreenConnect -ID [a098416j5c0c3908]

### Restart-ATBitlocker
Checks the current bitlocker status, suspends if drive is fully encrypted, then forcefully reboots. If bitlocker is not enabled, forcefully restarts computer.

Restart-ATBitlocker
