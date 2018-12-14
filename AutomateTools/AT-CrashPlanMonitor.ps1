# A function called to run the API query. Accpets arguments passed from main function.
Function Invoke-CPRequest{
    param(
        [Parameter(Mandatory=$True)]
        $Credential,
        [Parameter(Mandatory=$True)]
        $Query
    )

    # Sending GET request for Code 42 console data.
    $RequestResults = ((Invoke-WebRequest -Credential $Credential -Uri ("https://www.crashplan.com/api/computer" + $Query)`
                        -UseBasicParsing -Method Get -ErrorAction SilentlyContinue -ErrorVariable ErrorResult).content |`
                        ConvertFrom-Json).data.computers

    # Returns result if response code is OK and exits on error with error message.
    Switch($?){
        "True"  {Return $RequestResults}
        "False" {Write -Host "Unable to authenticate or GUID was invalid."; Exit}
    }
}

# The main function called from the LabTech automation. Accepts credentials, GUID, and optional output path.
Function Get-CPData{
    param(
        [Parameter(Mandatory=$True)]
        $Username,
        [Parameter(Mandatory=$True)]
        $Password,
        $Guid,
        $OutputPath = "C:\AutomateTools\Temp\CPResults.xml"
    )

    # Converting $Username and $Password to a PSCredential object requered by Invoke-WebRequest.
    $Password = $Password | ConvertTo-SecureString -asPlainText -Force
    $Credential = New-Object System.Management.Automation.PSCredential($Username, $Password)

    # This is an exit intended to catch SBS servers that can't use Powershell 3 or greater.
    If ($PSVersiontable.PSVersion.Major -lt 3) {
        Return "Powershell v2 is not compatible with Invoke-WebRequest."; Exit
        }

    # If no GUID is supplied, all data is requested.
    If($Guid -EQ $Null){
        $AllResults = Invoke-CPRequest -Credential $Credential -Query "?active=True"

        # Iterates through all the results to see if any names match the local hostname.
        ForEach($Result in $AllResults){
            If($Result.name -match $env:ComputerName){
                $NumberOfResults += 1
                $Guid = $Result.GUID
            }
        }

        # If too many matches are found, the script will end.
        Switch($NumberOfResults){
            {$NumberOfResults -gt 1} {Return "No GUID specified and to many results match the hostname of the system."; Exit}
            {$NumberOfResults -lt 1} {Return "No GUID specified and no results match the system's local hostname."; Exit}
        }
    }
    $R = Invoke-CPRequest -Credential $Credential -Query ("?guid=" + $Guid)
    
   # Sets data into hash table for output.
   $data = @{
        Name = $R.name
        GUID = $GUID
        Status = $R.status
        AlertState = $R.alertState
        AlertMessage = ($R.alertStates).Replace("{}","")
        LastConnected = ($R.lastConnected).Substring(0, 19)
        ProductVersion = $R.productVersion
        ScriptRun = Get-Date -Format "s"
    }

    Out-PlainXML -FilePath $OutputPath -Data $data
}