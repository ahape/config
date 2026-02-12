# Variables
$global:Repo = 'C:\src\projects'

# Aliases
Set-Alias -Name vi -Value vim -ErrorAction Ignore

# Lazy load custom modules. Requires the first invocation to be without auto-completed anything
$ExecutionContext.InvokeCommand.PreCommandLookupAction = {
  param($command)
  if ($command -in 'Invoke-LLM', 'Ask-LLM', 'Show-Markdown', 'Render-Markdown') {
    $ExecutionContext.InvokeCommand.PreCommandLookupAction = $null
    Import-Module (Join-Path $HOME 'source\repos\llmchat\Invoke-LLM.psm1') -ErrorAction SilentlyContinue
    Import-Module (Join-Path $HOME 'source\repos\markterm\Show-Markdown.psm1') -ErrorAction SilentlyContinue
  }
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
