function hx_theme --description "Set Helix theme based on OS dark/light mode"
    set -l config_file ~/.config/helix/config.toml
    set -l dark_theme "tokyo_night_storm"
    set -l light_theme "catppuccin_latte"
    set -l theme

    # Detect OS theme
    switch (uname)
        case Darwin
            # macOS: defaults returns "Dark" in dark mode, errors in light mode
            if defaults read -g AppleInterfaceStyle 2>/dev/null | grep -q Dark
                set theme $dark_theme
            else
                set theme $light_theme
            end
        case Linux
            # GNOME: check color-scheme setting
            if type -q gsettings
                set -l scheme (gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null)
                if string match -q "*dark*" $scheme
                    set theme $dark_theme
                else
                    set theme $light_theme
                end
            else
                # Default to dark if can't detect
                set theme $dark_theme
            end
        case '*'
            # Default to dark for unknown OS
            set theme $dark_theme
    end

    # Ensure helix config directory exists
    mkdir -p (dirname $config_file)

    # Update or create config.toml with theme
    if test -f $config_file
        # Check if theme line exists
        if grep -q '^theme\s*=' $config_file
            # Replace existing theme line
            set -l temp_file (mktemp)
            sed "s/^theme\s*=.*/theme = \"$theme\"/" $config_file > $temp_file
            mv $temp_file $config_file
        else
            # Prepend theme line to existing config
            set -l temp_file (mktemp)
            echo "theme = \"$theme\"" > $temp_file
            cat $config_file >> $temp_file
            mv $temp_file $config_file
        end
    else
        # Create new config with just the theme
        echo "theme = \"$theme\"" > $config_file
    end

    echo "Helix theme set to: $theme"
end
