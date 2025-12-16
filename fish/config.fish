if status is-interactive
    # Commands to run in interactive sessions can go here
end

set -x EDITOR hx

alias fish_config='$EDITOR ~/.config/fish/config.fish'
alias fish_source='source ~/.config/fish/config.fish'

set -gx PATH $HOME/go/bin $PATH

starship init fish | source
