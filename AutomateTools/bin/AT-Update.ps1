$config = Get-Content "C:\AutomateTools\config\config.json" -Raw | ConvertFrom-Json

If ($config.auto_update -eq $False){
    Add-Content "C:\AutomateTools\logs\$(Get-Date -Format "yyyy-MM-dd")_update.log" "$(Get-Date -Format o) AutoUpdate is disabled. To enable Auto-Update, modify config.json."
    Exit
}

$CurrentVersion = Get-Content "C:\AutomateTools\config\AT-Version.config"
$LatestVersion = Invoke-WebRequest -Uri $config.update_uri 

If ($CurrentVersion -ne $LatestVersion){
    Invoke-WebRequest -Uri $config.update_zip_uri -OutFile "C:\AutomateTools\updates\$LatestVersion.zip"
}

