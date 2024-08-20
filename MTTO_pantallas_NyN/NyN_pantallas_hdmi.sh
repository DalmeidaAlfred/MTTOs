#!/bin/bash

comunidad="set_community"

# Webhook URL
WEBHOOK_URL="https://flows.alfredsmartdata.com/webhook/raspberry-pi-pantallas-hdmi"

# Function to check HDMI connection status
check_hdmi_status() {
    HDMI_STATUS=$(cat /sys/class/drm/card1-HDMI-A-1/status)
    if [[ $HDMI_STATUS == "connected" ]]; then
        return 0
    else
        return 1
    fi
}

# Function to send HTTP POST request with HDMI status
send_http_post() {
    local status_message

    if check_hdmi_status; then
        status_message="TRUE"
    else
        status_message="FALSE"
    fi

    curl --show-error -k -X POST --header "Content-Type: application/json" \
         --data "{\"status\": \"$status_message\", \"timestamp\": \"$(date)\", \"comunidad\": \"$comunidad\"}" \
         "$WEBHOOK_URL"

    if [ $? -eq 0 ]; then
        sudo echo "$(date): HTTP POST request sent successfully, status: $status_message" >> /home/pi/MTTO/tv_status_check.log
    else
        sudo echo "$(date): HTTP POST request failed, status: $status_message" >> /home/pi/MTTO/tv_status_check.log
    fi
}

# Main logic
send_http_post