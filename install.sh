#!/bin/bash

DOTFILES_DIR="$HOME/.local/share/dotfiles"
REPO_URL="https://github.com/ETJeanMachine/dotfiles.git"

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

# Install starship prompt
echo "Installing starship..."
curl -sS https://starship.rs/install.sh | sh

# Configure starship with pure-preset
echo "Configuring starship with pure-preset..."
mkdir -p ~/.config
starship preset pure-preset -o ~/.config/starship.toml

echo "Installation complete!"
