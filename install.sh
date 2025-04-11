#!/data/data/com.termux/files/usr/bin/bash

echo "Installing Wi-Fi OSINT Tool..."
mkdir -p ~/.config/wifi-osint ~/.local/share/wifi-osint/logs
chmod +x wifi-osint-tool.sh
ln -sf "$(pwd)/wifi-osint-tool.sh" ~/bin/wifi-osint
echo "Installation complete! Run 'wifi-osint' to start the tool."
