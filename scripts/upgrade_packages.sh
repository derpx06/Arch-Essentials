#!/bin/bash

echo -e "${GREEN}Upgrading all packages...${RESET}"
echo -e "Step 1: Refreshing package databases..."
sudo pacman-key --init
sudo pacman-key --populate
sudo pacman -Syy --noconfirm
if [[ $? -eq 0 ]]; then
    echo -e "Step 2: Upgrading outdated packages..."
    sudo pacman -Su --noconfirm
    if [[ $? -eq 0 ]]; then
        echo -e "${CYAN}All packages upgraded successfully.${RESET}"
    else
        echo -e "${RED}Package upgrade failed. Please check for conflicts or broken dependencies.${RESET}"
    fi
else
    echo -e "${RED}Failed to refresh package databases. Please check your internet connection.${RESET}"
fi
