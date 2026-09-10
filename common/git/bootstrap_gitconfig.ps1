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

$gitDir = Split-Path -Parent $target
New-Item -ItemType Directory -Force -Path $gitDir | Out-Null
if (Test-Path -LiteralPath $target) {
    Remove-Item -LiteralPath $target -Force
}

Set-Git user.name 'Alan Hape'
Set-Git user.email 'ahape@brightmetrics.com'

Set-Git help.autocorrect '1'
Set-Git push.autoSetupRemote 'true'
Set-Git grep.fullName 'true'
Set-Git grep.lineNumber 'true'
Set-Git log.abbrevCommit 'true'
Set-Git status.short 'true'
Set-Git format.pretty 'oneline'
Set-Git alias.pull-r 'pull -r'

Set-Git web.browser 'chrome'

Set-Git merge.tool 'code'
Set-Git mergetool.code.cmd 'code --wait --merge $REMOTE $LOCAL $BASE $MERGED'
Set-Git diff.tool 'code'
Set-Git difftool.code.cmd 'code --new-window --wait --diff $LOCAL $REMOTE'

Set-Git core.longpaths 'true'
Set-Git core.hooksPath '.githooks'
Set-Git core.editor 'vim'
Set-Git core.excludesfile (ConvertTo-GitPath (Join-Path $HOME '.gitignore-global'))

Set-Git rebase.updateRefs 'true'

Set-Git 'credential.https://dev.azure.com.useHttpPath' 'true'
Set-Git 'credential.https://github.com.username' 'ahape'
Set-Git 'credential.https://github.com/ahape/.username' 'ahape'
Set-Git 'credential.https://github.com/brightmetrics/.username' 'ahape'
Set-Git 'credential.https://brightmetrics-staging.scm.azurewebsites.net.provider' 'generic'
Set-Git 'credential.https://brightmetrics-testing.scm.azurewebsites.net.provider' 'generic'

Set-Git filter.lfs.required 'true'
Set-Git filter.lfs.clean 'git-lfs clean -- %f'
Set-Git filter.lfs.smudge 'git-lfs smudge -- %f'
Set-Git filter.lfs.process 'git-lfs filter-process'

switch ($Platform) {
    'Windows' {
        Set-Git core.autocrlf 'true'
        Set-Git browser.chrome.path 'C:\Program Files\Google\Chrome\Application\chrome.exe'
        Set-Git credential.helper 'manager'
    }
    'Mac' {
        Set-Git core.autocrlf 'input'
        Set-Git browser.chrome.path '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'
        Set-Git credential.helper 'osxkeychain'
    }
    'WSL' {
        Set-Git core.autocrlf 'input'
        Set-Git browser.chrome.path '/mnt/c/Program Files/Google/Chrome/Application/chrome.exe'
        Set-Git credential.helper '/mnt/c/Program Files/Git/mingw64/bin/git-credential-manager.exe'
    }
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
