# Update Windows Terminal tab name after command
if (Get-Module PSReadLine) {
  Set-PSReadLineKeyHandler -Key Enter -ScriptBlock {
    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

    if (-not [string]::IsNullOrWhiteSpace($line)) {
      try {
        $Host.UI.RawUI.WindowTitle = "PS: $line"
      } catch {
        $Host.UI.RawUI.WindowTitle = 'PS: <OMITTED>'
      }
    }
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
  }
}
