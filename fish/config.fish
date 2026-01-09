set -gx EDITOR hx
set -gx HOMEBREW_NO_AUTO_UPDATE 1

if status is-interactive
    alias fish_source='source ~/.config/fish/config.fish'

    starship init fish | source
end

set -gx COLORTERM truecolor

# Optional addons (added via fish_add <addon>)
# fnm:path
# fnm:env
# go:path
# cargo:path
# bun:path
