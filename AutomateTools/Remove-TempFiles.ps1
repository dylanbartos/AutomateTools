Function Remove-TempFiles {
    param(
        [Parameter(Mandatory=$True)]
        [string] $Path,
        [Parameter(Mandatory=$True)]
        [string] $FileType,
        [int] $Depth = 0,
        [int] $Age = 30
    )

    [datetime] $ThresholdDate = (Get-Date).AddDays(-$Age)
    $r = Get-ChildItem -Path $Path -Depth $Depth | Where-Object { ($_.name -match "\....\b") -and ($_.name -like $FileType) -and ($_.LastWriteTime -lt $ThresholdDate) }
    $r | Remove-Item -Force -ErrorAction Ignore
 }

Remove-TempFiles -Path ($env:windir + "\temp\") -FileType "*.*" -Depth 1
Remove-TempFiles -Path ($env:windir + "\system32\wbem\logs\") -FileType "*.*" -Age 0
Remove-TempFiles -Path ($env:windir + "\system32\wbem\logs\") -FileType "*.*" -Depth 1
Remove-TempFiles -Path ($env:windir + "\system32\logfiles\") -FileType "*.*" -Depth 1
Remove-TempFiles -Path ($env:windir + "\debug\") -FileType "*.*" -Depth 1 -Age 0
Remove-TempFiles -Path ($env:windir + "\Logs\CBS\") -FileType "*.log" -Age 15
Remove-TempFiles -Path ($env:systemdrive + "\users\*\AppData\Local\Temp") -FileType "*.*" -Depth 1 -Age 0
Remove-TempFiles -Path ($env:systemdrive + "\users\*\AppData\Local\Temp") -FileType "*.*" -Depth 1 -Age 0
Remove-TempFiles -Path ($env:systemdrive + "\users\*\Downloads\") -FileType "*.scl" -Age 0
Remove-TempFiles -Path ($env:ProgramData + "\Himsa\Noah\Backup\Database") -FileType "*.*" -Depth 2 -Age 90