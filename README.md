
# Linux-Debian-Based Setup Scripts

This repository contains shell scripts that help you quickly set up essential software on Debian-based Linux distributions (such as Ubuntu, Linux Mint, etc.).

## Getting Started

### Prerequisites:

Ensure your system is running a Debian-based Linux distribution. If you're using a different distribution, some commands may vary.

### Downloading and Running a Script:

1. **Download the script you need** directly from this repository. Click on the script file (e.g., `VSCode_Install.sh`), then click the "Download" button or right-click on the "Raw" button and select "Save Link As" to save the file.

2. **Navigate to the directory** where you saved the script. You can either:

   - Open the terminal manually and use `cd` to navigate to the folder:
     ```bash
     cd /path/to/your/script
     ```

   - Alternatively, you can right-click on the folder in your file explorer and select "Open in Terminal" to open a terminal directly in that folder.

3. **Make the script executable** by running the following command:

   ```bash
   # Make the script executable
   chmod +x script_name.sh
   
   # Run the script
   sudo ./script_name.sh
   ```

## Available Scripts:

Currently, the repository contains the following scripts:

- **boot_clean.sh**: A basic system maintenance script.
- **grub_customizer_install.sh**: Installs GRUB Customizer, a tool for managing the GRUB bootloader.
- **octave_install.sh**: Installs GNU Octave, a software for numerical computations.
- **ubuntu_based_setup.sh**: Automated basic setup for Ubuntu-based systems (uses `nala` for newer systems and `apt` for older ones).
- **ubuntu_older_setup.sh**: Setup script specifically for older systems that use `apt`.
- **ubuntu_lts_upgrade.sh**: Upgrade Ubuntu to the next LTS release.
- **ubuntu_upgrade.sh**: Upgrade Ubuntu to the next available release (not necessarily the next LTS release).
- **vscode_install.sh**: Installs Visual Studio Code, a popular code editor.

## More Scripts Coming Soon:

This repository will be updated with more scripts to automate the installation of other useful tools and software. Keep checking back for updates!

## Author:
**Name**: Warad Teni  
**Mobile**: (+91) 91463 50289  
**Email**: waradteni@gmail.com

## Contributing:

Feel free to contribute by adding more useful scripts or improving the existing ones. Here's how you can contribute:

1. Fork the repository.
2. Create your feature branch (`git checkout -b feature/NewScript`).
3. Commit your changes (`git commit -m 'Add a new script for XYZ'`).
4. Push to the branch (`git push origin feature/NewScript`).
5. Open a Pull Request.
