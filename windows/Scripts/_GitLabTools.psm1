function New-GlabSnip {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [AllowEmptyString()]
        [string[]]$Content, # buffered
        [Parameter()]
        [string]$Title
    )
    begin {
        if (-not (Get-Command glab -ErrorAction SilentlyContinue)) {
            throw "The 'glab' CLI is not installed or not on PATH. See https://gitlab.com/gitlab-org/cli"
        }
        $lines = [System.Collections.Generic.List[string]]::new()
    }
    process {
        foreach ($item in $Content) {
            $lines.Add($item)
        }
    }
    end {
        $fullContent = $lines -join [Environment]::NewLine

        $uid = [guid]::NewGuid().ToString()
        $fileName = "$uid.md"
        $filePath = Join-Path ([System.IO.Path]::GetTempPath()) $fileName
        $snippetTitle = if ($PSBoundParameters.ContainsKey('Title')) { $Title } else { "anon-$uid" }

        try {
            Set-Content -LiteralPath $filePath -Value $fullContent -Encoding utf8
            $url = glab snippet create --personal -t $snippetTitle -v public -f $fileName $filePath 2>&1
            if ($LASTEXITCODE -ne 0) {
                throw "glab snippet create failed: $url"
            }
            Write-Output $url
        }
        finally {
            Remove-Item -LiteralPath $filePath -ErrorAction SilentlyContinue
        }
    }
}
Export-ModuleMember -Function New-GlabSnip
