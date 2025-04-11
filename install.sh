#!/bin/bash

# Enable error handling
set -e
trap 'echo "An error occurred. Exiting..."; exit 1;' ERR

# Banner for the tool
echo "====================================="
echo "  Installing Wi-Fi OSINT Tool"
echo "====================================="

# Check for Termux environment
if [[ -z "$PREFIX" ]]; then
  echo "Error: This script is designed for Termux. Make sure you're running it in Termux."
  exit 1
fi

# Check for current environment and provide instructions or make it compatible
if [[ "$OSTYPE" != "linux-android"* ]]; then
  echo "Warning: This script is designed for Termux on Android. You are running on $OSTYPE."
  echo "Attempting to make the script compatible with your environment..."
  # Add compatibility adjustments here if needed
fi

# Update and upgrade Termux packages
echo "Updating and upgrading Termux packages..."
pkg update -y && pkg upgrade -y

# Install required dependencies
echo "Installing necessary dependencies..."
pkg install -y curl git wget bash termux-api jq

# Define directories (XDG Base Directory compliant)
CONFIG_DIR="${HOME}/.config/wifi-osint"
LOG_DIR="${HOME}/.local/share/wifi-osint/logs"
BIN_DIR="${HOME}/bin"

# Create required directories
echo "Creating necessary directories..."
mkdir -p "$CONFIG_DIR" "$LOG_DIR" "$BIN_DIR"

# Define the tool script
TOOL_SCRIPT="wifi-osint-tool.sh"

# Validate the tool script
if [[ ! -f "$TOOL_SCRIPT" ]]; then
  echo "Error: $TOOL_SCRIPT not found in the current directory."
  exit 1
fi

# Make the tool executable
echo "Setting permissions for the tool..."
chmod +x "$TOOL_SCRIPT"

# Link the tool to the bin directory
echo "Linking the tool to $BIN_DIR..."
ln -sf "$(pwd)/$TOOL_SCRIPT" "$BIN_DIR/wifi-osint"

# Ensure the bin directory is in PATH
if ! echo "$PATH" | grep -q "$BIN_DIR"; then
  echo "Adding $BIN_DIR to PATH in .bashrc..."
  if ! grep -qx "export PATH=\$PATH:$BIN_DIR" "$HOME/.bashrc"; then
    echo "export PATH=\$PATH:$BIN_DIR" >> "$HOME/.bashrc"
  fi
  source "$HOME/.bashrc"
fi

# Post-installation message
echo "====================================="
echo "Installation complete!"
echo "Run 'wifi-osint' to start the tool."
echo "Logs will be saved in $LOG_DIR."
echo "Configuration files are stored in $CONFIG_DIR."
echo "====================================="
