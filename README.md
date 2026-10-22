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

## Modo futurista

Opcional en el instalador (viene marcado) y solo para Niri. Añade:

- **Animaciones:** las ventanas se abren como un holograma (una línea de luz las
  dibuja con líneas de escaneo) y se cierran como una pantalla vieja (CRT).
  Movimientos con un rebote ligero.
- **Borde neón** con degradado y brillo alrededor de la ventana activa.
- **Cristal:** terminales, barra y menús semitransparentes con el fondo desenfocado.
- **Colores que siguen al fondo:** DMS saca una paleta viva de cada fondo y con
  ella pinta la barra, los paneles, la terminal, el borde neón y las animaciones.
- **Fondos** que cambian solos cada 10 minutos con transiciones aleatorias
  (disolver, barrido, círculo, pixelado, portal…).

```bash
futurista on       # activarlo
futurista off      # volver al estilo normal
futurista estado   # ver si está activo
```

La parte de Niri está en `~/.config/niri/futurista.kdl`. Los colores del borde y
de las animaciones salen de la plantilla
`~/.config/matugen/templates/futurista-colores.kdl`, que DMS vuelve a generar en
cada cambio de fondo.

## Gaming

Opción **Gaming** del instalador (desmarcada en máquinas virtuales, donde no hay
tarjeta gráfica real):

- **Steam** con Proton (juegos de Windows), **GameMode** (más prioridad al
  juego), **MangoHud** (FPS y temperaturas en pantalla), **Gamescope** y
  **ProtonPlus** (versiones extra de Proton, como GE-Proton).
- **Drivers Vulkan de 32 y 64 bits** elegidos según tu tarjeta (AMD, Intel o
  NVIDIA). Así Steam no instala por error los drivers de NVIDIA.
- En Arch sin Omarchy con NVIDIA también instala el driver y lo configura para
  el arranque. Omarchy ya lo hace al instalarse.

En Steam: *Ajustes > Compatibilidad* y activa Proton para todos los juegos. Para
un juego, en sus *Opciones de lanzamiento*: `gamemoderun mangohud %command%`.

Antes de dejar Windows, revisa tus juegos en [ProtonDB](https://www.protondb.com)
y [Are We Anti-Cheat Yet](https://areweanticheatyet.com): los que usan ciertos
anticheat (Valorant, League of Legends, Fortnite…) no funcionan en Linux.

## Seguridad

Opción **Seguridad** del instalador (desmarcada por defecto; descarga 1,2 GB y ocupa unos 4 GB):

- En el sistema: `nmap` y Wireshark (usable sin `sudo`).
- Un **contenedor Kali** con sus 10 herramientas principales (Metasploit, Burp
  Suite, nmap, Wireshark, sqlmap, John, Hydra, Aircrack-ng, NetExec, Responder). Las herramientas quedan separadas
  del sistema donde juegas, pero comparten tu carpeta personal y tu red.

```bash
kali                         # abrir una terminal dentro de Kali
kali sqlmap -h               # ejecutar una herramienta de Kali
kali sudo apt install gobuster   # instalar más herramientas dentro
```

Para laboratorios o malware usa mejor una máquina virtual aparte.

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
