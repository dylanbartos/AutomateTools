 Function Remove-TempFiles{
    param(
        [Parameter(Mandatory=$True)]
        $Path,
        [Parameter(Mandatory=$True)]
        $FileType,
        $Depth = 1,
        $Age = 30
    )

    [datetime] $ThresholdDate = (Get-Date).AddDays(-$Age)
    $OriginPath = Get-Item $Path
    $SpaceFreed = 0
    $L1Paths = @()
    $L2Paths = @()
    $L3Paths = @()

    If(!(Test-Path $OriginPath)){
        Exit
    }

    If($Depth -gt 0){
        $FoundPaths = @($OriginPath)
        $L1Paths += (Get-ChildItem $OriginPath.FullName | Where-Object {$_.Attributes -eq "Directory"})
        $FoundPaths += $L1Paths

        If(($Depth -gt 1) -and ($L1Paths)){
            ForEach($L1Path in $L1Paths){
                $L2Paths += Get-ChildItem $L1Path.FullName | Where-Object {$_.Attributes -eq "Directory"}
            }
            $FoundPaths += $L2Paths

            If(($Depth -gt 2) -and ($L2Paths)){
                ForEach($L2Path in $L2Paths){
                    $L3Paths += Get-ChildItem $L2Path.FullName | Where-Object {$_.Attributes -eq "Directory"}
                }
                $FoundPaths += $L3Paths

            }
        }
    }

    $DetectedFiles = @()
    ForEach($P in $FoundPaths){
        $FoundFile = Get-ChildItem -Path $P.FullName | Where-Object {($_.Attributes -ne "Directory") -and ($_.LastWriteTime -lt $ThresholdDate) -and ($_.Extension -like $FileType)}
        $DetectedFiles += $FoundFile
    }



# Test Output #
$Break = "`n------------------------`n"
$Break | Add-Content "C:\TestResults.txt"
$OriginPath.fullname | Add-Content "C:\TestResults.txt"
$L1Paths.fullname | Add-Content "C:\TestResults.txt"
$L2Paths.fullname | Add-Content "C:\TestResults.txt"
$L3Paths.fullname | Add-Content "C:\TestResults.txt"
$DetectedFiles.FullName | Add-Content "C:\TestResults.txt"
$Break | Add-Content "C:\TestResults.txt"
}

If(Test-Path "C:\TestResults.txt"){
    Remove-Item "C:\TestResults.txt"
    New-Item "C:\TestResults.txt"
}

Remove-TempFiles -Path ($env:windir + "\temp\") -FileType "*.*" -Depth 1
Remove-TempFiles -Path ($env:windir + "\system32\wbem\logs\") -FileType "*.*" -Age 0
Remove-TempFiles -Path ($env:windir + "\system32\wbem\logs\") -FileType "*.*" -Depth 1
Remove-TempFiles -Path ($env:windir + "\system32\logfiles\") -FileType "*.*" -Depth 1
Remove-TempFiles -Path ($env:windir + "\debug\") -FileType "*.*" -Depth 1 -Age 0
Remove-TempFiles -Path ($env:windir + "\Logs\CBS\") -FileType "*.log" -Age 14
Remove-TempFiles -Path ($env:systemdrive + "\users\*\AppData\Local\Temp\") -FileType "*.*" -Depth 1 -Age 0
Remove-TempFiles -Path ($env:systemdrive + "\users\*\Downloads\") -FileType "*.scl" -Age 0
Remove-TempFiles -Path ($env:ProgramData + "\Himsa\Noah\Backup\Database\") -FileType "*.*" -Depth 2 -Age 90