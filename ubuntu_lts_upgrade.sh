#!/bin/bash

# System Update and Upgrade Script
# AUTHOR  : Warad Teni
# MOBILE  : (+91) 91463 50289
# EMAIL   : waradteni@gmail.com

#***************************************************************************#

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

# Step 1: Update package lists
echo "Updating package lists..."
sudo apt update -y
check_success "Package list update"

# Step 2: Upgrade all packages
echo "Upgrading installed packages..."
sudo apt upgrade -y
check_success "Package upgrade"

# Step 3: Perform distribution upgrade
echo "Performing distribution upgrade..."
sudo apt dist-upgrade -y
check_success "Distribution upgrade"

# Step 4: Remove unnecessary packages
echo "Removing unnecessary packages..."
sudo apt autoremove -y
check_success "Autoremove"

# Step 5: Ensure update-manager-core is installed
echo "Installing update-manager-core if not present..."
sudo apt install update-manager-core -y
check_success "Update-manager-core installation"

# Step 6: Ensure the system upgrades only to the next LTS release
echo "Configuring system to upgrade only to the next LTS release..."
sudo sed -i 's/^Prompt=.*/Prompt=lts/' /etc/update-manager/release-upgrades
check_success "LTS upgrade configuration"

# Step 7: Perform a release upgrade
echo "Checking for distribution release upgrade..."
sudo do-release-upgrade
check_success "Release upgrade"

# Step 8: Reboot the system
echo "Rebooting the system..."
sudo reboot

#***************************************************************************#
