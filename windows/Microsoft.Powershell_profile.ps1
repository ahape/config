# Variables
$global:Repo = 'C:\src\projects'

# Aliases
Set-Alias -Name vi -Value vim -ErrorAction Ignore
New-Alias -Name lsf -Value Git-LsFiles
New-Alias -Name gshow -Value Git-Show

# Lazy load custom modules. Requires the first invocation to be without auto-completed anything
$ExecutionContext.InvokeCommand.PreCommandLookupAction = {
  param($command)
  if ($command -in 'Invoke-LLM', 'Ask-LLM', 'Show-Markdown', 'Render-Markdown') {
    $ExecutionContext.InvokeCommand.PreCommandLookupAction = $null
    Import-Module (Join-Path $HOME 'source\repos\llmchat\Invoke-LLM.psm1') -ErrorAction SilentlyContinue
    Import-Module (Join-Path $HOME 'source\repos\markterm\Show-Markdown.psm1') -ErrorAction SilentlyContinue
  }
}

. "$PSScriptRoot\_Helpers.ps1"

function prompt {
  $info = Get-PromptInfo
  Write-Host "$($info.Path) $($info.Branch)"
  return "PS> "
}
