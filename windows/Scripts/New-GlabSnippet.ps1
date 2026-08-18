function New-GlabSnippet {
    <#
    .SYNOPSIS
        Creates a public personal GitLab snippet from markdown content.
    .DESCRIPTION
        Accepts markdown content (via pipeline or parameter), writes it to a
        temporary .md file, creates a public personal snippet using the glab
        CLI, outputs the snippet URL, and cleans up the temp file.
    .PARAMETER Content
        The markdown content to publish as a snippet. Accepts pipeline input.
    .PARAMETER Title
        Optional title for the snippet. Defaults to "anon-<guid>".
    .EXAMPLE
        Get-Content .\notes.md -Raw | New-GlabSnippet
    .EXAMPLE
        New-GlabSnippet -Content "# Hello" -Title "my-notes"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [AllowEmptyString()]
        [string]$Content,

        [Parameter()]
        [string]$Title
    )

    begin {
        if (-not (Get-Command glab -ErrorAction SilentlyContinue)) {
            throw "The 'glab' CLI is not installed or not on PATH. See https://gitlab.com/gitlab-org/cli"
        }
    }

    process {
        $uid = [guid]::NewGuid().ToString()
        $fileName = "$uid.md"
        $filePath = Join-Path ([System.IO.Path]::GetTempPath()) $fileName
        $snippetTitle = if ($PSBoundParameters.ContainsKey('Title')) { $Title } else { "anon-$uid" }

        try {
            Set-Content -LiteralPath $filePath -Value $Content -Encoding utf8

            $url = glab snippet create --personal -t $snippetTitle -v public -f $fileName $filePath 2>&1
            if ($LASTEXITCODE -ne 0) {
                throw "glab snippet create failed: $url"
            }
            # glab prints the snippet URL on success
            $url
        }
        finally {
            Remove-Item -LiteralPath $filePath -Force -ErrorAction SilentlyContinue
        }
    }
}

