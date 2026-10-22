-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1

--hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))
--hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })

-- Configure a specific monitor.
-- VMware Workstation guest: the virtual connector is "Virtual-1".
-- VMware no envia el tamano real de la pantalla (llegaba 1280x800, con mucho
-- zoom), asi que se fija 1920x1080, la pantalla del PC en pantalla completa.
-- Para que siga el tamano de la ventana de VMware, usa mode = "preferred" y
-- activa: systemctl --user enable --now vmware-display-sync
hl.monitor({ output = "Virtual-1", mode = "1920x1080@60", position = "auto", scale = omarchy_monitor_scale })

-- Portrait/rotated secondary monitor (transform: 1 = 90°, 3 = 270°).
-- hl.monitor({ output = "Virtual-1", mode = "preferred", position = "auto", scale = 1, transform = 1 })
