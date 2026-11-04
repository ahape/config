# Brightmetrics work tooling: .NET / Visual Studio, SQL Server, IIS, Azure.
. "$PSScriptRoot\_Install-WingetPackages.ps1"

Install-WingetPackages @(
  # Visual Studio installs only the core editor; choose workloads in the VS Installer afterward.
  # IIS Express, LocalDB, Web Deploy, the SQL Server ODBC driver, and the .NET Framework 4.6.2
  # targeting pack are VS Installer components, not separate packages.
  'Microsoft.VisualStudio.Enterprise'
  'Microsoft.VisualStudio.2022.Enterprise'

  # .NET
  'Microsoft.DotNet.SDK.8'
  'Microsoft.DotNet.SDK.9'
  'Microsoft.DotNet.SDK.10'
  'Microsoft.DotNet.Framework.DeveloperPack.4.5'
  'WiXToolset.WiXToolset'
  'icsharpcode.ILSpy'

  # Data and web hosting
  'Microsoft.SQLServerManagementStudio.22'
  'Microsoft.SQLServer.OLEDBDriver'
  'PostgreSQL.PostgreSQL.16'
  'Memurai.MemuraiDeveloper'
  'Microsoft.IIS.URLRewrite'

  # Azure
  'Microsoft.AzureCLI'
  'Microsoft.Azure.StorageExplorer'
  'Microsoft.Azure.AZCopy.10'

  # Communication
  'SlackTechnologies.Slack'
  'Zoom.Zoom'
)
