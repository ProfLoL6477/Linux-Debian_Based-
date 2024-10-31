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

# Update package list
echo "Updating package list..."
sudo apt update
check_success "Updating package list"

# Upgrade installed packages
echo "Upgrading installed packages..."
sudo apt upgrade -y
check_success "Upgrading packages"

echo "System update complete!"

# Install essential packages first
# Install required packages for adding PPAs and downloading files
echo "Installing required packages: apt-transport-https and wget..."
sudo apt install apt-transport-https wget -y
check_success "Installing apt-transport-https and wget"

# Install Flatpak
echo "Installing Flatpak..."
sudo apt install flatpak -y
check_success "Flatpak installation"

# Add Flathub repository
echo "Adding Flathub Repository..."
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
check_success "Adding Flathub Repository"

# Install Synaptic
echo "Installing Synaptic..."
sudo apt install synaptic -y
check_success "Synaptic installation"

# Install VLC
echo "Installing VLC..."
sudo apt install vlc -y
check_success "VLC installation"

# Install Stacer
echo "Installing Stacer..."
sudo apt install stacer -y
check_success "Stacer installation"

# Install GParted
echo "Installing GParted..."
sudo apt install gparted -y
check_success "GParted installation"

# Install Htop
echo "Installing Htop..."
sudo apt install htop -y
check_success "Htop installation"

# Install Neofetch
echo "Installing Neofetch..."
sudo apt install neofetch -y
check_success "Neofetch installation"

# Install Timeshift
echo "Installing Timeshift..."
sudo apt install timeshift -y
check_success "Timeshift installation"

# Install GUFW
echo "Installing GUFW..."
sudo apt install gufw -y
check_success "GUFW installation"

# Install Ubuntu Restricted Extras
echo "Installing Ubuntu Restricted Extras..."
sudo apt install ubuntu-restricted-extras -y
check_success "Ubuntu Restricted Extras installation"

# Install Brave browser
echo "Installing Brave..."
flatpak install flathub com.brave.Browser -y
check_success "Brave installation"

# Install ONLYOFFICE Desktop Editors
echo "Installing ONLYOFFICE Desktop Editors..."
flatpak install flathub org.onlyoffice.desktopeditors -y
check_success "ONLYOFFICE installation"

# Install Visual Studio Code
# Add Microsoft's GPG key
echo "Adding Microsoft GPG key..."
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
check_success "Adding Microsoft GPG key"

# Add Visual Studio Code repository
echo "Adding Visual Studio Code repository..."
echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
check_success "Adding Visual Studio Code repository"

# Update package list again for Visual Studio Code
echo "Updating package list after adding Visual Studio Code repository..."
sudo apt update
check_success "Updating package list for Visual Studio Code"

# Install Visual Studio Code
echo "Installing Visual Studio Code..."
sudo apt install code -y
check_success "Installing Visual Studio Code"

# Librewolf
# Install extrepo
echo "Installing extrepo..."
sudo apt install extrepo -y
check_success "extrepo installation"

# Enable the LibreWolf repository
echo "Enabling LibreWolf repository..."
sudo extrepo enable librewolf
check_success "LibreWolf repository enablement"

# Update package lists for LibreWolf
echo "Updating package lists for LibreWolf..."
sudo apt update
check_success "Package list update for LibreWolf"

# Install LibreWolf
echo "Installing LibreWolf..."
sudo apt install librewolf -y
check_success "LibreWolf installation"

# Uninstall Firefox
echo "Uninstalling Firefox..."
sudo apt remove --purge firefox -y
check_success "Firefox uninstallation"

# Set LibreWolf as the default browser
echo "Setting LibreWolf as the default browser..."
xdg-settings set default-web-browser librewolf.desktop
check_success "Setting LibreWolf as default browser"

# Set OnlyOffice as default for document types
echo "Setting OnlyOffice as default for various document types..."
xdg-mime default onlyoffice.desktop application/vnd.openxmlformats-officedocument.wordprocessingml.document
xdg-mime default onlyoffice.desktop application/msword
xdg-mime default onlyoffice.desktop application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
xdg-mime default onlyoffice.desktop application/vnd.ms-excel
xdg-mime default onlyoffice.desktop application/vnd.openxmlformats-officedocument.presentationml.presentation
xdg-mime default onlyoffice.desktop application/vnd.ms-powerpoint
xdg-mime default onlyoffice.desktop application/pdf
check_success "Setting OnlyOffice as default for document types"

# Set VLC as the default media player
echo "Setting VLC as the default media player..."
xdg-mime default vlc.desktop video/*
check_success "Setting VLC as default media player"

# Enable GUFW firewall
echo "Enabling GUFW firewall..."
sudo ufw enable
check_success "Enabling GUFW firewall"

# Grub-customizer
# Add Grub Customizer PPA
echo "Adding Grub Customizer PPA..."
sudo add-apt-repository ppa:danielrichter2007/grub-customizer -y
check_success "Adding Grub Customizer PPA"

# Update package list after adding PPA
echo "Updating package list for Grub Customizer..."
sudo apt update
check_success "Updating package list for Grub Customizer"

# Install Grub Customizer
echo "Installing Grub Customizer..."
sudo apt install grub-customizer -y
check_success "Installing Grub Customizer"

# Remove unnecessary packages
echo "Removing unnecessary packages..."
sudo apt autoremove -y
check_success "Removing unnecessary packages"

echo "System cleanup complete!"

# Launch Grub Customizer
echo "Launching Grub Customizer..."
grub-customizer
check_success "Grub Customizer setup completed."

# Launch Timeshift GUI for initial configuration
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
