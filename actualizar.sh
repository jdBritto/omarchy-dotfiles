#!/bin/bash
# Copia tu configuracion actual al repositorio y la sube a GitHub.
# Uso:  ./actualizar.sh "mensaje opcional"

set -euo pipefail
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Actualiza cada archivo que ya esta en el repositorio con su version actual.
ARBOLES=(home)
[[ $(systemd-detect-virt 2>/dev/null || true) == vmware ]] && ARBOLES+=(vmware)
for arbol in "${ARBOLES[@]}"; do
  while IFS= read -r -d '' f; do
    rel=${f#"$REPO/$arbol"/}
    [[ $rel == .config/escritorio-modo ]] && continue   # siempre arranca en DMS
    if [[ -f $HOME/$rel ]]; then cp -a "$HOME/$rel" "$f"; fi
  done < <(find "$REPO/$arbol" -type f -print0)
done

cd "$REPO"
git add -A
if git diff --cached --quiet; then
  echo "No hay cambios que subir."
else
  git commit -m "${1:-Actualizar configuracion $(date +%F)}"
  git push
  echo "Configuracion subida a GitHub."
fi
