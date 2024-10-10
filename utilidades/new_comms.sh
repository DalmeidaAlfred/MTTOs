#!/bin/bash

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

# Add the dummy section to the ini file
{
    echo "[$DUMMY]"
    echo "default_name=Escalera "$1""
    echo "default_room=Comunidad"
    echo "default_usage=CommunityDoor"
    echo "device_type=DUMMY_SWITCH"
    echo ""
} >> /home/openhabian/.alfredassistant/dummies.ini

# Check existing parameters for dummies in dummies.ini
DUMMIES_FILE="/home/openhabian/.alfredassistant/dummies.ini"

# Function to ensure each dummy has the required parameters
add_missing_parameters() {
    while IFS= read -r line; do
        if [[ $line =~ \[(DUMMY[0-9]{3})\] ]]; then
            DUMMY_NAME="${BASH_REMATCH[1]}"
            echo "Checking parameters for $DUMMY_NAME..."

            # Check for default_room
            if ! grep -q "default_room=" "$DUMMIES_FILE"; then
                echo "default_room=Comunidad" >> "$DUMMIES_FILE"
                echo "Added default_room for $DUMMY_NAME."
            fi

            # Check for default_usage
            if ! grep -q "default_usage=" "$DUMMIES_FILE"; then
                echo "default_usage=CommunityDoor" >> "$DUMMIES_FILE"
                echo "Added default_usage for $DUMMY_NAME."
            fi

            # Check for device_type
            if ! grep -q "device_type=" "$DUMMIES_FILE"; then
                echo "device_type=DUMMY_SWITCH" >> "$DUMMIES_FILE"
                echo "Added device_type for $DUMMY_NAME."
            fi
        fi
    done < "$DUMMIES_FILE"
}

# Run the function to add missing parameters for existing dummies
add_missing_parameters

# Backup and manage old rules
RULES_FILE="/etc/openhab2/rules/community.rules"
OLD_RULES_FILE="/etc/openhab2/rules/community_Franca.rules"
OLD_RANDOM_FILE="/etc/openhab2/rules/community_125.rules"

# Backup the old Franca rules if it exists
    cp "$OLD_RULES_FILE" "/etc/openhab2/rules/community_Franca.backup"
    echo "Backup of community_Franca.rules created at /etc/openhab2/rules/community_Franca.backup"

    # Extract USER and PASSWORD from community_Franca.rules before deletion
    USER=$(grep -oP 'val USER="\K[^"]+' "/etc/openhab2/rules/community_Franca.backup")
    PASSWORD=$(grep -oP 'val PASSWORD="\K[^"]+' "/etc/openhab2/rules/community_Franca.backup")

    # Remove the original Franca rules after backup
    rm "$OLD_RULES_FILE"
    echo "Deleted $OLD_RULES_FILE after backup."

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
