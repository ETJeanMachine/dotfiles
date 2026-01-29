function fish_update --description "Update fish config from dotfiles repo"
    set -l dotfiles_dir ~/.local/share/dotfiles
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
    if test -z "$(git -C $dotfiles_dir diff --name-only $old_head $new_head -- fish/)"
        echo "No fish config changes. Skipping update."
        return 0
    end

    echo "Updating fish configuration..."
    # Saving local configuration settings before we update.
    set -l local_config (sed -n "/$control_str/,\${/$control_str/!p;}" ~/.config/fish/config.fish)
    cp -r $dotfiles_dir/fish/. ~/.config/fish/
    printf '%s\n' $local_config | sed -i "/$control_str/r /dev/stdin" ~/.config/fish/config.fish

    echo "Done! Restart your shell or run 'fish_source' to apply changes."
end
