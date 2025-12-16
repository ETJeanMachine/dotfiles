function __fish_addon_fnm
    set -l config_file ~/.config/fish/config.fish

    # Install fnm if not present
    if not test -f ~/.local/share/fnm/fnm
        echo "Installing fnm..."
        curl -fsSL https://fnm.vercel.app/install | bash
    end

    # Add fnm to config if not already there
    if not grep -q "^set -gx PATH.*fnm" $config_file
        sed -i 's|# fnm:path|set -gx PATH $HOME/.local/share/fnm $PATH|' $config_file
        echo "Added fnm to PATH"
    end
    if not grep -q "^[^#]*fnm env" $config_file
        sed -i 's/# fnm:env/fnm env --use-on-cd --shell fish \| source/' $config_file
        echo "Added fnm env initialization"
    end
    echo "fnm added! Run 'fish_source' to apply."
end
