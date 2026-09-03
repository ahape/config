param([switch]$IncludeShada = $false)

$nvimData = "C:\Users\AlanHape\AppData\Local\nvim-data"

Remove-Item -Path "$nvimData\swap\*"

if ($IncludeShada) {
    Remove-Item -Path "$nvimData\shada\*"
}
