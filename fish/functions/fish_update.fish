function fish_update --description "Update fish config from dotfiles repo"
    set -l dotfiles_dir ~/.local/share/dotfiles
    set -l config_file ~/.config/fish/config.fish

    # Handle --add flag
    if test "$argv[1]" = "--add"
        switch $argv[2]
            case fnm
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

            case go
                if not grep -q "^set -gx PATH.*go/bin" $config_file
                    sed -i 's|# go:path|set -gx PATH $HOME/go/bin $PATH|' $config_file
                    echo "Added go/bin to PATH. Run 'fish_source' to apply."
                else
                    echo "go is already configured"
                end

            case cargo
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

            case '*'
                echo "Unknown addon: $argv[2]"
                echo "Available addons: fnm, go, cargo"
                return 1
        end
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
