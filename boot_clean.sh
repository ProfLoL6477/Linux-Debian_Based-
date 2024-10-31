#!/bin/bash

# AUTHOR  : Warad Teni
# MOBILE  : (+91) 91463 50289
# EMAIL   : waradteni@gmail.com

#****************************************************************#

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

#****************************************************************#
