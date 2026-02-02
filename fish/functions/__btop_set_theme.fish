function __btop_set_theme --description "Set btop theme to match dark/light mode" --argument-names mode
    set -l config_file ~/.config/btop/btop.conf
    set -l dark_theme catppuccin_frappe
    set -l light_theme catppuccin_latte
    set -l theme $dark_theme

    if test "$mode" = light
        set theme $light_theme
    end

    mkdir -p (dirname $config_file)
    set -l tmpfile $config_file.$fish_pid.tmp
    if test -f $config_file
        if grep -q '^color_theme = ' $config_file
            string replace -r '^color_theme = .*' "color_theme = \"$theme\"" <$config_file >$tmpfile
        else
            echo "color_theme = \"$theme\"" >$tmpfile
            cat $config_file >>$tmpfile
        end
        mv $tmpfile $config_file
    else
        echo "color_theme = \"$theme\"" >$config_file
    end

    # Signal btop to reload config if it's running
    pkill -USR2 btop 2>/dev/null
end
