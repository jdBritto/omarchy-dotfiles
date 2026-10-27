# Powerlevel10k estilo hacker (verde/cian neon). Se carga DESPUES de ~/.p10k.zsh
# y pisa sus colores/segmentos. Recargar sin cerrar la terminal: p10k reload
#
#  [] jdbritto㉿omarchy  ~/carpeta   main ✚   ...   ✘ 1  took 3s 󰖂 10.x  󰩟 192.168.x   15:58
#  ❯

# ---------------------------------------------------------------- que se muestra
typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(os_icon context dir vcs newline prompt_char)
typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
  status command_execution_time background_jobs virtualenv vpn_ip ip time
  newline
)

# Sin marco ╭─ ╰─, una linea en blanco entre comandos
typeset -g POWERLEVEL9K_MULTILINE_{FIRST,NEWLINE,LAST}_PROMPT_{PREFIX,SUFFIX}=
typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=true

# Prompt compacto: los comandos anteriores quedan como "❯ comando"
typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=always
# La bienvenida (fastfetch) imprime al abrir: sin "instant prompt"
typeset -g POWERLEVEL9K_INSTANT_PROMPT=off

# ---------------------------------------------------------------- paleta
_hk_bg='#070b0d'; _hk_dim='#1c2a2c'; _hk_txt='#cfe8d8'
_hk_green='#00ff9c'; _hk_cyan='#00e5ff'; _hk_purple='#c77dff'
_hk_yellow='#ffd23f'; _hk_red='#ff3b6b'; _hk_gray='#6f8f84'

# Logo del sistema
typeset -g POWERLEVEL9K_OS_ICON_BACKGROUND=$_hk_green
typeset -g POWERLEVEL9K_OS_ICON_FOREGROUND=$_hk_bg

# usuario㉿equipo (siempre visible, rojo si eres root)
typeset -g POWERLEVEL9K_CONTEXT_TEMPLATE='%n㉿%m'
typeset -g POWERLEVEL9K_CONTEXT_{DEFAULT,SUDO,REMOTE,REMOTE_SUDO}_CONTENT_EXPANSION='%B%n%b㉿%m'
typeset -g POWERLEVEL9K_CONTEXT_{DEFAULT,SUDO,REMOTE,REMOTE_SUDO}_VISUAL_IDENTIFIER_EXPANSION=
typeset -g POWERLEVEL9K_CONTEXT_BACKGROUND=$_hk_dim
typeset -g POWERLEVEL9K_CONTEXT_{DEFAULT,SUDO,REMOTE,REMOTE_SUDO}_FOREGROUND=$_hk_cyan
typeset -g POWERLEVEL9K_CONTEXT_{ROOT,REMOTE_ROOT}_FOREGROUND=$_hk_red
typeset -g POWERLEVEL9K_CONTEXT_{ROOT,REMOTE_ROOT}_CONTENT_EXPANSION='%B%n%b㉿%m'

# Carpeta
typeset -g POWERLEVEL9K_DIR_BACKGROUND=$_hk_cyan
typeset -g POWERLEVEL9K_DIR_FOREGROUND=$_hk_bg
typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND='#0f4a55'
typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND=$_hk_bg
typeset -g POWERLEVEL9K_DIR_ANCHOR_BOLD=true

# Git: morado limpio, amarillo con cambios, verde con archivos nuevos, rojo en conflicto
typeset -g POWERLEVEL9K_VCS_CLEAN_BACKGROUND=$_hk_purple
typeset -g POWERLEVEL9K_VCS_MODIFIED_BACKGROUND=$_hk_yellow
typeset -g POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND=$_hk_green
typeset -g POWERLEVEL9K_VCS_CONFLICTED_BACKGROUND=$_hk_red
typeset -g POWERLEVEL9K_VCS_LOADING_BACKGROUND=$_hk_dim

# Error del ultimo comando (si todo salio bien no se muestra nada)
typeset -g POWERLEVEL9K_STATUS_OK=false
typeset -g POWERLEVEL9K_STATUS_OK_PIPE=false
typeset -g POWERLEVEL9K_STATUS_ERROR_BACKGROUND=$_hk_red
typeset -g POWERLEVEL9K_STATUS_ERROR_FOREGROUND=$_hk_bg
typeset -g POWERLEVEL9K_STATUS_ERROR_{SIGNAL,PIPE}_BACKGROUND=$_hk_red
typeset -g POWERLEVEL9K_STATUS_ERROR_{SIGNAL,PIPE}_FOREGROUND=$_hk_bg

# Tiempo que tardo el comando (si pasa de 2 s)
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=2
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_BACKGROUND=$_hk_dim
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=$_hk_yellow

typeset -g POWERLEVEL9K_BACKGROUND_JOBS_BACKGROUND=$_hk_dim
typeset -g POWERLEVEL9K_BACKGROUND_JOBS_FOREGROUND=$_hk_purple
typeset -g POWERLEVEL9K_VIRTUALENV_BACKGROUND=$_hk_yellow
typeset -g POWERLEVEL9K_VIRTUALENV_FOREGROUND=$_hk_bg

# IP de la VPN (HTB/THM tun0, WireGuard, FortiClient fctvpn*...)
typeset -g POWERLEVEL9K_VPN_IP_INTERFACE='(gpd|wg|(.*tun)|tailscale|fctvpn|ppp|tap)[0-9a-z]*'
typeset -g POWERLEVEL9K_VPN_IP_SHOW_ALL=false
unset POWERLEVEL9K_VPN_IP_CONTENT_EXPANSION   # contenido por defecto: la IP de la VPN
typeset -g POWERLEVEL9K_VPN_IP_BACKGROUND=$_hk_green
typeset -g POWERLEVEL9K_VPN_IP_FOREGROUND=$_hk_bg
typeset -g POWERLEVEL9K_VPN_IP_VISUAL_IDENTIFIER_EXPANSION='󰖂'

# IP de la red local (cable o wifi)
typeset -g POWERLEVEL9K_IP_INTERFACE='(en|eth|wl)[0-9a-z]*'
typeset -g POWERLEVEL9K_IP_CONTENT_EXPANSION='$P9K_IP_IP'
typeset -g POWERLEVEL9K_IP_BACKGROUND=$_hk_dim
typeset -g POWERLEVEL9K_IP_FOREGROUND=$_hk_txt
typeset -g POWERLEVEL9K_IP_VISUAL_IDENTIFIER_EXPANSION='󰩟'

# Hora
typeset -g POWERLEVEL9K_TIME_FORMAT='%D{%H:%M}'
typeset -g POWERLEVEL9K_TIME_BACKGROUND=$_hk_cyan
typeset -g POWERLEVEL9K_TIME_FOREGROUND=$_hk_bg
typeset -g POWERLEVEL9K_TIME_UPDATE_ON_COMMAND=false

# Flecha ❯ (verde si el ultimo comando funciono, roja si fallo)
typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=$_hk_green
typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=$_hk_red

unset _hk_bg _hk_dim _hk_txt _hk_green _hk_cyan _hk_purple _hk_yellow _hk_red _hk_gray
