 Function Remove-TempFiles {
    param(
        $Path,
        [string] $FileType = "*.*",
        [bool] $Recurse = $False,
        [int] $Age = 0,
        [Parameter(Mandatory=$True)]
        $ValidationString
    )

    If(!(Test-Path $Path)){
        Exit
    }

    $Path = Get-Item $Path
    [datetime] $TDate = (Get-Date).AddDays(-$Age)

    If($Recurse -eq $True){
        $Contents = Get-ChildItem -Path $Path.FullName -Recurse | Where-Object {($_.Extension -like $FileType)} 
    }

    Else{
        $Contents = Get-ChildItem -Path $Path.FullName | Where-Object {($_.Extension -like $FileType)}
    }

    ForEach($c in $Contents){
        If($c.fullname -like $ValidationString){
            $c | Remove-Item
        }
    }

}

# List of specific temp locations
Remove-TempFiles -Path ("C:\Windows\temp\") -Recurse $True -ValidationString "C:\Windows\temp\*"
Remove-TempFiles -Path ("C:\Windows\Logs\CBS\") -FileType "*.log" -Age 14 -ValidationString "C:\Windows\Logs\CBS\*.log"
Remove-TempFiles -Path ("C:\users\*\AppData\Local\Temp\") -FileType "*.*" -ValidationString "C:\users\*\AppData\Local\Temp\*"
Remove-TempFiles -Path ("C:\users\*\Downloads\") -FileType "*.scl" -ValidationString "C:\users\*\Downloads\*.scl"