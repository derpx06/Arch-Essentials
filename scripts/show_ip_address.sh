#!/bin/bash

# Define Colors
RESET="\033[0m"
BOLD="\033[1m"
BLUE="\033[34m"
GREEN="\033[32m"
RED="\033[31m"
CYAN="\033[36m"

echo -e "${BLUE}${BOLD}Show IP Address${RESET}\n"

# Function to get IP address using hostname
get_ip_hostname() {
    hostname -I | awk '{print $1}'
}

# Function to get IP address using ip command
get_ip_ipcmd() {
    ip addr show | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | cut -d '/' -f1 | head -n 1
}

# Try both methods to get the IP address
IP_ADDRESS=$(get_ip_hostname)
if [[ -z "$IP_ADDRESS" ]]; then
    IP_ADDRESS=$(get_ip_ipcmd)
fi

# Display the result
if [[ -n "$IP_ADDRESS" ]]; then
    echo -e "${GREEN}Your IP Address: ${BOLD}$IP_ADDRESS${RESET}"
else
    echo -e "${RED}Could not determine IP address. Ensure you are connected to a network.${RESET}"
fi
