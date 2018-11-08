$url = 'https://raw.githubusercontent.com/dylanbartos/AutomateTools/master/AutomateTools/version.txt'
curl $url -OutFile tmp.file
if (Compare-Object -ReferenceObject $(Get-Content tmp.file) -DifferenceObject $(Get-Content version.txt))
    ##Different
    {"Files are different"}
Else
    ##Same
    {"Files are the same"}