function fish_add --description "Add optional addons to fish config"
    set -l addons_dir ~/.config/fish/functions/addons

    if test -z "$argv[1]"
        echo "Usage: fish_add <addon>"
        echo "Available addons: fnm, go, cargo, bun"
        return 1
    end

    set -l addon $argv[1]
    set -l addon_file "$addons_dir/$addon.fish"

    if not test -f $addon_file
        echo "Unknown addon: $addon"
        echo "Available addons: fnm, go, cargo, bun"
        return 1
    end

    source $addon_file
    __fish_addon_$addon
end
