$style = Import-PowerShellDataFile -path C:\users\jbrue\onedrive\documents\repos\pscribo\src\styles\default.psd1

$style.GetEnumerator() | foreach-object {
    "$($_.key)"
    $_.value.GetEnumerator() | foreach-object {
        if ($_.value.gettype() -is [system.collections.hashtable]){

        }
    }
}