#!/bin/bash

# AUTHOR  : Warad Teni
# MOBILE  : (+91) 91463 50289
# EMAIL   : waradteni@gmail.com

#************************************************************************************#

# Script to install Grub Customizer on Ubuntu

# Redirect all output (stdout and stderr) to a log file and the terminal
exec > >(tee -i grubcustomizer_install.log) 2>&1

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
}

# Update package list and upgrade installed packages
echo "Updating package list and upgrading installed packages..."
sudo apt update && sudo apt upgrade -y
check_success "Updating and upgrading packages"

# Install software-properties-common for adding PPAs
echo "Installing software-properties-common..."
sudo apt install software-properties-common -y
check_success "Installing software-properties-common"

# Add Grub Customizer PPA
echo "Adding Grub Customizer PPA..."
sudo add-apt-repository ppa:danielrichter2007/grub-customizer -y
check_success "Adding PPA"

# Update package list after adding PPA
echo "Updating package list again..."
sudo apt update
check_success "Updating package list after adding PPA"

# Install Grub Customizer
echo "Installing Grub Customizer..."
sudo apt install grub-customizer -y
check_success "Installing Grub Customizer"

# Launch Grub Customizer
echo "Launching Grub Customizer..."
grub-customizer

echo "Grub Customizer installation complete!"

#************************************************************************************#
