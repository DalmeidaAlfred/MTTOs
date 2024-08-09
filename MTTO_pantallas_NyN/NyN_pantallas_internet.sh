#!/bin/bash

comunidad="set_community"
comunidad=$(echo "$comunidad" | sed "s/ /+/g")

# Function to check internet connection
check_internet(){
    wget -q --spider http://google.com
    if [ $? -eq 0 ]; then
        return 0
    else
        return 1
    fi
}

# Function to send HTTP GET request
send_http_get() {
    curl --show-error -k -X GET --header "Content-Type: application/json" --header "Accept: application/json" "https://flows.alfredsmartdata.com/webhook/raspberry-pi-pantallas?building=$comunidad"
    if [ $? -eq 0 ]; then
        echo "$(date): HTTP GET request sent successfully" >> /home/pi/MTTO/internet_check.log
    else
        echo "$(date): HTTP GET request failed" >> /home/pi/MTTO/internet_check.log
    fi
}

# Main logic
if check_internet; then
    echo "$(date): Internet connection is available." >> /home/pi/MTTO/internet_check.log
    send_http_get
else
    echo "$(date): No internet connection. Rebooting..." >> /home/pi/MTTO/internet_check.log
    sudo reboot
fi