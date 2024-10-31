#!/bin/bash

# AUTHOR  : Warad Teni
# MOBILE  : (+91) 91463 50289
# EMAIL   : waradteni@gmail.com

#******************************************************************************************************************************#

# Function to check if a command was successful
check_success() {
    if [ $? -ne 0 ]; then
        echo "Error: $1 failed. Exiting."
        exit 1
    fi
    echo "$1 succeeded."
}

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root. Use sudo."
   exit 1
fi

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

# Install Synaptic, VLC, Stacer, GParted, Htop, Neofetch, Timeshift, GUFW, and Ubuntu Restricted Extras
for package in synaptic vlc stacer gparted htop neofetch timeshift gufw ubuntu-restricted-extras; do
    echo "Installing $package..."
    sudo apt install "$package" -y
    check_success "$package installation"
done

# Install Brave browser
echo "Installing Brave..."
flatpak install flathub com.brave.Browser -y
check_success "Brave installation"

# Install ONLYOFFICE Desktop Editors and Microsoft TrueType fonts
echo "Installing ONLYOFFICE Desktop Editors..."
flatpak install flathub org.onlyoffice.desktopeditors -y
check_success "ONLYOFFICE installation"
echo "Installing Microsoft TrueType fonts..."
echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | sudo debconf-set-selections
sudo apt install ttf-mscorefonts-installer -y
check_success "Microsoft TrueType fonts installation"

# Install Visual Studio Code
echo "Adding Microsoft GPG key..."
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
check_success "Microsoft GPG key addition"
echo "Adding Visual Studio Code repository..."
echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
check_success "Visual Studio Code repository addition"
echo "Installing Visual Studio Code..."
sudo apt update && sudo apt install code -y
check_success "Visual Studio Code installation"

# Install LibreWolf
echo "Installing extrepo and enabling LibreWolf repository..."
sudo apt install extrepo -y && sudo extrepo enable librewolf
sudo apt update
check_success "extrepo and LibreWolf repository setup"
echo "Installing LibreWolf..."
sudo apt install librewolf -y
check_success "LibreWolf installation"

# Ensure Firefox is removed and LibreWolf is set as default browser
echo "Uninstalling Firefox..."
sudo apt remove --purge firefox -y
check_success "Firefox uninstallation"
echo "Setting LibreWolf as the default browser..."
sudo update-alternatives --set x-www-browser /usr/bin/librewolf
xdg-settings set default-web-browser librewolf.desktop
check_success "LibreWolf set as default browser"

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
xdg-mime default vlc.desktop video/*
check_success "VLC set as default media player"

# Enable GUFW firewall
echo "Enabling GUFW firewall..."
sudo ufw enable
check_success "GUFW firewall enabled"

# Install and set up Grub Customizer
echo "Adding Grub Customizer PPA and installing..."
sudo add-apt-repository ppa:danielrichter2007/grub-customizer -y
check_success "Grub Customizer PPA added"
sudo apt install grub-customizer -y
check_success "Grub Customizer installation"

# Remove unnecessary packages
echo "Performing system cleanup..."
sudo apt autoremove -y
check_success "System cleanup"

# Launch Grub Customizer and Timeshift GUI for initial configuration
echo "Launching Grub Customizer..."
grub-customizer
check_success "Grub Customizer setup completed"
echo "Launching Timeshift GUI for initial setup..."
sudo timeshift-gtk
check_success "Timeshift GUI launched for configuration"

# Prompt user to reboot
read -p "Some changes will take effect after a reboot. Do you want to reboot now? (yes/no): " answer
if [[ $answer == "yes" || $answer == "Yes" || $answer == "YES" || $answer == "y" || $answer == "Y" ]]; then
    echo "Rebooting now..."
    reboot
else
    echo "You can reboot later to apply the changes."
fi

#******************************************************************************************************************************#
