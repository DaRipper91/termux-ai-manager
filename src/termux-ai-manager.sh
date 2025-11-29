#!/data/data/com.termux/files/usr/bin/bash
# Termux AI Manager - An AI-powered system maintenance tool for Termux
# Version: 1.0.0
# License: MIT
#
# Credits:
#   - Termux Project (https://github.com/termux/termux-tools) - GPL-3.0 License
#     System information and backup concepts inspired by termux-info and termux-backup scripts
#     Copyright (c) 2016-2024 Termux
#   - laraib07/TermuxBackupTools (https://github.com/laraib07/TermuxBackupTools) - MIT License
#     Backup/restore functionality concepts
#   - Termux Community - Various system maintenance patterns and best practices

set -e

# Configuration
VERSION="1.0.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REQUIREMENTS_FILE="${SCRIPT_DIR}/../requirements.txt"
CONFIG_DIR="${HOME}/.config/termux-ai-manager"
LOG_FILE="${CONFIG_DIR}/maintenance.log"
AI_SUGGESTIONS_FILE="${CONFIG_DIR}/ai_suggestions.json"
ASCII_SETUP_MARKER="${CONFIG_DIR}/.ascii_setup_done"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m' # No Color

# ASCII Art Logo - Android themed
print_logo() {
    echo -e "${GREEN}"
    cat << 'EOF'
                    ╭───────────╮
                   ╱             ╲
         ╭───╮   │  ●       ●  │   ╭───╮
          ╲  │   │             │   │  ╱
           ╲─╯    ╲           ╱    ╰─╱
                   ╰─────────╯
                 ┌─────────────┐
                 │             │
                 │   TERMUX    │
                 │  AI MANAGER │
                 │             │
                 └──┬───────┬──┘
                    │       │
                    │       │
                   ─┴─     ─┴─
EOF
    echo -e "${NC}"
}

# Print themed header with box design
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

# Print themed footer
print_themed_footer() {
    echo -e "${MAGENTA}"
    echo "+--------------------------------------------------+"
    echo -e "|  ${DIM}${WHITE}Powered by Termux AI Manager v${VERSION}${NC}${MAGENTA}             |"
    echo -e "|  ${DIM}${WHITE}(c) 2025 B.Rooster <DaRipper>${NC}${MAGENTA}                  |"
    echo "+--------------------------------------------------+"
    echo -e "${NC}"
}

# Print section divider
print_divider() {
    echo -e "${DIM}${CYAN}---------------------------------------------------${NC}"
}

# Print mini header for subsections
print_section() {
    local title="$1"
    echo -e "\n${YELLOW}[ ${WHITE}${BOLD}$title${NC}${YELLOW} ]${NC}"
    echo -e "${DIM}${CYAN}..................................................${NC}"
}

# Splash screen with loading animation
show_splash_screen() {
    clear
    echo -e "${GREEN}"
    cat << 'EOF'
    +----------------------------------------------------------+
    |                                                          |
    |                    ╭───────────╮                         |
    |                   ╱             ╲                        |
    |         ╭───╮   │  ●       ●  │   ╭───╮                  |
    |          ╲  │   │             │   │  ╱                   |
    |           ╲─╯    ╲           ╱    ╰─╱                    |
    |                   ╰─────────╯                            |
    |                 ┌─────────────┐                          |
    |                 │   TERMUX    │                          |
    |                 │ ╔═══════════╗│                         |
    |                 │ ║ AI MANAGER║│                         |
    |                 │ ╚═══════════╝│                         |
    |                 └──┬───────┬──┘                          |
    |                    │       │                             |
    |                   ─┴─     ─┴─                            |
    |                                                          |
    +----------------------------------------------------------+
EOF
    echo -e "${NC}"
    
    echo -e "${DIM}${WHITE}              AI-Powered System Maintenance Tool${NC}"
    echo -e "${DIM}${CYAN}                       Version ${VERSION}${NC}"
    echo ""
    echo -e "${YELLOW}               (c) 2025 B.Rooster <DaRipper>${NC}"
    echo ""
    
    # Quick loading animation (reduced delays)
    echo -ne "${GREEN}                     Loading "
    for i in {1..5}; do
        echo -ne "█"
        sleep 0.1
    done
    for i in {1..5}; do
        echo -ne "░"
        sleep 0.05
    done
    echo -e " ${GREEN}Done!${NC}"
    echo ""
    
    sleep 0.2
}

# Package to command mapping (package_name:command_name)
# Some packages provide commands with different names
declare -A PACKAGE_COMMANDS=(
    ["nala"]="nala"
    ["bc"]="bc"
    ["coreutils"]="ls"
    ["ncurses-utils"]="clear"
    ["procps"]="ps"
    ["findutils"]="find"
    ["grep"]="grep"
    ["sed"]="sed"
    ["gawk"]="awk"
)

# Initialize configuration directory
init_config() {
    mkdir -p "${CONFIG_DIR}"
    touch "${LOG_FILE}"
}

# Check and setup ASCII support packages (runs only once after install)
check_ascii_support() {
    # If already set up, skip
    if [ -f "${ASCII_SETUP_MARKER}" ]; then
        return 0
    fi
    
    # Packages needed for proper ASCII/Unicode display
    local ascii_packages=("ncurses-utils" "coreutils")
    local missing_ascii=()
    
    for pkg in "${ascii_packages[@]}"; do
        local cmd_to_check="${PACKAGE_COMMANDS[$pkg]:-$pkg}"
        if ! command -v "$cmd_to_check" &> /dev/null; then
            missing_ascii+=("$pkg")
        fi
    done
    
    # If all ASCII packages are installed, mark as done
    if [ ${#missing_ascii[@]} -eq 0 ]; then
        touch "${ASCII_SETUP_MARKER}"
        return 0
    fi
    
    # Display ASCII setup prompt
    clear
    echo -e "${GREEN}"
    cat << 'EOF'
    +----------------------------------------------------------+
    |                                                          |
    |              ASCII SUPPORT SETUP REQUIRED                |
    |                                                          |
    +----------------------------------------------------------+
EOF
    echo -e "${NC}"
    
    echo -e "${YELLOW}This tool requires the following packages for proper display:${NC}"
    echo ""
    for pkg in "${missing_ascii[@]}"; do
        echo -e "  ${CYAN}•${NC} ${pkg}"
    done
    echo ""
    echo -e "${WHITE}These packages enable ASCII art and terminal features.${NC}"
    echo ""
    echo -ne "${YELLOW}Would you like to install them now? [y/N]: ${NC}"
    read -r response
    
    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo ""
        for pkg in "${missing_ascii[@]}"; do
            echo -ne "${BLUE}[*]${NC} Installing ${pkg}... "
            if command -v pkg &> /dev/null; then
                pkg install -y "$pkg" &> /dev/null && echo -e "${GREEN}Done${NC}" || echo -e "${RED}Failed${NC}"
            elif command -v apt &> /dev/null; then
                apt install -y "$pkg" &> /dev/null && echo -e "${GREEN}Done${NC}" || echo -e "${RED}Failed${NC}"
            fi
        done
        
        # Mark as done so we don't ask again
        touch "${ASCII_SETUP_MARKER}"
        echo ""
        echo -e "${GREEN}[+] ASCII support setup complete!${NC}"
        sleep 1
        return 0
    else
        # User denied - exit with message
        echo ""
        echo -e "${RED}"
        cat << 'EOF'
    +----------------------------------------------------------+
    |                                                          |
    |   ╔═══════════════════════════════════════════════════╗  |
    |   ║                                                   ║  |
    |   ║   Sorry, but... No.                               ║  |
    |   ║                                                   ║  |
    |   ║   This tool requires ASCII support packages       ║  |
    |   ║   to function properly. Without them, the         ║  |
    |   ║   interface will not display correctly.           ║  |
    |   ║                                                   ║  |
    |   ║   Please run the script again and accept the      ║  |
    |   ║   package installation to continue.               ║  |
    |   ║                                                   ║  |
    |   ╚═══════════════════════════════════════════════════╝  |
    |                                                          |
    +----------------------------------------------------------+
EOF
        echo -e "${NC}"
        exit 1
    fi
}

# Check and install requirements from requirements.txt
check_requirements() {
    if [ ! -f "${REQUIREMENTS_FILE}" ]; then
        # Try alternative location (installed in PREFIX)
        if [ -f "${PREFIX}/share/termux-ai-manager/requirements.txt" ]; then
            REQUIREMENTS_FILE="${PREFIX}/share/termux-ai-manager/requirements.txt"
        else
            print_warning "Requirements file not found, skipping dependency check"
            return 0
        fi
    fi
    
    print_info "Checking requirements from ${REQUIREMENTS_FILE}..."
    
    local missing_packages=()
    
    while IFS= read -r line || [ -n "$line" ]; do
        # Skip comments and empty lines
        [[ "$line" =~ ^#.*$ ]] && continue
        [[ -z "$line" ]] && continue
        
        # Trim whitespace
        local package
        package=$(echo "$line" | tr -d '[:space:]')
        
        # Get the command to check for this package
        local cmd_to_check="${PACKAGE_COMMANDS[$package]:-$package}"
        
        # Check if the command provided by the package is available
        if ! command -v "$cmd_to_check" &> /dev/null; then
            missing_packages+=("$package")
        fi
    done < "${REQUIREMENTS_FILE}"
    
    if [ ${#missing_packages[@]} -gt 0 ]; then
        print_warning "Missing required packages: ${missing_packages[*]}"
        echo ""
        echo -n "Would you like to install them now? [y/N]: "
        read -r response
        
        if [[ "$response" =~ ^[Yy]$ ]]; then
            install_requirements "${missing_packages[@]}"
        else
            print_error "Required packages not installed. Some features may not work."
            return 1
        fi
    else
        print_success "All requirements satisfied"
    fi
    
    return 0
}

# Install required packages using apt (to bootstrap nala if needed)
install_requirements() {
    local packages=("$@")
    
    print_info "Installing required packages..."
    
    for package in "${packages[@]}"; do
        print_info "Installing ${package}..."
        
        # Use apt to install packages (including nala itself)
        if command -v apt &> /dev/null; then
            apt install -y "$package" 2>/dev/null && print_success "Installed ${package}" || print_error "Failed to install ${package}"
        elif command -v pkg &> /dev/null; then
            pkg install -y "$package" 2>/dev/null && print_success "Installed ${package}" || print_error "Failed to install ${package}"
        else
            print_error "No package manager available to install ${package}"
        fi
    done
}

# Logging function
log() {
    local level="$1"
    local message="$2"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[${timestamp}] [${level}] ${message}" >> "${LOG_FILE}"
}

# Print colored output
print_info() {
    echo -e "${BLUE}[*]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[+]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[-]${NC} $1"
}

print_header() {
    print_themed_header "$1"
}

# Get system information
get_system_info() {
    print_header "System Information"
    
    # Device info
    print_section "Device"
    if command -v getprop &> /dev/null; then
        echo -e "  ${CYAN}Model:${NC}   $(getprop ro.product.model 2>/dev/null || echo 'Unknown')"
        echo -e "  ${CYAN}Android:${NC} $(getprop ro.build.version.release 2>/dev/null || echo 'Unknown')"
    else
        echo -e "  ${CYAN}System:${NC}  Non-Android environment"
        echo -e "  ${CYAN}OS:${NC}      $(uname -s) $(uname -r)"
    fi
    
    # CPU info
    print_section "CPU"
    if [ -f /proc/cpuinfo ]; then
        local cpu_model
        cpu_model=$(grep -m1 'model name\|Hardware' /proc/cpuinfo | cut -d: -f2 | sed 's/^[ \t]*//' || echo "Unknown")
        local cpu_cores
        cpu_cores=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || echo "Unknown")
        echo -e "  ${CYAN}Model:${NC}   ${cpu_model:-Unknown}"
        echo -e "  ${CYAN}Cores:${NC}   ${cpu_cores}"
    fi
    
    # Memory info
    print_section "Memory"
    if [ -f /proc/meminfo ]; then
        local total_mem
        total_mem=$(grep MemTotal /proc/meminfo | awk '{printf "%.2f GB", $2/1024/1024}')
        local free_mem
        free_mem=$(grep MemAvailable /proc/meminfo | awk '{printf "%.2f GB", $2/1024/1024}')
        local used_mem
        used_mem=$(awk '/MemTotal/{t=$2}/MemAvailable/{a=$2}END{printf "%.2f GB", (t-a)/1024/1024}' /proc/meminfo)
        echo -e "  ${CYAN}Total:${NC}     ${total_mem}"
        echo -e "  ${CYAN}Used:${NC}      ${used_mem}"
        echo -e "  ${CYAN}Available:${NC} ${free_mem}"
    fi
    
    # Storage info
    print_section "Storage"
    df -h "${HOME}" 2>/dev/null | tail -1 | awk -v cyan="\033[0;36m" -v nc="\033[0m" '{print "  " cyan "Used:" nc "      " $3 " / " $2 " (" $5 " used)"}'
    
    print_divider
    log "INFO" "System information retrieved"
}

# Monitor system resources
monitor_resources() {
    print_header "Resource Monitor"
    
    # CPU usage
    print_section "CPU Usage"
    if [ -f /proc/stat ]; then
        local cpu_idle
        cpu_idle=$(awk '/^cpu /{print $5}' /proc/stat)
        local cpu_total
        cpu_total=$(awk '/^cpu /{print $2+$3+$4+$5+$6+$7+$8}' /proc/stat)
        sleep 1
        local cpu_idle2
        cpu_idle2=$(awk '/^cpu /{print $5}' /proc/stat)
        local cpu_total2
        cpu_total2=$(awk '/^cpu /{print $2+$3+$4+$5+$6+$7+$8}' /proc/stat)
        local cpu_usage
        cpu_usage=$(echo "scale=2; 100 - (($cpu_idle2 - $cpu_idle) * 100 / ($cpu_total2 - $cpu_total))" | bc 2>/dev/null || echo "N/A")
        echo -e "  ${CYAN}Current:${NC} ${cpu_usage}%"
    fi
    
    # Memory usage
    print_section "Memory Usage"
    if [ -f /proc/meminfo ]; then
        local mem_percent
        mem_percent=$(awk '/MemTotal/{t=$2}/MemAvailable/{a=$2}END{printf "%.1f", ((t-a)/t)*100}' /proc/meminfo)
        echo -e "  ${CYAN}Used:${NC} ${mem_percent}%"
        
        # Create visual bar with colors
        local bar_length=30
        local filled
        filled=$(printf "%.0f" "$(echo "${mem_percent} * ${bar_length} / 100" | bc)")
        local empty=$((bar_length - filled))
        printf "  ${MAGENTA}[${GREEN}"
        printf "%${filled}s" | tr ' ' '█'
        printf "${DIM}"
        printf "%${empty}s" | tr ' ' '░'
        printf "${NC}${MAGENTA}]${NC}\n"
    fi
    
    # Top processes
    print_section "Top Processes"
    if command -v ps &> /dev/null; then
        ps aux 2>/dev/null | head -6 || ps | head -6
    fi
    
    print_divider
    log "INFO" "Resource monitoring completed"
}

# Clean temporary files and cache
clean_system() {
    print_header "System Cleanup"
    
    local cleaned_size=0
    
    # Clean Termux cache
    print_section "Termux Cache"
    if [ -d "${PREFIX}/var/cache" ]; then
        local cache_size
        cache_size=$(du -sk "${PREFIX}/var/cache" 2>/dev/null | cut -f1)
        rm -rf "${PREFIX}/var/cache"/* 2>/dev/null
        mkdir -p "${PREFIX}/var/cache"
        cleaned_size=$((cleaned_size + cache_size))
        print_success "Cleaned package cache"
    fi
    
    # Clean apt cache if available
    if command -v apt &> /dev/null; then
        print_section "APT Cache"
        apt clean 2>/dev/null && print_success "Cleaned apt cache"
        apt autoclean 2>/dev/null && print_success "Cleaned old package files"
        apt autoremove -y 2>/dev/null && print_success "Removed unused packages"
    fi
    
    # Clean pip cache if available
    if command -v pip &> /dev/null; then
        print_section "Python Cache"
        pip cache purge 2>/dev/null && print_success "Cleaned pip cache"
    fi
    
    # Clean npm cache if available
    if command -v npm &> /dev/null; then
        print_section "NPM Cache"
        npm cache clean --force 2>/dev/null && print_success "Cleaned npm cache"
    fi
    
    # Clean temporary files
    print_section "Temporary Files"
    if [ -d "${TMPDIR:-/tmp}" ]; then
        find "${TMPDIR:-/tmp}" -type f -mtime +7 -delete 2>/dev/null
        print_success "Cleaned old temporary files"
    fi
    
    # Clean log files older than 30 days
    print_section "Log Files"
    if [ -d "${PREFIX}/var/log" ]; then
        find "${PREFIX}/var/log" -type f -name "*.log" -mtime +30 -delete 2>/dev/null
        print_success "Cleaned old log files"
    fi
    
    print_divider
    echo -e "\n${GREEN}██ Cleanup completed successfully!${NC}"
    log "INFO" "System cleanup completed"
}

# Update system packages
update_system() {
    print_header "System Update"
    
    if command -v pkg &> /dev/null; then
        print_section "Package Lists"
        pkg update -y 2>/dev/null
        print_success "Package lists updated"
        
        print_section "Upgrading Packages"
        pkg upgrade -y 2>/dev/null
        print_success "Packages upgraded"
    elif command -v apt &> /dev/null; then
        print_section "Package Lists"
        apt update 2>/dev/null
        print_success "Package lists updated"
        
        print_section "Upgrading Packages"
        apt upgrade -y 2>/dev/null
        print_success "Packages upgraded"
    else
        print_warning "No supported package manager found"
    fi
    
    print_divider
    echo -e "\n${GREEN}██ System update completed!${NC}"
    log "INFO" "System update completed"
}

# AI-powered diagnostics
ai_diagnostics() {
    print_header "AI Diagnostics"
    
    local issues_found=0
    local suggestions=()
    
    print_section "System Analysis"
    echo -e "  ${DIM}Scanning system for potential issues...${NC}\n"
    
    # Check memory usage
    if [ -f /proc/meminfo ]; then
        local mem_percent
        mem_percent=$(awk '/MemTotal/{t=$2}/MemAvailable/{a=$2}END{printf "%.0f", ((t-a)/t)*100}' /proc/meminfo)
        if [ "${mem_percent}" -gt 80 ]; then
            print_warning "High memory usage detected: ${mem_percent}%"
            suggestions+=("Consider closing unused applications or running 'termux-ai-manager clean' to free up memory")
            issues_found=$((issues_found + 1))
        else
            print_success "Memory usage is normal: ${mem_percent}%"
        fi
    fi
    
    # Check storage usage
    local storage_percent
    storage_percent=$(df -h "${HOME}" 2>/dev/null | tail -1 | awk '{gsub(/%/,""); print $5}')
    if [ -n "${storage_percent}" ] && [ "${storage_percent}" -gt 80 ]; then
        print_warning "High storage usage detected: ${storage_percent}%"
        suggestions+=("Run 'termux-ai-manager clean' to free up storage space")
        issues_found=$((issues_found + 1))
    else
        print_success "Storage usage is normal: ${storage_percent}%"
    fi
    
    # Check for package updates
    if command -v apt &> /dev/null; then
        local updates_count
        updates_count=$(apt list --upgradable 2>/dev/null | grep -c upgradable || echo "0")
        if [ "${updates_count}" -gt 0 ]; then
            print_warning "${updates_count} package updates available"
            suggestions+=("Run 'termux-ai-manager update' to update packages")
            issues_found=$((issues_found + 1))
        else
            print_success "All packages are up to date"
        fi
    fi
    
    # Check for large log files
    if [ -d "${PREFIX}/var/log" ]; then
        local large_logs
        large_logs=$(find "${PREFIX}/var/log" -type f -size +10M 2>/dev/null | wc -l)
        if [ "${large_logs}" -gt 0 ]; then
            print_warning "Found ${large_logs} large log files (>10MB)"
            suggestions+=("Consider rotating or cleaning log files")
            issues_found=$((issues_found + 1))
        fi
    fi
    
    # Check Termux environment
    if [ -z "${PREFIX}" ]; then
        print_warning "PREFIX environment variable not set - may not be running in Termux"
    fi
    
    # AI Suggestions
    print_section "AI Recommendations"
    if [ ${#suggestions[@]} -eq 0 ]; then
        echo -e "  ${GREEN}██ Your system appears to be healthy!${NC}"
        echo ""
        echo -e "  ${CYAN}Tips for optimal performance:${NC}"
        echo -e "    ${DIM}•${NC} Regularly update packages to get security fixes"
        echo -e "    ${DIM}•${NC} Clean cache periodically to free up space"
        echo -e "    ${DIM}•${NC} Monitor resource usage during heavy tasks"
    else
        echo -e "  ${YELLOW}Based on the analysis, here are my recommendations:${NC}"
        echo ""
        local i=1
        for suggestion in "${suggestions[@]}"; do
            echo -e "    ${CYAN}${i}.${NC} ${suggestion}"
            i=$((i + 1))
        done
    fi
    
    # Save suggestions to file
    {
        echo "{"
        echo "  \"timestamp\": \"$(date -Iseconds)\","
        echo "  \"issues_found\": ${issues_found},"
        echo "  \"suggestions\": ["
        local first=true
        for suggestion in "${suggestions[@]}"; do
            if [ "${first}" = true ]; then
                first=false
            else
                echo ","
            fi
            echo -n "    \"${suggestion}\""
        done
        echo ""
        echo "  ]"
        echo "}"
    } > "${AI_SUGGESTIONS_FILE}"
    
    print_divider
    log "INFO" "AI diagnostics completed with ${issues_found} issues found"
}

# Interactive menu
show_menu() {
    clear
    print_logo
    print_themed_header "MAIN MENU"
    echo ""
    echo -e "  ${CYAN}[${WHITE}1${CYAN}]${NC} ${WHITE}System Information${NC}"
    echo -e "  ${CYAN}[${WHITE}2${CYAN}]${NC} ${WHITE}Resource Monitor${NC}"
    echo -e "  ${CYAN}[${WHITE}3${CYAN}]${NC} ${WHITE}AI Diagnostics${NC}"
    echo -e "  ${CYAN}[${WHITE}4${CYAN}]${NC} ${WHITE}System Cleanup${NC}"
    echo -e "  ${CYAN}[${WHITE}5${CYAN}]${NC} ${WHITE}Update System${NC}"
    echo -e "  ${CYAN}[${WHITE}6${CYAN}]${NC} ${WHITE}Full Maintenance${NC}"
    echo -e "  ${CYAN}[${WHITE}7${CYAN}]${NC} ${WHITE}Package Manager${NC}"
    echo -e "  ${CYAN}[${WHITE}8${CYAN}]${NC} ${WHITE}View Logs${NC}"
    echo -e "  ${CYAN}[${WHITE}9${CYAN}]${NC} ${WHITE}Help${NC}"
    echo -e "  ${RED}[${WHITE}0${RED}]${NC} ${WHITE}Exit${NC}"
    echo ""
    print_themed_footer
    echo ""
    echo -ne "${YELLOW}Select an option ${CYAN}>> ${NC}"
}

# Package management menu
show_package_menu() {
    clear
    print_logo
    print_themed_header "PACKAGE MANAGER"
    echo ""
    echo -e "  ${CYAN}[${WHITE}1${CYAN}]${NC} ${WHITE}List installed requirements${NC}"
    echo -e "  ${CYAN}[${WHITE}2${CYAN}]${NC} ${WHITE}Add a new package${NC}"
    echo -e "  ${CYAN}[${WHITE}3${CYAN}]${NC} ${WHITE}Remove a package${NC}"
    echo -e "  ${CYAN}[${WHITE}4${CYAN}]${NC} ${WHITE}Install all requirements${NC}"
    echo -e "  ${CYAN}[${WHITE}5${CYAN}]${NC} ${WHITE}Search for packages${NC}"
    echo -e "  ${RED}[${WHITE}0${RED}]${NC} ${WHITE}Back to main menu${NC}"
    echo ""
    print_themed_footer
    echo ""
    echo -ne "${YELLOW}Select an option ${CYAN}>> ${NC}"
}

# Get user requirements file path
get_user_requirements_file() {
    echo "${CONFIG_DIR}/user_requirements.txt"
}

# List all requirements (core + user)
list_requirements() {
    print_header "Package Requirements"
    
    echo -e "${YELLOW}Core Requirements (from requirements.txt):${NC}"
    if [ -f "${REQUIREMENTS_FILE}" ]; then
        while IFS= read -r line || [ -n "$line" ]; do
            [[ "$line" =~ ^#.*$ ]] && continue
            [[ -z "$line" ]] && continue
            local package
            package=$(echo "$line" | tr -d '[:space:]')
            local cmd_to_check="${PACKAGE_COMMANDS[$package]:-$package}"
            if command -v "$cmd_to_check" &> /dev/null; then
                echo -e "  ${GREEN}✓${NC} $package (installed)"
            else
                echo -e "  ${RED}✗${NC} $package (not installed)"
            fi
        done < "${REQUIREMENTS_FILE}"
    else
        echo "  No core requirements file found"
    fi
    
    local user_req_file
    user_req_file=$(get_user_requirements_file)
    
    echo ""
    echo -e "${YELLOW}User-added Packages (from user_requirements.txt):${NC}"
    if [ -f "$user_req_file" ]; then
        local has_packages=false
        while IFS= read -r line || [ -n "$line" ]; do
            [[ "$line" =~ ^#.*$ ]] && continue
            [[ -z "$line" ]] && continue
            has_packages=true
            local package
            package=$(echo "$line" | tr -d '[:space:]')
            if command -v "$package" &> /dev/null || dpkg -l "$package" &> /dev/null 2>&1; then
                echo -e "  ${GREEN}✓${NC} $package (installed)"
            else
                echo -e "  ${RED}✗${NC} $package (not installed)"
            fi
        done < "$user_req_file"
        if [ "$has_packages" = false ]; then
            echo "  No user packages added yet"
        fi
    else
        echo "  No user packages added yet"
    fi
    
    log "INFO" "Listed package requirements"
}

# Add a package to user requirements
add_package() {
    print_header "Add Package"
    
    echo -n "Enter package name to add: "
    read -r package_name
    
    if [ -z "$package_name" ]; then
        print_error "Package name cannot be empty"
        return 1
    fi
    
    # Sanitize package name
    package_name=$(echo "$package_name" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')
    
    local user_req_file
    user_req_file=$(get_user_requirements_file)
    
    # Check if package already exists
    if [ -f "$user_req_file" ] && grep -q "^${package_name}$" "$user_req_file"; then
        print_warning "Package '$package_name' is already in your requirements"
        return 0
    fi
    
    # Check if it's in core requirements
    if [ -f "${REQUIREMENTS_FILE}" ] && grep -q "^${package_name}$" "${REQUIREMENTS_FILE}"; then
        print_warning "Package '$package_name' is already in core requirements"
        return 0
    fi
    
    # Add to user requirements file
    echo "$package_name" >> "$user_req_file"
    print_success "Added '$package_name' to user requirements"
    
    # Ask if user wants to install now
    echo ""
    echo -n "Would you like to install '$package_name' now? [y/N]: "
    read -r response
    
    if [[ "$response" =~ ^[Yy]$ ]]; then
        install_single_package "$package_name"
    fi
    
    log "INFO" "Added package to user requirements: $package_name"
}

# Remove a package from user requirements
remove_package() {
    print_header "Remove Package"
    
    local user_req_file
    user_req_file=$(get_user_requirements_file)
    
    if [ ! -f "$user_req_file" ]; then
        print_warning "No user packages to remove"
        return 0
    fi
    
    echo "User-added packages:"
    local i=1
    local packages=()
    while IFS= read -r line || [ -n "$line" ]; do
        [[ "$line" =~ ^#.*$ ]] && continue
        [[ -z "$line" ]] && continue
        local package
        package=$(echo "$line" | tr -d '[:space:]')
        packages+=("$package")
        echo "  $i) $package"
        i=$((i + 1))
    done < "$user_req_file"
    
    if [ ${#packages[@]} -eq 0 ]; then
        print_warning "No user packages to remove"
        return 0
    fi
    
    echo ""
    echo -n "Enter package number to remove (or 0 to cancel): "
    read -r choice
    
    if [ "$choice" = "0" ] || [ -z "$choice" ]; then
        return 0
    fi
    
    if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -gt ${#packages[@]} ]; then
        print_error "Invalid selection"
        return 1
    fi
    
    local package_to_remove="${packages[$((choice - 1))]}"
    
    # Remove from file
    grep -v "^${package_to_remove}$" "$user_req_file" > "${user_req_file}.tmp" 2>/dev/null || true
    mv "${user_req_file}.tmp" "$user_req_file"
    
    print_success "Removed '$package_to_remove' from user requirements"
    
    # Ask if user wants to uninstall
    echo ""
    echo -n "Would you like to uninstall '$package_to_remove' from the system? [y/N]: "
    read -r response
    
    if [[ "$response" =~ ^[Yy]$ ]]; then
        uninstall_package "$package_to_remove"
    fi
    
    log "INFO" "Removed package from user requirements: $package_to_remove"
}

# Install a single package using nala (preferred) or apt
install_single_package() {
    local package="$1"
    
    print_info "Installing $package..."
    
    if command -v nala &> /dev/null; then
        nala install -y "$package" 2>/dev/null && print_success "Installed $package" || print_error "Failed to install $package"
    elif command -v apt &> /dev/null; then
        apt install -y "$package" 2>/dev/null && print_success "Installed $package" || print_error "Failed to install $package"
    elif command -v pkg &> /dev/null; then
        pkg install -y "$package" 2>/dev/null && print_success "Installed $package" || print_error "Failed to install $package"
    else
        print_error "No package manager available"
        return 1
    fi
}

# Uninstall a package
uninstall_package() {
    local package="$1"
    
    print_info "Uninstalling $package..."
    
    if command -v nala &> /dev/null; then
        nala remove -y "$package" 2>/dev/null && print_success "Uninstalled $package" || print_error "Failed to uninstall $package"
    elif command -v apt &> /dev/null; then
        apt remove -y "$package" 2>/dev/null && print_success "Uninstalled $package" || print_error "Failed to uninstall $package"
    elif command -v pkg &> /dev/null; then
        pkg uninstall -y "$package" 2>/dev/null && print_success "Uninstalled $package" || print_error "Failed to uninstall $package"
    else
        print_error "No package manager available"
        return 1
    fi
}

# Install all requirements (core + user)
install_all_requirements() {
    print_header "Install All Requirements"
    
    local all_packages=()
    
    # Collect core requirements
    if [ -f "${REQUIREMENTS_FILE}" ]; then
        while IFS= read -r line || [ -n "$line" ]; do
            [[ "$line" =~ ^#.*$ ]] && continue
            [[ -z "$line" ]] && continue
            local package
            package=$(echo "$line" | tr -d '[:space:]')
            all_packages+=("$package")
        done < "${REQUIREMENTS_FILE}"
    fi
    
    # Collect user requirements
    local user_req_file
    user_req_file=$(get_user_requirements_file)
    if [ -f "$user_req_file" ]; then
        while IFS= read -r line || [ -n "$line" ]; do
            [[ "$line" =~ ^#.*$ ]] && continue
            [[ -z "$line" ]] && continue
            local package
            package=$(echo "$line" | tr -d '[:space:]')
            all_packages+=("$package")
        done < "$user_req_file"
    fi
    
    if [ ${#all_packages[@]} -eq 0 ]; then
        print_warning "No packages to install"
        return 0
    fi
    
    echo "The following packages will be installed:"
    for pkg in "${all_packages[@]}"; do
        echo "  - $pkg"
    done
    
    echo ""
    echo -n "Proceed with installation? [y/N]: "
    read -r response
    
    if [[ "$response" =~ ^[Yy]$ ]]; then
        for pkg in "${all_packages[@]}"; do
            install_single_package "$pkg"
        done
        print_success "All packages installation completed"
    else
        print_info "Installation cancelled"
    fi
    
    log "INFO" "Installed all requirements"
}

# Search for packages
search_packages() {
    print_header "Search Packages"
    
    echo -n "Enter search term: "
    read -r search_term
    
    if [ -z "$search_term" ]; then
        print_error "Search term cannot be empty"
        return 1
    fi
    
    print_info "Searching for packages matching '$search_term'..."
    echo ""
    
    if command -v nala &> /dev/null; then
        nala search "$search_term" 2>/dev/null | head -20
    elif command -v apt &> /dev/null; then
        apt search "$search_term" 2>/dev/null | head -20
    elif command -v pkg &> /dev/null; then
        pkg search "$search_term" 2>/dev/null | head -20
    else
        print_error "No package manager available for search"
        return 1
    fi
    
    log "INFO" "Searched for packages: $search_term"
}

# Package manager interactive mode
package_manager_mode() {
    while true; do
        show_package_menu
        read -r choice
        echo ""
        case ${choice} in
            1) list_requirements ;;
            2) add_package ;;
            3) remove_package ;;
            4) install_all_requirements ;;
            5) search_packages ;;
            0) return ;;
            *) print_error "Invalid option" ;;
        esac
        echo ""
        echo -n "Press Enter to continue..."
        read -r
    done
}

# View logs
view_logs() {
    print_header "Maintenance Logs"
    if [ -f "${LOG_FILE}" ]; then
        tail -50 "${LOG_FILE}"
    else
        print_info "No logs found"
    fi
}

# Full maintenance
full_maintenance() {
    print_header "Full System Maintenance"
    echo "Starting comprehensive system maintenance..."
    echo ""
    
    clean_system
    echo ""
    update_system
    echo ""
    ai_diagnostics
    
    print_success "Full maintenance completed!"
    log "INFO" "Full maintenance completed"
}

# Show help
show_help() {
    print_header "Termux AI Manager Help"
    cat << 'EOF'

USAGE:
    termux-ai-manager [COMMAND]

COMMANDS:
    info        Display system information
    monitor     Monitor system resources
    diagnose    Run AI-powered diagnostics
    clean       Clean system cache and temporary files
    update      Update system packages
    maintain    Run full maintenance (clean + update + diagnose)
    logs        View maintenance logs
    menu        Show interactive menu
    help        Show this help message
    version     Show version information

EXAMPLES:
    termux-ai-manager diagnose    # Run AI diagnostics
    termux-ai-manager clean       # Clean system
    termux-ai-manager maintain    # Full maintenance

For more information, visit:
    https://github.com/DaRipper91/termux-ai-manager

EOF
}

# Show version with themed output
show_version() {
    print_logo
    echo -e "${CYAN}Version:${NC}   ${VERSION}"
    echo -e "${CYAN}Author:${NC}    B.Rooster <DaRipper>"
    echo -e "${CYAN}License:${NC}   MIT"
    echo -e "${CYAN}Website:${NC}   https://github.com/DaRipper91/termux-ai-manager"
    print_divider
}

# Interactive mode
interactive_mode() {
    init_config
    show_splash_screen
    while true; do
        show_menu
        read -r choice
        echo ""
        case ${choice} in
            1) get_system_info ;;
            2) monitor_resources ;;
            3) ai_diagnostics ;;
            4) clean_system ;;
            5) update_system ;;
            6) full_maintenance ;;
            7) package_manager_mode ;;
            8) view_logs ;;
            9) show_help ;;
            0) 
                clear
                print_logo
                echo -e "${YELLOW}Thanks for using Termux AI Manager!${NC}"
                echo -e "${DIM}${WHITE}Goodbye!${NC}"
                echo ""
                exit 0 
                ;;
            *) print_error "Invalid option" ;;
        esac
        echo ""
        echo -ne "${DIM}Press ${WHITE}Enter${NC}${DIM} to continue...${NC}"
        read -r
    done
}

# Main entry point
main() {
    init_config
    check_ascii_support
    
    case "${1:-menu}" in
        info)
            get_system_info
            ;;
        monitor)
            monitor_resources
            ;;
        diagnose)
            ai_diagnostics
            ;;
        clean)
            clean_system
            ;;
        update)
            update_system
            ;;
        maintain)
            full_maintenance
            ;;
        logs)
            view_logs
            ;;
        menu)
            interactive_mode
            ;;
        help|--help|-h)
            show_help
            ;;
        version|--version|-v)
            show_version
            ;;
        *)
            print_error "Unknown command: $1"
            show_help
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
