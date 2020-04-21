# Commands
This file serves as a repository for each command in AutomateTools and includes a brief description and example usage.
[Brackets] serve as examples of real input, they are not valid parameters.

### Install-AT
Installs the AutomateTools software. Requires Administrator privleges. 

Install-AT -Uri [https://example.com/AT-Install.ps1]

### Remove-ATLabTech
Used to completely remove the LabTech agent by utilizing the universal uninstaller package.

Remove-ATLabTech -Uri [https://example.com/UniversalUninstaller.exe]

### Remove-ATScreenConnect
Used to completely remove a specified ScreenConnect installation. Must have the ID (found in parentheses of the installation display name).

Remove-ATScreenConnect -ID [a098416j5c0c3908]

### Restart-ATBitlocker
Checks the current bitlocker status, suspends if drive is fully encrypted, then forcefully reboots. If bitlocker is not enabled, forcefully restarts computer.

Restart-ATBitlocker
