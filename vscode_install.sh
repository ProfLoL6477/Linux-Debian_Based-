#!/bin/bash

# AUTHOR  : Warad Teni
# MOBILE  : (+91) 91463 50289
# EMAIL   : waradteni@gmail.com

#**************************************************************************************************************************************************************************#

# Redirect all output (stdout and stderr) to a log file and the terminal
exec > >(tee -i vscode_install.log) 2>&1

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

# Update package list
echo "Updating package list..."
sudo apt update
check_success "Updating package list"

# Upgrade installed packages
echo "Upgrading installed packages..."
sudo apt upgrade -y
check_success "Upgrading packages"

# Install necessary dependencies
echo "Installing required packages: apt-transport-https and wget..."
sudo apt install apt-transport-https wget -y
check_success "Installing apt-transport-https and wget"

# Add Microsoft's GPG key
echo "Adding Microsoft GPG key..."
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
check_success "Downloading Microsoft GPG key"
sudo install -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/
check_success "Microsoft GPG key addition"

# Add Visual Studio Code repository
echo "Adding Visual Studio Code repository..."
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
check_success "Adding Visual Studio Code repository"

# Update package list again
echo "Updating package list after adding Visual Studio Code repository..."
sudo apt update
check_success "Updating package list for Visual Studio Code"

# Install Visual Studio Code
echo "Installing Visual Studio Code..."
sudo apt install code -y
check_success "Installing Visual Studio Code"

echo "Visual Studio Code installation complete!"

#**************************************************************************************************************************************************************************#

