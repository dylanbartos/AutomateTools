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
    $xmlWriter.WriteStartElement("Root")
 
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