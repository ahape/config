<#
.SYNOPSIS
    Manages Windows Terminal color schemes and profiles with advanced features.

.DESCRIPTION
    This cmdlet provides comprehensive management of Windows Terminal themes including:
    - Shuffling themes across profiles
    - Updating community themes
    - Backing up settings
    - Setting specific themes
    - Viewing current configurations

.PARAMETER Action
    The action to perform. Valid values:
    - Shuffle: Randomize themes for all or specific profiles (default)
    - Current: Display current color schemes for all profiles
    - Update: Download and install community color schemes
    - List: List all available color schemes
    - Set: Set a specific theme for a profile
    - Backup: Create a backup of current settings
    - Restore: Restore settings from backup

.PARAMETER ProfileIndex
    The 1-based index of the profile to modify (optional)

.PARAMETER ThemeName
    The name of the color scheme to apply (used with Set action)

.PARAMETER IncludeFilter
    Regex pattern to include specific profiles (e.g., "PowerShell|pwsh")

.PARAMETER ExcludeFilter
    Regex pattern to exclude specific profiles (e.g., "CMD|Ubuntu")

.PARAMETER BackupPath
    Custom backup file path (default: settings.backup.json in same directory)

.EXAMPLE
    Set-WindowsTerminalTheme.ps1
    Shuffles themes for all profiles

.EXAMPLE
    Set-WindowsTerminalTheme.ps1 -Action Current
    Shows current theme configuration

.EXAMPLE
    Set-WindowsTerminalTheme.ps1 -Action Set -ProfileIndex 1 -ThemeName "Dracula"
    Sets profile 1 to use the Dracula theme

.EXAMPLE
    Set-WindowsTerminalTheme.ps1 -Action Shuffle -IncludeFilter "PowerShell"
    Only shuffles themes for PowerShell profiles

.NOTES
    Author: Enhanced Terminal Theme Manager
    Version: 2.0
    Requires: Windows Terminal
#>

[CmdletBinding(DefaultParameterSetName = 'Shuffle')]
param(
    [Parameter(ParameterSetName = 'Action')]
    [ValidateSet('Shuffle', 'Current', 'Update', 'List', 'Set', 'Backup', 'Restore')]
    [string]$Action = 'Shuffle',
    
    [Parameter(ParameterSetName = 'Action')]
    [Parameter(ParameterSetName = 'Shuffle')]
    [ValidateRange(1, 100)]
    [int]$ProfileIndex,
    
    [Parameter(ParameterSetName = 'Action', Mandatory = $false)]
    [string]$ThemeName,
    
    [Parameter()]
    [string]$IncludeFilter,
    
    [Parameter()]
    [string]$ExcludeFilter,
    
    [Parameter()]
    [string]$BackupPath,
    
    [Parameter()]
    [switch]$NoAnimation
)

# Configuration and constants
$ErrorActionPreference = 'Stop'
$ProgressPreference = if ($NoAnimation) { 'SilentlyContinue' } else { 'Continue' }

# Terminal settings paths
$terminalPaths = @(
    "$env:LOCALAPPDATA/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json",
    "$env:LOCALAPPDATA/Packages/Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe/LocalState/settings.json",
    "$env:APPDATA/Microsoft/Windows Terminal/settings.json"
)

$themesApiUrl = "https://2zrysvpla9.execute-api.eu-west-2.amazonaws.com/prod/themes"

#region Helper Functions

function Write-ColoredOutput {
    param(
        [string]$Message,
        [ConsoleColor]$Color = 'White',
        [switch]$NoNewline
    )
    Write-Host $Message -ForegroundColor $Color -NoNewline:$NoNewline
}

function Get-TerminalSettingsPath {
    foreach ($path in $terminalPaths) {
        if (Test-Path $path) {
            Write-ColoredOutput "✓ Found settings at: $path" -Color Green
            return $path
        }
    }
    throw "Windows Terminal settings.json not found. Please ensure Windows Terminal is installed."
}

function Read-TerminalSettings {
    param([string]$Path)
    
    try {
        $content = Get-Content $Path -Raw -Encoding UTF8
        $settings = $content | ConvertFrom-Json
        
        if (-not $settings.profiles -or -not $settings.profiles.list) {
            throw "Invalid settings structure - missing profiles"
        }
        
        return $settings
    }
    catch {
        throw "Failed to read settings: $_"
    }
}

function Save-TerminalSettings {
    param(
        [Parameter(Mandatory)]
        $Settings,
        [Parameter(Mandatory)]
        [string]$Path
    )
    
    try {
        $json = $Settings | ConvertTo-Json -Depth 100 -Compress:$false
        [System.IO.File]::WriteAllText($Path, $json, [System.Text.Encoding]::UTF8)
        Write-ColoredOutput "✓ Settings saved successfully" -Color Green
    }
    catch {
        throw "Failed to save settings: $_"
    }
}

function Get-FilteredProfiles {
    param(
        [array]$Profiles,
        [string]$IncludeFilter,
        [string]$ExcludeFilter,
        [int]$Index
    )
    
    $filtered = $Profiles
    
    if ($IncludeFilter) {
        $filtered = $filtered | Where-Object { $_.name -match $IncludeFilter -or $_.commandline -match $IncludeFilter }
    }
    
    if ($ExcludeFilter) {
        $filtered = $filtered | Where-Object { $_.name -notmatch $ExcludeFilter -and $_.commandline -notmatch $ExcludeFilter }
    }
    
    if ($Index) {
        if ($Index -le $Profiles.Count) {
            $filtered = @($Profiles[$Index - 1])
        } else {
            throw "Profile index $Index is out of range (1-$($Profiles.Count))"
        }
    }
    
    return $filtered
}

function Update-CommunityThemes {
    param($Settings)
    
    Write-ColoredOutput "`n📥 Downloading community themes..." -Color Cyan
    
    try {
        $headers = @{
            "Accept" = "application/json"
            "Accept-Encoding" = "gzip, deflate, br"
            "Origin" = "https://windowsterminalthemes.dev"
            "Referer" = "https://windowsterminalthemes.dev/"
        }
        
        $response = Invoke-RestMethod -Uri $themesApiUrl -Headers $headers -Method Get
        
        if (-not $response) {
            throw "No themes received from API"
        }
        
        $oldThemes = if ($Settings.schemes) { 
            $Settings.schemes | Select-Object -ExpandProperty name 
        } else { 
            @() 
        }
        
        $Settings.schemes = $response | Where {
            $_.name -notmatch "light"
        }
        
        $newThemes = $Settings.schemes | Select-Object -ExpandProperty name
        $added = $newThemes | Where-Object { $_ -notin $oldThemes }
        
        Write-ColoredOutput "✓ Total themes available: $($newThemes.Count)" -Color Green
        
        if ($added.Count -gt 0) {
            Write-ColoredOutput "`n🆕 New themes added:" -Color Yellow
            $added | ForEach-Object { Write-ColoredOutput "   • $_" -Color Gray }
        }
        
        return $Settings
    }
    catch {
        throw "Failed to download themes: $_"
    }
}

function Show-CurrentThemes {
    param($Profiles)
    
    Write-ColoredOutput "`n🎨 Current Theme Configuration" -Color Cyan
    Write-ColoredOutput ("=" * 50) -Color DarkGray
    
    $maxNameLength = ($Profiles.name | Measure-Object -Maximum -Property Length).Maximum
    
    for ($i = 0; $i -lt $Profiles.Count; $i++) {
        $profile = $Profiles[$i]
        $index = "{0,2}" -f ($i + 1)
        $name = "{0,-$maxNameLength}" -f $profile.name
        $theme = $profile.colorScheme
        
        Write-ColoredOutput "[$index] " -Color DarkGray -NoNewline
        Write-ColoredOutput "$name " -Color White -NoNewline
        Write-ColoredOutput "→ " -Color DarkGray -NoNewline
        Write-ColoredOutput "$theme" -Color Magenta
    }
}

function Set-RandomThemes {
    param(
        [array]$Profiles,
        [array]$Schemes
    )
    
    if ($Schemes.Count -eq 0) {
        throw "No color schemes available"
    }
    
    Write-ColoredOutput "`n🎲 Shuffling themes..." -Color Cyan
    $random = [System.Random]::new()
    $updates = @()
    
    foreach ($profile in $Profiles) {
        $oldTheme = $profile.colorScheme
        $newTheme = $Schemes[$random.Next($Schemes.Count)].name
        $profile.colorScheme = $newTheme
        
        $updates += [PSCustomObject]@{
            Profile = $profile.name
            OldTheme = $oldTheme
            NewTheme = $newTheme
        }
    }
    
    Write-ColoredOutput "`n✨ Theme Updates:" -Color Green
    $updates | Format-Table -AutoSize
}

function Set-SpecificTheme {
    param(
        [array]$Profiles,
        [string]$ThemeName,
        [array]$AvailableThemes
    )
    
    if ($ThemeName -notin $AvailableThemes) {
        Write-ColoredOutput "⚠ Theme '$ThemeName' not found. Available themes:" -Color Yellow
        Write-ColoredOutput "Use -Action List to see all available themes" -Color Gray
        return $false
    }
    
    foreach ($profile in $Profiles) {
        $profile.colorScheme = $ThemeName
        Write-ColoredOutput "✓ Set $($profile.name) to theme: $ThemeName" -Color Green
    }
    
    return $true
}

function Backup-Settings {
    param(
        [string]$SettingsPath,
        [string]$BackupPath
    )
    
    if (-not $BackupPath) {
        $dir = Split-Path $SettingsPath -Parent
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $BackupPath = Join-Path $dir "settings.backup.$timestamp.json"
    }
    
    Copy-Item $SettingsPath $BackupPath -Force
    Write-ColoredOutput "✓ Backup created: $BackupPath" -Color Green
    return $BackupPath
}

#endregion

#region Main Logic

try {
    # Find and load settings
    $settingsPath = Get-TerminalSettingsPath
    $settings = Read-TerminalSettings -Path $settingsPath
    
    # Get profiles
    $allProfiles = $settings.profiles.list
    if ($allProfiles.Count -eq 0) {
        throw "No profiles found in settings"
    }
    
    # Filter profiles based on parameters
    $targetProfiles = Get-FilteredProfiles `
        -Profiles $allProfiles `
        -IncludeFilter $IncludeFilter `
        -ExcludeFilter $ExcludeFilter `
        -Index $ProfileIndex
    
    # Execute action
    switch ($Action) {
        'Current' {
            Show-CurrentThemes -Profiles $allProfiles
        }
        
        'Update' {
            $settings = Update-CommunityThemes -Settings $settings
            Save-TerminalSettings -Settings $settings -Path $settingsPath
        }
        
        'List' {
            Write-ColoredOutput "`n📋 Available Color Schemes" -Color Cyan
            Write-ColoredOutput ("=" * 50) -Color DarkGray
            
            if ($settings.schemes) {
                $settings.schemes | ForEach-Object -Begin { $i = 1 } -Process {
                    Write-ColoredOutput ("{0,3}. {1}" -f $i++, $_.name) -Color White
                }
                Write-ColoredOutput "`nTotal: $($settings.schemes.Count) schemes" -Color Green
            } else {
                Write-ColoredOutput "No schemes found. Run with -Action Update first." -Color Yellow
            }
        }
        
        'Set' {
            if (-not $ThemeName) {
                throw "ThemeName is required when using -Action Set"
            }
            
            $availableThemes = $settings.schemes | Select-Object -ExpandProperty name
            if (Set-SpecificTheme -Profiles $targetProfiles -ThemeName $ThemeName -AvailableThemes $availableThemes) {
                Save-TerminalSettings -Settings $settings -Path $settingsPath
            }
        }
        
        'Backup' {
            Backup-Settings -SettingsPath $settingsPath -BackupPath $BackupPath
        }
        
        'Restore' {
            if (-not $BackupPath -or -not (Test-Path $BackupPath)) {
                throw "Valid BackupPath required for restore operation"
            }
            Copy-Item $BackupPath $settingsPath -Force
            Write-ColoredOutput "✓ Settings restored from: $BackupPath" -Color Green
        }
        
        'Shuffle' {
            # Auto-update if schemes are limited
            if ($settings.schemes.Count -lt 50) {
                Write-ColoredOutput "⚠ Limited themes detected. Updating..." -Color Yellow
                $settings = Update-CommunityThemes -Settings $settings
            }
            
            Set-RandomThemes -Profiles $targetProfiles -Schemes $settings.schemes
            Save-TerminalSettings -Settings $settings -Path $settingsPath
        }
    }
    
    Write-ColoredOutput "`n✅ Operation completed successfully!" -Color Green
}
catch {
    Write-ColoredOutput "`n❌ Error: $_" -Color Red
    exit 1
}

#endregion
