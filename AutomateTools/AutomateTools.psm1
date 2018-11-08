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


# A function to easily add a path to the powershell default environment path list
Function Set-EnvironmentPath{
    param(
        $ModulePath = "C:\AutomateTools"
    )

    # Get list of powershell environment paths
    $ev = $env:PsModulePath -split ";"

    # Searching paths to determine if path already exists
    $EnvPathExists = "False"
    ForEach($e in $ev){
        If($e -eq $ModulePath){
            $EnvPathExists = "True"
        }
    }

    # Adds path to existing list
    If($EnvPathExists = "True"){
        $env:PsModulePath = $env:PsModulePath + ";" + $ModulePath
    }
}


# A function to test and build a given file path
    Function Push-FileStructure{
        param(
            [Parameter(Mandatory=$True)]
            [string] $Path
        )

        # Adds the trailing slash if left out
        If(!($Path.EndsWith('\'))){
            $Path += '\'
        }

        # Test each level of the file path and creates it if it doesn't exist
        $Parts = $Path.split('\')
        ForEach($Part in $Parts){
            $RebuiltPath += ($Part + '\')
            If(!(Test-Path $RebuiltPath)){
                New-Item -ItemType Directory -Path $RebuiltPath
            }
        }
    }

# Adding supporting PowerShell functions
. $PSScriptRoot\Get-WBStats.ps1
. $PSScriptRoot\Get-NoahVersion.ps1
. $PSScriptRoot\Get-Update.ps1