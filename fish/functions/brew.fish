function brew --wraps=brew
    command brew $argv

    # Clear outdated cache after upgrade
    if test (count $argv) -ge 1
        if contains -- $argv[1] upgrade update
            rm -f ~/.cache/brew_outdated_count
        end
    end
end
