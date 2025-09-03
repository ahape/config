# Arguments
# ---------
# None: -- It will shuffle all themes for your terminal profiles
# 0: current -- [Optional] Display all of the current color schemes set
# 0: update -- [Optional] Updates the color schemes stored in your settings file
# 0: list-schemes -- [Optional] List all of the color schemes stored in your settings file
# 0: <1 | 2 | ...> -- [Optional] The Powershell profile index you want to change
# 1: <colorScheme> -- [Optional] The name of the colorScheme you want to set the profile

$file = "$env:LOCALAPPDATA/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json"
try {
    $settings = [System.IO.File]::ReadAllText($file) | ConvertFrom-Json
} catch {
    Write-Host "ERROR: Change [file] variable to the path of your terminal settings.json"
    Write-Host "You can find this in your $env:LOCALAPPDATA/Packages/Microsoft.WindowsTerminal_XXX folder"
    Exit
}

$profiles = $settings.profiles.list # | where { @("pwsh.exe", "powershell.exe").Contains($_.commandLine) }

if ($profiles.Length -eq 0) {
    Write-Host "ABORTING: No profiles to apply themes to"
    Exit
}

$updatedSchemes = [System.Collections.Generic.List[string]]::new()
$random = [System.Random]::new()
$commandArgs = $args

function updateLocalSchemes {
    Write-Host "Installing all community color schemes into your settings.json ..."

    $old = $settings.schemes | select -expandproperty "name"

    $settings.schemes = ((Invoke-WebRequest -UseBasicParsing -Uri "https://2zrysvpla9.execute-api.eu-west-2.amazonaws.com/prod/themes" `
        -Headers @{
          "Accept"="*/*"
          "Accept-Encoding"="gzip, deflate, br"
          "Accept-Language"="en-US,en;q=0.9"
          "Cache-Control"="no-cache"
          "Origin"="https://windowsterminalthemes.dev"
          "Pragma"="no-cache"
          "Referer"="https://windowsterminalthemes.dev/"
        }) | ConvertFrom-Json) | Select

    $new = $settings.schemes | select -expandproperty "name"

    return [system.linq.enumerable]::Except([string[]]$new, [string[]]$old)
}

function saveSettings {
    [System.IO.File]::WriteAllText($file, ($settings | ConvertTo-Json -Depth 100).ToString())
}

if ($args.Length -gt 0) {
    switch ($args[0]) {
        "current" {
            $profiles | foreach { Write-Host "$($_.name) -> $($_.colorScheme)" }
            Exit
        }
        "update" {
            updateLocalSchemes | foreach { Write-Host "[new] $_" }
            saveSettings
            Exit
        }
        "list-schemes" {
            $settings.schemes | foreach { Write-Host $_.name }
            Exit
        }
    }
}

# Update local schemes list if it's lacking
if ($settings.schemes.Count -lt 50) {
    updateLocalSchemes
}

$index = 0
foreach ($profile in $profiles) {
    $randomIndex = $random.Next($settings.schemes.Count)
    $theme = $settings.schemes[$randomIndex].name
    $profileIndex = $index + 1 # Non-zero indexing of profiles
    $index += 1

    if (($commandArgs.Length -gt 0) -and ($commandArgs[0] -ne $profileIndex)) {
        continue
    }

    if ($commandArgs.Length -gt 1) {
        $theme = $commandArgs[1]
    }

    $profile.colorScheme = $theme
    $updatedSchemes.Add($theme)
}

saveSettings

$updatedSchemes | foreach { Write-Host "New theme: $_" }
