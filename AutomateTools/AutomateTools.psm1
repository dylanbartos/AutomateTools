Function Out-PlainCSV {
    param(
        [Parameter(Mandatory=$True)]
        [string] $FilePath,
        [Parameter(Mandatory=$True)]
        [hashtable] $Data,
        $Delimiter = ","
    )
    [string] $CSVString = ""
    $Data.GetEnumerator() | ForEach-Object{
        $CSVString += "{0}{1}{2}{3}" -f $_.key, $Delimiter, $_.value, $Delimiter
    }
    $CSVString.TrimEnd($Delimiter) | Out-File $FilePath
}

Function Out-PlainXML {
    param(
        [Parameter(Mandatory=$True)]
        [string] $FilePath,
        [string] $RootElement = "Data",
        [Parameter(Mandatory=$True)]
        [hashtable] $Data
    )
    $XmlWriter = New-Object System.XMl.XmlTextWriter($FilePath,$Null)
    $xmlWriter.Formatting = "Indented"
    $xmlWriter.Indentation = "4"
    $xmlWriter.WriteStartDocument()
    $XSLPropText = "type='text/xsl' href='style.xsl'"
    $xmlWriter.WriteProcessingInstruction("xml-stylesheet", $XSLPropText)
    $xmlWriter.WriteStartElement("RootElement")
    $xmlWriter.WriteStartElement($RootElement)
    $Data.GetEnumerator() | ForEach-Object{
        $xmlWriter.WriteElementString($_.key, $_.value)
    }
    $xmlWriter.WriteEndElement | Out-Null
    $xmlWriter.WriteEndElement | Out-Null
    $xmlWriter.WriteEndDocument()
    $xmlWriter.Finalize
    $xmlWriter.Flush | Out-Null
    $xmlWriter.Close()
}

Function Push-FileStructure{
    param(
        [Parameter(Mandatory=$True)]
        [string] $Path
    )
    If(!($Path.EndsWith('\'))){
        $Path += '\'
    }
    $Parts = $Path.split('\')
    ForEach($Part in $Parts){
        $RebuiltPath += ($Part + '\')
        If(!(Test-Path $RebuiltPath)){
            New-Item -ItemType Directory -Path $RebuiltPath
        }
    }
}

. $PSScriptRoot\Get-WBStats.ps1
. $PSScriptRoot\Get-NoahVersion.ps1
. $PSScriptRoot\Get-FirewallStatus.ps1
. $PSScriptRoot\Reboot-Bitlocker.ps1
. $PSScriptRoot\Remove-TempFiles.ps1
. $PSScriptRoot\Reset-Winsock.ps1
. $PSScriptRoot\Set-NetProfilePrivate.ps1
. $PSScriptRoot\Remove-MiscTempFiles.ps1