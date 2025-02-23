#!/bin/bash

# Define Colors
RESET="\033[0m"
BOLD="\033[1m"
CYAN="\033[36m"
GREEN="\033[32m"
RED="\033[31m"

# Check for AUR helper (yay or paru)
if command -v yay &>/dev/null; then
    aur_helper="yay"
elif command -v paru &>/dev/null; then
    aur_helper="paru"
else
    echo -e "${RED}No AUR helper (yay/paru) found!${RESET}"
    exit 1
fi

# Count and list AUR packages
echo -e "${CYAN}${BOLD}AUR Packages:${RESET}"

# Get the list of AUR packages
aur_packages=$($aur_helper -Qmq 2>/dev/null)
if [[ -z "$aur_packages" ]]; then
    echo -e "${GREEN}No AUR packages found.${RESET}"
else
    count=$(echo "$aur_packages" | wc -l)
    echo -e "Number of installed AUR packages: ${BOLD}${count}${RESET}"
    echo -e "\n${CYAN}${BOLD}List of Installed AUR Packages:${RESET}"
    echo "$aur_packages"

    # Prompt to remove specific AUR packages
    read -p "Do you want to remove any AUR package? (y/n): " choice
    if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
        echo -e "${CYAN}${BOLD}Enter the name of the package to remove:${RESET}"
        read -p "> " package_name
        if $aur_helper -Qs "$package_name" &>/dev/null; then
            echo -e "${CYAN}${BOLD}Removing package: ${package_name}${RESET}"
            sudo $aur_helper -Rns "$package_name" --noconfirm
            echo -e "${GREEN}Package removed successfully.${RESET}"
        else
            echo -e "${RED}Package '${package_name}' not found!${RESET}"
        fi
    else
        echo -e "${CYAN}Skipping removal of AUR packages.${RESET}"
    fi
fi
