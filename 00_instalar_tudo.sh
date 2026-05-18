#!/usr/bin/env bash
# =============================================================================
# INSTALADOR COMPLETO - Todos os Ambientes de Desktop + Display Managers
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

# LightDM + greeter
info "Instalando LightDM..."
DEBIAN_FRONTEND=noninteractive apt-get install -y \
    lightdm \
    lightdm-gtk-greeter \
    lightdm-gtk-greeter-settings || warn "LightDM falhou ou já instalado."

# SDDM (Simple Desktop Display Manager)
info "Instalando SDDM..."
DEBIAN_FRONTEND=noninteractive apt-get install -y \
    sddm \
    qml-module-qtquick2 \
    qml-module-qtquick-controls || warn "SDDM falhou ou já instalado."

# LXDM
info "Instalando LXDM..."
DEBIAN_FRONTEND=noninteractive apt-get install -y lxdm || warn "LXDM falhou ou já instalado."

log "Display Managers instalados."

# =============================================================================
# AMBIENTES DE DESKTOP
# =============================================================================

info "=== Instalando Ambientes de Desktop ==="

# --- GNOME ---
info "Instalando GNOME..."
DEBIAN_FRONTEND=noninteractive apt-get install -y \
    gnome-shell \
    gnome-session \
    gnome-terminal \
    gnome-control-center \
    gnome-tweaks \
    nautilus \
    gdm3 || warn "GNOME falhou parcialmente."
log "GNOME instalado."

# --- KDE Plasma ---
info "Instalando KDE Plasma..."
DEBIAN_FRONTEND=noninteractive apt-get install -y \
    kde-plasma-desktop \
    plasma-workspace \
    plasma-nm \
    plasma-pa \
    konsole \
    dolphin \
    sddm || warn "KDE Plasma falhou parcialmente."
log "KDE Plasma instalado."

# --- XFCE ---
info "Instalando XFCE..."
DEBIAN_FRONTEND=noninteractive apt-get install -y \
    xfce4 \
    xfce4-goodies \
    xfce4-terminal \
    xfce4-power-manager \
    xfce4-notifyd \
    thunar \
    lightdm || warn "XFCE falhou parcialmente."
log "XFCE instalado."

# --- LXQt ---
info "Instalando LXQt..."
DEBIAN_FRONTEND=noninteractive apt-get install -y \
    lxqt \
    lxqt-core \
    lxqt-panel \
    lxqt-session \
    qterminal \
    pcmanfm-qt \
    openbox \
    sddm || warn "LXQt falhou parcialmente."
log "LXQt instalado."

# --- Cinnamon ---
info "Instalando Cinnamon..."
DEBIAN_FRONTEND=noninteractive apt-get install -y \
    cinnamon \
    cinnamon-core \
    cinnamon-control-center \
    nemo \
    lightdm || warn "Cinnamon falhou parcialmente."
log "Cinnamon instalado."

# --- MATE ---
info "Instalando MATE..."
DEBIAN_FRONTEND=noninteractive apt-get install -y \
    mate-desktop-environment \
    mate-terminal \
    caja \
    lightdm || warn "MATE falhou parcialmente."
log "MATE instalado."

# --- Budgie ---
info "Instalando Budgie..."
DEBIAN_FRONTEND=noninteractive apt-get install -y \
    budgie-desktop \
    budgie-indicator-applet \
    lightdm || warn "Budgie falhou parcialmente (pode não estar disponível nesta distro)."
log "Budgie instalado."

# --- i3 (Tiling Window Manager) ---
info "Instalando i3..."
DEBIAN_FRONTEND=noninteractive apt-get install -y \
    i3 \
    i3status \
    i3lock \
    dmenu \
    rxvt-unicode \
    lightdm || warn "i3 falhou parcialmente."
log "i3 instalado."

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
echo "  • sudo bash 04_usar_lxqt.sh"
echo "  • sudo bash 05_usar_cinnamon.sh"
echo "  • sudo bash 06_usar_mate.sh"
echo "  • sudo bash 07_usar_budgie.sh"
echo "  • sudo bash 08_usar_i3.sh"
echo "  • sudo bash 09_usar_gdm.sh   (só DM)"
echo "  • sudo bash 10_usar_lightdm.sh (só DM)"
echo "  • sudo bash 11_usar_sddm.sh  (só DM)"