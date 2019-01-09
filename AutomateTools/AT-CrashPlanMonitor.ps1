﻿Function Invoke-CPRequest{
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
        "False" {$Error = "ERROR - Unable to authenticate or GUID was invalid."
                 Write -Host $Error
                 New-CPLogEntry -EntryText $Error
                 Exit
                 }
    }
}

<#
.SYNOPSIS
Get-CPData requests the data for a specified endpoint and outputs the data in an XML file.
.DESCRIPTION
This command requires powershell version 3 or higher to perform the request using the code42 API.
.PARAMETER Username
Input for the Code42 account username.
.PARAMETER Password
Input for the Code42 account password.
.PARAMETER GUID
Input for the GUID of the targeted agent.
.PARAMETER OutputPath
Specifies the output path for the XML file.
#>

Function Get-CPData{
    param(
        [Parameter(Mandatory=$True)]
        $Username,
        [Parameter(Mandatory=$True)]
        $Password,
        [Parameter(Mandatory=$True)]
        $GUID,
        $OutputPath = "C:\AutomateTools\Temp\CPResults.xml"
    )

    $Password = $Password | ConvertTo-SecureString -asPlainText -Force
    $Credential = New-Object System.Management.Automation.PSCredential($Username, $Password)

    If ($PSVersiontable.PSVersion.Major -lt 3) {
        Return "[ERROR] Powershell v2 is not compatible with Invoke-WebRequest."; Exit
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