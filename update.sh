#!/data/data/com.termux/files/usr/bin/bash

echo "Updating Wi-Fi OSINT Tool..."
git pull origin main
chmod +x wifi-osint-tool.sh install.sh update.sh
echo "Update complete!"
