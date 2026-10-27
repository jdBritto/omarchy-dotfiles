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

   Al empezar muestra un menú para elegir qué instalar: te mueves con las
   flechas (o `j`/`k`), marcas o desmarcas con **Espacio** (o con el número de
   la opción), `a` marca todo, `n` nada, **Enter** continúa y `q` sale sin
   cambiar nada. Si elegiste Hyprland y Niri, después eliges con flechas con
   cuál arrancar. Para instalar lo recomendado sin preguntas: `install.sh --si`.

3. Reinicia el equipo.

### En Arch Linux limpio (sin Omarchy)

Instala Arch (por ejemplo con `archinstall`, perfil *Minimal*, con un usuario
que pueda usar `sudo` y con red), entra en la consola y ejecuta:

```bash
sudo pacman -S --needed git
git clone https://github.com/jdBritto/omarchy-dotfiles.git ~/omarchy-dotfiles
~/omarchy-dotfiles/install.sh
```

El menú agrega la opción **Base del sistema** (audio, red, Bluetooth,
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

## illogical-impulse con end4-pC (opcional)

Opción **illogical-impulse (end4-pC)** del instalador (solo en Omarchy,
desmarcada por defecto). Es Hyprland con el escritorio
[illogical-impulse](https://github.com/end-4/dots-hyprland) de end-4 y el shell
[end4-pC](https://github.com/pctrade/end4-pC) de pctrade: Material 3
Expressive, widgets en el escritorio, letras de canciones, fondos en línea,
barra configurable, asistente de IA y presets de la comunidad.

```bash
escritorio ii       # usar illogical-impulse (pide reiniciar)
escritorio omarchy  # volver a Omarchy (o: escritorio dms)
ii-dots actualizar  # traer lo último de illogical-impulse y end4-pC
ii-dots estado      # ver versiones instaladas
```

No usa el instalador oficial (`./setup install`) porque reemplaza el
`hyprland.lua` de Omarchy y borra configuraciones de kitty, foot, fish,
matugen y fuentes. `ii-dots` coloca solo lo que necesita:

- `~/.config/quickshell/ii` y `~/.config/quickshell/end4-pC` (los shells).
- `~/.config/hypr/hyprland/` y `~/.config/hypr/ii.lua` (configuración de
  Hyprland de ii). `hyprland.lua` la carga en lugar de la de Omarchy cuando
  `~/.config/escritorio-modo` dice `ii`.
- `~/.config/hypr/custom/`: tus ajustes para ii (teclado latam, end4-pC como
  shell, atajos). No se pisan al actualizar.
- Plantillas de colores de matugen, **sumadas** a las tuyas (la del modo
  futurista sigue).
- El Quickshell de Omarchy se mantiene: ii pide la versión 0.3.2 y es la misma.

Arranca con la sesión *Hyprland* normal, sin UWSM (illogical-impulse no se
lleva bien con UWSM); Omarchy sigue usando la suya.

Atajos dentro de illogical-impulse: `Super + F1` lista de atajos,
`Super + Escape` ajustes de end4-pC, `Ctrl + Super + T` elegir fondo,
`Super + Enter` terminal, `Super + Q` cerrar ventana.

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

## Zsh hacker

Opción **Zsh hacker** del instalador. Kitty abre **Zsh** (bash sigue siendo el shell
del sistema) con:

- **Oh My Zsh** con plugins: git, archlinux, docker, extract, copypath, copyfile,
  copybuffer, nmap, python, web-search, encode64, urltools, jsontools, aliases y
  you-should-use.
- **Powerlevel10k** en bloques verde/cian: usuario, carpeta, git, IP de la VPN,
  IP local y hora. Los comandos anteriores se reducen a `❯ comando`.
- **Bienvenida** con fastfetch al abrir la terminal y una línea con LAN, VPN y la ayuda.
- Sugerencias en gris, colores de sintaxis, menú con Tab (fzf-tab), `Esc Esc` para
  `sudo`, `ls` con iconos (eza) y alias de hacking (`serve`, `box`, `nmapq`...).

```bash
atajos                    # ayuda con todos los atajos y alias
estilo-prompt starship    # volver al prompt estilo Kali (Starship)
estilo-prompt p10k        # volver a Powerlevel10k
p10k reload               # aplicar cambios de ~/.config/zsh/p10k-hacker.zsh
```

Los colores del prompt están en `~/.config/zsh/p10k-hacker.zsh`, que se aplica
encima de la plantilla `~/.p10k.zsh`. Oh My Zsh, Powerlevel10k, fzf-tab y
you-should-use se descargan con git durante la instalación.

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
