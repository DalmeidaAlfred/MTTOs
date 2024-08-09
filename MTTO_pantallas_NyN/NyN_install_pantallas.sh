#!/bin/bash

COMUNIDAD=$1


echo Comunidad: $COMUNIDAD

# Check if main directory is created
if [ ! -d "/home/pi/MTTO" ]
then
mkdir /home/pi/MTTO;
echo Creating MTTO directory
fi

#Obtain all the files necesary
    wget -q -T 10 "https://raw.githubusercontent.com/DalmeidaAlfred/MTTOs/main/MTTO_pantallas_NyN/NyN_pantallas_tv.sh" -O /home/pi/MTTO/NyN_pantallas_tv.sh;
    wget -q -T 10 "https://raw.githubusercontent.com/DalmeidaAlfred/MTTOs/main/MTTO_pantallas_NyN/NyN_pantallas_hdmi.sh" -O /home/pi/MTTO/NyN_pantallas_hdmi.sh;
    wget -q -T 10 "https://raw.githubusercontent.com/DalmeidaAlfred/MTTOs/main/MTTO_pantallas_NyN/NyN_pantallas_internet.sh" -O /home/pi/MTTO/NyN_pantallas_internet.sh;
    wget -q -T 10 "https://raw.githubusercontent.com/DalmeidaAlfred/MTTOs/main/MTTO_pantallas_NyN/NyN_cron" -O /home/pi/MTTO/NyN_cron;

# Check if cec-utils is installed
if ! dpkg -l | grep -qw cec-utils; then
    echo "Cec-utils not found. Installing..."
    sudo apt install -y cec-utils
else
    echo "Cec-utils is already installed."
fi

# Define log files and their paths
log_files=(
    "/home/pi/MTTO/internet_check.log"
    "/home/pi/MTTO/tv_status_check.log"
    "/home/pi/MTTO/hdmi_status_check.log"
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
    "/home/pi/MTTO/NyN_pantallas_tv.sh"
    "/home/pi/MTTO/NyN_pantallas_hdmi.sh"
    "/home/pi/MTTO/NyN_pantallas_internet.sh"
)

# Apply execute permissions to all script files
echo Cambiando permisos scripts
for script_file in "${script_files[@]}"; do
    sed -i "s/set_community/$COMUNIDAD/g" "$script_file"
    chmod +x "$script_file"
done

# Apply community to curl of restart of internet
echo Cambiando cron de sitio
COMUNIDAD=$(echo "$COMUNIDAD" | sed "s/ /+/g")
sed -i "s/set_community/$COMUNIDAD/g" "/home/pi/MTTO/NyN_cron"
mv -f /home/pi/MTTO/NyN_cron /etc/cron.d/NyN_cron

echo Bashing every script

bash /home/pi/MTTO/NyN_pantallas_tv.sh;
sleep 10
bash /home/pi/MTTO/NyN_pantallas_internet.sh;
sleep 10
bash /home/pi/MTTO/NyN_pantallas_hdmi.sh;