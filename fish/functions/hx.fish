function hx --description "Helix wrapper that syncs theme with OS dark/light mode" --wraps hx
    set -l config_file ~/.config/helix/config.toml
    set -l dark_theme tokyonight_storm
    set -l light_theme catppuccin_latte
    set -l theme $dark_theme

    # Detect OS theme
    switch (uname)
        case Darwin
            if not defaults read -g AppleInterfaceStyle 2>/dev/null | grep -q Dark
                set theme $light_theme
            end
        case Linux
            if type -q gsettings
                set -l scheme (gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null)
                if not string match -q "*dark*" $scheme
                    set theme $light_theme
                end
            end
    end

    # Update config.toml with theme using fish string replace
    mkdir -p (dirname $config_file)
    if test -f $config_file
        set -l content (cat $config_file)
        if string match -q 'theme = *' $content
            # Replace existing theme line
            set content (string replace -r '^theme = .*' "theme = \"$theme\"" $content)
        else
            # Prepend theme line
            set content "theme = \"$theme\"\n$content"
        end
        printf '%s\n' $content > $config_file
    else
        echo "theme = \"$theme\"" > $config_file
    end

    command hx $argv
end
