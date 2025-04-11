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

# Setup function to create necessary directories
setup() {
    mkdir -p "$CONFIG_DIR" "$LOG_DIR"
    
    # Create default configuration if it doesn't exist
    if [ ! -f "$CONFIG_DIR/config.json" ]; then
        echo '{
            "theme": "default",
            "history_enabled": true,
            "max_log_age_days": 7,
            "save_results": true,
            "max_api_requests": 45
        }' > "$CONFIG_DIR/config.json"
    fi
    
    # Create OUI database directory
    mkdir -p "$DATA_DIR/oui_db"
    
    # Clean up old log files
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
        warning "Missing dependencies: ${missing_deps[*]}"
        echo -e "${YELLOW}Install missing dependencies? [Y/n]${NC}"
        read -r install_choice
        if [[ $install_choice != "n" && $install_choice != "N" ]]; then
            log "Installing missing dependencies..."
            pkg install -y "${missing_deps[@]}"
            success "Dependencies installed"
        else
            warning "Some features may not work without required dependencies"
        fi
    fi
    
    # Check for termux-api app
    if ! command -v termux-wifi-scaninfo &> /dev/null; then
        warning "Termux API app is not installed on your device."
        warning "For best functionality, install the Termux:API app from F-Droid or Google Play Store."
        warning "After installation, run 'pkg install termux-api' in Termux."
        echo -e "${YELLOW}Continue anyway? [Y/n]${NC}"
        read -r continue_choice
        if [[ $continue_choice == "n" || $continue_choice == "N" ]]; then
            exit 1
        fi
    fi

    optimize_for_termux
}

# Scan for nearby Wi-Fi networks
scan_wifi_networks() {
    show_header
    echo -e "${BLUE}=== Scanning for Wi-Fi Networks ===${NC}"
    
    if ! command -v termux-wifi-scaninfo &> /dev/null; then
        error "termux-wifi-scaninfo not available. Make sure Termux:API app is installed."
        echo -e "${YELLOW}Would you like to install Termux API package? [Y/n]${NC}"
        read -r install_api
        if [[ $install_api != "n" && $install_api != "N" ]]; then
            pkg install -y termux-api
            if ! command -v termux-wifi-scaninfo &> /dev/null; then
                error "Failed to install or access Termux API. Please install Termux:API app from F-Droid or Play Store."
                read -p "Press Enter to continue..." -r
                return
            fi
        else
            read -p "Press Enter to continue..." -r
            return
        fi
    fi
    
    log "Scanning for nearby Wi-Fi networks..."
    
    # Request location permission
    termux-location &>/dev/null
    
    # Scan for Wi-Fi networks
    echo -e "${YELLOW}Scanning...${NC}"
    local scan_result=$(termux-wifi-scaninfo 2>/dev/null)
    
    if [ -z "$scan_result" ] || [ "$scan_result" == "[]" ]; then
        error "No networks found or Wi-Fi is disabled"
        read -p "Press Enter to continue..." -r
        return
    fi
    
    # Parse and display results
    local network_count=$(echo "$scan_result" | jq '. | length')
    success "Found $network_count Wi-Fi networks"
    
    # Display results in a formatted table
    printf "${CYAN}%-3s %-32s %-18s %-8s %-15s %s${NC}\n" "No" "SSID" "BSSID" "Signal" "Frequency" "Security"
    echo "-----------------------------------------------------------------------------------------"
    
    local count=1
    while read -r network; do
        local ssid=$(echo "$network" | jq -r '.ssid // "<Hidden>"')
        local bssid=$(echo "$network" | jq -r '.bssid')
        local level=$(echo "$network" | jq -r '.level')
        local frequency=$(echo "$network" | jq -r '.frequency')
        local capability=$(echo "$network" | jq -r '.capabilities')
        
        # Determine security based on capabilities string
        local security="Open"
        if echo "$capability" | grep -q "WPA3"; then
            security="WPA3"
        elif echo "$capability" | grep -q "WPA2"; then
            security="WPA2"
        elif echo "$capability" | grep -q "WPA"; then
            security="WPA"
        elif echo "$capability" | grep -q "WEP"; then
            security="WEP"
        fi
        
        # Format signal strength
        if [ "$level" -gt -50 ]; then
            signal="${GREEN}Excellent${NC}"
        elif [ "$level" -gt -60 ]; then
            signal="${GREEN}Good${NC}"
        elif [ "$level" -gt -70 ]; then
            signal="${YELLOW}Fair${NC}"
        else
            signal="${RED}Poor${NC}"
        fi
        
        # Format frequency
        local band=""
        if [ "$frequency" -lt 2500 ]; then
            band="2.4 GHz"
        else
            band="5 GHz"
        fi
        
        printf "%-3s %-32s %-18s %-8s %-15s %s\n" "$count" "$ssid" "$bssid" "$signal" "$band" "$security"
        count=$((count + 1))
    done < <(echo "$scan_result" | jq -c '.[]')
    
    # Save results to file if enabled
    if [ "$(jq -r '.save_results' "$CONFIG_DIR/config.json")" == "true" ]; then
        local timestamp=$(date +%Y%m%d_%H%M%S)
        local results_file="$DATA_DIR/scan_$timestamp.json"
        echo "$scan_result" > "$results_file"
        success "Results saved to: $results_file"
    fi
    
    echo
    echo -e "${YELLOW}Select a network for detailed information (1-$((count-1))), or 0 to return:${NC}"
    read -r select_network
    
    if [[ "$select_network" =~ ^[0-9]+$ ]] && [ "$select_network" -gt 0 ] && [ "$select_network" -lt "$count" ]; then
        local selected=$(echo "$scan_result" | jq -c ".[$((select_network-1))]")
        network_details "$selected"
    fi
}

# Look up vendor from MAC address
lookup_mac_vendor() {
    local mac="$1"
    # Format MAC to match OUI database format (first 6 characters, uppercase)
    local oui=$(echo "$mac" | sed 's/[:-]//g' | cut -c 1-6 | tr '[:lower:]' '[:upper:]')
    
    # Check if database exists
    if [ ! -f "$DATA_DIR/oui_db/oui.txt" ]; then
        warning "OUI database not found. Would you like to download it now? [Y/n]"
        read -r download_choice
        if [[ $download_choice != "n" && $download_choice != "N" ]]; then
            update_oui_database
        else
            return "Unknown vendor"
        fi
    fi
    
    # Look up OUI in database
    local vendor=$(grep -i "$oui" "$DATA_DIR/oui_db/oui.txt" | head -1 | cut -d')' -f2- | sed 's/^\s*//')
    
    if [ -z "$vendor" ]; then
        echo "Unknown vendor"
    else
        echo "$vendor"
    fi
}

# Download and update OUI database
update_oui_database() {
    show_header
    echo -e "${BLUE}=== Updating MAC Address Database ===${NC}"
    
    log "Checking for OUI database updates..."
    
    # Check internet connectivity
    if ! check_internet; then
        error "No internet connection. Using local database if available."
        if [ ! -f "$DATA_DIR/oui_db/oui.txt" ]; then
            error "No local database found. Please connect to the internet and try again."
            read -p "Press Enter to continue..." -r
            return 1
        fi
        return 1
    fi
    
    # Download the IEEE OUI database
    log "Downloading latest IEEE OUI database..."
    curl -s "http://standards-oui.ieee.org/oui/oui.txt" -o "$DATA_DIR/oui_db/oui.txt.new"
    
    # Check if download was successful
    if [ ! -s "$DATA_DIR/oui_db/oui.txt.new" ]; then
        error "Failed to download OUI database"
        # Try alternative source
        log "Trying alternative source..."
        curl -s "https://raw.githubusercontent.com/wireshark/wireshark/master/manuf" -o "$DATA_DIR/oui_db/oui.txt.new"
        
        if [ ! -s "$DATA_DIR/oui_db/oui.txt.new" ]; then
            error "Failed to download OUI database from alternative source"
            if [ -f "$DATA_DIR/oui_db/oui.txt" ]; then
                warning "Using existing database"
            else
                error "No OUI database available. Some features will not work correctly."
            fi
            rm -f "$DATA_DIR/oui_db/oui.txt.new"
            read -p "Press Enter to continue..." -r
            return 1
        fi
    fi
    
    # Update database
    mv "$DATA_DIR/oui_db/oui.txt.new" "$DATA_DIR/oui_db/oui.txt"
    success "OUI database updated successfully"
    log "Last update: $(date)" > "$DATA_DIR/oui_db/last_update.txt"
    
    read -p "Press Enter to continue..." -r
    return 0
}

# Optimize for Termux
optimize_for_termux() {
    # Add any specific optimizations for Termux here
    log "Optimizing for Termux environment..."
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
            scan_wifi_networks
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
mkdir -p "$CONFIG_DIR" "$LOG_DIR"
optimize_for_termux
main_menu
