#!/bin/bash
# Instala mi entorno de trabajo con DankMaterialShell (DMS).
# Funciona sobre Omarchy o sobre Arch Linux limpio. Al empezar muestra una
# lista para elegir que instalar.
#
# Uso:  ./install.sh              (pregunta todo)
#       ./install.sh --si         (sin preguntas: lo recomendado)
#       ./install.sh --hyprland   (arrancar con Hyprland; solo Omarchy)
#       ./install.sh --niri       (arrancar con Niri)
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
    --si)       PREGUNTAR=false ;;
    -h|--help)  sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
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
if [[ $SESION == hyprland ]] && ! $ES_OMARCHY; then
  error "Hyprland con esta configuracion necesita Omarchy. En Arch limpio usa Niri."
fi

# ---------------------------------------------------------------- que instalar
# Cada componente: id, descripcion y si viene marcado.
IDS=()
declare -A DESC MARCA
agregar() { IDS+=("$1"); DESC[$1]=$2; MARCA[$1]=$3; }

$ES_OMARCHY || agregar base "Base del sistema: audio, red, Bluetooth, fuentes, terminal, archivos y pantalla de inicio" si
$ES_OMARCHY && agregar hyprland "Hyprland con DMS y el selector 'escritorio' (DMS u Omarchy)" si
agregar niri "Niri con DMS (ventanas en columnas que se desplazan de lado)" si
agregar terminales "Ajustes de terminales (Ghostty, Kitty, Alacritty, Foot)" si
agregar apps "Apps: Firefox, nano, cava" si
agregar herramientas "Herramientas de desarrollo: claude, codex, gh, node, opencode" si
agregar dictado "Dictado por voz (voxtype)" si
$ES_OMARCHY && agregar fondos "Galeria de fondos en ~/Pictures/Fondos y tema Tokyo Night" si
$ES_VMWARE && agregar vmware "Ajustes para VMware (resolucion, renderizado, herramientas)" si

quiere() { [[ ${MARCA[$1]:-no} == si ]]; }

mostrar_menu() {
  echo
  echo "Que quieres instalar? DankMaterialShell se instala siempre."
  local i=1
  for id in "${IDS[@]}"; do
    if quiere "$id"; then x="x"; else x=" "; fi
    printf '  %2d) [%s] %s\n' "$i" "$x" "${DESC[$id]}"
    i=$((i + 1))
  done
  $ES_OMARCHY || echo "      (Hyprland no aparece: esta configuracion de Hyprland necesita Omarchy)"
}

if $PREGUNTAR; then
  while true; do
    mostrar_menu
    echo "Escribe los numeros que quieres marcar o desmarcar (ej: 3 5) y Enter."
    read -rp "Enter sin nada para continuar: " r
    [[ -z $r ]] && {
      if quiere niri || quiere hyprland; then break; fi
      aviso "Elige al menos un escritorio (Hyprland o Niri)."
      continue
    }
    for n in $r; do
      if [[ $n =~ ^[0-9]+$ ]] && ((n >= 1 && n <= ${#IDS[@]})); then
        id=${IDS[n - 1]}
        if quiere "$id"; then MARCA[$id]=no; else MARCA[$id]=si; fi
      else
        aviso "Numero no valido: $n"
      fi
    done
  done
fi

# Si se pidio una sesion por opcion, ese escritorio tiene que instalarse.
[[ -n $SESION ]] && MARCA[$SESION]=si

# Con que escritorio arranca el equipo.
if [[ -z $SESION ]]; then
  if quiere hyprland && quiere niri; then
    SESION=hyprland
    if $PREGUNTAR; then
      echo
      echo "Con que escritorio quieres arrancar el equipo?"
      echo "  1) Hyprland   [por defecto]"
      echo "  2) Niri"
      echo "Despues puedes cambiar con: sesion alternar"
      read -rp "Elige 1 o 2: " r
      [[ $r == 2 ]] && SESION=niri
    fi
  elif quiere hyprland; then SESION=hyprland
  else SESION=niri
  fi
fi

echo
echo "Se va a instalar: DankMaterialShell$(for id in "${IDS[@]}"; do quiere "$id" && printf ', %s' "$id"; done)"
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
quiere niri && copiar "$H" .config/niri
quiere terminales && copiar "$H" .config/alacritty .config/foot .config/ghostty .config/kitty
$ES_OMARCHY && copiar "$H" .config/mimeapps.list
quiere herramientas && copiar "$H" .config/mise .claude
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
  sed -i "s|/home/jdbritto|$HOME|g" "$NIRI"
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

chmod +x "$HOME"/.local/bin/sesion "$HOME"/.local/bin/escritorio* "$HOME"/.local/bin/vmware-display-sync 2>/dev/null || true
if [[ -d $RESPALDO ]]; then echo "Copia de tus archivos anteriores: $RESPALDO"; fi

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
if [[ $SESION == niri ]]; then ARCHIVO=niri.desktop; else ARCHIVO=omarchy.desktop; fi
if sudo test -f "$AUTOLOGIN"; then
  sudo sed -i "s|^Session=.*|Session=$ARCHIVO|" "$AUTOLOGIN"
else
  echo "Este equipo no entra solo: elige \"$SESION\" en la pantalla de inicio (queda recordado)."
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
if quiere niri; then
  echo "  - En Niri: Super + K muestra todos los atajos."
fi
echo
echo "Para agregar algo que no elegiste, vuelve a ejecutar ./install.sh"
