#!/bin/bash
# Instala mi entorno de trabajo sobre una instalacion limpia de Omarchy:
# DankMaterialShell + selector `escritorio`, atajos, fuentes, herramientas
# (mise), dictado por voz (voxtype) y galeria de fondos.
#
# Uso:  ./install.sh              (pregunta: Hyprland o Niri)
#       ./install.sh --hyprland   (sin preguntar)
#       ./install.sh --niri
# Es seguro ejecutarlo mas de una vez. Antes de sobrescribir guarda una copia
# de tus archivos en ~/.config-respaldo-<fecha>.

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OMARCHY_PATH="${OMARCHY_PATH:-/usr/share/omarchy}"
RESPALDO="$HOME/.config-respaldo-$(date +%Y%m%d-%H%M%S)"

verde() { printf '\n\033[1;32m==> %s\033[0m\n' "$*"; }
aviso() { printf '\033[1;33m[aviso] %s\033[0m\n' "$*"; }
error() { printf '\033[1;31m[error] %s\033[0m\n' "$*" >&2; exit 1; }

# ---------------------------------------------------------------- comprobaciones
[[ $EUID -ne 0 ]] || error "No lo ejecutes con sudo; ejecutalo como tu usuario normal."
[[ -d $OMARCHY_PATH ]] || error "Omarchy no esta instalado. Instala primero Omarchy (https://omarchy.org) y luego vuelve a ejecutar este script."
command -v pacman >/dev/null || error "Este script es solo para Arch Linux / Omarchy."

# ---------------------------------------------------------------- escritorio
SESION=""
case "${1:-}" in
  --hyprland) SESION=hyprland ;;
  --niri)     SESION=niri ;;
  "")         ;;
  *)          error "Opcion desconocida: $1 (usa --hyprland o --niri)" ;;
esac
if [[ -z $SESION ]]; then
  if [[ -t 0 ]]; then
    echo
    echo "Con que escritorio quieres arrancar el equipo?"
    echo "  1) Hyprland  (Omarchy, con DankMaterialShell)   [por defecto]"
    echo "  2) Niri      (con DankMaterialShell)"
    echo "Se instalan los dos; despues puedes cambiar con: sesion alternar"
    read -rp "Elige 1 o 2: " r
    [[ $r == 2 ]] && SESION=niri || SESION=hyprland
  else
    SESION=hyprland
  fi
fi

ES_VMWARE=false
[[ $(systemd-detect-virt 2>/dev/null || true) == vmware ]] && ES_VMWARE=true

echo "Repositorio: $REPO"
echo "Maquina virtual VMware: $ES_VMWARE"
echo "Escritorio al arrancar: $SESION"
sudo -v || error "Hace falta tu contrasena de administrador."

# ---------------------------------------------------------------- paquetes
verde "Instalando paquetes"
mapfile -t PAQUETES < <(grep -vE '^\s*(#|$)' "$REPO/packages.txt")
$ES_VMWARE && mapfile -t -O "${#PAQUETES[@]}" PAQUETES < <(grep -vE '^\s*(#|$)' "$REPO/packages-vmware.txt")

FALTAN=()
for p in "${PAQUETES[@]}"; do pacman -Q "$p" &>/dev/null || FALTAN+=("$p"); done
if ((${#FALTAN[@]})); then
  echo "Instalando: ${FALTAN[*]}"
  sudo pacman -Syu --needed --noconfirm "${FALTAN[@]}" ||
    { command -v yay >/dev/null && yay -S --needed --noconfirm "${FALTAN[@]}"; } ||
    error "No se pudieron instalar algunos paquetes."
else
  echo "Todos los paquetes ya estaban instalados."
fi

# ---------------------------------------------------------------- archivos
copiar_arbol() { # copia $1/* dentro de $HOME, respaldando lo que ya exista
  local origen=$1
  while IFS= read -r -d '' f; do
    local rel=${f#"$origen"/}
    local destino="$HOME/$rel"
    if [[ -e $destino ]] && ! cmp -s "$f" "$destino"; then
      mkdir -p "$(dirname "$RESPALDO/$rel")"
      cp -a "$destino" "$RESPALDO/$rel"
    fi
    mkdir -p "$(dirname "$destino")"
    cp -a "$f" "$destino"
  done < <(find "$origen" -type f -print0)
}

verde "Copiando configuracion"
copiar_arbol "$REPO/home"

if $ES_VMWARE; then
  copiar_arbol "$REPO/vmware"
else
  # En un equipo nativo no se usan los ajustes de VMware.
  rm -f "$HOME/.config/hypr/vmware.lua" "$HOME/.config/hypr/envs.conf" "$HOME/.config/niri/vmware.kdl"
  if grep -q 'Virtual-1' "$HOME/.config/hypr/monitors.lua" 2>/dev/null; then
    mkdir -p "$RESPALDO" && cp -a "$HOME/.config/hypr/monitors.lua" "$RESPALDO/monitors.lua.vmware"
    cp "$OMARCHY_PATH/config/hypr/monitors.lua" "$HOME/.config/hypr/monitors.lua"
  fi
fi
# Niri no entiende $HOME en su configuracion: poner la ruta real.
sed -i "s|/home/jdbritto|$HOME|g" "$HOME/.config/niri/personal.kdl"
chmod +x "$HOME"/.local/bin/sesion "$HOME"/.local/bin/escritorio* "$HOME"/.local/bin/vmware-display-sync 2>/dev/null || true
if [[ -d $RESPALDO ]]; then echo "Copia de tus archivos anteriores: $RESPALDO"; fi

# ---------------------------------------------------------------- fondos
verde "Creando galeria de fondos en ~/Pictures/Fondos"
FONDOS="$HOME/Pictures/Fondos"
mkdir -p "$FONDOS"
for dir in "$OMARCHY_PATH"/themes/*/backgrounds; do
  tema=$(basename "$(dirname "$dir")")
  for img in "$dir"/*; do
    if [[ -e $img ]]; then ln -sfn "$img" "$FONDOS/$tema-$(basename "$img")"; fi
  done
done

# ---------------------------------------------------------------- herramientas (mise)
verde "Instalando herramientas de desarrollo (claude, codex, gh, node, opencode)"
if command -v mise >/dev/null; then
  MISE_MINIMUM_RELEASE_AGE=0 mise install --yes || aviso "mise no pudo instalar todo; reintenta luego con: mise install"
else
  aviso "mise no esta disponible; omitido."
fi

# ---------------------------------------------------------------- dictado (voxtype)
verde "Configurando dictado por voz (voxtype)"
if command -v voxtype >/dev/null; then
  voxtype setup --download --no-post-install || aviso "No se pudo descargar el modelo de voxtype."
  if command -v omarchy-hw-vulkan >/dev/null && omarchy-hw-vulkan; then
    voxtype setup gpu --enable || true
  fi
fi

# ---------------------------------------------------------------- servicios
verde "Activando servicios"
systemctl --user daemon-reload
systemctl --user enable voxtype.service 2>/dev/null || aviso "No se pudo activar voxtype.service"
if $ES_VMWARE; then
  sudo systemctl enable --now vmtoolsd.service 2>/dev/null || true
  # La resolucion se fija en monitors.lua; vmware-display-sync queda opcional.
else
  systemctl --user disable vmware-display-sync.service 2>/dev/null || true
fi

# ---------------------------------------------------------------- sesion de inicio
verde "Eligiendo el escritorio de inicio: $SESION"
AUTOLOGIN=/etc/sddm.conf.d/autologin.conf
if [[ $SESION == niri ]]; then ARCHIVO=niri.desktop; else ARCHIVO=omarchy.desktop; fi
if sudo test -f "$AUTOLOGIN"; then
  sudo sed -i "s|^Session=.*|Session=$ARCHIVO|" "$AUTOLOGIN"
else
  aviso "No encontre $AUTOLOGIN; elige el escritorio luego con: sesion $SESION"
fi

# ---------------------------------------------------------------- tema
if [[ -n ${WAYLAND_DISPLAY:-} ]] && command -v omarchy-theme-set >/dev/null; then
  verde "Aplicando tema Tokyo Night"
  omarchy-theme-set "Tokyo Night" || true
  hyprctl reload >/dev/null 2>&1 || true
fi

verde "Listo"
cat <<EOF
Reinicia el equipo para ver todo aplicado.

  - Escritorio al arrancar: $SESION, con DankMaterialShell.
  - Cambiar entre DMS y Omarchy:  Super + Shift + Ctrl + D
    o en una terminal:            escritorio alternar
    (en Hyprland)
  - Cambiar entre Hyprland y Niri (en una terminal):  sesion alternar
EOF
