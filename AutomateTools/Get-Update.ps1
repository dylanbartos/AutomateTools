<#
.SYNOPSIS
This is a command that retrieves a file from the web and compares contents to the version.txt stored locally. If different, executes a download of script files.
If files are the same, terminates.
.EXAMPLE
Get-Update
This command will launch an auto-updater or terminate.
.LINK
https://github.com/WesScott000/AutomateTools
#>

Function Get-Update{
    $url = 'https://raw.githubusercontent.com/dylanbartos/AutomateTools/master/AutomateTools/version.txt'
    curl $url -OutFile C:\AutomateTools\tmp.file
    if (Compare-Object -ReferenceObject $(Get-Content C:\AutomateTools\tmp.file) -DifferenceObject $(Get-Content C:\AutomateTools\version.txt))
        ##Different
        {"Files are different"}
        #
        #
        #Add code to download and launch auto-updater.
        #
        #
    Else
        ##Same
        {"Files are the same"}

    ##Cleanup
    Remove-Item -Path C:\AutomateTools\tmp.file
}