#!/usr/bin/env bash
# ==============================================================================
# FORÇAR GNOME + GDM3
# Execute como: sudo bash 01_usar_gnome.sh
# ==============================================================================
set -euo pipefail
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
log()  { echo -e "${GREEN}[OK]${NC} $*"; }
info() { echo -e "${CYAN}[INFO]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
die()  { echo -e "${RED}[ERRO]${NC} $*" >&2; exit 1; }

[[ $EUID -eq 0 ]] || die "Execute como root: sudo bash $0"

DE="GNOME"; DM="gdm3"; SESSION="gnome"
info "Configurando $DE com $DM..."

# --- Localizar binário do DM (independente de distro) ---
DM_BIN=$(command -v gdm3 2>/dev/null || true)
if [[ -z "$DM_BIN" ]]; then
    # Fallback: procurar em paths comuns
    for p in /usr/sbin/gdm3 /usr/bin/gdm3 /sbin/gdm3 /bin/gdm3 /usr/lib/gdm3/gdm3; do
        [[ -x "$p" ]] && DM_BIN="$p" && break
    done
fi
[[ -n "$DM_BIN" ]] || die "$DM não encontrado. Execute: sudo bash 00_instalar_tudo.sh"
info "$DM encontrado em: $DM_BIN"

# Removida verificação de sessão a pedido do usuário

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

# --- Configurar GDM3 ---
mkdir -p /etc/gdm3
GCONF="/etc/gdm3/custom.conf"
[[ -f "$GCONF" ]] || printf "[daemon]\n\n[security]\n\n[xdmcp]\n\n" > "$GCONF"
sed -i "s/^#WaylandEnable=false/WaylandEnable=false/" "$GCONF" 2>/dev/null || true
grep -q "^WaylandEnable" "$GCONF" || sed -i "/^\[daemon\]/a WaylandEnable=false" "$GCONF" 2>/dev/null || true
log "GDM3: Wayland desabilitado (Xorg padrão)."

# --- Diagnóstico final ---
info "=== Diagnóstico ==="
echo "  default-display-manager : $(cat /etc/X11/default-display-manager)"
echo "  $DM habilitado          : $(systemctl is-enabled $DM 2>/dev/null)"

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
