function zellij --description "Zellij wrapper that syncs theme with OS dark/light mode" --wraps zellij
    set -l config_file ~/.config/zellij/config.kdl
    set -l dark_theme catppuccin-frappe
    set -l light_theme catppuccin-latte
    set -l theme $dark_theme

    if test (__detect_os_theme) = light
        set theme $light_theme
    end

    # Update config.kdl with theme
    mkdir -p (dirname $config_file)
    if test -f $config_file
        if grep -q '^theme ' $config_file
            string replace -r '^theme .*' "theme \"$theme\"" <$config_file >$config_file.tmp
        else
            echo "theme \"$theme\"" >$config_file.tmp
            cat $config_file >>$config_file.tmp
        end
        mv $config_file.tmp $config_file
    else
        echo "theme \"$theme\"" >$config_file
    end

    command zellij $argv
end
