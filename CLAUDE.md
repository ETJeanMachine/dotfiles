# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal dotfiles repository for fish shell configuration with a modular addon system.

## Installation

```bash
./install.sh
```

This clones the repo to `~/.local/share/dotfiles`, copies fish configs to `~/.config/fish/`, installs starship prompt, and configures it with the pure-preset.

## Key Commands

- `fish_update` - Pull latest changes from repo and update local fish config
- `fish_add <addon>` - Install and configure optional tools (fnm, go, cargo, bun)
- `fish_source` - Reload fish config without restarting shell

## Testing Changes

No build system. To test locally:
1. Edit files in the repo
2. Run `cp -r fish/. ~/.config/fish/` to copy to active config
3. Run `fish_source` or restart fish to apply

## Architecture

```
fish/
├── config.fish              # Main config with placeholder comments for addons
├── functions/
│   ├── fish_update.fish     # Pulls repo and syncs config
│   ├── fish_add.fish        # Addon installer dispatcher
│   ├── fish_greeting.fish   # Shell greeting with cached package counts
│   ├── brew.fish            # Homebrew wrapper (clears cache on upgrade)
│   ├── hx.fish              # Helix wrapper (syncs theme with OS dark/light mode)
│   ├── claude.fish          # Claude Code wrapper (syncs theme with OS dark/light mode)
│   └── addons/              # Modular addon installers
│       ├── fnm.fish         # Fast Node Manager
│       ├── go.fish          # Go bin path
│       ├── cargo.fish       # Rust/Cargo
│       └── bun.fish         # Bun runtime
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

## Addon System

Addons work by replacing placeholder comments in `config.fish` (e.g., `# fnm:path`) with actual configuration lines using `sed`. Each addon file defines a `__fish_addon_<name>` function that:
1. Installs the tool if not present (via curl)
2. Modifies `config.fish` to add PATH and initialization

To add a new addon:
1. Add placeholder comment(s) to `config.fish` (e.g., `# newtool:path`)
2. Create `functions/addons/newtool.fish` with a `__fish_addon_newtool` function
3. Update the list in `functions/fish_add.fish` and `completions/fish_add.fish`

The repo is stored at `~/.local/share/dotfiles` after install for `fish_update` to pull from.

## Dynamic Theme Switching

Wrapper functions automatically sync application themes with the OS dark/light mode setting (macOS and GNOME supported):

- **`hx`** - Updates `~/.config/helix/config.toml` before launching Helix
  - Dark: `tokyonight_storm`
  - Light: `catppuccin_latte`

- **`claude`** - Updates `~/.claude.json` before launching Claude Code (requires `jq`)
  - Sets `theme` to `dark` or `light`

Detection methods:
- **macOS**: `defaults read -g AppleInterfaceStyle` (returns "Dark" in dark mode)
- **GNOME**: `gsettings get org.gnome.desktop.interface color-scheme`

## Git Filter for Controlled Blocks

The install script configures a git filter `ignore-after-comment` that truncates files at `# END CONTROLLED BLOCK` when staging. This allows local modifications after that marker without them being tracked by git.

To use on a file, add to `.gitattributes`:
```
fish/config.fish filter=ignore-after-comment
```
