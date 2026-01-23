set -gx EDITOR hx
set -gx HOMEBREW_NO_AUTO_UPDATE 1

if status is-interactive
    alias fish_source='source ~/.config/fish/config.fish'

    # Sync Helix theme with OS dark/light mode
    hx_theme >/dev/null 2>&1

    starship init fish | source
end

# Optional addons (added via fish_add <addon>)
# fnm:path
# fnm:env
# go:path
# cargo:path
# bun:path

# END CONTROLLED BLOCK
