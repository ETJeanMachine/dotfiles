set -gx EDITOR hx
set -gx PATH $HOME/go/bin $PATH

if status is-interactive
    alias fish_source='source ~/.config/fish/config.fish'

    fnm env --use-on-cd --shell fish | source
    starship init fish | source
end
