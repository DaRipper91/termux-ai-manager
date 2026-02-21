#!/usr/bin/env bash
# Fish Shell Installer - Termux & CachyOS/Arch
# Version: 1.0.1
# License: MIT

set -e

# Configuration
VERSION="1.0.1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# ASCII Art Logo
print_logo() {
    echo -e "${CYAN}"
    cat << 'EOF'
                 ___
          ___   /   \
         /   \ |     |
        |     ||     |
        |  O  ||  O  |
        |     ||     |
         \___/  \___/
          | |    | |
          |_|    |_|
         FISH  INSTALLER
EOF
    echo -e "${NC}"
}

# Themed Header
print_themed_header() {
    local title="$1"
    local width=48
    local title_len=${#title}
    local left_pad=$(( (width - title_len) / 2 ))
    local right_pad=$(( width - title_len - left_pad ))

    echo -e "${MAGENTA}"
    echo "+--------------------------------------------------+"
    echo "|                                                  |"
    printf "| %${left_pad}s${WHITE}${BOLD}%s${NC}${MAGENTA}%${right_pad}s |\n" "" "$title" ""
    echo "|                                                  |"
    echo "+--------------------------------------------------+"
    echo -e "${NC}"
}

# Themed Footer
print_themed_footer() {
    echo -e "${MAGENTA}"
    echo "+--------------------------------------------------+"
    echo -e "|  ${DIM}${WHITE}Powered by Fish Installer v${VERSION}${NC}${MAGENTA}                |"
    echo -e "|  ${DIM}${WHITE}(c) 2025 Fish Team${NC}${MAGENTA}                           |"
    echo "+--------------------------------------------------+"
    echo -e "${NC}"
}

# Divider
print_divider() {
    echo -e "${DIM}${CYAN}---------------------------------------------------${NC}"
}

# Section
print_section() {
    local title="$1"
    echo -e "\n${YELLOW}[ ${WHITE}${BOLD}$title${NC}${YELLOW} ]${NC}"
    echo -e "${DIM}${CYAN}..................................................${NC}"
}

# Helpers
print_success() { echo -e "${GREEN}[+]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[!]${NC} $1"; }
print_error() { echo -e "${RED}[-]${NC} $1"; }
print_info() { echo -e "${BLUE}[*]${NC} $1"; }

command_exists() { command -v "$1" &> /dev/null; }

is_termux() {
    if [[ -n "$PREFIX" && "$PREFIX" == *"/com.termux/"* ]]; then
        return 0
    fi
    if [[ "$(uname -o 2>/dev/null)" == "Android" ]]; then
        return 0
    fi
    return 1
}

is_arch() {
    if command_exists pacman && [ -f /etc/arch-release ]; then
        return 0
    fi
    if [ -f /etc/os-release ]; then
        grep -qE "^ID(_LIKE)?=.*arch" /etc/os-release && return 0
    fi
    return 1
}

install_termux_fish() {
    print_themed_header "Termux Fish Installation"

    if ! is_termux; then
        print_error "Not running in Termux environment!"
        return 1
    fi

    print_section "Updating Packages"
    pkg update -y || apt update
    pkg upgrade -y || apt upgrade -y

    print_section "Installing Fish"
    if command_exists pkg; then
        pkg install -y fish
    elif command_exists apt; then
        apt install -y fish
    else
        print_error "No package manager found!"
        return 1
    fi

    if ! command_exists fish; then
        print_error "Fish installation failed!"
        return 1
    fi
    print_success "Fish installed successfully!"

    print_section "Setting Default Shell"
    chsh -s fish

    print_divider
    echo -e "\n${GREEN}██ Termux Fish setup complete!${NC}"
    echo -e "Please restart Termux to start using Fish."
}

install_cachyos_fish() {
    print_themed_header "CachyOS / Arch Fish Installation"

    if ! is_arch; then
        print_warning "System does not appear to be Arch-based."
        echo -n "Continue anyway? [y/N]: "
        read -r choice
        if [[ ! "$choice" =~ ^[Yy]$ ]]; then
            print_info "Aborting installation."
            return 0
        fi
    fi

    print_section "Updating System & Installing Fish/Starship"
    # Full system upgrade (-Syu) and install packages in one go to prevent partial upgrades
    if ! sudo pacman -Syu --noconfirm fish starship; then
        print_error "Failed to update system or install packages!"
        return 1
    fi
    print_success "Fish and Starship installed!"

    print_section "Configuring CachyOS Style Prompt"
    mkdir -p ~/.config/fish
    local config_file="$HOME/.config/fish/config.fish"

    if [ -f "$config_file" ] && grep -q "starship init fish" "$config_file"; then
        print_info "Starship already configured in $config_file"
    else
        echo "" >> "$config_file"
        echo "# Initialize Starship prompt (CachyOS style)" >> "$config_file"
        echo "starship init fish | source" >> "$config_file"
        print_success "Added Starship init to $config_file"
    fi

    print_section "Setting Default Shell"
    local current_user
    current_user=$(whoami)
    if sudo chsh -s /usr/bin/fish "$current_user"; then
        print_success "Default shell set to Fish for user $current_user!"
    else
        print_error "Failed to set default shell. You may need to do it manually: chsh -s /usr/bin/fish"
    fi

    print_divider
    echo -e "\n${GREEN}██ CachyOS Fish setup complete!${NC}"
    echo -e "Please log out and log back in for changes to take effect."
}

show_menu() {
    clear
    print_logo
    print_themed_header "FISH INSTALLER"
    echo ""
    echo -e "  ${CYAN}[${WHITE}1${CYAN}]${NC} ${WHITE}Termux Environment${NC} (Standard Termux Config)"
    echo -e "  ${CYAN}[${WHITE}2${CYAN}]${NC} ${WHITE}CachyOS / Arch Environment${NC} (Fish + Starship Prompt)"
    echo -e "  ${RED}[${WHITE}0${RED}]${NC} ${WHITE}Exit${NC}"
    echo ""
    print_themed_footer
    echo ""
    echo -ne "${YELLOW}Select an option ${CYAN}>> ${NC}"
}

main() {
    while true; do
        show_menu
        read -r choice
        echo ""
        case ${choice} in
            1) install_termux_fish ;;
            2) install_cachyos_fish ;;
            0)
                clear
                print_logo
                echo -e "${YELLOW}Thanks for using Fish Installer!${NC}"
                exit 0
                ;;
            *) print_error "Invalid option" ;;
        esac
        echo ""
        echo -ne "${DIM}Press ${WHITE}Enter${NC}${DIM} to continue...${NC}"
        read -r
    done
}

main "$@"
