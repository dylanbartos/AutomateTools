<#
.SYNOPSIS
Remove-LabTech completely uninstalls the remote agent and services.
.PARAMETER Uri
The web address for the LT Uninversal Uninstaller zip archive.
.EXAMPLE
Remove-ATLabTech -Uri "https://labtech.com/LT_Uninstaller.zip"
.NOTES
This function is designed so that the files can be hosted on your own server or in Amazon S3.
#>
Function Remove-ATLabTech {
    param(
        [Parameter (Mandatory=$True)]
        [string] $Uri
    )

    If ((Test-Path -Path "C:\AutomateTools\Downloads") -eq $False){
        New-Item -Path "C:\AutomateTools\" -Name "Downloads" -ItemType "Directory" | Out-Null
    }

    Invoke-WebRequest -Uri $Uri -OutFile "C:\AutomateTools\Downloads\LT_Uninstaller.zip"
    Expand-Archive -Path "C:\AutomateTools\Downloads\LT_Uninstaller.zip" -DestinationPath "C:\AutomateTools\Downloads\LT_Uninstaller" -Force
    Start-Process -FilePath "C:\AutomateTools\Downloads\LT_Uninstaller\Agent_Uninstall.exe"
}

<#
.SYNOPSIS
Remove-ScreenConnect completely uninstalls a ScreenConnect agent.
.PARAMETER ScreenConnectID
The unique ID found in all ScreenConnect installations. This is a per-server ID, meaning it exists the same across all of your agents. It exists inside of the parentheses of the installation display name.
.EXAMPLE
Remove-ATScreenConnect -ID "a098416j5c0c3908"
#>
Function Remove-ATScreenConnect {
    param(
        [Parameter (Mandatory=$True)]
        [string] $ID
    )

    $ScreenConnect = Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -eq "ScreenConnect Client ($ID)"}
    If ($null -ne $ScreenConnect){
        $ScreenConnect.Uninstall()
    }
}