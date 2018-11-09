<#
.SYNOPSIS
This is an auto-updater which deletes the current directory of C:\AutomateTools and installs the new files.
.EXAMPLE
Get-UpdateFiles
.LINK
https://github.com/WesScott000/AutomateTools
#>

Function Get-UpdateFiles{
    #Cleanup old files
    New-Item -ItemType "directory" -Path "C:\AutomateTools\Backup" -ErrorAction SilentlyContinue
    Copy-Item -Path "C:\AutomateTools\*.*" -Destination "C:\AutomateTools\Backup"
    Remove-Item -Path "C:\AutomateTools\*.*"
    
    #Download Directory
    $path = 'C:\AutomateTools\'

    #Filename and Download links in hash table for later enumeration
    $files = @{
        'AutomateTools.psm1' = 'https://raw.githubusercontent.com/dylanbartos/AutomateTools/master/AutomateTools/AutomateTools.psm1'
        'Get-NoahVersion.ps1' = 'https://raw.githubusercontent.com/dylanbartos/AutomateTools/master/AutomateTools/Get-NoahVersion.ps1'
        'Get-Update.ps1' = 'https://raw.githubusercontent.com/dylanbartos/AutomateTools/master/AutomateTools/Get-Update.ps1'
        'Get-WBStats.ps1' = 'https://raw.githubusercontent.com/dylanbartos/AutomateTools/master/AutomateTools/Get-WBStats.ps1'
        'version.txt' = 'https://raw.githubusercontent.com/dylanbartos/AutomateTools/master/AutomateTools/version.txt'
    }
    
    #Downloads each file in hash table $file
    foreach($file in $files.GetEnumerator()) {
        curl $($file.Value) -OutFile $(Join-Path -Path $path -ChildPath $($file.Name))
    }
    
    [int]$downloadedCount = $($(Get-ChildItem "C:\AutomateTools\" -File).Name | Measure-Object).Count
    [int]$neededCount = $($files.Keys | Measure-Object).Count
    if ($neededCount -eq $downloadedCount) {
        Write-Host "Files downloaded successfully."
        Remove-Item -Path "C:\AutomateTools\Backup" -Recurse
    }
    Else {
        Write-Host "Files failed to download successfully."
    }
}