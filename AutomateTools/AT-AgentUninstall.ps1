Function Remove-LabTech {
    param(
        [string] $Uri,
        [string] $HashUri
    )

    IF ((Test-Path -Path "C:\AutomateTools\Downloads") -eq $False){
        New-Item -Path "C:\AutomateTools\" -Name "Downloads" -ItemType "Directory" | Out-Null
    }

    Invoke-WebRequest -Uri $Uri -OutFile "C:\AutomateTools\Downloads\LT_Uninstaller.zip"
    $WebHash = $(Invoke-WebRequest -Uri $HashUri).Content
    $FileHash = $(Get-FileHash -Path "C:\AutomateTools\Downloads\LT_Uninstaller.zip" -Algorithm "SHA256").Hash

    IF ($WebHash -eq $FileHash){
        Expand-Archive -Path "C:\AutomateTools\Downloads\LT_Uninstaller.zip" -DestinationPath "C:\AutomateTools\Downloads\LT_Uninstaller" -Force
        Start-Process -FilePath "C:\AutomateTools\Downloads\LT_Uninstaller\Agent_Uninstall.exe"
        ping 127.0.0.1 -n 30 | Out-Null
        Start-Process -FilePath "C:\AutomateTools\Downloads\LT_Uninstaller\Uninstall.exe"
    }
}

Function Remove-ScreenConnect {
    param(
        [string] $ScreenConnectID
    )

    $ScreenConnect = Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -eq "ScreenConnect Client ($ScreenConnectID)"}
    If ($null -ne $ScreenConnect){
        $ScreenConnect.Uninstall()
    }
}