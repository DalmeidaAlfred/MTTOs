COMUNIDAD=$1
COMUNIDAD=$(echo "$comunidad" | sed "s/ /+/g")

# Check if main directory is created
if [ ! -d "/home/pi/PIMCO" ]
then
mkdir /home/pi/PIMCO;
echo Creating PIMCO directory
fi

#Obtain all the files necesary
dwnld_links=(
    "https://drive.google.com/uc?export=download&id=1BpWctn7pjbckRdtooBZEQcj3PDWTplf_"
    "https://drive.google.com/uc?export=download&id=1IyhuLK0AGEZfBcfkSlx3lSk1nqDK1wXe"
    "https://drive.google.com/uc?export=download&id=148u0663RGIPjg-o8_V5Qdmq3evHNOKsz"
    "https://drive.google.com/uc?export=download&id=17VFNBULtMb5B_c2s_oMkc0j7_Vh8bVv7"
)

for dwnld_links in "${dwnld_links[@]}"; do
    wget -q -T 10 "$dwnld_links" -P /home/pi/PIMCO
done

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
    "/home/pi/PIMCO/mtto_pantallas.sh"
    "/home/pi/PIMCO/mtto_pantallas_TV.sh"
    "/home/pi/PIMCO/mtto_pantallas_HDMI.sh"
)

# Apply execute permissions to all script files
echo Cambiando permisos scripts
for script_file in "${script_files[@]}"; do
    sed "s/set_community/$COMUNIDAD" $script_file
    chmod +x "$script_file"
done

# Apply community to curl of restart of internet
echo Cambiando cron de sitio
sed "s/set_community/$COMUNIDAD" "/home/pi/PIMCO/cron_pimco"
echo AlfredSmart | sudo -S mv /home/pi/PIMCO/cron_pimco /etc/cron.d/cron_pimco 