function brew --wraps=brew
    set -l cache_file ~/.cache/brew_outdated_count
    command brew $argv

    # Reset cache after upgrade (but don't interrupt weekly cache check).
    if test (count $argv) -ge 1
        if test $argv[1] = upgrade; and test -f "$cache_file"
            # Don't write cache while fish_greeting is refreshing it.
            set -l lock_file ~/.cache/pkg_refresh.lock
            set -l lock_pid
            test -f $lock_file; and set lock_pid (cat $lock_file 2>/dev/null)
            if test -n "$lock_pid"; and kill -0 $lock_pid 2>/dev/null
                return
            end

            set -l line
            read -l line <$cache_file
            if test -n "$line"
                set -l data (string split , $line)
                if test (count $argv) -eq 1
                    # Bare upgrade: zero out counts
                    echo $data[1],0,0 > $cache_file
                else
                    # Targeted upgrade: re-count outdated packages
                    set -l formulae (command brew outdated --formula 2>/dev/null | wc -l | string trim)
                    set -l casks (command brew outdated --cask 2>/dev/null | wc -l | string trim)
                    echo $data[1],$formulae,$casks > $cache_file
                end
            end
        end
    end
end
