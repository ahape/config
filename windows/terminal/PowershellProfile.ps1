. "$PSScriptRoot\..\_Helpers.ps1"

function prompt {
  $info = Get-PromptInfo
  Write-Host "$env:USERNAME@$env:COMPUTERNAME $($info.Path) $($info.Branch)"
  return "PS> "
}

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
