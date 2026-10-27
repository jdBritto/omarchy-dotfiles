-- Ajustes generales propios para illogical-impulse.
-- Teclado: el mismo que el sistema (/etc/vconsole.conf), latam si no hay.
local layout, variant = "latam", ""
local f = io.open("/etc/vconsole.conf", "r")
if f then
	for line in f:lines() do
		layout = line:match("^XKBLAYOUT=(.+)") or layout
		variant = line:match("^XKBVARIANT=(.+)") or variant
	end
	f:close()
end
hl.config({ input = { kb_layout = layout, kb_variant = variant } })
