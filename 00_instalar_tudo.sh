#!/usr/bin/env bash
# =============================================================================
# INSTALADOR COMPLETO - XFCE, KDE e GDM
# Distribuições suportadas: Debian/Ubuntu e derivados
# Execute como: sudo bash 00_instalar_tudo.sh
# =============================================================================

set -euo pipefail

# --- Cores para output ---
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

log()  { echo -e "${GREEN}[OK]${NC} $*"; }
info() { echo -e "${CYAN}[INFO]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
die()  { echo -e "${RED}[ERRO]${NC} $*" >&2; exit 1; }

# --- Verificação de root ---
[[ $EUID -eq 0 ]] || die "Execute como root: sudo bash $0"

# --- Detectar distro ---
if [[ -f /etc/os-release ]]; then
    source /etc/os-release
    DISTRO_ID="${ID:-unknown}"
    DISTRO_LIKE="${ID_LIKE:-}"
else
    die "Não foi possível detectar a distribuição."
fi

is_debian_based() {
    [[ "$DISTRO_ID" == "debian" || "$DISTRO_ID" == "ubuntu" || \
       "$DISTRO_LIKE" == *"debian"* || "$DISTRO_LIKE" == *"ubuntu"* ]]
}

is_debian_based || die "Este script suporta apenas Debian/Ubuntu e derivados."

info "Distribuição detectada: $PRETTY_NAME"

# --- Atualizar repositórios ---
info "Atualizando lista de pacotes..."
apt-get update -qq

# --- Dependências comuns ---
info "Instalando dependências base..."
apt-get install -y --no-install-recommends \
    apt-utils \
    software-properties-common \
    dbus \
    dbus-x11 \
    x11-xserver-utils \
    xorg \
    xinit \
    xauth \
    libpam-systemd \
    policykit-1 \
    accountsservice \
    network-manager \
    pulseaudio \
    alsa-utils \
    fonts-noto \
    fonts-liberation \
    wget curl git

log "Dependências base instaladas."

# =============================================================================
# DISPLAY MANAGERS
# =============================================================================

info "=== Instalando Display Managers ==="

# GDM3 (GNOME Display Manager)
info "Instalando GDM3..."
DEBIAN_FRONTEND=noninteractive apt-get install -y gdm3 || warn "GDM3 falhou ou já instalado."

log "Display Managers instalados."

# =============================================================================
# AMBIENTES DE DESKTOP
# =============================================================================

info "=== Instalando Ambientes de Desktop ==="

# --- KDE Plasma ---
info "Instalando KDE Plasma..."
DEBIAN_FRONTEND=noninteractive apt-get install -y \
    kde-plasma-desktop \
    plasma-workspace \
    plasma-nm \
    plasma-pa \
    konsole \
    dolphin || warn "KDE Plasma falhou parcialmente."
log "KDE Plasma instalado."

# --- XFCE ---
info "Instalando XFCE..."
DEBIAN_FRONTEND=noninteractive apt-get install -y \
    xfce4 \
    xfce4-goodies \
    xfce4-terminal \
    xfce4-power-manager \
    xfce4-notifyd \
    thunar || warn "XFCE falhou parcialmente."
log "XFCE instalado."

# =============================================================================
# LIMPEZA
# =============================================================================

info "Limpando pacotes desnecessários..."
apt-get autoremove -y -qq
apt-get autoclean -qq

log "=============================================="
log "Instalação concluída!"
log "Use os scripts de troca para mudar de ambiente."
log "=============================================="
echo ""
echo -e "${BOLD}Ambientes disponíveis:${NC}"
echo "  • sudo bash 01_usar_gnome.sh"
echo "  • sudo bash 02_usar_kde.sh"
echo "  • sudo bash 03_usar_xfce.sh"