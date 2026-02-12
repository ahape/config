# Variables
$global:Repo = 'C:\src\projects'

# Aliases
Set-Alias -Name vi -Value vim -ErrorAction Ignore

# Custom modules
if ($PSVersionTable.PSVersion.Major -ge 7) {
  Start-ThreadJob { Import-CustomModules } | Out-Null
} else {
  Import-CustomModules
}

# Functions
function prompt {
  $path = $pwd.Path
  $parts = $path.Split([IO.Path]::DirectorySeparatorChar)

  if ($parts.Count -gt 2) {
    $lastTwo = $parts[-2..-1] -join '\'
    $path = "..\$lastTwo"
  }

  "PS $path> "
}

function Import-CustomModules {
  @(
    Join-Path $HOME 'source\repos\llmchat\Invoke-LLM.psm1'
    Join-Path $HOME 'source\repos\markterm\Show-Markdown.psm1'
  ) `
  | ? { Test-Path $_ } `
  | % { Import-Module $_ -ErrorAction SilentlyContinue }
}
