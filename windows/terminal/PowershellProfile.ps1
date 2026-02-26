function prompt {
  $lastOk  = $?
  $code    = $LASTEXITCODE
  # Current path — abbreviate home to ~, then keep last 3 segments
  $path  = $PWD.Path -replace [regex]::Escape($HOME), '~'
  $parts = $path -split '[/\\]'
  if ($parts.Count -gt 3) {
    $path = '…\' + ($parts | Select-Object -Last 3) -join '\'
  }
  # Git branch (silent if not a repo)
  $branch = ''
  if (Get-Command git -ErrorAction SilentlyContinue) {
    $branch = git rev-parse --abbrev-ref HEAD 2>$null
  }
  # Top line:  user@host  path  (branch)
  Write-Host $([string]::Join(" ", @(
    "$env:USERNAME@$env:COMPUTERNAME"
    $path
    $branch
  )))
  return "PS> "
}
if (Get-Module PSReadLine) {
  # Window title after each command
  Set-PSReadLineKeyHandler -Key Enter -ScriptBlock {
    $line   = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
    if (-not [string]::IsNullOrWhiteSpace($line)) {
      try   { $Host.UI.RawUI.WindowTitle = "PS: $line"       }
      catch { $Host.UI.RawUI.WindowTitle = 'PS: <OMITTED>'   }
    }
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
  }
  # Ctrl+O -- inject a random-scheme profile & open a new tab
  Set-PSReadLineKeyHandler -Chord 'Ctrl+o' -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    $settingsPath = "C:\Users\AlanHape\AppData\Local\Packages\" +
                    "Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
    $maxProfiles   = 10
    $profilePrefix = "Random-"
    try {
      Write-Host -ForegroundColor Cyan "`n[HACK] Reading settings.json..."
      $settings         = Get-Content $settingsPath -Raw | ConvertFrom-Json
      $generatedProfiles = @($settings.profiles.list | Where-Object { $_.name -like "$profilePrefix*" })
      # Rotate out oldest profiles when at the limit
      while ($generatedProfiles.Count -ge $maxProfiles) {
        $oldest = $generatedProfiles[0]
        Write-Host -ForegroundColor DarkGray "[CLEANUP] Rotating out: '$($oldest.name)'"
        $settings.profiles.list = @($settings.profiles.list | Where-Object { $_.guid -ne $oldest.guid })
        $generatedProfiles       = @($settings.profiles.list | Where-Object { $_.name -like "$profilePrefix*" })
      }
      # Pick a random colour scheme
      $schemeName = ($settings.schemes | Get-Random).name
      if (-not $schemeName) { $schemeName = "Obsidian" }
      # Build the new profile object
      $newGuid    = "{$(New-Guid)}"
      $newName    = "$profilePrefix$schemeName-$(Get-Random -Minimum 100 -Maximum 999)"
      $newProfile = [PSCustomObject]@{
        guid        = $newGuid
        name        = $newName
        commandline = "powershell.exe"
        colorScheme = $schemeName
        hidden      = $false
      }
      $settings.profiles.list += $newProfile
      $settings | ConvertTo-Json -Depth 99 | Set-Content $settingsPath -Encoding UTF8
      Write-Host -ForegroundColor Green  "[HACK] Injected profile : '$newName' ($schemeName)"
      Write-Host -ForegroundColor Gray   "[HACK] Waiting for Terminal to reload..."
      Start-Sleep -Milliseconds 600
      Start-Process "wt.exe" -ArgumentList "-w 0 nt -p `"$newGuid`""
    } catch {
      Write-Host -ForegroundColor Red "`n[ERROR] $_"
    }
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert("")
  }
  # PSReadLine quality-of-life
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
# Welcome banner
Write-Host "$(Get-Date -f 'ddd dd MMM yyyy HH:mm')"
