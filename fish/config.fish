set -gx EDITOR hx
set -gx PATH $HOME/go/bin $PATH

if status is-interactive
    alias fish_source='source ~/.config/fish/config.fish'

    starship init fish | source
end
