#!/bin/bash

LOG_FILE="/home/pi/MTTO/watchdog_service.log"

LAST_TV_STATUS="power status: on"

while true; do
    echo 'scan' | cec-client -s -d 1
    CURRENT_TV_STATUS=$(echo "pow 0" | cec-client -s -d 4 | grep "power status:")

    if [ -z "$CURRENT_TV_STATUS" ]; then
        echo "$(date): Error - Unable to retrieve TV power status." >> "$LOG_FILE"
    elif [[ "$LAST_TV_STATUS" == "power status: standby" || "$LAST_TV_STATUS" == "power status: transitioning from standby to on" ]] && [[ "$CURRENT_TV_STATUS" == "power status: on" ]]; then
        echo "$(date): TV restart detected, stopping signage." >> "$LOG_FILE"
        echo "Turn off signage"
        # Kill the existing signage process
    for KILLPID in $(ps ax | grep optisigns | awk '{print $1;}'); do
        kill -9 $KILLPID;
    done

    sleep 15

    echo "$(date): TV restart detected, starting signage." >> "$LOG_FILE"
    echo "Turn On signage"

    # Start the signage application
    /home/pi/Downloads/optisigns-5.6.32-arm64.AppImage &
    echo "$(date): Signage process started." >> "$LOG_FILE"
    fi

    echo "$(date): Nothing detected." >> "$LOG_FILE"

    # Update LAST_TV_STATUS for the next loop iteration
    LAST_TV_STATUS="$CURRENT_TV_STATUS"

    sleep 30  # Add a small delay to avoid excessive CPU usage
done