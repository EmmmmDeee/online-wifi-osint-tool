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

3. Optimize for Termux:
   The installation script will automatically call the `optimize_for_termux` function to ensure the tool is optimized for the Termux environment.

## Usage

Start the tool by typing:
```bash
wifi-osint
```

### Optimizing for Termux

The `optimize_for_termux` function is called during the installation process to ensure the tool is optimized for the Termux environment. This function performs specific optimizations to enhance the tool's performance and compatibility with Termux on Android Aarch64 devices.

## Dependencies

The tool requires the following dependencies:
- curl
- jq
- termux-tools
- termux-api
- iproute2

## Setup

The setup process will create necessary directories and default configuration files. It will also check and install any missing dependencies.

## Features

- Scan for nearby Wi-Fi networks
- Look up vendor from MAC address
- Download and update OUI database
