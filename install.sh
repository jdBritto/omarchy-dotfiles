#!/bin/bash
# Instala mi entorno de trabajo con DankMaterialShell (DMS).
# Funciona sobre Omarchy o sobre Arch Linux limpio. Al empezar muestra un
# menu para elegir que instalar (flechas y Espacio).
#
# Uso:  ./install.sh              (pregunta todo)
#       ./install.sh --si         (sin preguntas: lo recomendado)
#       ./install.sh --hyprland   (arrancar con Hyprland; solo Omarchy)
#       ./install.sh --niri       (arrancar con Niri)
#       ./install.sh --ii         (arrancar con illogical-impulse; solo Omarchy)
#
# Es seguro ejecutarlo mas de una vez. Antes de sobrescribir guarda una copia
# de tus archivos en ~/.config-respaldo-<fecha>.

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OMARCHY_PATH="${OMARCHY_PATH:-/usr/share/omarchy}"
RESPALDO="$HOME/.config-respaldo-$(date +%Y%m%d-%H%M%S)"

verde() { printf '\n\033[1;32m==> %s\033[0m\n' "$*"; }
aviso() { printf '\033[1;33m[aviso] %s\033[0m\n' "$*"; }
error() { printf '\033[1;31m[error] %s\033[0m\n' "$*" >&2; exit 1; }

# ---------------------------------------------------------------- opciones
SESION=""
PREGUNTAR=true
for arg in "$@"; do
  case "$arg" in
    --hyprland) SESION=hyprland ;;
    --niri)     SESION=niri ;;
    --ii)       SESION=ii ;;
    --si)       PREGUNTAR=false ;;
    -h|--help)  sed -n '2,13p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *)          error "Opcion desconocida: $arg (mira: ./install.sh --help)" ;;
  esac
done
[[ -t 0 ]] || PREGUNTAR=false

# ---------------------------------------------------------------- comprobaciones
[[ $EUID -ne 0 ]] || error "No lo ejecutes con sudo; ejecutalo como tu usuario normal."
command -v pacman >/dev/null || error "Este script es solo para Arch Linux / Omarchy."

ES_OMARCHY=false
[[ -d $OMARCHY_PATH ]] && ES_OMARCHY=true
ES_VMWARE=false
[[ $(systemd-detect-virt 2>/dev/null || true) == vmware ]] && ES_VMWARE=true

if $ES_OMARCHY; then BASE="Omarchy"; else BASE="Arch Linux (sin Omarchy)"; fi
echo "Sistema: $BASE"
echo "Maquina virtual VMware: $ES_VMWARE"
if [[ $SESION == hyprland || $SESION == ii ]] && ! $ES_OMARCHY; then
  error "Hyprland con esta configuracion necesita Omarchy. En Arch limpio usa Niri."
fi

# ---------------------------------------------------------------- logo
logo() {
  local colores=(117 111 105 141 177 183) i=0 linea
  while IFS= read -r linea; do
    printf '\033[1;38;5;%sm%s\033[0m\n' "${colores[i % ${#colores[@]}]}" "$linea"
    i=$((i + 1))
  done <<'LOGO'

   █████╗ ██████╗  ██████╗██╗  ██╗       ██████╗ ███╗   ███╗███████╗
  ██╔══██╗██╔══██╗██╔════╝██║  ██║       ██╔══██╗████╗ ████║██╔════╝
  ███████║██████╔╝██║     ███████║  ━╋━  ██║  ██║██╔████╔██║███████╗
  ██╔══██║██╔══██╗██║     ██╔══██║       ██║  ██║██║╚██╔╝██║╚════██║
  ██║  ██║██║  ██║╚██████╗██║  ██║       ██████╔╝██║ ╚═╝ ██║███████║
  ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝       ╚═════╝ ╚═╝     ╚═╝╚══════╝
LOGO
  printf '\033[2m  DankMaterialShell sobre %s\033[0m\n\n' "$BASE"
}
limpiar() { printf '\033[H\033[2J'; }

# ---------------------------------------------------------------- que instalar
# Cada componente: id, nombre corto, detalle y si viene marcado.
IDS=()
declare -A NOMBRE DESC MARCA
agregar() { IDS+=("$1"); NOMBRE[$1]=$2; DESC[$1]=$3; MARCA[$1]=$4; }

$ES_OMARCHY || agregar base "Base del sistema" "Audio, red, Bluetooth, fuentes, terminal, archivos y pantalla de inicio." si
$ES_OMARCHY && agregar hyprland "Hyprland" "Hyprland con DMS y el selector 'escritorio' (DMS u Omarchy)." si
$ES_OMARCHY && agregar ii "illogical-impulse (end4-pC)" "Hyprland con el shell Material 3 de end-4 y pctrade: widgets, letras, IA, fondos en linea. Se activa con: escritorio ii" no
agregar niri "Niri" "Niri con DMS: ventanas en columnas que se desplazan de lado." si
agregar futurista "Modo futurista" "Solo en Niri: animaciones holograma, borde neon y cristal; los colores siguen al fondo." si
agregar terminales "Terminales" "Ajustes de Ghostty, Kitty, Alacritty y Foot." si
agregar apps "Apps" "Firefox, nano y cava." si
agregar herramientas "Herramientas de desarrollo" "claude, codex, gh, node y opencode (con mise)." si
agregar dictado "Dictado por voz" "voxtype." si
# En una maquina virtual no hay tarjeta grafica real: gaming viene desmarcado.
if $ES_VMWARE; then JUEGOS=no; else JUEGOS=si; fi
agregar gaming "Gaming" "Steam, Proton, GameMode, MangoHud, Gamescope y drivers para tu tarjeta grafica." $JUEGOS
agregar seguridad "Seguridad" "nmap, Wireshark y un contenedor Kali con sus 10 herramientas principales (descarga 1,2 GB, ocupa unos 4 GB)." no
$ES_OMARCHY && agregar fondos "Galeria de fondos" "Fondos de los temas de Omarchy en ~/Pictures/Fondos y tema Tokyo Night." si
$ES_VMWARE && agregar vmware "Ajustes para VMware" "Resolucion, renderizado y herramientas de la maquina virtual." si

quiere() { [[ ${MARCA[$1]:-no} == si ]]; }
cambiar() { if quiere "$1"; then MARCA[$1]=no; else MARCA[$1]=si; fi; }

# Lee una tecla; las flechas llegan como Esc + [A / [B.
leer_tecla() {
  local resto
  IFS= read -rsn1 TECLA || exit 1
  if [[ $TECLA == $'\e' ]]; then
    IFS= read -rsn2 -t 0.1 resto || true
    TECLA+=$resto
  fi
}

# Menu con flechas: arriba/abajo (o j/k) para moverse, Espacio marca o desmarca.
menu() {
  local actual=0 total=${#IDS[@]} i id marca nota=""
  printf '\033[?25l'                 # ocultar el cursor mientras se elige
  trap 'printf "\033[?25h"' EXIT
  while true; do
    limpiar
    logo
    echo "  Elige que instalar (DankMaterialShell se instala siempre):"
    echo
    for i in "${!IDS[@]}"; do
      id=${IDS[i]}
      if quiere "$id"; then marca='\033[1;32m[x]\033[0m'; else marca='\033[2m[ ]\033[0m'; fi
      if ((i == actual)); then
        printf '  \033[1;35m❯\033[0m %b \033[1;35m%s\033[0m\n' "$marca" "${NOMBRE[$id]}"
      else
        printf '    %b %s\n' "$marca" "${NOMBRE[$id]}"
      fi
    done
    $ES_OMARCHY || printf '\n  \033[2m(Hyprland no aparece: esta configuracion de Hyprland necesita Omarchy)\033[0m\n'
    printf '\n  \033[3m%s\033[0m\n' "${DESC[${IDS[actual]}]}"
    if [[ -n $nota ]]; then printf '  \033[1;33m%s\033[0m\n' "$nota"; else echo; fi
    printf '\n  \033[2m↑↓ moverse   Espacio marcar   a todo   n nada   Enter continuar   q salir\033[0m\n'

    leer_tecla
    nota=""
    case $TECLA in
      $'\e[A' | k) actual=$(((actual - 1 + total) % total)) ;;
      $'\e[B' | j) actual=$(((actual + 1) % total)) ;;
      ' ') cambiar "${IDS[actual]}" ;;
      [1-9]) if ((TECLA <= total)); then actual=$((TECLA - 1)); cambiar "${IDS[actual]}"; fi ;;
      a | A) for id in "${IDS[@]}"; do MARCA[$id]=si; done ;;
      n | N) for id in "${IDS[@]}"; do MARCA[$id]=no; done ;;
      '') if quiere niri || quiere hyprland || quiere ii; then break; fi
          nota="Elige al menos un escritorio (Hyprland o Niri)." ;;
      q | Q) limpiar; echo "Cancelado. No se cambio nada."; exit 0 ;;
    esac
  done
}

# elegir_uno TITULO OPCION...: menu con flechas para elegir una; deja el numero en ELEGIDO.
elegir_uno() {
  local titulo=$1; shift
  local opciones=("$@") actual=0 i
  while true; do
    limpiar
    logo
    echo "  $titulo"
    echo
    for i in "${!opciones[@]}"; do
      if ((i == actual)); then
        printf '  \033[1;35m❯ %s\033[0m\n' "${opciones[i]}"
      else
        printf '    %s\n' "${opciones[i]}"
      fi
    done
    printf '\n  \033[2m↑↓ moverse   Enter elegir   (despues puedes cambiar con: sesion alternar)\033[0m\n'
    leer_tecla
    case $TECLA in
      $'\e[A' | k) actual=$(((actual - 1 + ${#opciones[@]}) % ${#opciones[@]})) ;;
      $'\e[B' | j) actual=$(((actual + 1) % ${#opciones[@]})) ;;
      '') ELEGIDO=$actual; return ;;
      q | Q) limpiar; echo "Cancelado. No se cambio nada."; exit 0 ;;
    esac
  done
}

if $PREGUNTAR; then menu; fi

# Si se pidio una sesion por opcion, ese escritorio tiene que instalarse.
[[ -n $SESION ]] && MARCA[$SESION]=si
# illogical-impulse se carga desde el hyprland.lua de este repo.
quiere ii && MARCA[hyprland]=si

# Con que escritorio arranca el equipo.
if [[ -z $SESION ]]; then
  ESCRITORIOS=()
  quiere hyprland && ESCRITORIOS+=(hyprland)
  quiere ii && ESCRITORIOS+=(ii)
  quiere niri && ESCRITORIOS+=(niri)
  if ((${#ESCRITORIOS[@]} > 1)); then
    SESION=${ESCRITORIOS[0]}
    if $PREGUNTAR; then
      declare -A ETIQUETA=([hyprland]="Hyprland (Omarchy / DMS)" [ii]="Hyprland con illogical-impulse (end4-pC)" [niri]="Niri")
      ETIQUETAS=()
      for e in "${ESCRITORIOS[@]}"; do ETIQUETAS+=("${ETIQUETA[$e]}"); done
      elegir_uno "Con que escritorio quieres arrancar el equipo?" "${ETIQUETAS[@]}"
      SESION=${ESCRITORIOS[ELEGIDO]}
    fi
  elif quiere hyprland; then SESION=hyprland
  else SESION=niri
  fi
fi

if $PREGUNTAR; then printf '\033[?25h'; limpiar; fi
logo
echo "Se va a instalar: DankMaterialShell$(for id in "${IDS[@]}"; do quiere "$id" && printf ', %s' "${NOMBRE[$id]}"; done)"
echo "Escritorio al arrancar: $SESION"
if $PREGUNTAR; then
  read -rp "Continuar? [S/n] " r
  [[ $r =~ ^[nN]$ ]] && { echo "Cancelado. No se cambio nada."; exit 0; }
fi
sudo -v || error "Hace falta tu contrasena de administrador."

# ---------------------------------------------------------------- paquetes
verde "Instalando paquetes"
leer_lista() { grep -vE '^\s*(#|$)' "$REPO/paquetes/$1.txt"; }
PAQUETES=()
mapfile -t -O 0 PAQUETES < <(leer_lista dms)
for id in "${IDS[@]}"; do
  if quiere "$id" && [[ -f $REPO/paquetes/$id.txt ]]; then
    mapfile -t -O "${#PAQUETES[@]}" PAQUETES < <(leer_lista "$id")
  fi
done

# Drivers Vulkan (32 y 64 bits) para la tarjeta grafica de este equipo.
# Steam pide un driver "cualquiera" y pacman --noconfirm elegiria el de NVIDIA,
# asi que se piden los correctos en la misma orden.
NVIDIA_NUEVA=false NVIDIA_ANTIGUA=false
tarjetas() { # tarjetas FABRICANTE: IDs de las tarjetas graficas de ese fabricante
  local d          # (0x10de NVIDIA, 0x1002 AMD, 0x8086 Intel)
  for d in /sys/bus/pci/devices/*; do
    [[ $(<"$d/vendor") == "$1" && $(<"$d/class") == 0x03* ]] && cat "$d/device"
  done
  return 0
}
nvidia_ids() { tarjetas 0x10de; }
for id in $(nvidia_ids); do
  if ((id >= 0x1e00)); then NVIDIA_NUEVA=true; elif ((id >= 0x1340)); then NVIDIA_ANTIGUA=true; fi
done
drivers_juegos() {
  local hay=false
  if [[ -n $(tarjetas 0x1002) ]]; then printf '%s\n' vulkan-radeon lib32-vulkan-radeon; hay=true; fi
  if [[ -n $(tarjetas 0x8086) ]]; then printf '%s\n' vulkan-intel lib32-vulkan-intel; hay=true; fi
  if $NVIDIA_NUEVA; then
    printf '%s\n' nvidia-utils lib32-nvidia-utils; hay=true
    $ES_OMARCHY || printf '%s\n' nvidia-open-dkms libva-nvidia-driver
  elif $NVIDIA_ANTIGUA; then
    printf '%s\n' nvidia-580xx-utils lib32-nvidia-580xx-utils; hay=true
    $ES_OMARCHY || printf '%s\n' nvidia-580xx-dkms
  fi
  # Sin tarjeta conocida (maquina virtual): Vulkan por software.
  $hay || printf '%s\n' vulkan-swrast lib32-vulkan-swrast
  # Los drivers dkms de NVIDIA necesitan los headers de cada kernel instalado.
  if ! $ES_OMARCHY && { $NVIDIA_NUEVA || $NVIDIA_ANTIGUA; }; then
    cat /usr/lib/modules/*/pkgbase 2>/dev/null | sed 's/$/-headers/' | sort -u
  fi
}
if quiere gaming; then
  mapfile -t -O "${#PAQUETES[@]}" PAQUETES < <(drivers_juegos)
  # Steam esta en el repositorio multilib (programas de 32 bits).
  if ! grep -q '^\[multilib\]' /etc/pacman.conf; then
    verde "Activando el repositorio multilib (necesario para Steam)"
    sudo sed -i '/^#\[multilib\]/,/^#Include/ s/^#//' /etc/pacman.conf
    sudo pacman -Sy
  fi
fi

FALTAN=()
for p in "${PAQUETES[@]}"; do pacman -Q "$p" &>/dev/null || FALTAN+=("$p"); done
if ((${#FALTAN[@]})); then
  sudo pacman -Syu --noconfirm
  OFICIALES=() AUR=()
  for p in "${FALTAN[@]}"; do
    if pacman -Si "$p" &>/dev/null; then OFICIALES+=("$p"); else AUR+=("$p"); fi
  done
  if ((${#OFICIALES[@]})); then
    echo "Instalando: ${OFICIALES[*]}"
    sudo pacman -S --needed --noconfirm "${OFICIALES[@]}" || error "No se pudieron instalar algunos paquetes."
  fi
  if ((${#AUR[@]})); then
    if ! command -v yay >/dev/null; then
      verde "Instalando yay (para paquetes del AUR)"
      sudo pacman -S --needed --noconfirm git base-devel
      TMP=$(mktemp -d)
      git clone --depth 1 https://aur.archlinux.org/yay-bin.git "$TMP/yay-bin"
      (cd "$TMP/yay-bin" && makepkg -si --noconfirm) || error "No se pudo instalar yay."
      rm -rf "$TMP"
    fi
    echo "Instalando del AUR: ${AUR[*]}"
    yay -S --needed --noconfirm "${AUR[@]}" || aviso "No se pudieron instalar del AUR: ${AUR[*]}"
  fi
else
  echo "Todos los paquetes ya estaban instalados."
fi

# ---------------------------------------------------------------- archivos
copiar() { # copiar ORIGEN RUTA...: copia esas rutas de ORIGEN a $HOME, respaldando lo que ya exista
  local origen=$1; shift
  local ruta f rel destino
  for ruta in "$@"; do
    [[ -e $origen/$ruta ]] || continue
    while IFS= read -r -d '' f; do
      rel=${f#"$origen"/}
      destino="$HOME/$rel"
      if [[ -e $destino ]] && ! cmp -s "$f" "$destino"; then
        mkdir -p "$(dirname "$RESPALDO/$rel")"
        cp -a "$destino" "$RESPALDO/$rel"
      fi
      mkdir -p "$(dirname "$destino")"
      cp -a "$f" "$destino"
    done < <(find "$origen/$ruta" -type f -print0)
  done
}

verde "Copiando configuracion"
H="$REPO/home" V="$REPO/vmware"
copiar "$H" .config/DankMaterialShell .local/bin/sesion
quiere hyprland && copiar "$H" .config/hypr .config/escritorio-modo .config/omarchy \
  .local/bin/escritorio .local/bin/escritorio-accion
quiere niri && copiar "$H" .config/niri .config/matugen .local/bin/futurista
quiere ii && copiar "$H" .local/bin/ii-dots
quiere terminales && copiar "$H" .config/alacritty .config/foot .config/ghostty .config/kitty
$ES_OMARCHY && copiar "$H" .config/mimeapps.list
quiere herramientas && copiar "$H" .config/mise .claude
quiere seguridad && copiar "$H" .local/bin/kali
quiere dictado && copiar "$H" .config/voxtype .config/systemd/user/voxtype.service

if quiere vmware; then
  quiere hyprland && copiar "$V" .config/hypr .config/systemd/user/vmware-display-sync.service .local/bin/vmware-display-sync
  quiere niri && copiar "$V" .config/niri/vmware.kdl
else
  # Sin VMware no se usan sus ajustes.
  rm -f "$HOME/.config/hypr/vmware.lua" "$HOME/.config/hypr/envs.conf" "$HOME/.config/niri/vmware.kdl"
  if $ES_OMARCHY && grep -q 'Virtual-1' "$HOME/.config/hypr/monitors.lua" 2>/dev/null; then
    mkdir -p "$RESPALDO" && cp -a "$HOME/.config/hypr/monitors.lua" "$RESPALDO/monitors.lua.vmware"
    cp "$OMARCHY_PATH/config/hypr/monitors.lua" "$HOME/.config/hypr/monitors.lua"
  fi
fi

if quiere niri; then
  NIRI="$HOME/.config/niri/personal.kdl"
  # Niri no entiende $HOME en su configuracion: poner la ruta real.
  sed -i "s|/home/jdbritto|$HOME|g" "$NIRI" "$HOME/.config/matugen/config.toml"
  if ! $ES_OMARCHY; then
    # Sin Omarchy no existen sus comandos.
    if quiere apps; then NAVEGADOR='"firefox"'; else NAVEGADOR='"xdg-open" "https://duckduckgo.com"'; fi
    sed -i -e '/OMARCHY_PATH/d' -e 's|/usr/share/omarchy/bin:||' \
      -e "s|\"omarchy-launch-browser\"|$NAVEGADOR|" "$NIRI"
  fi
fi

if ! $ES_OMARCHY; then
  # Los temas de las terminales vienen de Omarchy: quitar esas lineas.
  for t in alacritty/alacritty.toml foot/foot.ini ghostty/config kitty/kitty.conf; do
    if [[ -f $HOME/.config/$t ]]; then sed -i '/state\/omarchy/d' "$HOME/.config/$t"; fi
  done
  # Terminal por defecto (Super + Enter) y navegador por defecto.
  [[ -f $HOME/.config/xdg-terminals.list ]] || echo com.mitchellh.ghostty.desktop >"$HOME/.config/xdg-terminals.list"
  if quiere apps; then xdg-settings set default-web-browser firefox.desktop 2>/dev/null || true; fi
  if command -v xdg-user-dirs-update >/dev/null; then xdg-user-dirs-update || true; fi
  # Comandos propios (sesion, etc.) disponibles en la terminal.
  if ! grep -q '.local/bin' "$HOME/.bashrc" 2>/dev/null; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >>"$HOME/.bashrc"
  fi
fi

chmod +x "$HOME"/.local/bin/sesion "$HOME"/.local/bin/ii-dots "$HOME"/.local/bin/futurista "$HOME"/.local/bin/kali "$HOME"/.local/bin/escritorio* "$HOME"/.local/bin/vmware-display-sync 2>/dev/null || true
if [[ -d $RESPALDO ]]; then echo "Copia de tus archivos anteriores: $RESPALDO"; fi

# ---------------------------------------------------------------- illogical-impulse
if quiere ii; then
  verde "Instalando illogical-impulse con el shell end4-pC"
  "$HOME/.local/bin/ii-dots" instalar || aviso "illogical-impulse no quedo completo; reintenta con: ii-dots instalar"
fi

# ---------------------------------------------------------------- fondos
if quiere fondos; then
  verde "Creando galeria de fondos en ~/Pictures/Fondos"
  FONDOS="$HOME/Pictures/Fondos"
  mkdir -p "$FONDOS"
  for dir in "$OMARCHY_PATH"/themes/*/backgrounds; do
    tema=$(basename "$(dirname "$dir")")
    for img in "$dir"/*; do
      if [[ -e $img ]]; then ln -sfn "$img" "$FONDOS/$tema-$(basename "$img")"; fi
    done
  done
fi

# ---------------------------------------------------------------- herramientas (mise)
if quiere herramientas; then
  verde "Instalando herramientas de desarrollo (claude, codex, gh, node, opencode)"
  if command -v mise >/dev/null; then
    MISE_MINIMUM_RELEASE_AGE=0 mise install --yes || aviso "mise no pudo instalar todo; reintenta luego con: mise install"
    if ! $ES_OMARCHY && ! grep -q 'mise activate' "$HOME/.bashrc" 2>/dev/null; then
      echo 'eval "$(mise activate bash)"' >>"$HOME/.bashrc"
    fi
  else
    aviso "mise no esta disponible; omitido."
  fi
fi

# ---------------------------------------------------------------- dictado (voxtype)
if quiere dictado && command -v voxtype >/dev/null; then
  verde "Configurando dictado por voz (voxtype)"
  voxtype setup --download --no-post-install || aviso "No se pudo descargar el modelo de voxtype."
  if command -v omarchy-hw-vulkan >/dev/null && omarchy-hw-vulkan; then
    voxtype setup gpu --enable || true
  fi
fi

# ---------------------------------------------------------------- gaming
if quiere gaming; then
  verde "Configurando gaming"
  # GameMode sube la prioridad de los juegos mientras se juega.
  if getent group gamemode >/dev/null; then sudo usermod -aG gamemode "$USER"; fi
  # NVIDIA en Arch sin Omarchy (Omarchy ya lo hace al instalarse).
  if ! $ES_OMARCHY && { $NVIDIA_NUEVA || $NVIDIA_ANTIGUA; }; then
    echo "options nvidia_drm modeset=1" | sudo tee /etc/modprobe.d/nvidia.conf >/dev/null
    sudo mkdir -p /etc/mkinitcpio.conf.d
    echo "MODULES+=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)" | sudo tee /etc/mkinitcpio.conf.d/nvidia.conf >/dev/null
    sudo mkinitcpio -P || aviso "No se pudo regenerar el arranque (mkinitcpio)."
  fi
  if [[ -n $(nvidia_ids) ]] && ! $NVIDIA_NUEVA && ! $NVIDIA_ANTIGUA; then
    aviso "Tu tarjeta NVIDIA es muy antigua para los drivers actuales: https://wiki.archlinux.org/title/NVIDIA"
  fi
  $ES_VMWARE && aviso "En una maquina virtual los juegos iran muy lentos (no hay tarjeta grafica real)."
fi

# ---------------------------------------------------------------- seguridad
if quiere seguridad; then
  verde "Preparando las herramientas de seguridad"
  # Wireshark sin sudo.
  if getent group wireshark >/dev/null; then sudo usermod -aG wireshark "$USER"; fi
  # Los contenedores sin root necesitan un rango de IDs para tu usuario.
  if ! grep -q "^$USER:" /etc/subuid 2>/dev/null; then
    sudo usermod --add-subuids 100000-165535 --add-subgids 100000-165535 "$USER"
  fi
  if distrobox list 2>/dev/null | grep -qw kali; then
    echo "El contenedor Kali ya existe."
  else
    echo "Creando el contenedor Kali (tarda unos minutos)..."
    if distrobox create --yes --name kali --image docker.io/kalilinux/kali-rolling:latest; then
      echo "Instalando las 10 herramientas principales de Kali (descarga 1,2 GB)..."
      distrobox enter kali -- sudo env DEBIAN_FRONTEND=noninteractive apt-get update &&
        distrobox enter kali -- sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y kali-tools-top10 ||
        aviso "No se instalaron todas las herramientas de Kali; reintenta con: kali sudo apt install kali-tools-top10"
    else
      aviso "No se pudo crear el contenedor Kali. Reintenta luego con ./install.sh"
    fi
  fi
fi

# ---------------------------------------------------------------- servicios
verde "Activando servicios"
systemctl --user daemon-reload
if quiere dictado; then
  systemctl --user enable voxtype.service 2>/dev/null || aviso "No se pudo activar voxtype.service"
fi
if quiere vmware; then
  sudo systemctl enable --now vmtoolsd.service 2>/dev/null || true
else
  systemctl --user disable vmware-display-sync.service 2>/dev/null || true
fi
if quiere base; then
  sudo systemctl enable NetworkManager.service bluetooth.service 2>/dev/null || true
  # Pantalla de inicio: SDDM, salvo que ya haya otra.
  if ! systemctl is-enabled display-manager.service &>/dev/null; then
    sudo systemctl enable sddm.service || aviso "No se pudo activar la pantalla de inicio (sddm)."
  fi
fi

# ---------------------------------------------------------------- sesion de inicio
verde "Eligiendo el escritorio de inicio: $SESION"
AUTOLOGIN=/etc/sddm.conf.d/autologin.conf
case $SESION in
  niri) ARCHIVO=niri.desktop ;;
  # illogical-impulse no usa UWSM: sesion "Hyprland" normal.
  ii)   ARCHIVO=hyprland.desktop; echo ii >"$HOME/.config/escritorio-modo" ;;
  *)    ARCHIVO=omarchy.desktop
        if [[ $(cat "$HOME/.config/escritorio-modo" 2>/dev/null) == ii ]]; then echo omarchy >"$HOME/.config/escritorio-modo"; fi ;;
esac
if sudo test -f "$AUTOLOGIN"; then
  sudo sed -i "s|^Session=.*|Session=$ARCHIVO|" "$AUTOLOGIN"
else
  echo "Este equipo no entra solo: elige \"$SESION\" en la pantalla de inicio (queda recordado)."
fi

# ---------------------------------------------------------------- modo futurista
if quiere niri; then
  if quiere futurista; then
    verde "Activando el modo futurista"
    "$HOME/.local/bin/futurista" on
  else
    "$HOME/.local/bin/futurista" off >/dev/null
  fi
elif quiere futurista; then
  aviso "El modo futurista es para Niri; como no elegiste Niri, se omite."
fi

# ---------------------------------------------------------------- tema
if quiere fondos && [[ -n ${WAYLAND_DISPLAY:-} ]] && command -v omarchy-theme-set >/dev/null; then
  verde "Aplicando tema Tokyo Night"
  omarchy-theme-set "Tokyo Night" || true
  hyprctl reload >/dev/null 2>&1 || true
fi

verde "Listo"
echo "Reinicia el equipo para ver todo aplicado."
echo
echo "  - Escritorio al arrancar: $SESION, con DankMaterialShell."
if quiere hyprland; then
  echo "  - En Hyprland, cambiar entre DMS y Omarchy:  Super + Shift + Ctrl + D"
  echo "    o en una terminal:                         escritorio alternar"
fi
if quiere hyprland && quiere niri; then
  echo "  - Cambiar entre Hyprland y Niri (en una terminal):  sesion alternar"
fi
if quiere ii; then
  echo "  - illogical-impulse:  escritorio ii   (volver: escritorio omarchy)"
  echo "    Dentro: Super + F1 atajos, Super + Escape ajustes, Ctrl + Super + T fondo."
  echo "    Actualizar illogical-impulse y end4-pC:  ii-dots actualizar"
fi
if quiere niri; then
  echo "  - En Niri: Super + K muestra todos los atajos."
  echo "  - Modo futurista (animaciones y efectos):  futurista on  /  futurista off"
fi
if quiere gaming; then
  echo "  - Gaming: abre Steam y activa Proton en Ajustes > Compatibilidad."
  echo "    En un juego, opciones de lanzamiento: gamemoderun mangohud %command%"
fi
if quiere seguridad; then
  echo "  - Seguridad: escribe  kali  en una terminal para entrar al contenedor Kali."
fi
echo
echo "Para agregar algo que no elegiste, vuelve a ejecutar ./install.sh"
