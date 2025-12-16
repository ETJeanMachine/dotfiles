# Completions for fish_update

# No file completion by default
complete -c fish_update -f

# --add flag
complete -c fish_update -l add -d "Add an optional addon to fish config" -xa "fnm go cargo"

# Addon descriptions when --add is present
complete -c fish_update -n "__fish_seen_argument -l add" -xa "fnm" -d "Fast Node Manager"
complete -c fish_update -n "__fish_seen_argument -l add" -xa "go" -d "Go language bin path"
complete -c fish_update -n "__fish_seen_argument -l add" -xa "cargo" -d "Rust/Cargo bin path"
