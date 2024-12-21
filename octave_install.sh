#!/bin/bash

# AUTHOR  : Warad Teni
# MOBILE  : (+91) 91463 50289
# EMAIL   : waradteni@gmail.com

#**********************************************************************************************************#

# Redirect all output (stdout and stderr) to a log file and the terminal
exec > >(tee -i octave_install.log) 2>&1

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
echo "Updating package list and upgrading installed packages..."
sudo apt update && sudo apt upgrade -y
check_success "Updating and upgrading packages"

# Install Octave and required packages
echo "Installing Octave and development packages..."
sudo apt install octave octave-dev python3 python3-pip -y
check_success "Installing Octave and required packages"

# Start Octave and install required packages
echo "Starting Octave to install additional packages..."
octave << EOF
pkg update

% Install required packages
pkg install -forge control
pkg install -forge signal
pkg install -forge communications
pkg install -forge symbolic

% Load the packages
pkg load control
pkg load signal
pkg load communications
pkg load symbolic

exit
EOF

check_success "Installing Octave packages"

# Open GNU Octave
echo "Opening GNU Octave..."
octave &

echo "Installation complete. GNU Octave has been opened. You can now run your modulation simulation code."

#**********************************************************************************************************#

