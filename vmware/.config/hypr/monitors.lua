-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1

--hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))
--hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })

-- Configure a specific monitor.
-- VMware Workstation guest: the virtual connector is "Virtual-1", not "DP-2".
-- vmwgfx exposes the host window size as the connector's preferred mode, so
-- "preferred" keeps the desktop proportional to the VMware window (and to
-- full-screen mode) instead of pinning a fixed resolution.
hl.monitor({ output = "Virtual-1", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })

-- Portrait/rotated secondary monitor (transform: 1 = 90°, 3 = 270°).
-- hl.monitor({ output = "Virtual-1", mode = "preferred", position = "auto", scale = 1, transform = 1 })
