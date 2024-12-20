#!/bin/bash

# AUTHOR  : Warad Teni
# MOBILE  : (+91) 91463 50289
# EMAIL   : waradteni@gmail.com

#******************************************************************************************************************************#

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

# Update package list and upgrade installed packages
echo "Updating package list and upgrading packages..."
sudo apt update && sudo apt upgrade -y
check_success "System update and upgrade"

# Install essential packages
echo "Installing required packages: apt-transport-https and wget..."
sudo apt install apt-transport-https wget -y
check_success "apt-transport-https and wget installation"

# Install Flatpak and add Flathub repository
echo "Installing Flatpak..."
sudo apt install flatpak -y
check_success "Flatpak installation"
echo "Adding Flathub Repository..."
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
check_success "Flathub Repository addition"

# Pre-accept EULA for ubuntu-restricted-extras to avoid user interaction
echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | sudo debconf-set-selections

# Install Synaptic, VLC, Stacer, GParted, Kitty, Htop, Ranger, Vim, Neovim, Neofetch, Timeshift, GUFW, and Ubuntu Restricted Extras
for package in synaptic vlc stacer gparted kitty htop ranger vim neovim neofetch timeshift gufw ubuntu-restricted-extras; do
    echo "Installing $package..."
    sudo apt install "$package" -y
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
sudo apt install ttf-mscorefonts-installer -y
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
sudo apt update && sudo apt install code -y
check_success "Visual Studio Code installation"
# rm microsoft.gpg
# check_success "Removing microsoft GPG key"

# Install LibreWolf
echo "Installing extrepo and enabling LibreWolf repository..."
sudo apt install extrepo -y && sudo extrepo enable librewolf
sudo apt update
check_success "extrepo and LibreWolf repository setup"
echo "Installing LibreWolf..."
sudo apt install librewolf -y
check_success "LibreWolf installation"

# Ensure Firefox is removed and LibreWolf is set as default browser
if ! command -v librewolf &>/dev/null; then
    echo "LibreWolf installation failed. Retaining Firefox as the default browser."
else
    echo "Uninstalling Firefox..."
    sudo apt remove --purge firefox -y
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
echo "Adding Grub Customizer PPA and installing..."
sudo add-apt-repository ppa:danielrichter2007/grub-customizer -y
sudo apt update
check_success "Grub Customizer PPA added"
sudo apt install grub-customizer -y
check_success "Grub Customizer installation"

# Remove unnecessary packages
echo "Performing system cleanup..."
sudo apt clean && sudo apt autoremove --purge -y
check_success "System cleanup"

# Launch Grub Customizer and Timeshift GUI for initial configuration
if [[ $DISPLAY ]]; then
    echo "Launching Grub Customizer..."
    sudo grub-customizer
    check_success "Grub Customizer setup completed"
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

#******************************************************************************************************************************#
