## What This Repo Is

Personal dotfiles and configuration repo for cross-platform use (macOS, Linux, Windows). There is no build system, test suite, or CI. Changes are validated by manually deploying configs and verifying behavior.

## Repository Layout

- **`common/`** -- Cross-platform configs (zsh, tmux, screen, nvim, git, editorconfig, nuget, mgba). These get symlinked into `$HOME` by `bootstrap_ubuntu.sh`.
- **`osx/`** -- macOS-specific configs: Homebrew `Brewfile`, Rectangle window manager, application list.
- **`windows/`** -- Windows-specific configs: PowerShell profiles, Windows Terminal settings, helper scripts, Chocolatey package list, SharpKeys (Caps Lock remapped to Ctrl).
- **`bootstrap_ubuntu.sh`** -- Symlink installer for Linux/macOS. Links files from `common/` into the appropriate `$HOME` locations. Backs up existing files before overwriting. Does not install `~/.gitconfig`.
- **`common/git/bootstrap_gitconfig.ps1`** -- Generates `~/.config/git/generated.gitconfig` and points `~/.gitconfig` at it. Required `-Platform` is `Mac`, `Windows`, or `WSL`. Settings live in `common/git/config-settings.csv` (`key`, `value`, `env`; empty `env` is common to all platforms).

## Architecture Notes

**Two distinct PowerShell profiles exist for Windows:**
- `windows/Microsoft.Powershell_profile.ps1` -- The main PowerShell profile (loaded at shell startup). Contains aliases (`vi`, `lsf`, `gshow`), lazy-loads external modules (llmchat, markterm), and defines a minimal 2-segment prompt.
- `windows/terminal/PowershellProfile.ps1` -- A separate profile for Windows Terminal tabs spawned via the `Ctrl+O` keybinding. Has its own richer prompt (user@host, git branch), PSReadLine config with color scheme, window-title updates, and a `Ctrl+O` handler that injects a randomly-themed Terminal profile.

**Nvim config** is split across `init.vim`, `functions.vim`, and `augroups.vim`, with a custom `2do` filetype (syntax + ftdetect).

## Key Conventions

- Config files in `common/` must work on both macOS and Linux (the zshrc and tmux.conf already handle platform differences with runtime checks).
- Secrets are loaded from `~/.zprofile.secrets` (never committed).
- All bootstrap scripts are idempotent -- re-running them skips already-correct symlinks and avoids stacking backups.
