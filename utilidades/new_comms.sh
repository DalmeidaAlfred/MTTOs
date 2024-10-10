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
    local current_dummy=""
    local dummy_found=false
    local temp_file=$(mktemp)

    while IFS= read -r line; do
        if [[ $line =~ \[(DUMMY[0-9]{3})\] ]]; then
            if [ "$dummy_found" = true ]; then
                # Check if parameters exist before adding them
                if ! grep -q "^default_room=" "$temp_file"; then
                    echo "default_room=Comunidad" >> "$temp_file"
                fi
                if ! grep -q "^default_usage=" "$temp_file"; then
                    echo "default_usage=CommunityDoor" >> "$temp_file"
                fi
                if ! grep -q "^device_type=" "$temp_file"; then
                    echo "device_type=DUMMY_SWITCH" >> "$temp_file"
                fi
                dummy_found=false  # Reset for the next dummy
            fi
            current_dummy="${BASH_REMATCH[1]}"
            echo "$line" >> "$temp_file"
            dummy_found=true
        else
            # Write the line to the temp file only if we're inside a dummy section
            if [ "$dummy_found" = true ]; then
                echo "$line" >> "$temp_file"
            fi
        fi
    done < "$DUMMIES_FILE"

    # If we reach the end of the file, check the last dummy
    if [ "$dummy_found" = true ]; then
        if ! grep -q "^default_room=" "$temp_file"; then
            echo "default_room=Comunidad" >> "$temp_file"
        fi
        if ! grep -q "^default_usage=" "$temp_file"; then
            echo "default_usage=CommunityDoor" >> "$temp_file"
        fi
        if ! grep -q "^device_type=" "$temp_file"; then
            echo "device_type=DUMMY_SWITCH" >> "$temp_file"
        fi
    fi

    # Replace the original file with the modified temp file
    mv "$temp_file" "$DUMMIES_FILE"
}

# Run the function to add missing parameters for existing dummies
add_missing_parameters

# Backup and manage old rules
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
    echo "$OLD_RULES_FILE does not exist. Extracting USER and PASSWORD from backup."
    
    # Check if the backup file exists
    if [ -f "/etc/openhab2/rules/community_Franca.backup" ]; then
        USER=$(grep -oP 'val USER="\K[^"]+' "/etc/openhab2/rules/community_Franca.backup")
        PASSWORD=$(grep -oP 'val PASSWORD="\K[^"]+' "/etc/openhab2/rules/community_Franca.backup")
    else
        echo "Backup file not found. Exiting."
        exit 1
    fi
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
