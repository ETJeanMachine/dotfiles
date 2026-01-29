function claude --description "Claude Code wrapper that syncs theme with OS dark/light mode" --wraps claude
    set -l config_file ~/.claude.json
    set -l theme (__detect_os_theme)

    # Update ~/.claude.json with theme using jq
    if test -f $config_file; and type -q jq
        set -l temp_file (mktemp)
        jq --arg theme "$theme" '.theme = $theme' $config_file > $temp_file
        mv $temp_file $config_file
    else if type -q jq
        echo '{}' | jq --arg theme "$theme" '.theme = $theme' > $config_file
    end

    command claude $argv
end
