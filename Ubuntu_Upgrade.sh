#!/bin/bash

# System Update and Upgrade Script
# AUTHOR  : Warad Teni
# MOBILE  : (+91) 91463 50289
# EMAIL   : waradteni@gmail.com

#*****************************************************#

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

# Step 2: Upgrade all packages
echo "Upgrading installed packages..."
sudo apt upgrade -y

# Step 3: Perform distribution upgrade
echo "Performing distribution upgrade..."
sudo apt dist-upgrade -y

# Step 4: Remove unnecessary packages
echo "Removing unnecessary packages..."
sudo apt autoremove -y

# Step 5: Ensure update-manager-core is installed
echo "Installing update-manager-core if not present..."
sudo apt install update-manager-core -y

# Step 6: Perform a release upgrade
echo "Checking for distribution release upgrade..."
sudo do-release-upgrade -y

# Step 7: Reboot the system
echo "Rebooting the system..."
sudo reboot

#*****************************************************#