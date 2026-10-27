-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/

-- illogical-impulse (end4-pC): con `escritorio ii` (o `sesion ii`) se carga su
-- configuracion completa en lugar de la de Omarchy. Sus archivos viven en
-- hypr/ii.lua, hypr/hyprland/ (de illogical-impulse) y hypr/custom/ (los tuyos).
do
	local f = io.open(os.getenv("HOME") .. "/.config/escritorio-modo", "r")
	local modo_ii = f and f:read("*l") == "ii"
	if f then f:close() end
	if modo_ii then
		local hypr = os.getenv("HOME") .. "/.config/hypr"
		package.path = hypr .. "/?.lua;" .. hypr .. "/?/init.lua;" .. package.path
		-- Al recargar (hyprctl reload) volver a leer los modulos.
		for m in pairs(package.loaded) do
			if m == "ii" or m == "monitors" or m == "workspaces" or m:match("^hyprland[./]") or m:match("^custom[./]") then
				package.loaded[m] = nil
			end
		end
		require("ii")
		return
	end
end

-- Omarchy's bootstrap keeps path setup out of this user config.
dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")

-- Disable all Omarchy default bindings. Add your own in hypr/bindings.lua.
-- omarchy_default_bindings = false
--
-- Or disable only bindings for Omarchy's preinstalled apps/web apps while
-- keeping core window-manager bindings:
-- omarchy_preinstalled_bindings = false

-- Load Omarchy defaults.
require("default.hypr.omarchy")

-- Put your personal overrides in these files. They're loaded after Omarchy's
-- defaults so package updates can improve the defaults without rewriting your
-- ~/.config/hypr files.
require("hypr.monitors")
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")

-- DankMaterialShell: colores y diseno solo cuando DMS es el escritorio activo
-- (se cambia con el comando `escritorio`).
local modo_file = io.open(os.getenv("HOME") .. "/.config/escritorio-modo", "r")
local modo = modo_file and modo_file:read("*l") or "omarchy"
if modo_file then modo_file:close() end
if modo == "dms" then
	pcall(require, "hypr.dms.colors")
	pcall(require, "hypr.dms.layout")
	pcall(require, "hypr.dms.windowrules")
end

-- Ajustes solo para maquinas virtuales VMware (el instalador crea
-- hypr/vmware.lua solo si detecta VMware; en equipos nativos no existe).
pcall(require, "hypr.vmware")

-- Toggle config flags dynamically.
require("default.hypr.toggles")

-- Add any other personal Hyprland configuration below.
-- o.window("qemu", { workspace = "5" })
