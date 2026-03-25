$script:lastRotation = [datetime]::MinValue
$script:rotateInterval = [timespan]::FromMinutes(30)

function Rotate-DefaultProfile {
  $now = [datetime]::UtcNow
  if (($now - $script:lastRotation) -lt $script:rotateInterval) { return }
  $script:lastRotation = $now
  $settingsPath = "$HOME\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
  try {
    $settings = Get-Content $settingsPath -Raw | ConvertFrom-Json
    $profiles = @($settings.profiles.list | Where-Object {
      -not $_.hidden -and $_.source -ne "Microsoft.WSL"
    })
    if ($profiles.Count -lt 2) { return }
    $idx = -1
    for ($i = 0; $i -lt $profiles.Count; $i++) {
      if ($profiles[$i].guid -eq $settings.defaultProfile) { $idx = $i; break }
    }
    $next = $profiles[($idx + 1) % $profiles.Count]
    $settings.defaultProfile = $next.guid
    $settings | ConvertTo-Json -Depth 99 | Set-Content $settingsPath -Encoding UTF8
  } catch {}
}

function Set-TabTitleToDisplayReadLine {
  $line   = $null
  $cursor = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
  if (-not [string]::IsNullOrWhiteSpace($line)) {
    try   { $Host.UI.RawUI.WindowTitle = "PS: $line"       }
    catch { $Host.UI.RawUI.WindowTitle = 'PS: <OMITTED>'   }
  }
}

function Enable-RecentCommandAutocompleteDropdown {
  Set-PSReadLineOption -PredictionSource    History
  Set-PSReadLineOption -PredictionViewStyle ListView
  Set-PSReadLineOption -EditMode            Windows
  Set-PSReadLineOption -Colors @{
    Command            = "`e[96m"   # bright cyan
    Parameter          = "`e[90m"   # dark grey
    String             = "`e[93m"   # yellow
    Comment            = "`e[32m"   # green
    InlinePrediction   = "`e[90m"   # dark grey ghost text
  }
}

function Get-PromptInfo {
  # Current path. Abbreviate $HOME to ~, then keep last 3 segments
  $path  = $PWD.Path -replace [regex]::Escape($HOME), '~'
  $parts = $path -split '[/\\]'
  if ($parts.Count -gt 3) {
    $path = '…\' + [string]::Join("\", ($parts | Select-Object -Last 3))
  }
  # Git branch (silent if not a repo)
  $branch = ''
  if (Get-Command git -ErrorAction SilentlyContinue) {
    $branch = git rev-parse --abbrev-ref HEAD 2>$null
  }
  return @{ Path = $path; Branch = $branch }
}

function Initialize-LazyModuleImports {
  $ExecutionContext.InvokeCommand.PreCommandLookupAction = {
    param($command)
    if ($command -in 'Invoke-LLM', 'Ask-LLM', 'Show-Markdown', 'Render-Markdown') {
      $ExecutionContext.InvokeCommand.PreCommandLookupAction = $null
        Import-Module (Join-Path $HOME 'source\repos\llmchat\Invoke-LLM.psm1') -ErrorAction SilentlyContinue
        Import-Module (Join-Path $HOME 'source\repos\markterm\Show-Markdown.psm1') -ErrorAction SilentlyContinue
    }
  }
}
