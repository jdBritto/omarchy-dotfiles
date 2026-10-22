-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")

-- ===== Escritorio (DMS u Omarchy segun `escritorio estado`) =====
local function accion(keys, desc, nombre, opts)
  hl.unbind(keys)
  o.bind(keys, desc, "escritorio-accion " .. nombre, opts)
end

accion("SUPER + SPACE", "Buscar aplicaciones", "aplicaciones")
accion("SUPER + ALT + SPACE", "Menu", "menu")
accion("SUPER + ESCAPE", "Apagar / reiniciar / cerrar sesion", "apagar")
accion("SUPER + SHIFT + CTRL + SPACE", "Cambiar tema", "temas")
accion("SUPER + CTRL + SPACE", "Cambiar fondo de pantalla", "fondos")
accion("SUPER + I", "Configuracion", "ajustes")
accion("SUPER + CTRL + V", "Historial del portapapeles", "portapapeles")
accion("SUPER + A", "Centro de control", "panel")
accion("SUPER + N", "Notificaciones", "notificaciones")
accion("SUPER + SHIFT + comma", "Borrar notificaciones", "limpiar-notif")
accion("SUPER + K", "Ver atajos de teclado", "atajos")
accion("SUPER + CTRL + L", "Bloquear pantalla", "bloquear")
accion("CTRL + SHIFT + ESCAPE", "Administrador de tareas", "procesos")
accion("SUPER + CTRL + ALT + D", "Calendario", "calendario")
accion("XF86PowerOff", "Menu de apagado", "apagar", { locked = true })
accion("XF86AudioPlay", "Play/Pausa", "play", { locked = true })
accion("XF86AudioPause", "Play/Pausa", "play", { locked = true })
accion("XF86AudioNext", "Siguiente", "siguiente", { locked = true })
accion("XF86AudioPrev", "Anterior", "anterior", { locked = true })

-- Cambiar entre DankMaterialShell y Omarchy
o.bind("SUPER + SHIFT + CTRL + D", "Alternar escritorio DMS/Omarchy", "escritorio alternar")
