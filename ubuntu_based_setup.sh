#!/bin/bash

# AUTHOR  : Warad Teni
# MOBILE  : (+91) 91463 50289
# EMAIL   : waradteni@gmail.com

#**************************************************************************************************************************************************************************#

# Redirect all output (stdout and stderr) to a log file and the terminal
exec > >(tee -i setup_script.log) 2>&1

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root. Use sudo."
   exit 1
fi

# Check for internet connectivity
if ! ping -c 1 google.com &>/dev/null; then
    echo "Internet connection required. Please check your connection and try again."
    exit 1
fi

# Function to check if a command was successful
check_success() {
    if [ $? -ne 0 ]; then
        echo "Error: $1 failed. Exiting."
        exit 1
    fi
    echo "$1 succeeded."
}

# # Function to check if /home is a separate partition
# is_home_separate() {
#     # Check the mounted partitions for /home
#     if lsblk -o MOUNTPOINT,NAME | grep -q "/home"; then
#         return 0 # /home is mounted on a separate partition
#     else
#         return 1 # /home is not separate
#     fi
# }

# configure_timeshift() {
#     # Check if /home is a separate partition
#     if is_home_separate; then
#         backup_device=$(lsblk -n -o MOUNTPOINT,NAME | grep "/home" | awk '{print $2}')
#         backup_location="/home/timeshift"
#         echo "/home is a separate partition. Backups will be stored in /home."
#     else
#         backup_device=$(lsblk -n -o MOUNTPOINT,NAME | grep "/$" | awk '{print $2}')
#         backup_location="/timeshift"
#         echo "/home is not a separate partition. Backups will be stored in /."
#     fi

#     # Create the backup directory if it doesn't exist
#     sudo mkdir -p "$backup_location"
#     sudo chown root:root "$backup_location"
#     sudo chmod 755 "$backup_location"

#     # Configure Timeshift for RSYNC mode
#     echo "Configuring Timeshift to use RSYNC mode..."
#     sudo timeshift --rsync

#     # Set the backup location explicitly
#     echo "Setting up Timeshift backup location to /dev/$backup_device..."
#     sudo timeshift --create --comments "Initial Backup" --tags "D" --backup-device "/dev/$backup_device"
#     check_success "Timeshift initial backup setup"

#     # Set the backup schedule (e.g., daily)
#     echo "Setting backup schedule to daily..."
#     sudo timeshift --schedule --add --tags "D"
#     check_success "Daily backup schedule set"

#     # Set retention policy to keep 5 backups in total
#     echo "Setting backup retention policy to keep 5 backups..."
#     sudo timeshift --max-daily 5 --max-weekly 0 --max-monthly 0 --max-yearly 0
#     check_success "Backup retention policy set to keep 5 daily backups"

#     # Enable Timeshift for automatic backups (using systemd)
#     echo "Enabling Timeshift for automatic backups..."
#     sudo systemctl enable timeshift.timer
#     sudo systemctl start timeshift.timer
#     check_success "Timeshift automatic backup enabled"

#     echo "Timeshift configuration completed successfully."
# }

# Function to detect if the system is using GRUB
is_grub_installed() {
    if [ -d "/boot/grub" ]; then
        return 0  # GRUB is found
    else
        return 1  # GRUB is not found
    fi
}

# Function to detect if the system is using systemd-boot
is_systemd_boot_installed() {
    if [ -d "/boot/efi/loader/entries" ]; then
        return 0  # systemd-boot is found
    else
        return 1  # systemd-boot is not found
    fi
}

# Function to install Grub Customizer
install_grub_customizer() {
    echo "Adding Grub Customizer PPA and installing..."
    sudo add-apt-repository ppa:danielrichter2007/grub-customizer -y
    sudo nala update
    check_success "Grub Customizer PPA added"
    sudo nala install grub-customizer -y
    check_success "Grub Customizer installation"
}

# # Function to clean up GRUB entries (Windows, recovery, memtest, and UEFI firmware)
# cleanup_grub() {
#     echo "Cleaning up GRUB entries..."

#     # Check if Windows is installed
#     if grep -q "Windows" /boot/grub/grub.cfg; then
#         echo "Windows detected. Renaming Windows Boot Manager..."
#         sudo grub-customizer --no-gui --set-entry-name "Windows Boot Manager" "Windows"
#         check_success "Windows Boot Manager renamed"

#         # Check if Windows Recovery Environment is installed
#         if grep -q "Windows Recovery Environment" /boot/grub/grub.cfg; then
#             echo "Windows Recovery Environment entry detected. Disabling it..."
#             sudo grub-customizer --no-gui --disable-entry "Windows Recovery Environment"
#             check_success "Windows Recovery Environment entry disabled"
#         else
#             echo "No Windows Recovery Environment entry found. Skipping removal."
#         fi
#     else
#         echo "No Windows entry found. Skipping Windows-related actions."
#     fi

#     # Check if the recovery entry exists before trying to remove it
#     if grep -q "Ubuntu recovery mode" /boot/grub/grub.cfg; then
#         echo "Ubuntu recovery mode entry detected. Disabling it..."
#         sudo grub-customizer --no-gui --disable-entry "Ubuntu recovery mode"
#         check_success "Ubuntu recovery mode entry disabled"
#     else
#         echo "No Ubuntu recovery mode entry found. Skipping removal."
#     fi

#     # Check if memtest entry exists (searching for any entry containing "memtest" or "memtest86+")
#     if grep -qi "memtest" /boot/grub/grub.cfg; then
#         echo "Memtest entry detected. Disabling it..."
#         sudo grub-customizer --no-gui --disable-entry "memtest*"
#         check_success "Memtest entry disabled"
#     else
#         echo "No Memtest entry found. Skipping removal."
#     fi

#     # Check if UEFI Firmware Settings entry exists and remove it
#     if grep -q "UEFI Firmware Settings" /boot/grub/grub.cfg; then
#         echo "UEFI Firmware Settings entry detected. Disabling it..."
#         sudo grub-customizer --no-gui --disable-entry "UEFI Firmware Settings"
#         check_success "UEFI Firmware Settings entry disabled"
#     else
#         echo "No UEFI Firmware Settings entry found. Skipping removal."
#     fi

#     # Update GRUB to apply changes
#     echo "Updating GRUB configuration..."
#     sudo update-grub
#     check_success "GRUB configuration updated"
# }

# Function to clean up systemd-boot entries (Windows, recovery, memtest, and UEFI firmware)
cleanup_systemd_boot() {
    echo "Cleaning up systemd-boot entries..."

    # Check for Windows entry in systemd-boot
    if [ -f "/boot/efi/loader/entries/windows*.conf" ]; then
        echo "Windows entry detected. Renaming Windows Boot Manager..."
        sudo sed -i 's/Windows Boot Manager/Windows/' /boot/efi/loader/entries/windows*.conf
        check_success "Windows Boot Manager renamed"

        # Check if Windows Recovery Environment entry exists and remove it
        if [ -f "/boot/efi/loader/entries/windows-recovery*.conf" ]; then
            echo "Windows Recovery Environment entry detected. Removing it..."
            sudo rm -f /boot/efi/loader/entries/windows-recovery*.conf
            check_success "Windows Recovery Environment entry removed"
        else
            echo "No Windows Recovery Environment entry found. Skipping removal."
        fi
    else
        echo "No Windows entry found. Skipping Windows-related actions."
    fi

    # Check if the recovery entry exists before trying to remove it in systemd-boot
    if [ -f "/boot/efi/loader/entries/ubuntu-recovery*.conf" ]; then
        echo "Ubuntu recovery entry detected. Removing it..."
        sudo rm -f /boot/efi/loader/entries/ubuntu-recovery*.conf
        check_success "Ubuntu recovery entry removed"
    else
        echo "No Ubuntu recovery entry found. Skipping removal."
    fi

    # Check if memtest entry exists and remove it in systemd-boot (search for any entry with "memtest" in the name)
    if [ -f "/boot/efi/loader/entries/*memtest*.conf" ]; then
        echo "Memtest entry detected. Removing it..."
        sudo rm -f /boot/efi/loader/entries/*memtest*.conf
        check_success "Memtest entry removed"
    else
        echo "No Memtest entry found. Skipping removal."
    fi

    # Check if UEFI Firmware Settings entry exists and remove it in systemd-boot
    if [ -f "/boot/efi/loader/entries/*uefi-firmware-settings*.conf" ]; then
        echo "UEFI Firmware Settings entry detected. Removing it..."
        sudo rm -f /boot/efi/loader/entries/*uefi-firmware-settings*.conf
        check_success "UEFI Firmware Settings entry removed"
    else
        echo "No UEFI Firmware Settings entry found. Skipping removal."
    fi

    # Rebuild systemd-boot entries (if needed)
    echo "Rebuilding systemd-boot entries..."
    sudo bootctl update
    check_success "Systemd-boot entries updated"
}

# Function to install Grub Customizer only if GRUB is installed
automate_boot_cleanup() {
    echo "Detecting bootloader..."

    if is_grub_installed; then
        echo "GRUB detected. Proceeding with GRUB cleanup and Grub Customizer installation..."
        install_grub_customizer
        # cleanup_grub
        sudo grub-customizer
    elif is_systemd_boot_installed; then
        echo "systemd-boot detected. Proceeding with systemd-boot cleanup..."
        cleanup_systemd_boot
    else
        echo "No recognized bootloader found. Skipping bootloader cleanup."
    fi
}

# Update package list and upgrade installed packages
echo "Updating package list and upgrading packages..."
sudo apt-get update && sudo apt-get upgrade -y
check_success "System update and upgrade"

# Install nala a front end for apt
echo "Installing nala..."
sudo apt-get install nala -y
check_success "Install nala"

# Install essential packages
echo "Installing required packages: apt-transport-https and wget..."
sudo nala install apt-transport-https wget -y
check_success "apt-transport-https and wget installation"

# Install Flatpak and add Flathub repository
echo "Installing Flatpak..."
sudo nala install flatpak -y
check_success "Flatpak installation"
echo "Adding Flathub Repository..."
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
check_success "Flathub Repository addition"

# Pre-accept EULA for ubuntu-restricted-extras to avoid user interaction
echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | sudo debconf-set-selections

# Install Synaptic, VLC, Stacer, GParted, Kitty, Htop, Ranger, Vim, Neovim, Neofetch, Timeshift, GUFW, and Ubuntu Restricted Extras
for package in synaptic vlc stacer gparted kitty htop ranger vim neovim neofetch timeshift gufw ubuntu-restricted-extras; do
    echo "Installing $package..."
    sudo nala install "$package" -y
    check_success "$package installation"
done

# Install Brave browser
echo "Installing Brave..."
flatpak install --noninteractive flathub com.brave.Browser -y
check_success "Brave installation"

# Install ONLYOFFICE Desktop Editors and Microsoft TrueType fonts
echo "Installing ONLYOFFICE Desktop Editors..."
flatpak install --noninteractive flathub org.onlyoffice.desktopeditors -y
check_success "ONLYOFFICE installation"
echo "Installing Microsoft TrueType fonts..."
# echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | sudo debconf-set-selections
sudo nala install ttf-mscorefonts-installer -y
check_success "Microsoft TrueType fonts installation"

# Install Visual Studio Code
echo "Adding Microsoft GPG key..."
# wget -qO- https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
check_success "Downloading Microsoft GPG key"
sudo install -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/
check_success "Microsoft GPG key addition"
echo "Adding Visual Studio Code repository..."
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
# echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
check_success "Visual Studio Code repository addition"
echo "Installing Visual Studio Code..."
sudo nala update && sudo nala install code -y
check_success "Visual Studio Code installation"
# rm microsoft.gpg
# check_success "Removing microsoft GPG key"

# Install LibreWolf
echo "Installing extrepo and enabling LibreWolf repository..."
sudo nala install extrepo -y && sudo extrepo enable librewolf
sudo nala update
check_success "extrepo and LibreWolf repository setup"
echo "Installing LibreWolf..."
sudo nala install librewolf -y
check_success "LibreWolf installation"

# Ensure Firefox is removed and LibreWolf is set as default browser
if ! command -v librewolf &>/dev/null; then
    echo "LibreWolf installation failed. Retaining Firefox as the default browser."
else
    echo "Uninstalling Firefox..."
    sudo nala remove --purge firefox -y
    check_success "Firefox uninstallation"
    sudo rm -rf ~/.mozilla
    check_success "Cleaning residual configuration files"
    echo "Setting LibreWolf as the default browser..."
    sudo update-alternatives --set x-www-browser /usr/bin/librewolf
    xdg-settings set default-web-browser librewolf.desktop
    check_success "LibreWolf set as default browser"
fi

# Set Kitty as the default terminal emulator
sudo update-alternatives --install /usr/bin/x-terminal-emulator kitty /usr/bin/kitty 1
sudo update-alternatives --set x-terminal-emulator /usr/bin/kitty

# Add a fallback to ensure that the 'kitty' command works
sudo update-alternatives --install /usr/bin/kitty kitty /usr/bin/kitty 1

# Set OnlyOffice as default for document types
echo "Setting OnlyOffice as default for various document types..."
for type in application/vnd.openxmlformats-officedocument.wordprocessingml.document \
    application/msword application/vnd.openxmlformats-officedocument.spreadsheetml.sheet \
    application/vnd.ms-excel application/vnd.openxmlformats-officedocument.presentationml.presentation \
    application/vnd.ms-powerpoint application/pdf; do
    xdg-mime default onlyoffice.desktop $type
done
check_success "OnlyOffice set as default for document types"

# Set VLC as the default media player
echo "Setting VLC as the default media player..."
for type in video/* audio/*; do
    xdg-mime default vlc.desktop $type
done
check_success "VLC set as default media player"

# Enable GUFW firewall
echo "Enabling GUFW firewall..."
sudo ufw enable
check_success "GUFW firewall enabled"

# Install and set up Grub Customizer
# echo "Adding Grub Customizer PPA and installing..."
# sudo add-apt-repository ppa:danielrichter2007/grub-customizer -y
# sudo apt update
# check_success "Grub Customizer PPA added"
# sudo apt install grub-customizer -y
# check_success "Grub Customizer installation"

# Remove unnecessary packages
echo "Performing system cleanup..."
sudo nala clean && sudo nala autoremove --purge -y
check_success "System cleanup"

# Boot Cleanup
automate_boot_cleanup

# Timeshift backup configuration
configure_timeshift

# Launch Timeshift for manual gui setup
if [[ $DISPLAY ]]; then
    # echo "Launching Grub Customizer..."
    # sudo grub-customizer
    # check_success "Grub Customizer setup completed"
    echo "Launching Timeshift GUI for initial setup..."
    sudo timeshift-gtk
    check_success "Timeshift GUI launched for configuration"
else
    echo "Skipping GUI-based applications as no graphical session is detected."
fi

# Prompt user to reboot
read -p "Some changes will take effect after a reboot. Do you want to reboot now? (yes/no): " answer
if [[ $answer == "yes" || $answer == "Yes" || $answer == "YES" || $answer == "y" || $answer == "Y" ]]; then
    echo "Rebooting now..."
    reboot
else
    echo "You can reboot later to apply the changes."
fi

#**************************************************************************************************************************************************************************#
