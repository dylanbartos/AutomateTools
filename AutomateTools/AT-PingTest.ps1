#Mandatory Parameters = URI
#Script will only write to file/host when ping fails with date/timestamp

#Examples:
#URI = 192.168.0.1
#URI = www.google.com

#Example Command
#AT-PingTest "www.google.com", "192.168.0.1", "SVR-01"

Function AT-PingTest {
    param (
        [Parameter(Mandatory=$True, Position=0)] [string[]] $URIs
    )

    If ((Test-Path "C:\AutomateTools\Logs") -eq $False) {
        New-Item -Path "C:\AutomateTools\Logs" -ItemType "Directory"
    }

    While ($True){
        foreach ($URI in $URIs) {
            If ((Test-Connection $URI -Quiet -Count 1) -eq $False){
                Add-Content -Path "C:\AutomateTools\Logs\PingTest.log" -Value (Get-Date)
                Write-Host (Get-Date)
                Add-Content -Path "C:\AutomateTools\Logs\PingTest.log" -Value "[FAILED] Ping to $URI." 
                Write-Host "[FAILED] Ping to $URI."
            }        
        }
    }
}