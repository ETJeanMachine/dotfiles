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
│   ├── apt.fish             # APT wrapper (clears cache on upgrade)
│   └── addons/              # Modular addon installers
│       ├── fnm.fish         # Fast Node Manager
│       ├── go.fish          # Go bin path
│       ├── cargo.fish       # Rust/Cargo
│       └── bun.fish         # Bun runtime
└── completions/             # Tab completions for custom functions
```

## Greeting System

`fish_greeting.fish` displays an animated greeting followed by a quote of the day from computer scientists.

**Greeting animation** depends on cache staleness (>6 hours):

- **Cache fresh:** Static greeting with dark blue star, cyan text.
- **Cache stale:** Animated greeting while refreshing brew/apt:
  - Scanning color wave sweeps back and forth (cyan → brblack taper)
  - Dark blue cycling star (`·` → `+` → `✳` → `✶`)
  - Shows "(refreshing brew/apt)" during refresh
  - After refresh, displays package status

**Quote of the day:**
- Quotes sourced from [skolakoda/programming-quotes](https://github.com/skolakoda/programming-quotes)
- Downloaded during `install.sh` to `~/.config/fish/quotes.json`
- Same quote shown throughout the day (based on day of year)
- Requires `python3` for JSON parsing

The `brew` and `apt` wrapper functions clear caches after upgrade commands.

## Addon System

Addons work by replacing placeholder comments in `config.fish` (e.g., `# fnm:path`) with actual configuration lines using `sed`. Each addon file defines a `__fish_addon_<name>` function that:
1. Installs the tool if not present (via curl)
2. Modifies `config.fish` to add PATH and initialization

To add a new addon:
1. Add placeholder comment(s) to `config.fish` (e.g., `# newtool:path`)
2. Create `functions/addons/newtool.fish` with a `__fish_addon_newtool` function
3. Update the list in `functions/fish_add.fish` and `completions/fish_add.fish`

The repo is stored at `~/.local/share/dotfiles` after install for `fish_update` to pull from.
