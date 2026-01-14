$global:repo = "C:\src\projects";

Set-Alias -Name vi -Value vim -ErrorAction Ignore

# -----------------------------------------------------------------------------
#       Hook the 'Enter' key to update the Title BEFORE the command runs
# -----------------------------------------------------------------------------
if (Get-Module -ListAvailable PSReadLine) {
    Set-PSReadLineKeyHandler -Key Enter -ScriptBlock {
        # 1. Get the current command line text
        $line = $null
        $cursor = $null
        [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

        # 2. Update the window title immediately if there is a command
        if (-not [string]::IsNullOrWhiteSpace($line)) {
            $Host.UI.RawUI.WindowTitle = "PS: $line"
        }

        # 3. Proceed to execute the command (standard Enter behavior)
        [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
    }
}

# -----------------------------------------------------------------------------
#                             PS ..\src\projects>
# -----------------------------------------------------------------------------
function prompt {
    # Optional: You can keep this to ensure the title persists or updates
    # based on history after the command finishes.
    $title = GetCustomWindowTitle
    if ($title) {
        $Host.UI.RawUI.WindowTitle = $title
    }
    return OverridePrompt
}

function OverridePrompt {
    $path = $pwd.Path
    $parts = $path -split '\\'

    # Check if there are more than 2 directory levels (e.g., C:\A\B)
    if ($parts.Count -gt 2) {
        # Join the last two parts
        $lastTwo = $parts[-2..-1] -join '\'
        return "PS ..\$lastTwo> "
    }
    else {
        # Show full path if it's short (e.g., C:\Users or C:\)
        return "PS $path> "
    }
}

function GetCustomWindowTitle {
    try {
        # This acts as a fallback/refresher when the prompt reloads
        $lastCommand = $(Get-History | Select-Object -Last 1).CommandLine
        if (-not $lastCommand) {
            return "PS: New"
        }
        return "PS: $lastCommand"
    } catch {
        return $null
    }
}
