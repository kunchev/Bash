#!/bin/bash

set -e


# VSCode installation script for RHEL, Fedora, and CentOS based distros

# Repository setup
echo "Configuring repository..."
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'

# VSCode installation
dnf check-update
sudo dnf install code -y

# Check status of setup
if [ $? -eq 0 ]
then
  echo "You can now start using VSCode"
else
  echo "Setup failed"
  exit 1
fi
