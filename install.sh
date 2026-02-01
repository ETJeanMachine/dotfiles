#!/bin/bash

DOTFILES_DIR="$HOME/.local/share/dotfiles"
REPO_URL="https://github.com/ETJeanMachine/dotfiles.git"

# Check for Homebrew
if ! command -v brew &>/dev/null; then
    echo "Error: Homebrew is not installed."
    echo "Install it from https://brew.sh and re-run this script."
    exit 1
fi

# Install packages from Brewfile
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
echo "Installing brew packages..."
brew bundle --file="$SCRIPT_DIR/Brewfile"

# Clone or update dotfiles repo to a known location
if [ -d "$DOTFILES_DIR/.git" ]; then
    echo "Updating existing dotfiles repo..."
    git -C "$DOTFILES_DIR" pull
else
    echo "Cloning dotfiles repo to $DOTFILES_DIR..."
    mkdir -p "$HOME/.local/share"
    rm -rf "$DOTFILES_DIR" 2>/dev/null
    git clone "$REPO_URL" "$DOTFILES_DIR"
fi

# Copy fish configuration files (merges with existing, overwrites conflicts)
mkdir -p ~/.config/fish
cp -r "$DOTFILES_DIR/fish/." ~/.config/fish/

# Copy helix themes
mkdir -p ~/.config/helix/themes
cp -r "$DOTFILES_DIR/hx/themes/." ~/.config/helix/themes/

# Configure starship with pure-preset
echo "Configuring starship with pure-preset..."
mkdir -p ~/.config
starship preset pure-preset -o ~/.config/starship.toml

echo "Installation complete!"
