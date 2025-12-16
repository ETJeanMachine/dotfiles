set -gx EDITOR hx

if status is-interactive
    alias fish_source='source ~/.config/fish/config.fish'

    starship init fish | source
end

# Optional addons (added via fish_add <addon>)
# fnm:path
# fnm:env
# go:path
# cargo:path
# bun:path
