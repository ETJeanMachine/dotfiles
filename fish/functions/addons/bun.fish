function __fish_addon_bun
    set -l config_file ~/.config/fish/config.fish

    # Install bun if not present
    if not test -f ~/.bun/bin/bun
        echo "Installing bun..."
        curl -fsSL https://bun.sh/install | bash
    end

    if not grep -q "^set -gx PATH.*bun/bin" $config_file
        sed -i 's|# bun:path|set -gx PATH $HOME/.bun/bin $PATH|' $config_file
        echo "Added bun/bin to PATH. Run 'fish_source' to apply."
    else
        echo "bun is already configured"
    end
end
