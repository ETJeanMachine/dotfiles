function hx --description "Helix wrapper that syncs theme with OS dark/light mode" --wraps hx
    set -l config_file ~/.config/helix/config.toml
    set -l dark_theme catppuccin_frappe
    set -l light_theme catppuccin_latte
    set -l theme $dark_theme

    if test (__detect_os_theme) = light
        set theme $light_theme
    end

    # Update config.toml with theme using sed
    mkdir -p (dirname $config_file)
    if test -f $config_file
        if grep -q '^theme = ' $config_file
            sed -i "s/^theme = .*/theme = \"$theme\"/" $config_file
        else
            sed -i "1i theme = \"$theme\"" $config_file
        end
    else
        echo "theme = \"$theme\"" >$config_file
    end

    command hx $argv
end
