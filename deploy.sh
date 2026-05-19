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

# Navega para o diretório de instalação e executa o menu
cd /opt/alternar_interfaces || exit 1
./menu.sh
EOF

# Dá permissão de execução para o comando global
chmod +x "$BIN_CMD"

echo "✅ Instalação concluída com sucesso!"
echo "🎉 Agora você pode digitar 'interfaces' (ou 'sudo interfaces') em qualquer lugar do terminal para alternar seus ambientes gráficos."
