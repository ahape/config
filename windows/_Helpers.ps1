$script:lastRotation = [datetime]::MinValue
$script:rotateInterval = [timespan]::FromMinutes(30)

function Get-WindowsTerminalSettingsPath {
  $packageRoot = Join-Path $HOME 'AppData\\Local\\Packages'
  $candidates = @(
    'Microsoft.WindowsTerminal_8wekyb3d8bbwe',
    'Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe'
  ) | ForEach-Object { Join-Path $packageRoot $_ }

  $paths = $candidates | ForEach-Object { Join-Path $_ 'LocalState\\settings.json' }
  $paths += Join-Path $HOME 'AppData\\Local\\Microsoft\\Windows Terminal\\settings.json'

  foreach ($path in $paths) {
    if (Test-Path $path) { return $path }
  }

  return $null
}

function Get-GitRepositoryRoot {
  param(
    [string]$Path = $PWD.Path
  )

  try {
    $current = (Resolve-Path -Path $Path).ProviderPath
  } catch {
    return $null
  }

  while ($current) {
    $gitEntry = Join-Path $current '.git'
    if (Test-Path $gitEntry) {
      return $current
    }

    $parent = Split-Path $current -Parent
    if ([string]::IsNullOrEmpty($parent) -or $parent -eq $current) {
      break
    }
    $current = $parent
  }

  return $null
}

function Get-GitBranchName {
  param(
    [string]$Path = $PWD.Path
  )

  $repoRoot = Get-GitRepositoryRoot -Path $Path
  if (-not $repoRoot) { return '' }

  try {
    $branch = git -C $repoRoot rev-parse --abbrev-ref HEAD 2>$null
  } catch {
    $branch = ''
  }

  return $branch
}

function Rotate-DefaultProfile {
  $now = [datetime]::UtcNow
  if (($now - $script:lastRotation) -lt $script:rotateInterval) { return }

  $settingsPath = Get-WindowsTerminalSettingsPath
  if (-not $settingsPath) {
    Write-Warning 'Windows Terminal settings.json not found; skipping profile rotation.'
    return
  }

  try {
    $settingsRaw = Get-Content -LiteralPath $settingsPath -Raw -ErrorAction Stop
    $settings   = $settingsRaw | ConvertFrom-Json -ErrorAction Stop
  } catch {
    Write-Warning "Unable to read Windows Terminal settings: $($_.Exception.Message)"
    return
  }

  $profiles = @($settings.profiles.list | Where-Object { -not $_.hidden -and $_.source -ne 'Microsoft.WSL' })
  if ($profiles.Count -lt 2) { return }

  $idx = -1
  for ($i = 0; $i -lt $profiles.Count; $i++) {
    if ($profiles[$i].guid -eq $settings.defaultProfile) { $idx = $i; break }
  }

  $next = $profiles[($idx + 1) % $profiles.Count]
  if ($next.guid -eq $settings.defaultProfile) { return }

  $updatedJson = [regex]::Replace(
    $settingsRaw,
    '("defaultProfile"\s*:\s*")([^"\\]+?)(")',
    {
      param($match)
      "{0}{1}{2}" -f $match.Groups[1].Value, $next.guid, $match.Groups[3].Value
    },
    1
  )

  if ($updatedJson -eq $settingsRaw) {
    Write-Warning 'Failed to update defaultProfile entry; leaving settings untouched.'
    return
  }

  try {
    Set-Content -LiteralPath $settingsPath -Value $updatedJson -Encoding UTF8
    $script:lastRotation = $now
  } catch {
    Write-Warning "Unable to write Windows Terminal settings: $($_.Exception.Message)"
  }
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
    $branch = Get-GitBranchName -Path $PWD.Path
  }
  return @{ Path = $path; Branch = $branch }
}

function Initialize-LazyModuleImports {
  $ExecutionContext.InvokeCommand.PreCommandLookupAction = {
    param($command)

    $commands = @('Invoke-LLM', 'Ask-LLM', 'Show-Markdown', 'Render-Markdown')
    if ($commands -notcontains $command) { return }

    $modules = @(
      @{ Description = 'llmchat'; Path = Join-Path $HOME 'source\repos\llmchat\Invoke-LLM.psm1' },
      @{ Description = 'markterm'; Path = Join-Path $HOME 'source\repos\markterm\Show-Markdown.psm1' }
    )

    $allLoaded = $true
    foreach ($module in $modules) {
      if (Get-Module | Where-Object { $_.Path -eq $module.Path }) { continue }
      try {
        Import-Module $module.Path -ErrorAction Stop
      } catch {
        Write-Warning "Failed to import $($module.Description) module from $($module.Path): $($_.Exception.Message)"
        $allLoaded = $false
      }
    }

    if ($allLoaded) {
      $ExecutionContext.InvokeCommand.PreCommandLookupAction = $null
    }
  }
}
