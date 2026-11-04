# Personal and general dev tooling.
. "$PSScriptRoot\_Install-WingetPackages.ps1"

Install-WingetPackages @(
  # Shell and core
  'Git.Git'
  'GitHub.cli'
  'GLab.GLab'
  'Microsoft.PowerShell'
  'Microsoft.WindowsTerminal'
  'Microsoft.WSL'
  'RandyRants.SharpKeys'

  # CLI tools
  'BurntSushi.ripgrep.MSVC'
  'jqlang.jq'
  'MikeFarah.yq'
  'sharkdp.bat'
  'sharkdp.fd'
  'dandavison.delta'
  'eza-community.eza'
  'junegunn.fzf'
  'jftuga.less'
  'JernejSimoncic.Wget'
  'GnuWin32.UnZip'
  'UniversalCtags.Ctags'
  'Neovim.Neovim'
  'vim.vim'

  # Languages and runtimes (Node versions come from `fnm install`)
  'Schniz.fnm'
  'Oven-sh.Bun'
  'Rustlang.Rustup'
  'Python.Python.3.14'
  'astral-sh.uv'

  # Editors and AI tools
  'Microsoft.VisualStudioCode'
  'Anthropic.ClaudeCode'
  'SST.opencode'
  'Google.Antigravity'

  # Dev utilities
  'Docker.DockerDesktop'
  'Graphviz.Graphviz'
  'DBBrowserForSQLite.DBBrowserForSQLite'

  # Browsers
  'Google.Chrome'
  'Google.Chrome.Canary'
  'Mozilla.Firefox'
  'Mozilla.Firefox.DeveloperEdition'

  # Apps and utilities
  'Spotify.Spotify'
  'WireGuard.WireGuard'
  '7zip.7zip'
  'Greenshot.Greenshot'
  'NickeManarin.ScreenToGif'
  'REALiX.HWiNFO'
)
