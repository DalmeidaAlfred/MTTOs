#!/bin/bash

case $1 in
  "A")
    DUMMY="ALFRED_DUMMY131_DUMMY_SWITCH_Switch"
    ;;
  "B")
    DUMMY="ALFRED_DUMMY132_DUMMY_SWITCH_Switch"
    ;;
  "C")
    DUMMY="ALFRED_DUMMY133_DUMMY_SWITCH_Switch"
    ;;
  "D")
    DUMMY="ALFRED_DUMMY134_DUMMY_SWITCH_Switch"
    ;;
  "E")
    DUMMY="ALFRED_DUMMY135_DUMMY_SWITCH_Switch"
    ;;
  "F")
    DUMMY="ALFRED_DUMMY136_DUMMY_SWITCH_Switch"
    ;;
  "G")
    DUMMY="ALFRED_DUMMY137_DUMMY_SWITCH_Switch"
    ;;
esac

# Define the file path to your rule
RULE_FILE="/etc/openhab2/rules/community_Franca.rules"

# Define the new dummy items to append
NEW_ITEMS=$(cat <<EOL
  or
  Item $DUMMY received command ON
EOL
)

# Insert the new items just before the "then" statement
sed -i "s/Item ALFRED_DUMMY127_DUMMY_SWITCH_Switch received command ON/$NEW_ITEMS/g" "$RULE_FILE"
