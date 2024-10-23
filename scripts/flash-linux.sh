#!/bin/bash
# This script installs the Linux MCU code to /usr/local/bin/

if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root"
    exit -1
fi
set -e

# Setting build output directory
if [ -z "${1}" ]; then
    out='out'
else
    out=${1}
fi

# Install new micro-controller code
echo "Installing micro-controller code to /usr/local/bin/"
rm -f /usr/local/bin/hydrogen_mcu
cp ${out}/hydrogen.elf /usr/local/bin/hydrogen_mcu
sync

# Restart (if system install script present)
if [ -f /etc/init.d/hydrogen_pru ]; then
    echo "Attempting host PRU restart..."
    service hydrogen_pru restart
fi

# Restart (if system install script present)
if [ -f /etc/systemd/system/hydrogen-mcu.service ]; then
    echo "Attempting host MCU restart..."
    systemctl restart hydrogen-mcu
fi

if [ -f /etc/init.d/hydrogen_mcu ]; then
    echo "Attempting host MCU restart..."
    service hydrogen_mcu restart
fi
