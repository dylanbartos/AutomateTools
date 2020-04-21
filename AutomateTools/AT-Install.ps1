<#
.SYNOPSIS
Install-AutomateTools downloads and extracts the Automate package onto the C: drive. 

.PARAMETER Uri
Specifies the web location for which to download the Automate zip package from.
#>
Function Install-AutomateTools {
    #Requires -RunAsAdministrator
    param (
        [Parameter(Mandatory=$True)]
        [string] $Uri
    )

    If ($false -eq (Test-Path -Path "C:\AutomateTools")){
        New-Item -Path "C:\" -Name "AutomateTools" -ItemType "Directory" | Out-Null
        New-Item -Path "C:\AutomateTools" -Name "logs" -ItemType "Directory" | Out-Null
        New-Item -Path "C:\AutomateTools" -Name "updates" -ItemType "Directory" | Out-Null
        New-Item -Path "C:\AutomateTools" -Name "bin" -ItemType "Directory" | Out-Null
        New-Item -Path "C:\AutomateTools" -Name "config" -ItemType "Directory" | Out-Null
    }

    Invoke-WebRequest -Uri $Uri -OutFile "C:\AutomateTools\Installer.zip"
    Expand-Archive -Path "C:\AutomateTools\Installer.zip" -DestinationPath "C:\AutomateTools\Installer" -Force

    #Profile is necessary in order to load the AutomateTools.psm1 module, which dot sources each PS script
    $ProfileExists = Select-String -Path "C:\Windows\System32\WindowsPowerShell\v1.0\profile.ps1" -Pattern 'bin\AutomateTools.psm1' -SimpleMatch -ErrorAction SilentlyContinue
    If ($null -eq $ProfileExists){
        #Import-Module C:\AutomateTools\bin\AutomateTools.psm1 is critical to have inside of the profile.ps1
        Add-Content -Path "C:\Windows\System32\WindowsPowerShell\v1.0\profile.ps1" "Import-Module C:\AutomateTools\bin\AutomateTools.psm1"
    }
    
    Get-ChildItem -Path "C:\AutomateTools\Installer" | ForEach-Object {Move-Item -Path "C:\AutomateTools\Installer\$_" -Destination "C:\AutomateTools\bin" -Force}
    Remove-Item -Path "C:\AutomateTools\Installer.zip", "C:\AutomateTools\Installer"
    
    try{
        powershell Test-AutomateTools | Out-Null
    }catch{
        Write-Host "Error occurred during installation. Test-AutomateTools failed. Check profile.ps1 installation."
    }

    If ((powershell Test-AutomateTools) -eq "Automate Tools Base Configuration: Successful!"){
        Write-Host "Installation Completed Successfully."
    }Else{
        Write-Host "Error occurred during installation. Test-AutomateTools failed."
    }
}