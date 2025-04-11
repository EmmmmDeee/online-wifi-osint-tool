#!/data/data/com.termux/files/usr/bin/bash

# Wi-Fi OSINT Tool for Termux (Android Aarch64)
# Version: 1.0.0
# Created by: EmmmmDeee
# Repository: https://github.com/EmmmmDeee/online-wifi-osint-tool
# License: MIT

# ==================== CONFIGURATION ======================
VERSION="1.0.0"
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
CONFIG_DIR="$HOME/.config/wifi-osint"
LOG_DIR="$HOME/.local/share/wifi-osint/logs"
LOG_FILE="$LOG_DIR/osint_$(date +%Y%m%d).log"

# ==================== COLORS =============================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ==================== HELPER FUNCTIONS ===================
log() {
    echo -e "${CYAN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

success() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')] ✓ $1${NC}" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')] ✗ $1${NC}" | tee -a "$LOG_FILE"
}

# Check internet connectivity
check_internet() {
    if ping -c 1 8.8.8.8 &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# Setup function to create necessary directories
setup() {
    mkdir -p "$CONFIG_DIR" "$LOG_DIR"
}

# Clean up old log files
cleanup_logs() {
    find "$LOG_DIR" -name "osint_*.log" -type f -mtime +7 -delete 2>/dev/null
}

# Check dependencies function
check_dependencies() {
    local missing_deps=()
    local deps=("curl" "jq" "termux-tools" "termux-api" "iproute2")
    
    for dep in "${deps[@]}"; do
        if ! pkg list-installed | grep -q "^$dep"; then
            missing_deps+=("$dep")
        fi
    done
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        echo -e "${YELLOW}Missing dependencies: ${missing_deps[*]}${NC}"
        echo -e "${YELLOW}Install missing dependencies? [Y/n]${NC}"
        read -r install_choice
        if [[ $install_choice != "n" && $install_choice != "N" ]]; then
            log "Installing missing dependencies..."
            pkg install -y "${missing_deps[@]}"
            success "Dependencies installed"
        else
            echo -e "${YELLOW}Some features may not work without required dependencies${NC}"
        fi
    fi
    
    # Check for termux-api app
    if ! command -v termux-wifi-scaninfo &> /dev/null; then
        echo -e "${YELLOW}Termux API app is not installed on your device.${NC}"
        echo -e "${YELLOW}For best functionality, install the Termux:API app from F-Droid or Google Play Store.${NC}"
        echo -e "${YELLOW}After installation, run 'pkg install termux-api' in Termux.${NC}"
        echo -e "${YELLOW}Continue anyway? [Y/n]${NC}"
        read -r continue_choice
        if [[ $continue_choice == "n" || $continue_choice == "N" ]]; then
            exit 1
        fi
    fi
}

# ==================== MAIN MENU ==========================
main_menu() {
    clear
    echo -e "${BLUE}Wi-Fi OSINT Tool v${VERSION}${NC}"
    echo -e "${CYAN}1.${NC} Scan Wi-Fi Networks"
    echo -e "${CYAN}2.${NC} Generate OSINT Report"
    echo -e "${CYAN}3.${NC} Exit"
    read -rp "Select an option: " choice

    case $choice in
        1)
            log "Scanning Wi-Fi networks..."
            echo "Feature under development."
            ;;
        2)
            log "Generating OSINT report..."
            echo "Feature under development."
            ;;
        3)
            log "Exiting tool."
            exit 0
            ;;
        *)
            error "Invalid option."
            sleep 1
            main_menu
            ;;
    esac
}

# ==================== RUN THE TOOL =======================
setup
cleanup_logs
check_dependencies
main_menu
