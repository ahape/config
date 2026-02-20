[CmdletBinding()]
param(
  [Parameter(ValueFromPipeline=$true, Mandatory=$true)]
  [string]$pattern
)
git ls-files | Select-String -Pattern $pattern.Trim() -SimpleMatch
