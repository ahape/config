. "$PSScriptRoot\..\_Helpers.ps1"

if ($Host.Name -eq 'ConsoleHost' -and $Host.UI.RawUI.WindowTitle) {
  Enable-RecentCommandAutocompleteDropdown
}

if (Get-Module PSReadLine) {
  Set-PSReadLineKeyHandler -Key Enter -ScriptBlock {
    Set-TabTitleToDisplayReadLine

    Rotate-DefaultProfile

    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
  }
}

# Welcome banner
Write-Host "$(Get-Date -f 'ddd dd MMM yyyy HH:mm')"
