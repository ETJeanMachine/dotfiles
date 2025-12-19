echo (set_color cyan)"Welcome back, Jean."(set_color normal)

# Detect package manager
if command -v brew &>/dev/null
    # Homebrew (Darwin/Bazzite)
    set -l cache_file ~/.cache/brew_outdated_count
    set -l cache_age 21600  # 6 hours in seconds
    set -l cache_stale false

    if not test -f $cache_file; or test (math (date +%s) - (stat -f %m $cache_file 2>/dev/null || stat -c %Y $cache_file)) -gt $cache_age
        set cache_stale true
        # Refresh cache in background
        fish -c "
            brew update &>/dev/null
            set formulae (brew outdated | wc -l | string trim)
            set casks (brew outdated --cask 2>/dev/null | wc -l | string trim)
            echo (date +%s),\$formulae,\$casks > $cache_file
        " &
        disown
    end

    if test -f $cache_file
        set -l data (cat $cache_file | string split ,)
        if test "$data[2]" != "0" -o "$data[3]" != "0"
            set -l checked_time (date -r $data[1] 2>/dev/null || date -d @$data[1] "+%b %d, %H:%M")
            echo (set_color yellow)$data[2](set_color normal)" formulae, "(set_color magenta)$data[3](set_color normal)" casks outdated "(set_color --dim)"(checked $checked_time)"(set_color normal)
        end
    end

    if test $cache_stale = true
        echo (set_color --dim)"Refreshing brew in background..."(set_color normal)
    end

else if command -v apt &>/dev/null
    # APT (Debian/Ubuntu)
    set -l cache_file ~/.cache/apt_upgradable_count
    set -l cache_age 21600  # 6 hours in seconds
    set -l apt_lists_dir /var/lib/apt/lists

    set -l lists_stale false
    if test -d $apt_lists_dir
        set -l newest_list (find $apt_lists_dir -type f -name '*Packages*' -printf '%T@\n' 2>/dev/null | sort -n | tail -1)
        if test -n "$newest_list"
            if test (math (date +%s) - (math -s0 $newest_list)) -gt $cache_age
                set lists_stale true
            end
        else
            set lists_stale true
        end
    else
        set lists_stale true
    end

    if test $lists_stale = true
        echo (set_color red)"Run 'sudo apt-get update' to refresh package lists"(set_color normal)
    else
        if not test -f $cache_file; or test (math (date +%s) - (stat -c %Y $cache_file)) -gt $cache_age
            set -l upgradable (apt list --upgradable 2>/dev/null | tail -n +2 | wc -l | string trim)
            echo (date +%s),$upgradable > $cache_file
        end

        if test -f $cache_file
            set -l data (cat $cache_file | string split ,)
            if test "$data[2]" != "0"
                set -l checked_time (date -d @$data[1] "+%b %d, %H:%M")
                echo (set_color yellow)$data[2](set_color normal)" packages upgradable "(set_color --dim)"(checked $checked_time)"(set_color normal)
            end
        end
    end
end
