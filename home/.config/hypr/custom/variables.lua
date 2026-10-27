-- Variables de illogical-impulse (se cargan despues de hyprland/variables.lua).
-- Shell de Quickshell: end4-pC en lugar del ii original.
hl.env("qsConfig", "end4-pC")

-- Terminal: Kitty primero (abre Zsh con el estilo hacker). Foot queda de respaldo.
terminal = "~/.config/hypr/hyprland/scripts/launch_first_available.sh 'kitty -1' 'foot' 'alacritty' 'wezterm' 'konsole' 'kgx' 'uxterm' 'xterm'"
