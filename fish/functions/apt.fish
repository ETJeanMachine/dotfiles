function apt --wraps=apt
    command apt $argv

    # Clear upgradable cache after upgrade
    if test (count $argv) -ge 1
        if contains -- $argv[1] upgrade full-upgrade dist-upgrade
            rm -f ~/.cache/apt_upgradable_count
        end
    end
end
