#Requires -RunAsAdministrator

If ($false -eq (Test-Path -Path "C:\AutomateTools")){
    New-Item -Path "C:\" -Name "AutomateTools" -ItemType "Directory" | Out-Null
}

#Profile is necessary in order to load the AutomateTools.psm1 module, which dot sources each PS script
If ((Test-Path "C:\Windows\System32\WindowsPowerShell\v1.0\profile.ps1") -eq $True){
    $ProfileExists = Select-String -Path "C:\Windows\System32\WindowsPowerShell\v1.0\profile.ps1" -Pattern 'lib\AutomateTools.psm1' -SimpleMatch
    If ($null -eq $ProfileExists){
        #Import-Module C:\AutomateTools\bin\AutomateTools.psm1 is critical to have inside of the profile.ps1
        Add-Content -Path "C:\Windows\System32\WindowsPowerShell\v1.0\profile.ps1" "Import-Module C:\AutomateTools\lib\AutomateTools.psm1"
    }
} Else {
    #Import-Module C:\AutomateTools\bin\AutomateTools.psm1 is critical to have inside of the profile.ps1
    Add-Content -Path "C:\Windows\System32\WindowsPowerShell\v1.0\profile.ps1" "Import-Module C:\AutomateTools\lib\AutomateTools.psm1"
}

###
#Add section for task scheduler running auto-updater
###

try{
    powershell Test-AT | Out-Null
}catch{
    Write-Host "Error occurred during installation. Test-AutomateTools failed. Check profile.ps1 installation."
}

If ((powershell Test-AT) -eq "Automate Tools Base Configuration: Successful!"){
    Write-Host "Installation Completed Successfully."
}Else{
    Write-Host "Error occurred during installation. Test-AutomateTools failed."
}