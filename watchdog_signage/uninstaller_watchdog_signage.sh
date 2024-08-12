#!/bin/bash

# Define variables for directories, files, and service
MAIN_DIR="/home/pi/MTTO"
LOG_FILE="/home/pi/MTTO/watchdog_service.log"
SERVICE_FILE="/etc/systemd/system/watchdog_signage.service"

# Stop the watchdog_signage service
if systemctl is-active --quiet watchdog_signage; then
    echo "Stopping watchdog_signage service..."
    sudo service watchdog_signage stop
fi

# Disable the watchdog_signage service
if systemctl is-enabled --quiet watchdog_signage; then
    echo "Disabling watchdog_signage service..."
    sudo systemctl disable watchdog_signage
fi

# Remove the service file
if [ -f "$SERVICE_FILE" ]; then
    echo "Removing watchdog_signage service file..."
    sudo rm -f "$SERVICE_FILE"
fi

# Reload systemd daemon
echo "Reloading systemd daemon..."
sudo systemctl daemon-reload

# Remove log file
if [ -f "$LOG_FILE" ]; then
    echo "Removing log file..."
    rm -f "$LOG_FILE"
fi

# Remove the MTTO directory and its contents
if [ -d "$MAIN_DIR" ]; then
    echo "Removing MTTO directory and its contents..."
    rm -rf "$MAIN_DIR"
fi

echo "Uninstallation complete."