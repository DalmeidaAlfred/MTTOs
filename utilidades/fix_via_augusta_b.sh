#!/bin/bash

# Define the file paths to the rules and configuration files
RULES_FILE="/etc/openhab2/rules/community_Dahua.rules"
DUMMIES_FILE="/home/openhabian/.alfredassistant/dummies.ini"

# Backup the original rules and configuration files before making changes
cp "$RULES_FILE" "${RULES_FILE}.bak"
cp "$DUMMIES_FILE" "${DUMMIES_FILE}.bak"

# Overwrite the dummies.ini file with the new content
cat <<EOL > "$DUMMIES_FILE"
[DUMMYComm201]
default_name=Puerta B
default_room=Piscina
device_type=DUMMY_SWITCH
default_usage=CommunityDoor

[DUMMYComm202]
default_name=Puerta B
default_room=Terraza
device_type=DUMMY_SWITCH
default_usage=CommunityDoor

[DUMMYComm102]
default_name=Principal
default_room=Comunidad
device_type=DUMMY_SWITCH
default_usage=CommunityDoor
EOL

cat <<EOL > "$RULES_FILE"
rule "Open community door"
when
  Item ALFRED_DUMMYComm102_DUMMY_SWITCH_Switch received command ON
then
  val USER="admin"
  val PASSWORD="AlfredSmart"

  executeCommandLine("/etc/openhab2/scripts/community_dahua.sh " + USER + " " + PASSWORD + " " + triggeringItem.name + " " + receivedCommand, 15000)  
end
rule "Open Pool B door"
when
  Item ALFRED_DUMMYComm201_DUMMY_SWITCH_Switch received command ON
then
  val USER="0000000081b7f468"
  val PASSWORD="C2tVM4khusCvLSBbSK1Cg4eMUhIo1z"

  executeCommandLine("/etc/openhab2/scripts/community_door.sh " + USER + " " + PASSWORD + " " + triggeringItem.name + " " + receivedCommand, 15000)  
end

rule "Open Terraza door"
when
  Item ALFRED_DUMMYComm202_DUMMY_SWITCH_Switch received command ON
then
  val USER="0000000081b7f468"
  val PASSWORD="C2tVM4khusCvLSBbSK1Cg4eMUhIo1z"

  executeCommandLine("/etc/openhab2/scripts/community_door.sh " + USER + " " + PASSWORD + " " + triggeringItem.name + " " + receivedCommand, 15000)  
end
EOL

echo "Replacement completed. Original files backed up as ${RULES_FILE}.bak and ${DUMMIES_FILE}.bak"
sudo systemctl restart alfred-assistant