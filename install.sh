#!/data/data/com.termux/files/usr/bin/bash

# Enable strict error handling
set -e
trap 'echo "An error occurred. Exiting..."; exit 1;' ERR

# Banner
echo "=========================================="
echo "    Upgrading Wi-Fi OSINT Tool"
echo "    For Termux (Android AArch64)"
echo "=========================================="

# Ensure the script is running in Termux
if [[ ! -d "/data/data/com.termux" ]]; then
  echo "Error: This script is designed for Termux. Please run it within Termux."
  exit 1
fi

# Ensure the device is AArch64 architecture
if [[ "$(uname -m)" != "aarch64" ]]; then
  echo "Error: This tool is optimized for Android AArch64 devices."
  exit 1
fi

# Update and upgrade Termux packages
echo "Updating and upgrading Termux packages..."
pkg update -y && pkg upgrade -y

# Install or upgrade required dependencies
echo "Installing/upgrading necessary dependencies..."
dependencies=(curl git wget bash)
for dep in "${dependencies[@]}"; do
  pkg install -y "$dep"
done

# Define tool directories
TOOL_DIR="${HOME}/.wifi-osint"
BIN_DIR="${HOME}/bin"
TOOL_SCRIPT="wifi-osint-tool.sh"

# Ensure tool directories exist
echo "Ensuring necessary directories exist..."
mkdir -p "$TOOL_DIR" "$BIN_DIR"

# Pull the latest tool script from the repository
echo "Fetching the latest version of the tool..."
cd "$TOOL_DIR"
if [[ -d ".git" ]]; then
  git pull origin main
else
  git clone https://github.com/EmmmmDeee/online-wifi-osint-tool.git "$TOOL_DIR"
fi

# Ensure the tool script exists
if [[ ! -f "$TOOL_DIR/$TOOL_SCRIPT" ]]; then
  echo "Error: The tool script '$TOOL_SCRIPT' is missing in the repository."
  exit 1
fi

# Make the tool executable
echo "Setting executable permissions for the tool..."
chmod +x "$TOOL_DIR/$TOOL_SCRIPT"

# Link the tool script to the bin directory
echo "Linking the tool to $BIN_DIR..."
ln -sf "$TOOL_DIR/$TOOL_SCRIPT" "$BIN_DIR/wifi-osint"

# Add the bin directory to PATH if not already present
if ! echo "$PATH" | grep -q "$BIN_DIR"; then
  echo "Adding $BIN_DIR to PATH in .bashrc..."
  if ! grep -qx "export PATH=\$PATH:$BIN_DIR" "$HOME/.bashrc"; then
    echo "export PATH=\$PATH:$BIN_DIR" >> "$HOME/.bashrc"
  fi
  source "$HOME/.bashrc"
fi

# Post-upgrade message
echo "=========================================="
echo "Upgrade completed successfully!"
echo "To start the tool, run: wifi-osint"
echo "=========================================="