[CmdletBinding()]
param(
  [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
  [Alias("FullName")]
  [string] $Path,

  [Parameter(Mandatory=$false)]
  [int] $Wrap,

  [Parameter(Mandatory=$false)]
  [string] $Theme = "monokai"
)

begin {
  $markterm = "C:\Users\AlanHape\source\repos\markterm"
  $program = Join-Path $markterm "markterm" "cli.py"

  if (-not (Test-Path $program)) {
    throw "Could not find markterm. Either run from repository or install with: pip install -e ."
  }
}

process {
  $resolved = Resolve-Path -LiteralPath $Path -ErrorAction Stop
  try {
    Push-Location $markterm

    # Build arguments
    $args = @($program, $resolved.Path, "--theme", $Theme)
    if ($PSBoundParameters.ContainsKey("Wrap")) {
      $args += @("--wrap", $Wrap)
    }

    & ".venv/Scripts/python.exe" @args

  } finally {
    Pop-Location
  }
}
