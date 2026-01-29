# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal dotfiles repository for fish shell configuration.

## Installation

```bash
./install.sh
```

This clones the repo to `~/.local/share/dotfiles`, copies fish configs to `~/.config/fish/`, installs starship prompt, and configures it with the pure-preset.

## Key Commands

- `fish_update` - Pull latest changes from repo and update local fish config (skips copy if only non-fish files changed)
- `fish_source` - Reload fish config without restarting shell

## Testing Changes

No build system. To test locally:
1. Edit files in the repo
2. Run `cp -r fish/. ~/.config/fish/` to copy to active config
3. Run `fish_source` or restart fish to apply

## Architecture

```
fish/
├── config.fish              # Main config
├── functions/
│   ├── fish_update.fish     # Pulls repo and syncs config (only if fish/ changed)
│   ├── fish_greeting.fish   # Shell greeting with cached package counts
│   ├── brew.fish            # Homebrew wrapper (clears cache on upgrade)
│   ├── hx.fish              # Helix wrapper (syncs theme with OS dark/light mode)
│   ├── claude.fish          # Claude Code wrapper (syncs theme with OS dark/light mode)
│   └── __detect_os_theme.fish # Shared helper returning 'dark' or 'light'
└── completions/             # Tab completions for custom functions
```

## Greeting System

`fish_greeting.fish` behavior depends on cache staleness (>1 week):

**Cache fresh:** Static greeting with dark blue star, cyan text.

**Cache stale:** Animated greeting while refreshing brew:
- Scanning color wave sweeps back and forth (cyan → brblack taper)
- Dark blue cycling star (`·` → `+` → `✶` → `✱`)
- Shows "(refreshing brew)" during refresh
- After refresh, displays package status ("X formulae, Y casks outdated" or "Casks and formulae up to date")

The `brew` wrapper function clears the cache after upgrade commands. A lockfile (`~/.cache/pkg_refresh.lock`) prevents concurrent cache writes between `fish_greeting` and `brew`.

## Dynamic Theme Switching

Wrapper functions automatically sync application themes with the OS dark/light mode setting (macOS and GNOME supported):

- **`hx`** - Updates `~/.config/helix/config.toml` before launching Helix
  - Dark: `catppuccin_frappe`
  - Light: `catppuccin_latte`

- **`claude`** - Updates `~/.claude.json` before launching Claude Code (requires `jq`)
  - Sets `theme` to `dark` or `light`

Detection methods:
- **macOS**: `defaults read -g AppleInterfaceStyle` (returns "Dark" in dark mode)
- **GNOME**: `gsettings get org.gnome.desktop.interface color-scheme`

## Portability

These configs must work on both macOS and Linux. Avoid `sed -i` as its syntax is incompatible between BSD (macOS) and GNU (Linux). Prefer fish builtins like `string replace` with a temp file instead.

## Git Filter for Controlled Blocks

The install script configures a git filter `ignore-after-comment` that truncates files at `# END CONTROLLED BLOCK` when staging. This allows local modifications after that marker without them being tracked by git.

To use on a file, add to `.gitattributes`:
```
fish/config.fish filter=ignore-after-comment
```
