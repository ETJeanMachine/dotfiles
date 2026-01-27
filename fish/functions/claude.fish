function claude --description "Claude Code wrapper that syncs theme with OS dark/light mode" --wraps claude
    set -l config_file ~/.claude.json
    set -l theme dark

    # Detect OS theme
    switch (uname)
        case Darwin
            if not defaults read -g AppleInterfaceStyle 2>/dev/null | grep -q Dark
                set theme light
            end
        case Linux
            if type -q gsettings
                set -l scheme (gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null)
                if not string match -q "*dark*" $scheme
                    set theme light
                end
            end
    end

    # Update ~/.claude.json with theme using jq
    if test -f $config_file; and type -q jq
        set -l temp_file (mktemp)
        jq --arg theme "$theme" '.theme = $theme' $config_file > $temp_file
        mv $temp_file $config_file
    end

    command claude $argv
end
