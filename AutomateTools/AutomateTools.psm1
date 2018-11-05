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
    # Special thanks to Roger Delph, from whom much of this XML generation code was borrowed:
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

# Adding supporting PowerShell functions
. $PSScriptRoot\Get-WBStats.ps1
. $PSScriptRoot\Remove-NoahBackups.ps1