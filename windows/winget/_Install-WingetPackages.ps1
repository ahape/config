# Installs each winget package ID that isn't already present. Exits 1 if any install fails.
function Install-WingetPackages {
  param([Parameter(Mandatory)][string[]]$Ids)

  if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    throw 'winget not found on PATH (it ships with the App Installer package from the Microsoft Store).'
  }

  $failed = @()
  foreach ($id in $Ids) {
    # Checked up front because `winget install` reinstalls packages that are already present
    winget list --id $id --exact --disable-interactivity *> $null
    if ($LASTEXITCODE -eq 0) {
      Write-Host "skip     $id (already installed)"
      continue
    }

    Write-Host "install  $id"
    winget install --id $id --exact --source winget --accept-package-agreements --accept-source-agreements --disable-interactivity
    if ($LASTEXITCODE -ne 0) { $failed += $id }
  }

  if ($failed) {
    Write-Warning "Failed: $($failed -join ', ')"
    exit 1
  }
}
