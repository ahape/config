[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateSet('Mac', 'Windows', 'WSL')]
    [string]$Platform
)

$ErrorActionPreference = 'Stop'

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw 'git is not on PATH'
}

$target = "$HOME/.config/git/generated.gitconfig"
$homeGitconfig = Join-Path $HOME '.gitconfig'
$script:GitConfigFile = $target

function Set-Git {
    param(
        [Parameter(Mandatory)][string]$Key,
        [Parameter(Mandatory)][string]$Value
    )

    git config --file $script:GitConfigFile $Key $Value
    if ($LASTEXITCODE -ne 0) {
        throw "git config failed: $Key"
    }
    Write-Verbose "Added: $Key -> $Value"
}

function Get-NextBackupPath {
    param([Parameter(Mandatory)][string]$Destination)

    $backup = "$Destination.backup"
    $index = 1
    while (Test-Path -LiteralPath $backup) {
        $backup = "$Destination.backup.$index"
        $index++
    }
    return $backup
}

function ConvertTo-GitPath {
    param([Parameter(Mandatory)][string]$Path)
    return ($Path -replace '\\', '/')
}

function Test-AlreadyBootstrapped {
    param(
        [Parameter(Mandatory)][string]$GitconfigPath,
        [Parameter(Mandatory)][string]$TargetPath
    )

    if (-not (Test-Path -LiteralPath $GitconfigPath)) {
        return $false
    }

    $keys = @(git config --file $GitconfigPath --list 2>$null)
    if ($keys.Count -ne 1) {
        return $false
    }

    if ($keys[0] -notmatch '^include\.path=(.+)$') {
        return $false
    }

    $current = ConvertTo-GitPath $Matches[1]
    $want = ConvertTo-GitPath $TargetPath
    return $current -eq $want
}

function ConvertTo-SettingValue {
    param([Parameter(Mandatory)][AllowEmptyString()][string]$Value)

    if ($Value.Contains('$HOME')) {
        return ConvertTo-GitPath ($Value.Replace('$HOME', $HOME))
    }
    return $Value
}

$settingsFile = Join-Path $PSScriptRoot 'config-settings.csv'
if (-not (Test-Path -LiteralPath $settingsFile)) {
    throw "Settings file not found: $settingsFile"
}

$settings = @(Import-Csv -LiteralPath $settingsFile)
if ($settings.Count -eq 0) {
    throw "Settings file is empty: $settingsFile"
}
foreach ($name in @('key', 'value', 'env')) {
    if (-not ($settings[0].PSObject.Properties.Name -contains $name)) {
        throw "Settings file missing '$name' column: $settingsFile"
    }
}

$gitDir = Split-Path -Parent $target
New-Item -ItemType Directory -Force -Path $gitDir | Out-Null
if (Test-Path -LiteralPath $target) {
    Remove-Item -LiteralPath $target -Force
}

$allowedEnvs = @('Mac', 'Windows', 'WSL')
$applied = 0
foreach ($row in $settings) {
    $key = [string]$row.key
    if ([string]::IsNullOrWhiteSpace($key)) {
        continue
    }
    $key = $key.Trim()

    $envName = ([string]$row.env).Trim()
    if ($envName -and $envName -notin $allowedEnvs) {
        throw "Unknown env '$envName' for key '$key'. Expected Mac, Windows, WSL, or empty."
    }
    if ($envName -and $envName -ne $Platform) {
        continue
    }

    Set-Git $key (ConvertTo-SettingValue ([string]$row.value))
    $applied++
}

if ($applied -eq 0) {
    throw "No settings applied from $settingsFile for platform $Platform"
}

$targetPosix = ConvertTo-GitPath $target
if ((Test-Path -LiteralPath $homeGitconfig) -and -not (Test-AlreadyBootstrapped $homeGitconfig $targetPosix)) {
    $backup = Get-NextBackupPath $homeGitconfig
    Write-Host "Backing up existing $homeGitconfig to $backup"
    Move-Item -LiteralPath $homeGitconfig -Destination $backup
}

if (-not (Test-AlreadyBootstrapped $homeGitconfig $targetPosix)) {
    git config --file $homeGitconfig include.path $targetPosix
    if ($LASTEXITCODE -ne 0) {
        throw "git config failed: include.path"
    }
}

Write-Host "Generated $target for $Platform"
Write-Host "Included from $homeGitconfig"
