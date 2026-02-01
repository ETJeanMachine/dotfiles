function hx --description "Helix wrapper that syncs theme with OS dark/light mode" --wraps hx
    set -l config_file ~/.config/helix/config.toml
    set -l dark_theme catppuccin_frappe_transparent
    set -l light_theme catppuccin_latte_transparent
    set -l theme $dark_theme

    if test (__detect_os_theme) = light
        set theme $light_theme
    end

    # Update config.toml with theme
    mkdir -p (dirname $config_file)
    if test -f $config_file
        if grep -q '^theme = ' $config_file
            string replace -r '^theme = .*' "theme = \"$theme\"" <$config_file >$config_file.tmp
        else
            echo "theme = \"$theme\"" >$config_file.tmp
            cat $config_file >>$config_file.tmp
        end
        mv $config_file.tmp $config_file
    else
        echo "theme = \"$theme\"" >$config_file
    end

    command hx $argv
end
