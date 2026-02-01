function fish_update --description "Update fish config from dotfiles repo"
    set -l dotfiles_dir ~/.local/share/dotfiles
    set -l config_file ~/.config/fish/config.fish
    set -l control_str "# END CONTROLLED BLOCK"

    if not test -d $dotfiles_dir
        echo "Dotfiles repo not found at $dotfiles_dir"
        echo "Please run the install script first."
        return 1
    end

    echo "Pulling latest changes..."
    set -l old_head (git -C $dotfiles_dir rev-parse HEAD)
    set -l pull_output (git -C $dotfiles_dir pull 2>&1)
    echo $pull_output

    if string match -q "Already up to date*" $pull_output
        return 0
    end

    set -l new_head (git -C $dotfiles_dir rev-parse HEAD)
    set -l fish_changed (git -C $dotfiles_dir diff --name-only $old_head $new_head -- fish/)
    set -l hx_changed (git -C $dotfiles_dir diff --name-only $old_head $new_head -- hx/)

    if test -z "$fish_changed" -a -z "$hx_changed"
        echo "No relevant changes. Skipping update."
        return 0
    end

    # Update fish config if fish/ changed
    if test -n "$fish_changed"
        echo "Updating fish configuration..."
        # Saving local configuration settings before we update.
        set -l local_config (sed -n "/$control_str/,\${/$control_str/!p;}" $config_file)
        cp -r $dotfiles_dir/fish/. ~/.config/fish/
        set -l local_block (printf '%s\n' $local_config)
        string replace "$control_str" "$control_str
$local_block" <$config_file >$config_file.tmp
        mv $config_file.tmp $config_file
    end

    # Update helix themes if hx/ changed
    if test -n "$hx_changed"
        echo "Updating helix themes..."
        mkdir -p ~/.config/helix/themes
        cp -r $dotfiles_dir/hx/themes/. ~/.config/helix/themes/
    end

    echo "Done! Restart your shell or run 'fish_source' to apply changes."
end
