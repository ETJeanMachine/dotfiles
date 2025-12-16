if status is-interactive
    # Commands to run in interactive sessions can go here
end

set -x EDITOR hx

alias fishconf='$EDITOR ~/.config/fish/config.fish'
alias fishsrc='source ~/.config/fish/config.fish'

starship init fish | source
