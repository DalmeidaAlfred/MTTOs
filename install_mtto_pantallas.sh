#!/bin/bash

COMUNIDAD=$1
COMUNIDAD=$(echo "$COMUNIDAD" | sed "s/ /+/g")

echo Comunidad: $COMUNIDAD

# Check if main directory is created
if [ ! -d "/home/pi/PIMCO" ]
then
mkdir /home/pi/PIMCO;
echo Creating PIMCO directory
fi

#Obtain all the files necesary
    wget -q -T 10 "https://raw.githubusercontent.com/DalmeidaAlfred/mtto_pantallas_nyn/main/PIMCO_pantallas_TV.sh" -O /home/pi/PIMCO/PIMCO_pantallas_TV.sh;
    wget -q -T 10 "https://raw.githubusercontent.com/DalmeidaAlfred/mtto_pantallas_nyn/main/PIMCO_pantallas_hdmi.sh" -O /home/pi/PIMCO/PIMCO_pantallas_hdmi.sh;
    wget -q -T 10 "https://raw.githubusercontent.com/DalmeidaAlfred/mtto_pantallas_nyn/main/PIMCO_pantallas_internet.sh" -O /home/pi/PIMCO/PIMCO_pantallas_internet.sh;
    wget -q -T 10 "https://raw.githubusercontent.com/DalmeidaAlfred/mtto_pantallas_nyn/main/cron_pimco" -O /home/pi/PIMCO/cron_pimco;

# Check if cec-utils is installed
if ! dpkg -l | grep -qw cec-utils; then
    echo "Cec-utils not found. Installing..."
    sudo apt install -y cec-utils
else
    echo "Cec-utils is already installed."
fi

# Define log files and their paths
log_files=(
    "/home/pi/PIMCO/internet_check.log"
    "/home/pi/PIMCO/tv_status_check.log"
    "/home/pi/PIMCO/hdmi_status_check.log"
)

# Check and create log files if they don't exist
for log_file in "${log_files[@]}"; do
    if [ ! -f "$log_file" ]; then
        touch "$log_file"
        echo "Creating $(basename "$log_file")"
    fi
done

# Define script files and their paths
script_files=(
    "/home/pi/PIMCO/PIMCO_pantallas_TV.sh"
    "/home/pi/PIMCO/PIMCO_pantallas_hdmi.sh"
    "/home/pi/PIMCO/PIMCO_pantallas_internet.sh"
)

# Apply execute permissions to all script files
echo Cambiando permisos scripts
for script_file in "${script_files[@]}"; do
    sed -i "s/set_community/$COMUNIDAD/g" "$script_file"
    chmod +x "$script_file"
done

# Apply community to curl of restart of internet
echo Cambiando cron de sitio
sed -i "s/set_community/$COMUNIDAD/g" "/home/pi/PIMCO/cron_pimco"
echo AlfredSmart | sudo -S mv /home/pi/PIMCO/cron_pimco /etc/cron.d/cron_pimco