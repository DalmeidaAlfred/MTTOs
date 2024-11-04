#!/bin/bash

# Define the OpenHAB REST API URL (replace <your-openhab-ip> with your actual IP or 'localhost' if running on the same machine)
OPENHAB_URL="http://localhost:8080/rest/things"
WEBHOOK_URL="https://flows.alfredsmartdata.com/webhook/costa-brava-UPONOR"

# Fetch the things using the REST API
response=$(curl -s "$OPENHAB_URL")

# Check if the response is empty
if [[ -z "$response" ]]; then
  echo "Failed to connect to OpenHAB. Please make sure OpenHAB is running."
  exit 1
fi

# Use jq to parse the response, filter out things with "Dummy" in the label, and create a single string for each remaining thing's label and status
filtered_response=$(echo "$response" | jq -r '.[] | select(.label | contains("Dummy") | not) | "\(.label): \(.statusInfo.status)"')

# Check if filtered response is empty
if [[ -z "$filtered_response" ]]; then
  echo "No things found after filtering."
  exit 0
fi

# Create a single string combining all labels and statuses, escape special characters properly for JSON
combined_string=$(echo "$filtered_response" | paste -sd ", " | jq -R .)

# Determine zwave_controller flag (set to true/false)
zwave_controller=$(echo "$response" | jq -r '.[] | select(.thingTypeUID | contains("zwave:serial_zstick"))' | wc -l)
if [[ $zwave_controller -eq 0 ]]; then
  zwave_controller=false
else
  zwave_controller=true
fi

# Determine uponor_online flag (only account for items containing "Valve", set to true/false)
uponor_online=$(echo "$response" | jq -r '.[] | select((.label | contains("Valve")) and (.statusInfo.status == "OFFLINE"))' | wc -l)
if [[ $uponor_online -gt 0 ]]; then
  uponor_online=false
else
  uponor_online=true
fi

# Determine airzone_online flag (set to true/false)
airzone_online=$(echo "$response" | jq -r '.[] | select((.label | contains("Airzone")) and (.statusInfo.status == "OFFLINE"))' | wc -l)
if [[ $airzone_online -gt 0 ]]; then
  airzone_online=false
else
  airzone_online=true
fi

# Determine modbus_online flag (set to true/false)
modbus_online=$(echo "$response" | jq -r '.[] | select((.label | contains("modbus")) and (.statusInfo.status == "OFFLINE"))' | wc -l)
if [[ $modbus_online -gt 0 ]]; then
  modbus_online=false
else
  modbus_online=true
fi

# Calculate memory usage percentage with a comma as a decimal separator
memory_usage=$(free | awk '/Mem:/ {printf("%.2f"), $3/$2 * 100.0}' | sed 's/\./,/g')

# Get the gid from /etc/openhab2/html/version.json
gid=$(cat /etc/openhab2/html/version.json | jq -r '.gid')

# Prepare JSON payload with combined string, flags, gid, and memory usage
json_payload=$(jq -n \
  --arg status "$combined_string" \
  --argjson zwave_controller "$zwave_controller" \
  --argjson uponor_online "$uponor_online" \
  --argjson airzone_online "$airzone_online" \
  --argjson modbus_online "$modbus_online" \
  --arg gid "$gid" \
  --arg memory_usage "$memory_usage" \
  '{
    gid: $gid,
    status: $status,
    zwave_controller: $zwave_controller,
    uponor_online: $uponor_online,
    airzone_online: $airzone_online,
    modbus_online: $modbus_online,
    memory_usage: $memory_usage
  }')

# Post the JSON payload to the specified webhook URL
curl -X POST -H "Content-Type: application/json" -d "$json_payload" "$WEBHOOK_URL"
