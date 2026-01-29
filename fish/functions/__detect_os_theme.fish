function __detect_os_theme --description "Detect OS dark/light mode, prints 'dark' or 'light'"
    switch (uname)
        case Darwin
            if not defaults read -g AppleInterfaceStyle 2>/dev/null | grep -q Dark
                echo light
                return
            end
        case Linux
            if type -q gsettings
                set -l scheme (gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null)
                if not string match -q "*dark*" $scheme
                    echo light
                    return
                end
            end
    end
    echo dark
end
