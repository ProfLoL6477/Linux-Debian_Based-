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
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
check_success "Adding Microsoft GPG key"

# Add Visual Studio Code repository
echo "Adding Visual Studio Code repository..."
echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
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

#******************************************************************************************************************************#

