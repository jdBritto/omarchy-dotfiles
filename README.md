# omarchy-dotfiles

Mi entorno de trabajo sobre [Omarchy](https://omarchy.org) o Arch Linux limpio: DankMaterialShell con
el selector `escritorio`, atajos de teclado en español, fuentes, herramientas de
desarrollo (Claude Code, Codex, gh, Node, OpenCode vía mise), dictado por voz
(voxtype) y galería de fondos.

## Instalar en un equipo nuevo

1. Instala Omarchy normalmente y entra al escritorio.
2. Abre una terminal (`Super + Enter`) y ejecuta:

```bash
git clone https://github.com/jdBritto/omarchy-dotfiles.git ~/omarchy-dotfiles
~/omarchy-dotfiles/install.sh
```

   Al empezar muestra una lista para elegir qué instalar (escribes los
   números para marcar o desmarcar) y, si elegiste Hyprland y Niri, con cuál
   arrancar. Para instalar lo recomendado sin preguntas: `install.sh --si`.

3. Reinicia el equipo.

### En Arch Linux limpio (sin Omarchy)

Instala Arch (por ejemplo con `archinstall`, perfil *Minimal*, con un usuario
que pueda usar `sudo` y con red), entra en la consola y ejecuta:

```bash
sudo pacman -S --needed git
git clone https://github.com/jdBritto/omarchy-dotfiles.git ~/omarchy-dotfiles
~/omarchy-dotfiles/install.sh
```

La lista agrega la opción **Base del sistema** (audio, red, Bluetooth,
fuentes, terminal Ghostty, archivos y la pantalla de inicio SDDM), que Omarchy
ya trae. El escritorio es **Niri con DankMaterialShell**: la configuración de
Hyprland de este repo necesita Omarchy, así que no aparece. Los paquetes del
AUR (como el dictado por voz) se instalan con `yay`, que se instala solo si
hace falta. Al reiniciar, elige *Niri* en la pantalla de inicio.

El script detecta si estás en una máquina virtual VMware y solo en ese caso
aplica los ajustes de VMware (renderizado por software, monitor `Virtual-1`,
open-vm-tools). En un equipo nativo usa la configuración normal de Omarchy.
Antes de sobrescribir nada guarda una copia en `~/.config-respaldo-<fecha>`.

## Niri (opcional)

También queda instalado Niri, otro gestor de ventanas (con columnas que se
desplazan de lado), usando DankMaterialShell y los mismos atajos.

```bash
sesion niri       # arrancar con Niri
sesion hyprland   # volver a Hyprland (Omarchy)
sesion estado     # ver cuál está elegido
```

Después de cambiar, `sesion` ofrece reiniciar el equipo. Hace falta reiniciar
el equipo entero: si solo se reinicia la sesión, Hyprland puede quedar con la
pantalla en negro.

En Niri, `Super + Tab` muestra la vista general y `Super + K` la lista de atajos.

## Guardar cambios de configuración

Si cambias algo de tu configuración y quieres guardarlo en GitHub:

```bash
~/omarchy-dotfiles/actualizar.sh "lo que cambié"
```

(Para agregar un archivo nuevo, cópialo dentro de `home/` con la misma ruta
que tiene en tu carpeta personal.)

## Qué contiene

| Carpeta / archivo   | Qué es |
|---------------------|--------|
| `install.sh`        | Instalador |
| `actualizar.sh`     | Sube tu configuración actual al repositorio |
| `paquetes/`         | Paquetes de cada opción del instalador (`dms.txt` siempre) |
| `home/`             | Archivos que se copian a tu carpeta personal |
| `vmware/`           | Archivos que solo se copian en VMware |

## Atajos principales

| Atajo | Acción |
|-------|--------|
| `Super + Espacio` | Buscar aplicaciones |
| `Super + Alt + Espacio` | Menú |
| `Super + Escape` | Apagar / reiniciar |
| `Super + Ctrl + Espacio` | Cambiar fondo |
| `Super + I` | Configuración |
| `Super + Ctrl + V` | Portapapeles |
| `Super + A` | Centro de control |
| `Super + N` | Notificaciones |
| `Super + K` | Ver atajos |
| `Super + Shift + Ctrl + D` | Alternar DMS / Omarchy |
