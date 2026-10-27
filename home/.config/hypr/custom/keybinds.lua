-- Atajos propios para illogical-impulse (se suman a los de hyprland/keybinds.lua).
hl.bind("CTRL+SUPER+ALT+Slash", hl.dsp.exec_cmd("xdg-open ~/.config/hypr/custom/keybinds.lua"), { description = "Edit user keybinds" })

-- Panel de ajustes de end4-pC (se cierra con el mismo atajo o con Esc).
hl.bind("SUPER + Escape", hl.dsp.global("quickshell:settingsToggle"), { description = "Toggle settings" })

-- Lista de atajos. end4-pC no trae la pantalla de atajos de ii: se muestran en
-- el buscador escribiendo "<", asi que se abre el buscador con "<" ya escrito.
hl.bind("SUPER + F1", hl.dsp.exec_cmd("qs -c $qsConfig ipc call search open && sleep 0.3 && wtype '<'"), { description = "Shell: Lista de atajos" })
