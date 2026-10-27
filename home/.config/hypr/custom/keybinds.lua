-- Atajos propios para illogical-impulse (se suman a los de hyprland/keybinds.lua).
hl.bind("CTRL+SUPER+ALT+Slash", hl.dsp.exec_cmd("xdg-open ~/.config/hypr/custom/keybinds.lua"), { description = "Edit user keybinds" })

-- Panel de ajustes de end4-pC (se cierra con el mismo atajo o con Esc).
hl.bind("SUPER + Escape", hl.dsp.global("quickshell:settingsToggle"), { description = "Toggle settings" })

-- Lista de atajos. Super + / no es comodo en teclado latam (/ es Shift + 7).
hl.bind("SUPER + F1", hl.dsp.global("quickshell:cheatsheetToggle"), { description = "Shell: Toggle cheatsheet" })
