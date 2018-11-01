# A function used to output a hashtable as a csv file
Function Out-PlainCSV {
    param(
        [Parameter(Mandatory=$True)]
        [string] $FilePath,
        [Parameter(Mandatory=$True)]
        [hashtable] $Data,
        $Delimiter = ","
    )

    # Building the string for output
    [string] $CSVString = ""
    $Data.GetEnumerator() | ForEach-Object{
        $CSVString += "{0}{1}{2}{3}" -f $_.key, $Delimiter, $_.value, $Delimiter
    }
    
    # Writing the string to a file
    $CSVString.TrimEnd($Delimiter) | Out-File $FilePath
}


# A function used to output a hashtable as a xml file
Function Out-PlainXML {
    param(
        [Parameter(Mandatory=$True)]
        [string] $FilePath,
        [string] $RootElement = "Data",
        [Parameter(Mandatory=$True)]
        [hashtable] $Data
    )
    # Special thanks to Roger Delph, from whom much of this code was borrowed:
    # https://www.rogerdelph.com/creating-xml-documents-from-powershell/

    # Create The Document
    $XmlWriter = New-Object System.XMl.XmlTextWriter($FilePath,$Null)
 
    # Set The Formatting
    $xmlWriter.Formatting = "Indented"
    $xmlWriter.Indentation = "4"
 
    # Write the XML Decleration
    $xmlWriter.WriteStartDocument()
 
    # Set the XSL
    $XSLPropText = "type='text/xsl' href='style.xsl'"
    $xmlWriter.WriteProcessingInstruction("xml-stylesheet", $XSLPropText)
 
    # Write Root Element
    $xmlWriter.WriteStartElement("RootElement")
 
    # Write the Document
    $xmlWriter.WriteStartElement($RootElement)
    $Data.GetEnumerator() | ForEach-Object{
        $xmlWriter.WriteElementString($_.key, $_.value)
    }
    $xmlWriter.WriteEndElement | Out-Null
 
    # Write Close Tag for Root Element
    $xmlWriter.WriteEndElement | Out-Null
 
    # End the XML Document
    $xmlWriter.WriteEndDocument()
 
    # Finish The Document
    $xmlWriter.Finalize
    $xmlWriter.Flush | Out-Null
    $xmlWriter.Close()
}


# A function used to collect Windows Server Backup stats and output them in the specified format
Function Get-WBStats {
    param(
        [Parameter(Mandatory=$True)]
        [string] $FilePath,
        [ValidateSet("Xml", "CliXml", "Csv")]
        [string] $OutputType = "Xml",
        $Delimiter = ",",
        [int] $Threshold = 1
    )

    # Added the Windows Server Backup module if not present
    If((Get-Command Get-WBSummary).count -eq $Null){
        Add-PSSnapIn Windows.ServerBackup
    }

    # Storing native command output as objects
    $WBPolicy = Get-WBPolicy
    $WBSummary = Get-WBSummary

    # Getting datesfor script execution, last successful job, and next scheduled job
    [DateTime] $ScriptRun = Get-Date
    [DateTime] $LastSuccess = $WBSummary.LastSuccessfulBackupTime
    [DateTime] $NextJob = $WBSummary.NextBackupTime

    # Determining the age of the last successful backup
    $LastJob = New-TimeSpan -Start $LastSuccess -End $ScriptRun
    $Age = [math]::Round(($LastJob.Days) + (($LastJob.Hours) / 24), 2)

    # Calculating the duration of the last backup job
    $PreviousJob = Get-WBJob -Previous 1
    $JobRunTime = New-TimeSpan -Start $PreviousJob.StartTime -End $PreviousJob.EndTime

    # Getting the backup target type and scope of backup job
    $BackupType = (Get-WBBackupTarget -Policy $WBPolicy).TargetType
    $Scope = $WBPolicy.VolumesToBackup -join ", "

    # Getting all error logs for the threshold specified
    $ErrorLogs = (Get-WinEvent Microsoft-Windows-Backup |
        Where-Object {($_.LevelDisplayName -like 'Error') -and ($_.TimeCreated -ge ($ScriptRun).AddDays(-$Threshold))})
    [int] $EventLogErrors = $ErrorLogs.Count

    # Setting status to 'error' if backup age is above threshold or error were detected in that time frame
    $BackupStatus = "Normal"
    If(($Age -gt $Threshold) -Or ($EventLogErrors -gt 0)){
        $BackupStatus = "Error"
    }

    # Setting data in a hash table for output
    $Data = @{
        ScriptRun = $ScriptRun
        LastSuccess = $LastSuccess
        LastJobRunTime = $JobRunTime
        LastBackupAge = $Age
        NextJob = $NextJob
        Scope = $Scope
        BackupType = $BackupType
        EventLogErrors = $EventLogErrors
        BackupStatus = $BackupStatus
    }

    # Output data to XML format, determined by user input
    If($OutputType -eq "CliXml"){
        $Data | Export-Clixml -Path $FilePath
    }
    ElseIf($OutputType -eq "Csv"){
        Out-PlainCsv -FilePath $FilePath -Delimiter $Delimiter -Data $Data
    }
    Else{
        Out-PlainXML -FilePath $FilePath -Data $Data
    }
    
}

# Output Testing #

# Get-WBStats -FilePath "C:\test.xml" -OutputType csv -Delimiter " | " -Threshold 1

# Get-WBStats -FilePath "C:\test.xml" -OutputType clixml -Threshold 10

# Get-WBStats -FilePath "C:\test.xml"