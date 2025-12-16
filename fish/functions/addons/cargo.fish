function __fish_addon_cargo
    set -l config_file ~/.config/fish/config.fish

    # Install cargo/rust if not present
    if not test -d ~/.cargo
        echo "Installing rust/cargo..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    end

    if not grep -q "^set -gx PATH.*cargo/bin" $config_file
        sed -i 's|# cargo:path|set -gx PATH $HOME/.cargo/bin $PATH|' $config_file
        echo "Added cargo/bin to PATH. Run 'fish_source' to apply."
    else
        echo "cargo is already configured"
    end
end
