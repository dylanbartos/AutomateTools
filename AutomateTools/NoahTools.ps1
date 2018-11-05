Function Remove-NoahBackups{
    param(
        [string] $Path = "C:\ProgramData\Himsa\Noah\Backup\Database",
        [int] $Threshold = 90,
        [int] $Keep = 3,
        [bool] $CliOutput = $False
    )

    $TDate = (Get-Date).AddDays(-$Threshold)
    $Directories = Get-ChildItem $Path | Where-Object { $_.LastWriteTime -lt $TDate } | Select -Last 1000 -Skip $Keep
    $BackupsDeleted = 0

    ForEach ($Directory in $Directories){
        IF ($Directory.Name -Match "[2][0]\d\d-\d\d-\d\d[ ]\d\d[.]\d\d[.]\d\d"){
            Remove-Item -Path ($Path + "\" + $Directory) -Force -Recurse -ErrorAction Ignore
            $BackupsDeleted += 1
        }
    }

    If($CliOutput = $True){
        $Directories = Get-ChildItem $Path
        $BackupCount = ($Directories | Measure-Object).count + $BackupsDeleted

        Write-Host "$BackupCount found. $BackupsDeleted removed."
    }
}