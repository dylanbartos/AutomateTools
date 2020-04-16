Function Test-AutomateTools{

    [bool] $CatResult = $False

    If(Test-Path "C:\Windows\System32\WindowsPowerShell\v1.0\profile.ps1"){
        [string] $R = cat "C:\Windows\System32\WindowsPowerShell\v1.0\profile.ps1"
        If($R -like "Import-Module C:\AutomateTools\AutomateTools.psm1"){
            $CatResult = $True
        }
    }

    Else{
        Return "C:\Windows\System32\WindowsPowerShell\v1.0\profile.ps1 is not present."
        Exit
    }

    If($CatResult -eq $True){
        Return "Automate Tools Base Configuration: Successful!"
    }
}
 
# Updated List
. $PSScriptRoot\AT-BitLockerUtilities.ps1
. $PSScriptRoot\AT-DiskUtilities.ps1
. $PSScriptRoot\AT-FirewallUtilities.ps1
. $PSScriptRoot\AT-NetworkUtilities.ps1
. $PSScriptRoot\AT-NoahUtilities.ps1
. $PSScriptRoot\AT-OutputUtilities.ps1
. $PSScriptRoot\AT-AgentUninstall.ps1
. $PSScriptRoot\AT-CPMonitor.ps1
. $PSScriptRoot\AT-WSBMonitor.ps1
