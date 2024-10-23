#!/bin/bash
# Uninstall script for raspbian/debian type installations

# Stop Hydrogen Service
echo "#### Stopping Hydrogen Service.."
sudo service hydrogen stop

# Remove Hydrogen from Startup
echo
echo "#### Removing Hydrogen from Startup.."
sudo update-rc.d -f hydrogen remove

# Remove Hydrogen from Services
echo
echo "#### Removing Hydrogen Service.."
sudo rm -f /etc/init.d/hydrogen /etc/default/hydrogen

# Notify user of method to remove Hydrogen source code
echo
echo "The Hydrogen system files have been removed."
echo
echo "The following command is typically used to remove local files:"
echo "  rm -rf ~/klippy-env ~/hydrogen"
