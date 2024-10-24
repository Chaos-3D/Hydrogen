#!/bin/bash
# This script installs Hydrogen on an Ubuntu 22.04 ("Jammy") machine

PYTHONDIR="${HOME}/klippy-env"
SYSTEMDDIR="/etc/systemd/system"
HYDROGEN_USER=$USER
HYDROGEN_GROUP=$HYDROGEN_USER

# Step 1: Install system packages
install_packages()
{
    # Packages for python cffi
    PKGLIST="virtualenv python3-dev libffi-dev build-essential"
    # kconfig requirements
    PKGLIST="${PKGLIST} libncurses-dev"
    # hub-ctrl
    PKGLIST="${PKGLIST} libusb-dev"
    # AVR chip installation and building
    PKGLIST="${PKGLIST} avrdude gcc-avr binutils-avr avr-libc"
    # ARM chip installation and building
    PKGLIST="${PKGLIST} stm32flash dfu-util libnewlib-arm-none-eabi"
    PKGLIST="${PKGLIST} gcc-arm-none-eabi binutils-arm-none-eabi libusb-1.0"

    # Update system package info
    report_status "Running apt-get update..."
    sudo apt-get update

    # Install desired packages
    report_status "Installing packages..."
    sudo apt-get install --yes ${PKGLIST}
}

# Step 2: Create python virtual environment
create_virtualenv()
{
    report_status "Updating python virtual environment..."

    # Create virtualenv if it doesn't already exist
    [ ! -d ${PYTHONDIR} ] && virtualenv -p python3 ${PYTHONDIR}

    # Install/update dependencies
    ${PYTHONDIR}/bin/pip install -r ${SRCDIR}/scripts/klippy-requirements.txt
}

# Step 3: Install startup script
install_script()
{
# Create systemd service file
    HYDROGEN_LOG=/tmp/klippy.log
    report_status "Installing system start script..."
    sudo /bin/sh -c "cat > $SYSTEMDDIR/hydrogen.service" << EOF
[Unit]
Description=Starts Hydrogen on startup
After=network.target

[Install]
WantedBy=multi-user.target

[Service]
Type=simple
User=$HYDROGEN_USER
RemainAfterExit=yes
ExecStart=${PYTHONDIR}/bin/python ${SRCDIR}/klippy/klippy.py ${HOME}/printer.cfg -l ${HYDROGEN_LOG}
EOF
# Use systemctl to enable the hydrogen systemd service script
    sudo systemctl enable hydrogen.service
}

# Step 4: Start host software
start_software()
{
    report_status "Launching Hydrogen host software..."
    sudo systemctl start hydrogen
}

# Helper functions
report_status()
{
    echo -e "\n\n###### $1"
}

verify_ready()
{
    if [ "$EUID" -eq 0 ]; then
        echo "This script must not run as root"
        exit -1
    fi
}

# Force script to exit if an error occurs
set -e

# Find SRCDIR from the pathname of this script
SRCDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )"/.. && pwd )"

# Run installation steps defined above
verify_ready
install_packages
create_virtualenv
install_script
start_software
