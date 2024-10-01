#!/bin/bash

# Define the file paths to the rules and configuration files
RULES_FILE="/etc/openhab2/rules/community_Dahua.rules"
DUMMIES_FILE="/home/openhabian/.alfredassistant/dummies.ini"

# Backup the original rules and configuration files before making changes
cp "$RULES_FILE" "${RULES_FILE}.bak"
cp "$DUMMIES_FILE" "${DUMMIES_FILE}.bak"

# Update the rules file for OpenHAB
# Replace ALFRED_DUMMY2_DUMMY_LOCK_DoorLock with ALFRED_DUMMYComm101_DUMMY_SWITCH_Switch in the community door rule
sed -i 's/ALFRED_DUMMY2_DUMMY_LOCK_DoorLock/ALFRED_DUMMYComm101_DUMMY_SWITCH_Switch/g' "$RULES_FILE"

# Replace ALFRED_DUMMY1_DUMMY_LOCK_DoorLock with ALFRED_DUMMYComm102_DUMMY_SWITCH_Switch in the pool door rule
sed -i 's/ALFRED_DUMMY1_DUMMY_LOCK_DoorLock/ALFRED_DUMMYComm102_DUMMY_SWITCH_Switch/g' "$RULES_FILE"

DUMMIES_FILE="/home/openhabian/.alfredassistant/dummies.ini"

# Backup the original configuration file before making changes
cp "$DUMMIES_FILE" "${DUMMIES_FILE}.bak"

# Overwrite the dummies.ini file with the new content
cat <<EOL > "$DUMMIES_FILE"
[DUMMYComm101]
default_name=Puerta
default_room=Piscina
device_type=DUMMY_SWITCH
default_usage=CommunityDoor

[DUMMYComm102]
default_name=Principal
default_room=Comunidad
device_type=DUMMY_SWITCH
default_usage=CommunityDoor
EOL

echo "Replacement completed. Original files backed up as ${RULES_FILE}.bak and ${DUMMIES_FILE}.bak"
sudo systemctl restart alfred-assistant