#!/data/data/com.termux/files/usr/bin/bash

set -e
set -o pipefail

echo "Starting the update process for Wi-Fi OSINT Tool..."

# Step 1: Ensure Git is installed
if ! command -v git >/dev/null 2>&1; then
    echo "Git is not installed. Installing Git..."
    pkg update -y && pkg install -y git
    echo "Git installation completed."
fi

# Step 2: Ensure proper file permissions
echo "Ensuring necessary permissions for script files..."
chmod u+x wifi-osint-tool.sh install.sh update.sh

# Step 3: Pull the latest changes from the repository
echo "Pulling the latest changes from the repository..."
if git pull origin main; then
    echo "Repository updated successfully."
else
    echo "Error: Failed to update the repository. Please check your internet connection or repository permissions."
    exit 1
fi

# Step 4: Ensure Termux environment is correctly set up
echo "Verifying Termux environment setup..."

# Ensure basic utilities are installed
for pkg in bash coreutils; do
    if ! command -v "$pkg" >/dev/null 2>&1; then
        echo "Installing missing package: $pkg..."
        pkg install -y "$pkg"
    fi
done

# Step 5: Confirm successful update
echo "Update process completed successfully!"
