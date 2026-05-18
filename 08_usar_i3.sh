#!/usr/bin/env bash
# ==============================================================================
# FORÇAR i3 + LIGHTDM
# Execute como: sudo bash 08_usar_i3.sh
# ==============================================================================
set -euo pipefail
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
log()  { echo -e "${GREEN}[OK]${NC} $*"; }
info() { echo -e "${CYAN}[INFO]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
die()  { echo -e "${RED}[ERRO]${NC} $*" >&2; exit 1; }

[[ $EUID -eq 0 ]] || die "Execute como root: sudo bash $0"

DE="i3"; DM="lightdm"; SESSION="i3"
info "Configurando $DE com $DM..."

# --- Localizar binário do DM (independente de distro) ---
DM_BIN=$(command -v lightdm 2>/dev/null || true)
if [[ -z "$DM_BIN" ]]; then
    # Fallback: procurar em paths comuns
    for p in /usr/sbin/lightdm /usr/bin/lightdm /sbin/lightdm /bin/lightdm /usr/lib/lightdm/lightdm; do
        [[ -x "$p" ]] && DM_BIN="$p" && break
    done
fi
[[ -n "$DM_BIN" ]] || die "$DM não encontrado. Execute: sudo bash 00_instalar_tudo.sh"
info "$DM encontrado em: $DM_BIN"

# --- Verificar DE instalado ---
command -v i3 &>/dev/null || die "$DE não instalado. Execute: sudo bash 00_instalar_tudo.sh"

# --- Verificar sessão .desktop ---
SESSION_DESKTOP=$(find /usr/share/xsessions/ -iname "i3*.desktop" 2>/dev/null | head -1)
if [[ -z "$SESSION_DESKTOP" ]]; then
    warn "Sessão 'i3' não encontrada em /usr/share/xsessions/"
    warn "Sessões disponíveis: $(ls /usr/share/xsessions/ 2>/dev/null | tr '\n' ' ')"
    die "Pacote do ambiente pode estar incompleto."
fi
SESSION_NAME=$(basename "$SESSION_DESKTOP" .desktop)
info "Sessão detectada: '$SESSION_NAME'"

# --- Parar todos os DMs ---
info "Parando todos os display managers..."
for svc in gdm gdm3 lightdm sddm lxdm xdm; do
    systemctl stop  "$svc" 2>/dev/null || true
    systemctl disable "$svc" 2>/dev/null || true
done
pkill -15 Xorg 2>/dev/null || true
pkill -15 X    2>/dev/null || true
sleep 1

# --- REGISTRAR DM ---
info "Registrando $DM_BIN como display manager padrão..."
echo "$DM_BIN" > /etc/X11/default-display-manager
log "  /etc/X11/default-display-manager = $(cat /etc/X11/default-display-manager)"

echo "$DM shared/default-x-display-manager select $DM" | debconf-set-selections 2>/dev/null || true
DEBIAN_FRONTEND=noninteractive dpkg-reconfigure "$DM" 2>/dev/null || true

# Garantir após dpkg-reconfigure
echo "$DM_BIN" > /etc/X11/default-display-manager
systemctl enable "$DM"
log "$DM habilitado."

# --- Configurar LightDM ---
LCONF="/etc/lightdm/lightdm.conf"
if [[ -f "$LCONF" ]]; then
    grep -q "^\[Seat" "$LCONF" || printf "\n[Seat:*]\n" >> "$LCONF"
    if grep -q "^user-session=" "$LCONF"; then
        sed -i "s/^user-session=.*/user-session=$SESSION_NAME/" "$LCONF"
    else
        sed -i "/^\[Seat/a user-session=$SESSION_NAME" "$LCONF"
    fi
    log "LightDM: sessão $SESSION_NAME configurada."
fi

# .xinitrc para fallback sem DM
if [[ -n "${SUDO_USER:-}" && "${SUDO_USER}" != "root" ]]; then
    echo "exec i3" > "/home/$SUDO_USER/.xinitrc"
    chown "$SUDO_USER:$SUDO_USER" "/home/$SUDO_USER/.xinitrc"
    log ".xinitrc criado para i3."
fi
info "Atalhos i3: Mod+Enter=terminal | Mod+d=launcher | Mod+Shift+Q=fechar"

# --- .dmrc do usuário ---
if [[ -n "${SUDO_USER:-}" && "${SUDO_USER}" != "root" ]]; then
    info "Configurando sessão '$SESSION_NAME' para $SUDO_USER..."
    printf "[Desktop]\nSession=%s\n" "$SESSION_NAME" > "/home/$SUDO_USER/.dmrc"
    chown "$SUDO_USER:$SUDO_USER" "/home/$SUDO_USER/.dmrc"
    log ".dmrc configurado."
fi

# --- Diagnóstico final ---
info "=== Diagnóstico ==="
echo "  default-display-manager : $(cat /etc/X11/default-display-manager)"
echo "  $DM habilitado          : $(systemctl is-enabled $DM 2>/dev/null)"
echo "  Sessão .desktop          : $SESSION_DESKTOP"

log "=============================================="
log "$DE + $DM configurados com sucesso! Iniciando em 3s..."
log "=============================================="
sleep 3

systemctl start "$DM" || {
    warn "Falha ao iniciar $DM. Diagnóstico:"
    journalctl -xeu "${DM}.service" --no-pager -n 40 2>/dev/null || true
    echo ""
    echo "  /etc/X11/default-display-manager = $(cat /etc/X11/default-display-manager 2>/dev/null)"
    die "$DM não iniciou. Veja diagnóstico acima."
}
