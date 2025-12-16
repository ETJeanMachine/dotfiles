function fish_update --description "Update fish config from dotfiles repo"
    set -l dotfiles_dir ~/.local/share/dotfiles
    set -l addons_dir ~/.config/fish/functions/addons

    # Handle --add flag
    if test "$argv[1]" = "--add"
        set -l addon $argv[2]
        set -l addon_file "$addons_dir/$addon.fish"

        if not test -f $addon_file
            echo "Unknown addon: $addon"
            echo "Available addons: fnm, go, cargo, bun"
            return 1
        end

        source $addon_file
        __fish_addon_$addon
        return 0
    end

    if not test -d $dotfiles_dir
        echo "Dotfiles repo not found at $dotfiles_dir"
        echo "Please run the install script first."
        return 1
    end

    echo "Pulling latest changes..."
    set -l pull_output (git -C $dotfiles_dir pull 2>&1)
    echo $pull_output

    if string match -q "Already up to date*" $pull_output
        return 0
    end

    echo "Updating fish configuration..."
    cp -r $dotfiles_dir/fish/. ~/.config/fish/

    echo "Done! Restart your shell or run 'fish_source' to apply changes."
end
