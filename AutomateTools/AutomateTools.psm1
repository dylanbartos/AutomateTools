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
. C:\AutomateTools\AT-BitLockerUtilities.ps1
. C:\AutomateTools\AT-CPMonitor.ps1
. C:\AutomateTools\AT-DiskUtilities.ps1
. C:\AutomateTools\AT-FirewallUtilities.ps1
. C:\AutomateTools\AT-Install.ps1
. C:\AutomateTools\AT-NetworkUtilities.ps1
. C:\AutomateTools\AT-NoahUtilities.ps1
. C:\AutomateTools\AT-OutputUtilities.ps1
. C:\AutomateTools\AT-WSBMonitor.ps1