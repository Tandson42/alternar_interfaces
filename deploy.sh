#!/bin/bash

# Verifica se o script está sendo executado como root (sudo)
if [[ "$EUID" -ne 0 ]]; then
    echo "Por favor, execute este script como root: sudo ./deploy.sh"
    exit 1
fi

INSTALL_DIR="/opt/alternar_interfaces"
BIN_CMD="/usr/local/bin/interfaces"

echo "⚙️  Instalando os scripts em $INSTALL_DIR..."
mkdir -p "$INSTALL_DIR"
cp *.sh "$INSTALL_DIR/"

# Dar permissão de execução para todos os scripts copiados
chmod +x "$INSTALL_DIR"/*.sh

echo "🔗 Criando o comando global 'interfaces'..."
cat << 'EOF' > "$BIN_CMD"
#!/bin/bash

# Verifica se está rodando como root, se não, re-executa com sudo
if [[ "$EUID" -ne 0 ]]; then
    exec sudo "$0" "$@"
fi

# Navega para o diretório de instalação
cd /opt/alternar_interfaces || exit 1

# Trata o parâmetro recebido
SCRIPT="menu.sh"
if [[ -n "$1" ]]; then
    case "$1" in
        gdm)  SCRIPT="01_usar_gnome.sh" ;;
        kde)  SCRIPT="02_usar_kde.sh" ;;
        xfce) SCRIPT="03_usar_xfce.sh" ;;
        *)
            echo "Parâmetro inválido: $1"
            echo "Uso opcional: interfaces [gdm|kde|xfce]"
            exit 1
            ;;
    esac
fi

# Se detectarmos que estamos numa interface gráfica (GUI) e rodando de um terminal interativo (TTY), forçamos a execução num VT
if [[ (-n "$DISPLAY" || -n "$WAYLAND_DISPLAY") && -t 1 ]]; then
    echo "Ambiente gráfico detectado. Mudando para o modo texto (TTY) para execução segura..."
    sleep 2
    # openvt cria o terminal. Adicionamos um sleep para dar tempo da placa de vídeo
    # completar a transição de tela do GDM para o TTY antes de rodar o script.
    exec openvt -s -w -- bash -c "sleep 1.5; clear; bash $SCRIPT"
else
    # Já estamos no modo texto, SSH ou rodando via daemon (Epoptes), só rodar o script
    exec bash "$SCRIPT"
fi
EOF

# Dá permissão de execução para o comando global
chmod +x "$BIN_CMD"

echo "✅ Instalação concluída com sucesso!"
echo "🎉 Agora você pode digitar 'interfaces' (ou 'sudo interfaces') em qualquer lugar do terminal para alternar seus ambientes gráficos."
