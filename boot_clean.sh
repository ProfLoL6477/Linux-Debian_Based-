#!/bin/bash

# AUTHOR  : Warad Teni
# MOBILE  : (+91) 91463 50289
# EMAIL   : waradteni@gmail.com

#************************************************************************************#

# Redirect all output (stdout and stderr) to a log file and the terminal
exec > >(tee -i boot_clean.log) 2>&1

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

# Remove unnecessary packages
echo "Removing unnecessary packages..."
sudo apt autoremove -y
check_success "Removing unnecessary packages"

echo "System update and cleanup complete!"

#************************************************************************************#
