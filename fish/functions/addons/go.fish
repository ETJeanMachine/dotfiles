function __fish_addon_go
    set -l config_file ~/.config/fish/config.fish

    if not grep -q "^set -gx PATH.*go/bin" $config_file
        sed -i 's|# go:path|set -gx PATH $HOME/go/bin $PATH|' $config_file
        echo "Added go/bin to PATH. Run 'fish_source' to apply."
    else
        echo "go is already configured"
    end
end
