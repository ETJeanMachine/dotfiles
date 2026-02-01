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

# Copy all config directories to ~/.config/
for dir in "$DOTFILES_DIR"/*/; do
    dirname=$(basename "$dir")
    echo "Installing $dirname configuration..."
    mkdir -p "$HOME/.config/$dirname"
    cp -r "$dir." "$HOME/.config/$dirname/"
done

# Copy standalone config files to ~/.config/
echo "Installing starship configuration..."
cp "$DOTFILES_DIR/starship.toml" "$HOME/.config/starship.toml"

echo "Installation complete!"
