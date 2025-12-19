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

## Greeting Cache System

`fish_greeting.fish` displays outdated package counts cached in `~/.cache/`. The `brew` and `apt` wrapper functions clear these caches after upgrade commands so the greeting reflects current state. Counts of zero are hidden.

## Addon System

Addons work by replacing placeholder comments in `config.fish` (e.g., `# fnm:path`) with actual configuration lines using `sed`. Each addon file defines a `__fish_addon_<name>` function that:
1. Installs the tool if not present (via curl)
2. Modifies `config.fish` to add PATH and initialization

The repo is stored at `~/.local/share/dotfiles` after install for `fish_update` to pull from.
