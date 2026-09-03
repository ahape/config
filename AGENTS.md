# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

Personal dotfiles and configuration repo for cross-platform use (macOS, Linux, Windows). There is no build system, test suite, or CI. Changes are validated by manually deploying configs and verifying behavior.

## Repository Layout

- **`common/`** -- Cross-platform configs (zsh, tmux, screen, nvim, git, editorconfig, nuget, mgba). These get symlinked into `$HOME` by `bootstrap_ubuntu.sh`.
- **`osx/`** -- macOS-specific configs: Homebrew `Brewfile`, Rectangle window manager, application list.
- **`windows/`** -- Windows-specific configs: PowerShell profiles, Windows Terminal settings, helper scripts, Chocolatey package list, SharpKeys (Caps Lock remapped to Ctrl).
- **`bootstrap_ubuntu.sh`** -- Symlink installer for Linux/macOS. Links files from `common/` into the appropriate `$HOME` locations. Backs up existing files before overwriting.

## Architecture Notes

**Two distinct PowerShell profiles exist for Windows:**
- `windows/Microsoft.Powershell_profile.ps1` -- The main PowerShell profile (loaded at shell startup). Contains aliases (`vi`, `lsf`, `gshow`), lazy-loads external modules (llmchat, markterm), and defines a minimal 2-segment prompt.
- `windows/terminal/PowershellProfile.ps1` -- A separate profile for Windows Terminal tabs spawned via the `Ctrl+O` keybinding. Has its own richer prompt (user@host, git branch), PSReadLine config with color scheme, window-title updates, and a `Ctrl+O` handler that injects a randomly-themed Terminal profile.

**Helper scripts in `windows/Scripts/`** are invoked via aliases defined in the main profile:
- `Git-Show.ps1` (alias `gshow`) -- Opens a commit in the browser by constructing a URL from `remote.origin.url`.
- `Git-LsFiles.ps1` (alias `lsf`) -- Pipes `git ls-files` through `Select-String`.
- `Clean-SwapFiles.ps1` -- Clears nvim swap/shada files from the Windows nvim-data directory.

**Git config (`common/git/.gitconfig`)** uses VS Code as both merge and diff tool, sets `core.hooksPath = .githooks`, and defaults to `pretty = oneline` log format.

**Nvim config** is split across `init.vim`, `functions.vim`, and `augroups.vim`, with a custom `2do` filetype (syntax + ftdetect).

## Key Conventions

- Config files in `common/` must work on both macOS and Linux (the zshrc and tmux.conf already handle platform differences with runtime checks).
- The `.gitconfig` has a commented-out `autocrlf` setting -- it must be set per-platform, not committed as a single value.
- Secrets are loaded from `~/.zprofile.secrets` (never committed).
- The bootstrap script is idempotent -- re-running it skips already-correct symlinks and backs up conflicts.
