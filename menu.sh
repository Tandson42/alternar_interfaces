#!/usr/bin/env bash

# Ocultar o cursor
tput civis
# Restaurar o cursor na saída
trap 'tput cnorm; exit' SIGINT SIGTERM EXIT

# Definindo cores e estilos
FG_WHITE='\033[97m'
FG_GREEN='\033[92m'
FG_CYAN='\033[96m'
FG_RED='\033[91m'
FG_YELLOW='\033[93m'
BG_CYAN='\033[46m'
BOLD='\033[1m'
RESET='\033[0m'

options=("XFCE" "GNOME (GDM)" "KDE" "Sair")
scripts=("./03_usar_xfce.sh" "./01_usar_gnome.sh" "./02_usar_kde.sh" "")

selected=0

function draw_menu() {
    clear
    echo -e "\n"
    echo -e "    ${FG_CYAN}╭──────────────────────────────────────────╮${RESET}"
    echo -e "    ${FG_CYAN}│${RESET} ${BOLD}${FG_WHITE}   🌟  ESCOLHA SEU AMBIENTE GRÁFICO   🌟 ${RESET}${FG_CYAN}│${RESET}"
    echo -e "    ${FG_CYAN}├──────────────────────────────────────────┤${RESET}"
    echo -e "    ${FG_CYAN}│${RESET}                                          ${FG_CYAN}│${RESET}"

    for i in "${!options[@]}"; do
        if [[ $i -eq $selected ]]; then
            # Para alinhamento de texto fixo com padding
            printf "    ${FG_CYAN}│${RESET} ${BOLD}${FG_YELLOW}  ➜  ${BG_CYAN}${FG_WHITE}%-33s${RESET}${FG_CYAN}   │${RESET}\n" "${options[$i]}"
        else
            printf "    ${FG_CYAN}│${RESET}      ${FG_WHITE}%-33s${RESET}${FG_CYAN}   │${RESET}\n" "${options[$i]}"
        fi
    done

    echo -e "    ${FG_CYAN}│${RESET}                                          ${FG_CYAN}│${RESET}"
    echo -e "    ${FG_CYAN}╰──────────────────────────────────────────╯${RESET}"
    echo -e "\n    ${FG_YELLOW}Use as setas (↑/↓) para mover e ENTER para escolher.${RESET}\n"
}

while true; do
    draw_menu
    
    # Ler 1 caractere silenciosamente
    read -rsn1 key
    case "$key" in
        $'\x1b') # Início de escape sequence (Setas)
            read -rsn2 -t 0.1 seq
            case "$seq" in
                "[A") # Cima
                    ((selected--))
                    if [[ $selected -lt 0 ]]; then
                        selected=$((${#options[@]} - 1))
                    fi
                    ;;
                "[B") # Baixo
                    ((selected++))
                    if [[ $selected -ge ${#options[@]} ]]; then
                        selected=0
                    fi
                    ;;
            esac
            ;;
        "") # ENTER pressionado
            break
            ;;
    esac
done

# Restaura o cursor antes de executar as opções
tput cnorm
clear

echo -e "\n    ${FG_CYAN}Você selecionou: ${BOLD}${FG_WHITE}${options[$selected]}${RESET}\n"

if [[ ${options[$selected]} == "Sair" ]]; then
    echo -e "    ${FG_YELLOW}Até logo!${RESET}\n"
    exit 0
fi

script_to_run="${scripts[$selected]}"

if [[ -f "$script_to_run" ]]; then
    echo -e "    ${FG_GREEN}Executando o script...${RESET}\n"
    sudo bash "$script_to_run"
else
    echo -e "    ${FG_RED}Erro: Arquivo $script_to_run não encontrado.${RESET}\n"
fi
