# Alternar Interfaces

Um conjunto de scripts automatizados para instalar e alternar rapidamente entre diferentes Ambientes de Desktop (Desktop Environments - DE) e Gerenciadores de Tela (Display Managers - DM) em sistemas Linux.

## ⚠️ Aviso Importante

A execução de qualquer um dos scripts de troca irá **encerrar imediatamente a sua sessão gráfica atual**. Todos os aplicativos abertos serão fechados sem salvar. Salve todo o seu trabalho antes de executar qualquer mudança de ambiente.

## 📋 Pré-requisitos

1.  **Acesso Root:** Todos os scripts precisam de privilégios de administrador (root) para reconfigurar os serviços do sistema e instalar pacotes.
2.  **Sistema Compatível:** O instalador suporta distribuições baseadas em Debian/Ubuntu.

## 🚀 Como Usar

### 1. Instalação
Se você ainda não possui os ambientes gráficos instalados, execute o script de instalação principal, que fará o download e configuração do GDM, KDE e XFCE:

```bash
sudo bash 00_instalar_tudo.sh
```

### 2. Menu Interativo (Recomendado)

A forma mais fácil e elegante de alterar as interfaces é através do menu interativo no terminal:

```bash
sudo bash menu.sh
```

Utilize as setas direcionais (↑/↓) do teclado para escolher o ambiente desejado e pressione `ENTER`.

### 3. Scripts Disponíveis (Modo Manual)

Caso queira chamar o script de troca diretamente, basta executar:

*   `01_usar_gnome.sh` - Configura a sessão para o ambiente GNOME usando o GDM3.
*   `02_usar_kde.sh` - Configura a sessão para o ambiente KDE Plasma.
*   `03_usar_xfce.sh` - Configura a sessão para o ambiente XFCE.
*   `menu.sh` - Inicia o menu TUI para selecionar o ambiente a ser executado.

## ⚙️ O que os scripts de troca fazem internamente?

1.  Verificam se os binários necessários e as sessões gráficas já estão presentes no sistema.
2.  Encerram os serviços do gerenciador de tela em execução e forçam a parada do Xorg.
3.  Registram o gerenciador de tela escolhido em `/etc/X11/default-display-manager` e executam as reconfigurações do pacote (`dpkg`).
4.  Ajustam as configurações padrão do usuário (geralmente em `~/.dmrc`).
5.  Iniciam automaticamente o serviço do novo ambiente gráfico.
