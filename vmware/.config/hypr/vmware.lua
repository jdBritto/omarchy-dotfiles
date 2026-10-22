-- Solo para VMware Workstation (lo instala install.sh si detecta VMware).
hl.env("AQ_NO_MODIFIERS", "1")

-- VMware Workstation guest: the SVGA3D driver makes Mesa allocate the
-- compositor's window buffers over zwp_linux_dmabuf_v1. Hyprland rejects
-- those buffers ("invalid arguments for wl_surface.attach") and kills the
-- client, which is why the Quickshell shell (bar, menu, OSD) never appeared.
-- Software rendering makes Mesa use wl_shm instead.
hl.env("LIBGL_ALWAYS_SOFTWARE", "1")

hl.config({
	cursor = {no_hardware_cursors = true},
})
