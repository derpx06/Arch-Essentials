#!/bin/bash

# Define Colors
RESET="\033[0m"
BOLD="\033[1m"
CYAN="\033[36m"
GREEN="\033[32m"
RED="\033[31m"

# Count and list orphaned packages
echo -e "${CYAN}${BOLD}Orphaned Packages:${RESET}"

# Get the list of orphaned packages
orphaned_packages=$(pacman -Qdtq 2>/dev/null)
if [[ -z "$orphaned_packages" ]]; then
    echo -e "${GREEN}No orphaned packages found.${RESET}"
else
    count=$(echo "$orphaned_packages" | wc -l)
    echo -e "Number of orphaned packages: ${BOLD}${count}${RESET}"
    echo -e "\n${CYAN}${BOLD}List of Orphaned Packages:${RESET}"
    echo "$orphaned_packages"
fi
