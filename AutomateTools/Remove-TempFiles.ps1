$FileInfo = Get-ChildItem 'C:\Windows\Logs\CBS'
$SizeInGBs = 4
$TotalSize = 0

ForEach($File in $FileInfo){
    If($File -like 'CbsPersist*.cab'){
        $TotalSize = ($File.Length / 10000000)
    }
}

If($TotalSize -gt $SizeInGBs){
    Remove-Item -Path 'C:\Windows\Logs\CBS\CbsPersist*.cab' -Force -ErrorAction Ignore
}