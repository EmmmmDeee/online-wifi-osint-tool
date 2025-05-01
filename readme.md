# Online Wi-Fi OSINT Tool for Termux (Android Aarch64)

This is a fully automated Wi-Fi OSINT tool for Termux on Android Aarch64 devices. It works without root and uses free public resources.

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/EmmmmDeee/online-wifi-osint-tool.git
   ```
2. Run the installation script:
   ```bash
   cd online-wifi-osint-tool
   ./install.sh
   ```

## Usage

Start the tool by typing:
```bash
wifi-osint
```

## Uninstallation

To uninstall the tool, run the following command:
```bash
./uninstall.sh
```

## Update

To update the tool, run the following command:
```bash
./update.sh
```

## Features

- Scan for nearby Wi-Fi networks
- Lookup BSSID in WiGLE database
- Check MAC vendor reputation
- Search for similar networks
- Generate OSINT report for Wi-Fi networks

## Configuration

The tool creates a default configuration file at `~/.config/wifi-osint/config.json` if it doesn't exist. You can customize the following settings:

- `theme`: The theme of the tool (default: "default")
- `history_enabled`: Enable or disable history logging (default: true)
- `max_log_age_days`: Maximum age of log files in days (default: 7)
- `save_results`: Enable or disable saving scan results (default: true)
- `max_api_requests`: Maximum number of API requests per session (default: 45)

## Logs

Logs are saved in the `~/.local/share/wifi-osint/logs` directory. The log files are automatically cleaned up after 7 days.

## Dependencies

The tool requires the following dependencies:

- curl
- jq
- termux-tools
- termux-api
- iproute2

The installation script will automatically install these dependencies if they are not already installed.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
