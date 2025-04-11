#!/data/data/com.termux/files/usr/bin/bash

# Enable error handling
set -e
trap 'echo "An error occurred. Exiting..."; exit 1;' ERR

# Banner for the tool
echo "====================================="
echo "  Installing Wi-Fi OSINT Tool"
echo "====================================="

# Define directories (XDG Base Directory compliant)
CONFIG_DIR="${HOME}/.config/wifi-osint"
LOG_DIR="${HOME}/.local/share/wifi-osint/logs"
BIN_DIR="${HOME}/bin"

# Ensure Termux's environment is prepared
if [[ -z "$PREFIX" ]]; then
  echo "Error: This script is designed for Termux. Make sure you're running it in Termux."
  exit 1
fi

# Create required directories
echo "Creating necessary directories..."
mkdir -p "$CONFIG_DIR" "$LOG_DIR" "$BIN_DIR"

# Validate the tool script
TOOL_SCRIPT="wifi-osint-tool.sh"
if [[ ! -f "$TOOL_SCRIPT" ]]; then
  echo "Error: $TOOL_SCRIPT not found in the current directory."
  exit 1
fi

# Make the tool executable
echo "Setting permissions for the tool..."
chmod +x "$TOOL_SCRIPT"

# Create a symbolic link for easy access
echo "Linking the tool to $BIN_DIR..."
ln -sf "$(pwd)/$TOOL_SCRIPT" "$BIN_DIR/wifi-osint"

# Ensure the bin directory is in PATH
if ! echo "$PATH" | grep -q "$BIN_DIR"; then
  echo "Adding $BIN_DIR to PATH in .bashrc..."
  echo "export PATH=\$PATH:$BIN_DIR" >> "$HOME/.bashrc"
  source "$HOME/.bashrc"
fi

# Final instructions
echo "====================================="
echo "Installation complete!"
echo "Run 'wifi-osint' to start the tool."
echo "Logs will be saved in $LOG_DIR."
echo "Configuration files are stored in $CONFIG_DIR."
echo "====================================="
