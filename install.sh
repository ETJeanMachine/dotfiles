#!/bin/bash

# Copy fish configuration files
cp fish/config.fish ~/.config/fish
cp fish/functions/fish_greeting.fish ~/.config/fish/functions/

# Install starship prompt
echo "Installing starship..."
curl -sS https://starship.rs/install.sh | sh

# Configure starship with pure-preset
echo "Configuring starship with pure-preset..."
mkdir -p ~/.config
starship preset pure-preset -o ~/.config/starship.toml

echo "Installation complete!"
