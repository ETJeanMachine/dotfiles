echo (set_color cyan)"Welcome back, Jean."(set_color normal)
echo ""

set -l cache_file ~/.cache/apt_upgradable_count
set -l cache_age 86400  # 1 day in seconds
set -l apt_lists_dir /var/lib/apt/lists

# Check if apt lists are fresh (look at most recently modified file)
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
    # Update cache if missing or older than 1 day
    if not test -f $cache_file; or test (math (date +%s) - (stat -c %Y $cache_file)) -gt $cache_age
        set -l upgradable (apt list --upgradable 2>/dev/null | tail -n +2 | wc -l | string trim)
        echo (date +%s),$upgradable > $cache_file
    end

    # Display cached results
    if test -f $cache_file
        set -l data (cat $cache_file | string split ,)
        set -l checked_time (date -d @$data[1] "+%b %d, %H:%M")
        echo (set_color yellow)$data[2](set_color normal)" packages upgradable "(set_color --dim)"(checked $checked_time)"(set_color normal)
    end
end
