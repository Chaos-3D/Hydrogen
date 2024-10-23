#!/bin/bash
#  This script launches flash_sdcard.py, a utitlity that enables
#  unattended firmware updates on boards with "SD Card" bootloaders

# Non-standard installations may need to change this location
KLIPPY_ENV="${HOME}/klippy-env/bin/python"
SRCDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )"/.. && pwd )"
HYDROGEN_BIN="${SRCDIR}/out/hydrogen.bin"
HYDROGEN_BIN_DEFAULT=$HYDROGEN_BIN
HYDROGEN_DICT_DEFAULT="${SRCDIR}/out/hydrogen.dict"
SPI_FLASH="${SRCDIR}/scripts/spi_flash/spi_flash.py"
BAUD_ARG=""
CHECK_ARG=""
# Force script to exit if an error occurs
set -e

print_help_message()
{
    echo "SD Card upload utility for Hydrogen"
    echo
    echo "usage: flash_sdcard.sh [-h] [-l] [-c] [-b <baud>] [-f <firmware>] [-d <dictionary>]"
    echo "                       <device> <board>"
    echo
    echo "positional arguments:"
    echo "  <device>          device serial port"
    echo "  <board>           board type"
    echo
    echo "optional arguments:"
    echo "  -h                show this message"
    echo "  -l                list available boards"
    echo "  -c                run flash check/verify only (skip upload)"
    echo "  -b <baud>         serial baud rate (default is 250000)"
    echo "  -f <firmware>     path to hydrogen.bin"
    echo "  -d <dictionary>   path to hydrogen.dict for firmware validation"
}

# Parse command line "optional args"
while getopts "hlcb:f:d:" arg; do
    case $arg in
        h)
            print_help_message
            exit 0
            ;;
        l)
            ${KLIPPY_ENV} ${SPI_FLASH} -l
            exit 0
            ;;
        c) CHECK_ARG="-c";;
        b) BAUD_ARG="-b ${OPTARG}";;
        f) HYDROGEN_BIN=$OPTARG;;
        d) HYDROGEN_DICT=$OPTARG;;
    esac
done

# Make sure that we have the correct number of positional args
if [ $(($# - $OPTIND + 1)) -ne 2 ]; then
    echo "Invalid number of args: $(($# - $OPTIND + 1))"
    exit -1
fi

DEVICE=${@:$OPTIND:1}
BOARD=${@:$OPTIND+1:1}

if [ ! -f $HYDROGEN_BIN ]; then
    echo "No file found at '${HYDROGEN_BIN}'"
    exit -1
fi

if [ ! -e $DEVICE ]; then
    echo "No device found at '${DEVICE}'"
    exit -1
fi

if [ ! $HYDROGEN_DICT ] && [ $HYDROGEN_BIN == $HYDROGEN_BIN_DEFAULT ] ; then
    HYDROGEN_DICT=$HYDROGEN_DICT_DEFAULT
fi

if [ $HYDROGEN_DICT ]; then
    if [ ! -f $HYDROGEN_DICT ]; then
        echo "No file found at '${HYDROGEN_BIN}'"
        exit -1
    fi
    HYDROGEN_DICT="-d ${HYDROGEN_DICT}"
fi

# Run Script
echo "Flashing ${HYDROGEN_BIN} to ${DEVICE}"
${KLIPPY_ENV} ${SPI_FLASH} ${CHECK_ARG} ${BAUD_ARG} ${HYDROGEN_DICT} ${DEVICE} ${BOARD} ${HYDROGEN_BIN}
