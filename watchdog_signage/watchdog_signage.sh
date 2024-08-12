#!/bin/bash

LOG_FILE="/home/pi/MTTO/watchdog_service.log"

LAST_TV_STATUS="power status: on"

while true; do
    echo 'scan' | cec-client -s -d 1
    CURRENT_TV_STATUS=$(echo "pow 0" | cec-client -s -d 4 | grep "power status:")

    if [ -z "$CURRENT_TV_STATUS" ]; then
        echo "$(date): Error - Unable to retrieve TV power status." >> "$LOG_FILE"
    elif [[ "$LAST_TV_STATUS" == "power status: standby" || "$LAST_TV_STATUS" == "power status: in transition from standby to on" || "$LAST_TV_STATUS" == "power status: unknown" ]] && [[ "$CURRENT_TV_STATUS" == "power status: on" ]]; then
        echo "$(date): TV restart detected, stopping signage." >> "$LOG_FILE"
        # Kill the existing signage process
        for KILLPID in $(ps ax | grep optisigns | grep -v grep | awk '{print $1}'); do
            kill -9 $KILLPID
        done
        sleep 10
        #Start the signage application
        export DISPLAY=:0
        sudo nohup /home/pi/Downloads/optisigns-5.6.32-arm64.AppImage &
        echo "$(date): Signage process started." >> "$LOG_FILE"
    else
        echo "$(date): Current TV status: $CURRENT_TV_STATUS." >> "$LOG_FILE"
        echo "$(date): Last TV status: $LAST_TV_STATUS." >> "$LOG_FILE"
    fi

    # Update LAST_TV_STATUS for the next loop iteration
    LAST_TV_STATUS="$CURRENT_TV_STATUS"

    sleep 10  # Add a small delay to avoid excessive CPU usage
done
