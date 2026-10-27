# ~/.zshrc - Zsh estilo hacker (abre en Kitty). Bash sigue igual para el sistema.
# Atajos clave:
#   Esc Esc     -> agrega/quita "sudo" al comando (o al ultimo si la linea esta vacia)
#   Flecha ->   -> acepta la sugerencia gris
#   Tab         -> autocompletado con menu buscable (fzf-tab)
#   Ctrl+R      -> buscar en el historial  |  Ctrl+T -> buscar archivo  |  Alt+C -> ir a carpeta
#   Flechas arriba/abajo -> historial filtrado por lo que ya escribiste
# Ayuda de atajos y alias: escribe "atajos"

ZPLUG="$HOME/.local/share/zsh/plugins"
export STARSHIP_CONFIG="$HOME/.config/starship-hacker.toml"
[[ ":$PATH:" == *":$HOME/.local/bin:"* ]] || export PATH="$HOME/.local/bin:$PATH"   # vpn-ip y otros

# ---------------------------------------------------------------- entorno de Omarchy
[[ -r /usr/share/omarchy/default/bash/env-bootstrap ]] && source /usr/share/omarchy/default/bash/env-bootstrap
if command -v omarchy-launch-editor &>/dev/null; then
  export EDITOR="${EDITOR:-omarchy-launch-editor --inline}"
else
  export EDITOR="${EDITOR:-nano}"
fi
export SUDO_EDITOR="$EDITOR"
command -v omarchy-launch-browser &>/dev/null && export BROWSER="${BROWSER:-omarchy-launch-browser}"
export BAT_THEME=ansi
export MANROFFOPT="-c"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# ---------------------------------------------------------------- historial
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt extended_history share_history inc_append_history
setopt hist_ignore_all_dups hist_ignore_space hist_reduce_blanks hist_verify

# ---------------------------------------------------------------- opciones
setopt auto_cd auto_pushd pushd_ignore_dups interactive_comments
setopt no_beep complete_in_word
WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'   # Ctrl+Retroceso borra hasta "/"

# ---------------------------------------------------------------- autocompletado
fpath=(/usr/share/zsh/site-functions $fpath)

# ---------------------------------------------------------------- Oh My Zsh
# Plugins + tema Powerlevel10k (colores hacker en ~/.config/zsh/p10k-hacker.zsh).
# Agregar plugins: anadir el nombre a la lista y abrir una terminal nueva.
# Lista completa: ls ~/.oh-my-zsh/plugins   |   ver alias de un plugin: als <plugin>
export ZSH="$HOME/.oh-my-zsh"
# Estilo del prompt: p10k (Powerlevel10k) o starship. Cambiar con: estilo-prompt p10k|starship
ZSH_PROMPT_STYLE=$(<"$HOME/.config/zsh/prompt-style" 2>/dev/null)
[[ $ZSH_PROMPT_STYLE == starship ]] || ZSH_PROMPT_STYLE=p10k
if [[ $ZSH_PROMPT_STYLE == p10k ]]; then ZSH_THEME="powerlevel10k/powerlevel10k"; else ZSH_THEME=""; fi
ZSH_COMPDUMP="$HOME/.cache/zcompdump-omz"
zstyle ':omz:update' mode reminder     # avisa cuando hay actualizacion (omz update)
DISABLE_MAGIC_FUNCTIONS=true           # pegar URLs sin que se escapen
plugins=(
  git            # alias de git: gst, gaa, gcmsg, gp, glog...
  archlinux      # alias de pacman/yay: pacupg, yaupg, pacin...
  docker         # autocompletado y alias de docker
  extract        # extract archivo.zip/.tar.gz/.7z/... (cualquier formato)
  copypath       # copypath  -> copia la ruta de la carpeta actual
  copyfile       # copyfile f -> copia el contenido del archivo
  copybuffer     # Ctrl+O    -> copia el comando que estas escribiendo
  nmap           # alias de nmap: nmap_fast, nmap_full, nmap_open_ports...
  python         # alias de python y venvs: mkv, vrun, pyclean...
  web-search     # google algo / ddg algo / github algo desde la terminal
  jsontools      # pp_json, is_json, urlencode_json...
  encode64       # e64 / d64 para base64
  urltools       # urlencode / urldecode
  aliases        # als -> lista todos los alias por grupo
  you-should-use # te recuerda el alias cuando escribes el comando largo
)
YSU_MESSAGE_POSITION="after"
source "$ZSH/oh-my-zsh.sh"
if [[ $ZSH_PROMPT_STYLE == p10k ]]; then
  [[ -r ~/.p10k.zsh ]] && source ~/.p10k.zsh                              # base "rainbow"
  [[ -r ~/.config/zsh/p10k-hacker.zsh ]] && source ~/.config/zsh/p10k-hacker.zsh  # colores hacker
fi
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$HOME/.cache/zsh"

# fzf-tab: menu buscable al presionar Tab (debe ir despues de compinit)
if [[ -r $ZPLUG/fzf-tab/fzf-tab.plugin.zsh ]]; then
  source $ZPLUG/fzf-tab/fzf-tab.plugin.zsh
  zstyle ':fzf-tab:*' fzf-flags --color=fg:#cfe8d8,hl:#00ff9c,fg+:#ffffff,hl+:#00ff9c,pointer:#00ff9c,marker:#00e5ff,prompt:#00e5ff,info:#6f8f84,border:#1c2a2c
  zstyle ':fzf-tab:*' switch-group '<' '>'
  zstyle ':fzf-tab:complete:(cd|zd|z|__zoxide_z):*' fzf-preview 'eza -1 --color=always --icons $realpath'
  zstyle ':fzf-tab:complete:(cat|bat|nvim|n|less):*' fzf-preview 'bat --color=always --style=numbers --line-range=:200 $realpath 2>/dev/null || eza -1 --color=always --icons $realpath'
  zstyle ':fzf-tab:complete:kill:argument-rest' fzf-preview 'ps -p $word -o pid,user,%cpu,%mem,cmd --no-headers'
fi

# ---------------------------------------------------------------- teclas
bindkey -e
bindkey '^[[1;5C' forward-word        # Ctrl+Derecha
bindkey '^[[1;5D' backward-word       # Ctrl+Izquierda
bindkey '^[[H'    beginning-of-line   # Inicio
bindkey '^[[F'    end-of-line         # Fin
bindkey '^[[3~'   delete-char         # Supr
bindkey '^H'      backward-kill-word  # Ctrl+Retroceso
bindkey '^[[3;5~' kill-word           # Ctrl+Supr

# Esc Esc: agrega o quita "sudo" al principio de la linea
sudo-command-line() {
  [[ -z $BUFFER ]] && BUFFER="$(fc -ln -1)" && CURSOR=${#BUFFER}
  if [[ $BUFFER == sudo\ * ]]; then
    if [[ $LBUFFER == sudo\ * ]]; then LBUFFER="${LBUFFER#sudo }"; else BUFFER="${BUFFER#sudo }"; fi
  else
    LBUFFER="sudo $LBUFFER"
  fi
  zle redisplay
}
zle -N sudo-command-line
bindkey '\e\e' sudo-command-line

# Editar el comando actual en el editor: Ctrl+X Ctrl+E
autoload -Uz edit-command-line && zle -N edit-command-line
bindkey '^X^E' edit-command-line

# ---------------------------------------------------------------- herramientas
command -v mise    &>/dev/null && eval "$(mise activate zsh)"
command -v zoxide  &>/dev/null && eval "$(zoxide init zsh)"
[[ $ZSH_PROMPT_STYLE == starship ]] && command -v starship &>/dev/null && [[ $TERM != dumb ]] && eval "$(starship init zsh)"

# Prompt compacto: al ejecutar un comando, el prompt de 2 lineas se reduce a "❯ comando"
# (asi el historial en pantalla queda limpio). Desactivar: ZSH_TRANSIENT=0 en este archivo.
ZSH_TRANSIENT=${ZSH_TRANSIENT:-1}
if (( ZSH_TRANSIENT )) && [[ $ZSH_PROMPT_STYLE == starship ]]; then   # p10k ya trae el suyo
  zle-line-init() {
    emulate -L zsh
    [[ $CONTEXT == start ]] || return 0
    while true; do
      zle .recursive-edit
      local -i ret=$?
      [[ $ret == 0 && $KEYS == $'\4' ]] || break
      [[ -o ignore_eof ]] || exit 0
    done
    local saved_prompt=$PROMPT saved_rprompt=$RPROMPT
    PROMPT='%F{#00ff9c}%B❯%b%f '
    RPROMPT=''
    zle .reset-prompt
    PROMPT=$saved_prompt
    RPROMPT=$saved_rprompt
    if (( ret )); then zle .send-break; else zle .accept-line; fi
    return ret
  }
  zle -N zle-line-init
fi

if command -v fzf &>/dev/null; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'
  export FZF_DEFAULT_OPTS="--height 45% --layout=reverse --border=rounded --prompt='❯ ' --pointer='▶' --marker='✓' \
    --color=fg:#cfe8d8,bg:-1,hl:#00ff9c,fg+:#ffffff,bg+:#10181a,hl+:#00ff9c \
    --color=info:#6f8f84,prompt:#00e5ff,pointer:#00ff9c,marker:#00e5ff,spinner:#00ff9c,header:#c77dff,border:#1c2a2c"
  export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:200 {}'"
  export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --color=always --icons {}'"
  source <(fzf --zsh)
fi

# ---------------------------------------------------------------- alias y funciones de Omarchy
# (ls con iconos, cd inteligente, ff, git, tmux, etc.)
if [[ -d /usr/share/omarchy ]]; then
  source /usr/share/omarchy/default/bash/aliases
  for f in /usr/share/omarchy/default/bash/fns/*(N); do source "$f" 2>/dev/null; done
fi

# ls con iconos y colores (tema en ~/.config/eza/theme.yml)
if command -v eza &>/dev/null; then
  alias l='eza --group-directories-first --icons=auto'          # cuadricula
  alias la='eza -a --group-directories-first --icons=auto'      # cuadricula con ocultos
  alias ll='eza -lh --group-directories-first --icons=auto --git --time-style=relative'  # lista con git
  alias lla='ll -a'
  alias tree='eza --tree --icons=auto --group-directories-first'
  alias lt='eza --tree --level=2 -lh --icons=auto --git --group-directories-first'
fi

# ---------------------------------------------------------------- utilidades de hacking etico
alias ips='ip -br -c addr'                       # IPs de todas las interfaces
alias myip='curl -s https://ifconfig.me; echo'   # IP publica
alias vpnip='vpn-ip || echo "Sin VPN activa"'    # IP de la VPN (tun0, wg, forti)
alias ports='sudo ss -tulpn'                     # puertos abiertos en este equipo
alias listen='nc -lvnp'                          # listen 4444
alias nmapq='nmap -T4 -F'                        # escaneo rapido: nmapq 10.10.10.5
alias nmapf='sudo nmap -sC -sV -p- -T4 -oN nmap_full.txt'   # completo con versiones
alias hist='history 1 | grep -i'                 # hist ssh
alias grep='grep --color=auto'

# Servir la carpeta actual por HTTP: serve [puerto]
serve() {
  local port=${1:-8000}
  echo "Sirviendo $(pwd) en:"
  ip -4 -o addr | awk -v p=$port '$2!="lo"{split($4,a,"/"); print "  http://"a[1]":"p}'
  python3 -m http.server "$port"
}

# Crear carpeta de trabajo para una maquina: box nombre [ip]
box() {
  [[ -z $1 ]] && { echo "Uso: box <nombre> [ip]"; return 1; }
  mkdir -p ~/boxes/$1/{nmap,loot,exploits} && cd ~/boxes/$1
  [[ -n $2 ]] && export TARGET=$2 && echo "TARGET=$2"
  echo "Carpeta lista: $(pwd)"
}

# Cambiar el estilo del prompt: estilo-prompt p10k | starship
estilo-prompt() {
  case $1 in
    p10k|starship) print -r -- $1 > ~/.config/zsh/prompt-style; exec zsh ;;
    *) echo "Uso: estilo-prompt p10k|starship   (actual: $ZSH_PROMPT_STYLE)"; return 1 ;;
  esac
}

atajos() {
  print -P "%F{#00ff9c}%BAtajos de la terminal%b%f
  %F{#00e5ff}Esc Esc%f          agregar/quitar sudo
  %F{#00e5ff}→%f                aceptar sugerencia gris
  %F{#00e5ff}Tab%f              menu de autocompletado (< > cambia grupo)
  %F{#00e5ff}Ctrl+R%f           buscar en historial
  %F{#00e5ff}Ctrl+T / Alt+C%f   buscar archivo / ir a carpeta
  %F{#00e5ff}↑ ↓%f              historial que empieza con lo escrito
  %F{#00e5ff}Ctrl+X Ctrl+E%f    editar comando en el editor
%F{#00ff9c}%BKitty%b%f
  %F{#00e5ff}Ctrl+Shift+\\\\ / -%f  dividir vertical / horizontal
  %F{#00e5ff}Alt+flechas%f      moverse entre paneles
  %F{#00e5ff}Ctrl+Shift+Z%f     zoom al panel
  %F{#00e5ff}Ctrl+Shift+T%f     nueva pestana
  %F{#00e5ff}Ctrl+Shift+E%f     abrir enlaces/IPs visibles con el teclado
%F{#00ff9c}%BHacking%b%f
  ips  myip  vpnip  ports  serve [puerto]  listen <puerto>
  nmapq <ip>  nmapf <ip>  box <nombre> [ip]  hist <texto>
%F{#00ff9c}%BOh My Zsh%b%f
  %F{#00e5ff}als%f              ver todos los alias (git, pacman, docker...)
  %F{#00e5ff}Ctrl+O%f           copiar el comando escrito
  %F{#00e5ff}extract f%f        descomprimir cualquier archivo
  %F{#00e5ff}estilo-prompt%f    p10k | starship  (cambiar diseno del prompt)"
}

# ---------------------------------------------------------------- plugins visuales (al final)
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh 2>/dev/null
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#3b4a45'
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[command]='fg=#00ff9c,bold'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#00ff9c,bold'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#00e5ff,bold'
ZSH_HIGHLIGHT_STYLES[function]='fg=#00e5ff,bold'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=#ff3b6b,bold,underline'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#ff3b6b'
ZSH_HIGHLIGHT_STYLES[path]='fg=#cfe8d8,underline'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#ffd23f'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#ffd23f'
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#c77dff'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#c77dff'
ZSH_HIGHLIGHT_STYLES[comment]='fg=#3b4a45,italic'

source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh 2>/dev/null
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^[OA' history-substring-search-up
bindkey '^[OB' history-substring-search-down
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='fg=#070b0d,bg=#00ff9c'

# ---------------------------------------------------------------- bienvenida
if [[ -z $ZSH_WELCOMED && $SHLVL -le 2 ]]; then
  export ZSH_WELCOMED=1
  [[ $COLUMNS -ge 70 ]] && command -v fastfetch &>/dev/null && fastfetch -c ~/.config/fastfetch/hacker.jsonc
  _lan=$(ip -4 -o route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="src"){print $(i+1); exit}}')
  _vpn=$(vpn-ip 2>/dev/null | cut -d' ' -f2)
  if [[ -n $_vpn ]]; then _vc='#00ff9c'; else _vc='#ff3b6b'; fi
  print -P "%F{#00ff9c}▌%f %B%F{#00e5ff}%n%f%b%F{#00ff9c}㉿%f%B%F{#00e5ff}%m%f%b  %F{#6f8f84}│%f  LAN %F{#cfe8d8}${_lan:-—}%f  %F{#6f8f84}│%f  VPN %F{$_vc}${_vpn:-off}%f  %F{#6f8f84}│ escribe%f %F{#00e5ff}atajos%f"
  unset _lan _vpn _vc
fi
