#Ensures script does not overlap with itself
ping 127.0.0.1 -n 5 | Out-Null

$config = Get-Content "C:\AutomateTools\config\config.json" -Raw | ConvertFrom-Json

    If ($config.auto_update -eq $False){
        Add-Content "C:\AutomateTools\logs\$(Get-Date -Format "yyyy-MM-dd")_update.log" "$(Get-Date -Format o) AutoUpdate is disabled. To enable Auto-Update, modify config.json."
        Exit
    }

    #Compare version
    $CurrentVersion = Get-Content "C:\AutomateTools\config\AT-Version.config"
    try{
        $LatestVersion = Invoke-WebRequest -Uri $config.update_uri -UseBasicParsing -ErrorAction Stop
    } Catch {
        Add-Content "C:\AutomateTools\logs\$(Get-Date -Format "yyyy-MM-dd")_update.log" "$(Get-Date -Format o) update_uri is empty or contains an invalid web address. Update is unable to continue."
        Exit
    }

If ($PSScriptRoot -eq "C:\AutomateTools\bin"){
    If ($CurrentVersion -ne $LatestVersion){
        Add-Content "C:\AutomateTools\logs\$(Get-Date -Format "yyyy-MM-dd")_update.log" "$(Get-Date -Format o) CurrentVersion: $CurrentVersion does not match LatestVersion: $LatestVersion. Attempting update."

        #Download update package
        If ($False -eq (Test-Path "C:\AutomateTools\updates")){
            New-Item -Path "C:\AutomateTools" -Name "updates" -ItemType Directory
        }
        try {
            If ($False -eq (Test-Path "C:\AutomateTools\updates\$LatestVersion.zip")){
                Invoke-WebRequest -Uri $config.update_zip_uri -OutFile "C:\AutomateTools\updates\$LatestVersion.zip" -ErrorAction Stop
            }
        } Catch {
            Add-Content "C:\AutomateTools\logs\$(Get-Date -Format "yyyy-MM-dd")_update.log" "$(Get-Date -Format o) update_zip_uri is empty or contains an invalid web address. Update is unable to continue."
            Exit
        }

        Expand-Archive -Path "C:\AutomateTools\updates\$LatestVersion.zip" -DestinationPath "C:\AutomateTools\updates\$LatestVersion" -Force
        
        Start-Job -FilePath "C:\AutomateTools\updates\$LatestVersion\bin\AT-Update.ps1"
    } Else {
        Add-Content "C:\AutomateTools\logs\$(Get-Date -Format "yyyy-MM-dd")_update.log" "$(Get-Date -Format o) CurrentVersion: $CurrentVersion is equal to LatestVersion: $LatestVersion."
        Exit
    }

} Elseif ($PSScriptRoot -ne "C:\AutomateTools\bin"){

    #Old files backup
    If ($False -eq (Test-Path "C:\AutomateTools\backup\$(Get-Date -Format "yyyy-MM-dd")")){
        New-Item -Path "C:\AutomateTools\backup" -Name "$(Get-Date -Format "yyyy-MM-dd")" -ItemType Directory | Out-Null
    }

    Move-Item -Path "C:\AutomateTools\bin" -Destination "C:\AutomateTools\backup\$(Get-Date -Format "yyyy-MM-dd")\bin"
    Move-Item -Path "C:\AutomateTools\config" -Destination "C:\AutomateTools\backup\$(Get-Date -Format "yyyy-MM-dd")\config"
    Move-Item -Path "C:\AutomateTools\lib" -Destination "C:\AutomateTools\backup\$(Get-Date -Format "yyyy-MM-dd")\lib"

    #New files transfer
    Copy-Item -Path "C:\AutomateTools\updates\$LatestVersion\bin" -Destination "C:\AutomateTools\bin" -Recurse
    Copy-Item -Path "C:\AutomateTools\updates\$LatestVersion\lib" -Destination "C:\AutomateTools\lib" -Recurse
    Copy-Item -Path "C:\AutomateTools\updates\$LatestVersion\config" -Destination "C:\AutomateTools\config" -Recurse

    #Rewrite config file
    $newConfig = Get-Content "C:\AutomateTools\config\config.json" -Raw | ConvertFrom-Json
    $newConfig.auto_update = $config.auto_update
    $newConfig.update_uri = $config.update_uri
    $newConfig | ConvertTo-Json | Set-Content "C:\AutomateTools\config\config.json"

    #End cleanup only the non-archive updates
    Remove-Item -Path "C:\AutomateTools\updates\$LatestVersion.zip"
    Add-Content "C:\AutomateTools\logs\$(Get-Date -Format "yyyy-MM-dd")_update.log" "$(Get-Date -Format o) Update complete."
}