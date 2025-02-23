#!/bin/bash

# Define Colors
RESET="\033[0m"
BOLD="\033[1m"
BLUE="\033[34m"
GREEN="\033[32m"
RED="\033[31m"
CYAN="\033[36m"

echo -e "${BLUE}${BOLD}Testing Internet Connection${RESET}\n"

# List of reliable servers to ping
SERVERS=("8.8.8.8" "1.1.1.1" "8.8.4.4")

# Function to test connectivity to a server
test_server() {
    local server=$1
    echo -e "${CYAN}Pinging $server...${RESET}"
    ping -c 4 "$server" > /dev/null 2>&1
    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}Connection to $server is working.${RESET}"
        return 0
    else
        echo -e "${RED}Failed to connect to $server.${RESET}"
        return 1
    fi
}

# Test each server
INTERNET_WORKING=false
for server in "${SERVERS[@]}"; do
    if test_server "$server"; then
        INTERNET_WORKING=true
    fi
done

# Final result
if $INTERNET_WORKING; then
    echo -e "\n${GREEN}${BOLD}Internet connection is working.${RESET}"
else
    echo -e "\n${RED}${BOLD}No internet connection detected.${RESET}"
fi
