Function Invoke-CPRequest{
    param(
        [Parameter(Mandatory=$True)]
        $Credential,
        [Parameter(Mandatory=$True)]
        $Query
    )

    $RequestResults = ((Invoke-WebRequest -Credential $Credential -Uri ("https://www.crashplan.com/api/computer" + $Query)`
                        -UseBasicParsing -Method Get -ErrorAction SilentlyContinue -ErrorVariable ErrorResult).content |`
                        ConvertFrom-Json).data.computers

    Switch($?){
        "True"  {Return $RequestResults}
        "False" {Write -Host "[ERROR] Unable to authenticate or GUID was invalid."; Exit}
    }
}

Function New-CPLogEntry{
    param(
        [string] $EntryText,
        $File = "C:\AutomateTools\Logs\CrashPlan.log",
        [string] $Date
    )
    $Line = "[" + $Date + "] " + $EntryText
    Add-Content $File $Line
}

Function Get-CPData{
    param(
        [Parameter(Mandatory=$True)]
        $Username,
        [Parameter(Mandatory=$True)]
        $Password,
        $Guid,
        $OutputPath = "C:\AutomateTools\Temp\CPResults.xml"
    )

    $Password = $Password | ConvertTo-SecureString -asPlainText -Force
    $Credential = New-Object System.Management.Automation.PSCredential($Username, $Password)

    If ($PSVersiontable.PSVersion.Major -lt 3) {
        Return "[ERROR] Powershell v2 is not compatible with Invoke-WebRequest."; Exit
        }

    If($Guid -EQ $Null){
        $AllResults = Invoke-CPRequest -Credential $Credential -Query "?active=True"

        ForEach($Result in $AllResults){
            If($Result.name -match $env:ComputerName){
                $NumberOfResults += 1
                $Guid = $Result.GUID
            }
        }

        Switch($NumberOfResults){
            {$NumberOfResults -gt 1} {Return "[ERROR] No GUID specified and to many results match the hostname of the system."; Exit}
            {$NumberOfResults -lt 1} {Return "[ERROR] No GUID specified and no results match the system's local hostname."; Exit}
        }
    }
    $R = Invoke-CPRequest -Credential $Credential -Query ("?guid=" + $Guid)
    
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