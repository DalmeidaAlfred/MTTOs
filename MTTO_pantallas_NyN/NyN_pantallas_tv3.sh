#!/bin/bash

comunidad="set_community"

# Webhook URL
WEBHOOK_URL="https://flows.alfredsmartdata.com/webhook/raspberry-pi-pantallas-tv"

# Function to check TV status
check_tv_status() {
    TV_STATUS=$(echo "pow 0.0.0.0" | cec-client -s -d 4 | grep "power status:")
    if [[ $TV_STATUS == *"on"* ]]; then
        return 0
    else
        return 1
    fi
}

# Function to send HTTP POST request with TV status
send_http_post() {
    local status_message

    if check_tv_status; then
        status_message="TRUE"
    else
        status_message="FALSE"
    fi

    curl --show-error -k -X POST --header "Content-Type: application/json" \
         --data "{\"status\": \"$status_message\", \"timestamp\": \"$(date)\", \"comunidad\": \"$comunidad\"}" \
         "$WEBHOOK_URL"

    if [ $? -eq 0 ]; then
        sudo echo "$(date): HTTP POST request sent successfully" >> /home/pi/MTTO/tv_status_check.log
    else
        sudo echo "$(date): HTTP POST request failed" >> /home/pi/MTTO/tv_status_check.log
    fi
}

# Main logic
echo 'scan' | cec-client -s -d 1
send_http_post  
