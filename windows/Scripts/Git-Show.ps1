[CmdletBinding()]
param(
    [Parameter(ValueFromPipeline=$true)]
    [String]$CommitHash
)

# https://github.com/org/repo[.git] --> https://github.com/org/repo/[commit]
$remoteUrl=(git config --get remote.origin.url).Replace(".git", "/commit")

# Assuming the default application for opening links is set up
explorer.exe "$remoteUrl/$($CommitHash.Trim())?w=1"
