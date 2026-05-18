# Alternar Interfaces

Um conjunto de scripts automatizados para alternar rapidamente entre diferentes Ambientes de Desktop (Desktop Environments - DE) e Gerenciadores de Tela (Display Managers - DM) em sistemas Linux.

## ⚠️ Aviso Importante

A execução de qualquer um destes scripts irá **encerrar imediatamente a sua sessão gráfica atual**. Todos os aplicativos abertos serão fechados sem salvar. Salve todo o seu trabalho antes de executar qualquer script.

## 📋 Pré-requisitos

1.  **Acesso Root:** Todos os scripts precisam de privilégios de administrador (root) para reconfigurar os serviços do sistema e o gerenciador de exibição padrão.
2.  **Pacotes Instalados:** Você precisa ter o Ambiente de Desktop e o Gerenciador de Tela desejados já instalados no sistema antes de tentar alternar para eles.

## 🚀 Como Usar

Para alternar para um ambiente específico, abra o terminal e execute o script correspondente com privilégios `sudo`.

Por exemplo, para usar o GNOME com o GDM3:

```bash
sudo bash 01_usar_gnome.sh
```

## 📜 Scripts Disponíveis

### Ambientes de Desktop (DE) e Gerenciadores de Janela (WM)
*   `01_usar_gnome.sh` - Configura o ambiente GNOME com o GDM3.
*   `02_usar_kde.sh` - Configura o ambiente KDE Plasma.
*   `03_usar_xfce.sh` - Configura o ambiente XFCE.
*   `04_usar_lxqt.sh` - Configura o ambiente LXQt.
*   `05_usar_cinnamon.sh` - Configura o ambiente Cinnamon.
*   `06_usar_mate.sh` - Configura o ambiente MATE.
*   `07_usar_budgie.sh` - Configura o ambiente Budgie.
*   `08_usar_i3.sh` - Configura o gerenciador de janelas i3.

### Gerenciadores de Tela (DM)
Caso queira apenas alterar o gerenciador de tela mantendo as sessões disponíveis:
*   `09_usar_gdm.sh` - Define o GDM (GNOME Display Manager) como padrão.
*   `10_usar_lightdm.sh` - Define o LightDM como padrão.
*   `11_usar_sddm.sh` - Define o SDDM como padrão.

## ⚙️ O que os scripts fazem internamente?

1.  Verificam se os binários do gerenciador de tela e a sessão gráfica estão instalados.
2.  Encerram todos os serviços de gerenciadores de tela em execução (`gdm`, `lightdm`, `sddm`, etc.) e forçam a parada do Xorg.
3.  Registram o gerenciador de tela escolhido em `/etc/X11/default-display-manager` e reconfiguram o pacote no `dpkg`.
4.  Ajustam as configurações padrão do usuário em `~/.dmrc`.
5.  Iniciam automaticamente o novo serviço do gerenciador de tela.
