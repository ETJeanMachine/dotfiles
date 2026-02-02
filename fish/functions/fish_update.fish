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

    # Find all config directories in the repo (top-level dirs, excluding hidden/meta)
    set -l config_dirs
    for dir in $dotfiles_dir/*/
        set -l dirname (basename $dir)
        set config_dirs $config_dirs $dirname
    end

    # Check which directories had changes
    set -l changed_dirs
    for dir in $config_dirs
        set -l dir_changed (git -C $dotfiles_dir diff --name-only $old_head $new_head -- $dir/)
        if test -n "$dir_changed"
            set changed_dirs $changed_dirs $dir
        end
    end

    # Check if standalone config files changed
    set -l starship_changed (git -C $dotfiles_dir diff --name-only $old_head $new_head -- starship.toml)

    if test (count $changed_dirs) -eq 0 -a -z "$starship_changed"
        echo "No relevant changes. Skipping update."
        return 0
    end

    # Copy standalone config files if changed
    if test -n "$starship_changed"
        echo "Updating starship configuration..."
        cp $dotfiles_dir/starship.toml ~/.config/starship.toml
    end

    # Save local config.fish content after the controlled block before overwriting
    set -l local_backup (mktemp)
    set -l has_local_content 0
    if contains fish $changed_dirs; and test -f $config_file
        sed -n "/$control_str/,\${/$control_str/!p;}" $config_file >$local_backup
        if test -s $local_backup
            set has_local_content 1
        end
    end

    for dir in $changed_dirs
        echo "Updating $dir configuration..."
        mkdir -p ~/.config/$dir
        cp -r $dotfiles_dir/$dir/. ~/.config/$dir/
    end

    # Restore local config.fish content after the controlled block
    if test $has_local_content -eq 1
        cat $local_backup >>$config_file
    end
    rm -f $local_backup

    echo "Done! Restart your shell or run 'fish_source' to apply changes."
end
