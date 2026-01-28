# Animated greeting with scanning color wave and cycling star
function fish_greeting
    set -l msg "Welcome back, Jean."
    set -l len (string length $msg)
    set -l stars "·" "+" "✶" "✱" "✶" "+"
    set -l star_colors cyan brblue blue magenta brmagenta magenta blue brblue

    # Check to see if brew isn't installed, then immediately exit.
    if not type -q brew
        return 0
    end

    # These are numbers/files I may want to change in the future.
    set -l cache_age 7 # Store this number in days. (Currently 1 week).
    set -l cache_file ~/.cache/brew_outdated_count

    # Check cache staleness
    set -l now (date +%s)
    set -l cache_stale false


    if test -f "$cache_file"
        set -l data
        test -f $cache_file; and read -l line <$cache_file; and set data (string split , $line)
        if test -z "$data[1]"; or test (math $now - $data[1]) -gt (math "$cache_age * 86400")
            set cache_stale true
        end
    end

    # Lock file to prevent concurrent refreshes
    set -l lock_file ~/.cache/pkg_refresh.lock

    # Check for existing lock before starting refresh
    if test $cache_stale = true; and test -f $lock_file
        set -l lock_pid (cat $lock_file 2>/dev/null)
        if test -n "$lock_pid"; and kill -0 $lock_pid 2>/dev/null
            # Another refresh is in progress, show static greeting
            set cache_stale false
        else
            # Stale lock from crashed process, remove it
            rm -f $lock_file
        end
    end

    if test $cache_stale = true
        # Animation frame renderer
        function __greeting_frame -a pos frame
            set -l msg "Welcome back, Jean."
            set -l len (string length $msg)
            set -l stars "·" "+" "✶" "✱" "✶" "+"
            set -l star_colors cyan brblue blue magenta brmagenta magenta blue brblue
            set -l star_count (count $stars)
            set -l color_count (count $star_colors)
            set -l taper_colors cyan brcyan brblue blue brblack

            set -l output ""
            for i in (seq 1 $len)
                set -l char (string sub -s $i -l 1 $msg)
                set -l dist (math -s0 "abs($i - $pos)")
                if test $dist -ge 4
                    set output $output(set_color brblack)$char
                else
                    set -l taper_idx (math -s0 "$dist + 1")
                    set output $output(set_color $taper_colors[$taper_idx])$char
                end
            end
            set -l star_idx (math -s0 "(floor(($frame - 1) / 3) % $star_count) + 1")
            printf "\r%s%s%s %s%s" (set_color blue) $stars[$star_idx] (set_color normal) "$output" (set_color normal)
        end

        # Hide cursor and print initial line for animation to update
        printf "\e[?25l"
        printf "%s✦ %s%s\n" (set_color cyan) $msg (set_color normal)

        # Start refresh and animate while waiting
        set -l frame 0
        fish -c "
            echo %self > $lock_file
            brew update &>/dev/null
            set formulae (brew outdated | wc -l | string trim)
            set casks (brew outdated --cask 2>/dev/null | wc -l | string trim)
            echo (date +%s),\$formulae,\$casks > $cache_file
            rm -f $lock_file
        " &
        set -l refresh_pid $last_pid

        # Loop animation while refresh runs
        set -l pos 1
        set -l dir 1
        while kill -0 $refresh_pid 2>/dev/null
            set frame (math "$frame + 1")
            printf "\e[A\r"
            __greeting_frame $pos $frame
            printf " %s\e[K" (set_color --dim)"(refreshing brew)"(set_color normal)
            printf "\n"
            sleep 0.034
            set pos (math "$pos + $dir")
            if test $pos -gt $len
                set dir -1
                set pos $len
            else if test $pos -lt 1
                set dir 1
                set pos 1
            end
        end
        printf "\e[?25h"
        printf "\e[A\r%s✦ %s%s\e[K\n" (set_color cyan) $msg (set_color normal)

        # Re-read cache and show status
        set -l data
        read -l line <$cache_file; and set data (string split , $line)
        if test -n "$data[2]" -a \( "$data[2]" != 0 -o "$data[3]" != 0 \)
            echo (set_color yellow)$data[2](set_color normal)" formulae, "(set_color magenta)$data[3](set_color normal)" casks outdated"
        else if test -n "$data[2]"
            echo (set_color green)"Casks and formulae up to date."(set_color normal)
        end

        functions -e __greeting_frame
    else
        # Cache is fresh, just print static greeting
        printf "%s✦ %s%s%s\n" (set_color blue) (set_color cyan) $msg (set_color normal)
    end
end
