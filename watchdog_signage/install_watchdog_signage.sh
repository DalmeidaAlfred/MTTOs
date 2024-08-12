#!/bin/bash

# Ensure the MAIN directory exists
MAIN_DIR="/home/pi/MTTO"

if [ ! -d "$MAIN_DIR" ]; then
    mkdir -p "$MAIN_DIR"
    echo Creating MTTO directory
fi

# Define log files and their paths
LOG_DIR="/home/pi/MTTO/watchdog_service.log"

# Check and create log files if they don't exist
[ -f "$LOG_DIR" ] || { touch "$LOG_DIR"; echo "Creating $(basename "$LOG_DIR")"; }

# Check if cec-utils is installed
if ! dpkg -l | grep -qw cec-utils; then
    echo "Cec-utils not found. Installing..."
    sudo apt install -y cec-utils
else
    echo "Cec-utils is already installed."
fi

wget -q -T 10 "https://raw.githubusercontent.com/DalmeidaAlfred/MTTOs/main/watchdog_signage/Start_watchdog_signage.sh" -O /home/pi/MTTO/Start_watchdog_signage.sh;
wget -q -T 10 "https://raw.githubusercontent.com/DalmeidaAlfred/MTTOs/main/watchdog_signage/Stop_watchdog_signage.sh" -O /home/pi/MTTO/Stop_watchdog_signage.sh;
wget -q -T 10 "https://raw.githubusercontent.com/DalmeidaAlfred/MTTOs/main/watchdog_signage/watchdog_signage.service" -O /home/pi/MTTO/watchdog_signage.service;
wget -q -T 10 "https://raw.githubusercontent.com/DalmeidaAlfred/MTTOs/main/watchdog_signage/watchdog_signage.sh" -O /home/pi/MTTO/watchdog_signage.sh;
wget -q -T 10 "https://raw.githubusercontent.com/DalmeidaAlfred/MTTOs/main/watchdog_signage/uninstaller_watchdog_signage.sh" -O /home/pi/MTTO/uninstaller_watchdog_signage.sh;

chmod a+x /home/pi/MTTO/Start_watchdog_signage.sh
chmod a+x /home/pi/MTTO/Stop_watchdog_signage.sh
chmod a+x /home/pi/MTTO/watchdog_signage.sh
chmod a+x /home/pi/MTTO/uninstaller_watchdog_signage.sh

sudo mv -f /home/pi/MTTO/watchdog_signage.service /etc/systemd/system/watchdog_signage.service

sudo systemctl enable /etc/systemd/system/watchdog_signage.service
sudo systemctl daemon-reload
sudo service watchdog_signage start