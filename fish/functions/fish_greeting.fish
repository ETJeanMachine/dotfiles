echo (set_color cyan)"Welcome back, Jean."(set_color normal)

set -l now (date +%s)
set -l cache_age 21600  # 6 hours in seconds

# Detect package manager
if command -v brew &>/dev/null
    # Homebrew (Darwin/Bazzite)
    set -l cache_file ~/.cache/brew_outdated_count
    set -l cache_stale false

    # Read cache: timestamp,formulae,casks
    set -l data
    test -f $cache_file; and read -l line < $cache_file; and set data (string split , $line)

    if test -z "$data[1]"; or test (math $now - $data[1]) -gt $cache_age
        set cache_stale true
        fish -c "
            brew update &>/dev/null
            set formulae (brew outdated | wc -l | string trim)
            set casks (brew outdated --cask 2>/dev/null | wc -l | string trim)
            echo (date +%s),\$formulae,\$casks > $cache_file
        " &
        disown
    end

    if test -n "$data[2]" -a \( "$data[2]" != "0" -o "$data[3]" != "0" \)
        echo (set_color yellow)$data[2](set_color normal)" formulae, "(set_color magenta)$data[3](set_color normal)" casks outdated"
    end

    if test $cache_stale = true
        echo (set_color --dim)"Refreshing brew in background..."(set_color normal)
    end

else if command -v apt &>/dev/null
    # APT (Debian/Ubuntu)
    set -l cache_file ~/.cache/apt_upgradable_count
    set -l cache_stale false

    # Read cache: timestamp,count
    set -l data
    test -f $cache_file; and read -l line < $cache_file; and set data (string split , $line)

    if test -z "$data[1]"; or test (math $now - $data[1]) -gt $cache_age
        set cache_stale true
        fish -c "
            set upgradable (apt list --upgradable 2>/dev/null | tail -n +2 | wc -l | string trim)
            echo (date +%s),\$upgradable > $cache_file
        " &
        disown
    end

    if test -n "$data[2]" -a "$data[2]" != "0"
        echo (set_color yellow)$data[2](set_color normal)" packages upgradable"
    end

    if test $cache_stale = true
        echo (set_color --dim)"Refreshing apt in background..."(set_color normal)
    end
end
