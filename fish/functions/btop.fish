function btop --description "btop wrapper that syncs theme with OS dark/light mode" --wraps btop
    # Initial theme sync
    __btop_set_theme (__detect_os_theme)

    # Spawn background watcher for live theme changes
    switch (uname)
        case Darwin
            fish -c '
                swift -e "
                    import Cocoa
                    let center = DistributedNotificationCenter.default()
                    let name = Notification.Name(\"AppleInterfaceThemeChangedNotification\")
                    center.addObserver(forName: name, object: nil, queue: nil) { _ in
                        fputs(\"changed\\n\", stdout)
                        fflush(stdout)
                    }
                    RunLoop.current.run()
                " | while read -l line
                    __btop_set_theme (__detect_os_theme)
                end
            ' &
            set -l watcher_pid $last_pid
        case Linux
            if type -q gsettings
                fish -c '
                    gsettings monitor org.gnome.desktop.interface color-scheme | while read -l line
                        __btop_set_theme (__detect_os_theme)
                    end
                ' &
                set -l watcher_pid $last_pid
            end
    end

    command btop $argv

    # Clean up watcher on exit
    if set -q watcher_pid
        kill $watcher_pid 2>/dev/null
    end
end
