#!/bin/bash
# This script installs Hydrogen on an Arch Linux system

PYTHONDIR="${HOME}/klippy-env"
SYSTEMDDIR="/etc/systemd/system"
AURCLIENT="pamac"
HYDROGEN_USER=$USER
HYDROGEN_GROUP=$HYDROGEN_USER

# Step 1: Install system packages
install_packages()
{
    # Packages for python cffi
    PKGLIST="python2-virtualenv libffi base-devel"
    # kconfig requirements
    PKGLIST="${PKGLIST} ncurses"
    # hub-ctrl
    PKGLIST="${PKGLIST} libusb"
    # AVR chip installation and building
    PKGLIST="${PKGLIST} avrdude avr-gcc avr-binutils avr-libc"
    # ARM chip installation and building
    AURLIST="stm32flash"
    PKGLIST="${PKGLIST} arm-none-eabi-newlib"
    PKGLIST="${PKGLIST} arm-none-eabi-gcc arm-none-eabi-binutils"

    # Install desired packages
     report_status "Installing packages..."
     sudo pacman -S ${PKGLIST}
     $AURCLIENT build ${AURLIST}
}

# Step 2: Create python virtual environment
create_virtualenv()
{
    report_status "Updating python virtual environment..."

    # Create virtualenv if it doesn't already exist
    [ ! -d ${PYTHONDIR} ] && virtualenv2 ${PYTHONDIR}

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
# Use systemctl to enable the Hydrogen systemd service script
    sudo systemctl enable hydrogen.service
    report_status "Make sure to add $HYDROGEN_USER to the user group controlling your serial printer port"
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
