[CmdletBinding()]
param(
    [Parameter(ValueFromPipeline=$true)]
    [String]$commit_hash
)
# https://github.com/org/repo.git --> https://github.com/org/repo/commit
$remote_url=(git config --get remote.origin.url).Replace(".git", "/commit")
# Assuming the default application for opening links is set up
start "$remote_url/$($commit_hash.Trim())?w=1"
