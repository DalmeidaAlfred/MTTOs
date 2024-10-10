#!/bin/bash

# Function to remove duplicate dummies from dummies.ini
remove_duplicates() {
    # Use awk to filter duplicates
    awk '!seen[$0]++' /home/openhabian/.alfredassistant/dummies.ini > /home/openhabian/.alfredassistant/dummies.tmp && mv /home/openhabian/.alfredassistant/dummies.tmp /home/openhabian/.alfredassistant/dummies.ini
}

case $1 in
  "A")
    DUMMY="DUMMY131"
    ;;
  "B")
    DUMMY="DUMMY132"
    ;;
  "C")
    DUMMY="DUMMY133"
    ;;
  "D")
    DUMMY="DUMMY134"
    ;;
  "E")
    DUMMY="DUMMY135"
    ;;
  "F")
    DUMMY="DUMMY136"
    ;;
  "G")
    DUMMY="DUMMY137"
    ;;
esac

echo $DUMMY
# Define the new dummy items to append
NEW_ITEMS="or \n  Item ALFRED_"$DUMMY"_DUMMY_SWITCH_Switch received command ON"
echo $NEW_ITEMS

# Append the new dummy item to dummies.ini
echo "
[$DUMMY]
default_name=Escalera "$1"
default_room=Comunidad
default_usage=CommunityDoor
device_type=DUMMY_SWITCH
" >> /home/openhabian/.alfredassistant/dummies.ini

# Remove duplicate entries from dummies.ini
remove_duplicates

cat /etc/openhab2/rules/community_Franca.rules
cat /home/openhabian/.alfredassistant/dummies.ini
echo DONE

# Paths
RULES_FILE="/etc/openhab2/rules/community.rules"
OLD_RULES_FILE="/etc/openhab2/rules/community_Franca.rules"
OLD_RANDOM_FILE="/etc/openhab2/rules/community_125.rules"

# Backup the old Franca rules if it exists
if [ -f "$OLD_RULES_FILE" ]; then
    cp "$OLD_RULES_FILE" "/etc/openhab2/rules/community_Franca.backup"
    echo "Backup of community_Franca.rules created at /etc/openhab2/rules/community_Franca.backup"

    # Extract USER and PASSWORD from community_Franca.rules before deletion
    USER=$(grep -oP 'val USER="\K[^"]+' "$OLD_RULES_FILE")
    PASSWORD=$(grep -oP 'val PASSWORD="\K[^"]+' "$OLD_RULES_FILE")

    # Remove the original Franca rules after backup
    rm "$OLD_RULES_FILE"
    echo "Deleted $OLD_RULES_FILE after backup."
else
    echo "No community_Franca.rules file found, no backup or deletion."
    USER=""
    PASSWORD=""
fi

# Remove the random community_125.rules if it exists
if [ -f "$OLD_RANDOM_FILE" ]; then
    rm "$OLD_RANDOM_FILE"
    echo "Deleted $OLD_RANDOM_FILE"
else
    echo "No community_125.rules file found, nothing to delete."
fi

# Grep all dummies and extract the part after ":"
existing_dummies=$(grep -oP 'ALFRED_DUMMY\d{3}_DUMMY_SWITCH_Switch' /etc/openhab2/items/* | cut -d':' -f2 | sort | uniq | tr -d ' ')

# Create the 'when' block
when_block="when"
for dummy in $existing_dummies; do
    when_block+="\n  Item $dummy received command ON or"
done

# Remove the last 'or'
when_block=$(echo -e "$when_block" | sed '$ s/ or$//')

# Construct the new rule
new_rule="rule \"Puertas Community\"\n$when_block\nthen\n  val USER=\"$USER\"\n  val PASSWORD=\"$PASSWORD\"\n\n  executeCommandLine(\"/etc/openhab2/scripts/community.sh \" + USER + \" \" + PASSWORD + \" \" + triggeringItem.name + \" \" + receivedCommand, 15000)\nend"

# Write the new rule to community.rules
echo -e "$new_rule" > "$RULES_FILE"

# Print confirmation
echo "New rules written to $RULES_FILE"
