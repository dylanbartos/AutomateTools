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
. $PSScriptRoot\AT-FileSystemAndOutput.ps1

# Old List
. $PSScriptRoot\Get-WBStats.ps1
. $PSScriptRoot\Get-NoahVersion.ps1
. $PSScriptRoot\Get-FirewallStatus.ps1
. $PSScriptRoot\Reboot-Bitlocker.ps1
. $PSScriptRoot\Remove-TempFiles.ps1
. $PSScriptRoot\Reset-Winsock.ps1
. $PSScriptRoot\Set-NetProfilePrivate.ps1
. $PSScriptRoot\Remove-MiscTempFiles.ps1