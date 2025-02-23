#!/bin/bash

# Define Colors
RESET="\033[0m"
BOLD="\033[1m"
CYAN="\033[36m"
GREEN="\033[32m"
RED="\033[31m"

# Count and list system packages (installed via pacman)
echo -e "${CYAN}${BOLD}System Packages:${RESET}"

# Get the list of system packages
system_packages=$(pacman -Qnq 2>/dev/null)
if [[ -z "$system_packages" ]]; then
    echo -e "${RED}No system packages found!${RESET}"
else
    count=$(echo "$system_packages" | wc -l)
    echo -e "Number of installed system packages: ${BOLD}${count}${RESET}"
    echo -e "\n${CYAN}${BOLD}List of Installed System Packages:${RESET}"
    echo "$system_packages"
        echo -e "Number of installed system packages: ${BOLD}${count}${RESET}"
fi
