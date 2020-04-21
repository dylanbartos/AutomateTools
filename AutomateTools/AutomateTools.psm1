Function Test-AutomateTools{
    $ProfileExists = Select-String -Path "C:\Windows\System32\WindowsPowerShell\v1.0\profile.ps1" -Pattern 'bin\AutomateTools.psm1' -SimpleMatch -ErrorAction SilentlyContinue
    If ($null -eq $ProfileExists){
        Return "C:\Windows\System32\WindowsPowerShell\v1.0\profile.ps1 is not present or 'Import-Module C:\AutomateTools\bin\AutomateTools.psm1' is not in the profile.ps1."
    }Else{
        Return "Automate Tools Base Configuration: Successful!"
        Exit
    }
}
 
# Updated List
. $PSScriptRoot\AT-AgentUninstall.ps1
. $PSScriptRoot\AT-BitLockerUtilities.ps1
. $PSScriptRoot\AT-CPMonitor.ps1
. $PSScriptRoot\AT-DiskUtilities.ps1
. $PSScriptRoot\AT-FirewallUtilities.ps1
. $PSScriptRoot\AT-Install.ps1
. $PSScriptRoot\AT-NetworkUtilities.ps1
. $PSScriptRoot\AT-NoahUtilities.ps1
. $PSScriptRoot\AT-OutputUtilities.ps1
. $PSScriptRoot\AT-WSBMonitor.ps1
