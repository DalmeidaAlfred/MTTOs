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

# Update the dummies.ini file for device configuration
# Replace [DUMMY1] section with [DUMMYComm101] for the pool door
sed -i 's/\[DUMMY1\]/\[DUMMYComm101\]/g' "$DUMMIES_FILE"
sed -i 's/default_name=Piscina/default_name=Puerta/g' "$DUMMIES_FILE"
sed -i 's/default_room=Piscina/default_room=Piscina/g' "$DUMMIES_FILE"
sed -i 's/device_type=DUMMY_LOCK/device_type=DUMMY_SWITCH/g' "$DUMMIES_FILE"
sed -i '/device_type=DUMMY_SWITCH/a default_usage=CommunityDoor' "$DUMMIES_FILE"

# Replace [DUMMY2] section with [DUMMYComm102] for the community door
sed -i 's/\[DUMMY2\]/\[DUMMYComm102\]/g' "$DUMMIES_FILE"
sed -i 's/default_name=Principal/default_name=Principal/g' "$DUMMIES_FILE"
sed -i 's/default_room=Comunidad/default_room=Comunidad/g' "$DUMMIES_FILE"
sed -i 's/device_type=DUMMY_LOCK/device_type=DUMMY_SWITCH/g' "$DUMMIES_FILE"
sed -i '/device_type=DUMMY_SWITCH/a default_usage=CommunityDoor' "$DUMMIES_FILE"

echo "Replacement completed. Original files backed up as ${RULES_FILE}.bak and ${DUMMIES_FILE}.bak"
sudo systemctl restart alfred-assistant