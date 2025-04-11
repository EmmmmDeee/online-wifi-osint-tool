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

## Handling Dependencies

The tool checks for dependencies and prompts the user to install missing ones. Here are some best practices for handling dependencies in Termux:

* **Check for dependencies**: Before running the main script, check if all required dependencies are installed. This can be done using the `pkg list-installed` command to verify the presence of necessary packages.
* **Install missing dependencies**: If any dependencies are missing, prompt the user to install them. Use the `pkg install -y` command to install the required packages automatically if the user agrees.
* **Use Termux-specific packages**: Ensure that the dependencies are compatible with Termux by using Termux-specific packages like `termux-tools` and `termux-api`.
* **Handle Termux API app**: Check if the Termux API app is installed on the device. If not, inform the user and provide instructions to install it from F-Droid or Google Play Store.
* **Check internet connectivity**: Before attempting to download any resources or updates, verify that the device has an active internet connection using the `ping` command.
* **Create necessary directories**: Ensure that all required directories for configuration, data, and logs are created using the `mkdir -p` command.
* **Clean up old files**: Implement a mechanism to clean up old log files or temporary files to avoid clutter and save storage space.
* **Provide clear instructions**: Include clear instructions in the `README.md` file for installing and running the tool, as well as for handling any potential issues related to dependencies.
