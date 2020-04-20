<#
.SYNOPSIS
Install-AutomateTools downloads and extracts the Automate package onto the C: drive. 

.PARAMETER Uri
Specifies the web location for which to download the Automate zip package from.

.PARAMETER Force
Overwrites the pre-existing PowerShell profile at %system32%\WindowsPowerShell\v1.0\profile.ps1.
#>
Function Install-AutomateTools {
    #Requires -RunAsAdministrator
    param (
        [Parameter(Mandatory=$True)]
        [string] $Uri,
        [switch] $Force
    )

    If ($false -eq (Test-Path -Path "C:\AutomateTools")){
        New-Item -Path "C:\" -Name "AutomateTools" -ItemType "Directory" | Out-Null
        New-Item -Path "C:\AutomateTools" -Name "Logs" -ItemType "Directory" | Out-Null
        New-Item -Path "C:\AutomateTools" -Name "Updates" -ItemType "Directory" | Out-Null
    }

    Invoke-WebRequest -Uri $Uri -OutFile "C:\AutomateTools\Installer.zip"
    Expand-Archive -Path "C:\AutomateTools\Installer.zip" -DestinationPath "C:\AutomateTools\Installer" -Force

    If ((Test-Path -Path "C:\Windows\System32\WindowsPowerShell\v1.0\profile.ps1") -eq $False){
        Move-Item -Path "C:\AutomateTools\Installer\profile.ps1" -Destination "C:\Windows\System32\WindowsPowerShell\v1.0\profile.ps1"
    } Else {
        If ($Force -eq $True ){
            Move-Item -Path "C:\AutomateTools\Installer\profile.ps1" -Destination "C:\Windows\System32\WindowsPowerShell\v1.0\profile.ps1" -Force
        } Else {
            Write-Host "PowerShell Profile already exists at '%system32%\WindowsPowerShell\v1.0\profile.ps1'."
            Write-Host "You will need to install the profile.ps1 file manually if 'n' is selected."
            $ForceProfile = Read-Host "Do you want to allow the installation to overwrite the profile [y | n]?"
            If (($ForceProfile -eq "y") -or ($ForceProfile -eq "Y")){
                Move-Item -Path "C:\AutomateTools\Installer\profile.ps1" -Destination "C:\Windows\System32\WindowsPowerShell\v1.0\profile.ps1" -Force
            }
        }
    } 
    
    Get-ChildItem -Path "C:\AutomateTools\Installer" | ForEach-Object {Move-Item -Path "C:\AutomateTools\Installer\$_" -Destination "C:\AutomateTools" -Force}
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