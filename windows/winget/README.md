# winget packages

Two install scripts: `Install-Personal.ps1` (general dev tools, CLI tools, browsers, utilities) and `Install-Brightmetrics.ps1` (work tooling: .NET / Visual Studio, SQL Server, IIS, Azure). Packages that are already installed are skipped, so both scripts are safe to re-run.

```ps1
pwsh -File .\Install-Personal.ps1
pwsh -File .\Install-Brightmetrics.ps1
```

Not available on winget, so install these another way:

- NUnit Console: MSI from the `nunit/nunit-console` GitHub releases
- Emscripten: `emsdk` from GitHub
- Node: `fnm install 22`, `fnm install 24`
- PostGIS: StackBuilder, after PostgreSQL is installed
