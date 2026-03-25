# Variables
if (Test-Path 'C:\src\projects') {
  $global:Repo = 'C:\src\projects'
}

. "$PSScriptRoot\_Helpers.ps1"

# Aliases
Set-Alias -Name vi -Value vim -ErrorAction Ignore
New-Alias -Name lsf -Value Git-LsFiles -ErrorAction Ignore
New-Alias -Name gshow -Value Git-Show -ErrorAction Ignore

# Avoid locking up thread while importing modules
Initialize-LazyModuleImports

function prompt {
  $info = Get-PromptInfo
  Write-Host "$env:USERNAME@$env:COMPUTERNAME $($info.Path) $($info.Branch)"
  return "PS> "
}
