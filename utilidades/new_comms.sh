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
NEW_ITEMS=("or \n  Item ALFRED_"$DUMMY"_DUMMY_SWITCH_Switch  received command ON")
echo $NEW_ITEMS

# Insert the new items just before the "then" statement
if ! grep "ALFRED_DUMMY13" /etc/openhab2/rules/community_Franca.rules

then
sed -i "s/Item ALFRED_DUMMY127_DUMMY_SWITCH_Switch received command ON/Item ALFRED_DUMMY127_DUMMY_SWITCH_Switch received command ON $NEW_ITEMS/g" /etc/openhab2/rules/community_Franca.rules

echo "

["$DUMMY"]
default_name=Escalera "$1"
default_room=Comunidad
default_usage=CommunityDoor
device_type=DUMMY_SWITCH
" >> /home/openhabian/.alfredassistant/dummies.ini
cat /etc/openhab2/rules/community_Franca.rules
cat /home/openhabian/.alfredassistant/dummies.ini
echo DONE
fi
