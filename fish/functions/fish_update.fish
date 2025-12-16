function fish_update --description "Update fish config from dotfiles repo"
    set -l dotfiles_dir ~/.local/share/dotfiles

    if not test -d $dotfiles_dir
        echo "Dotfiles repo not found at $dotfiles_dir"
        echo "Please run the install script first."
        return 1
    end

    echo "Pulling latest changes..."
    git -C $dotfiles_dir pull

    echo "Updating fish configuration..."
    cp -r $dotfiles_dir/fish/. ~/.config/fish/

    echo "Done! Restart your shell or run 'fish_source' to apply changes."
end
