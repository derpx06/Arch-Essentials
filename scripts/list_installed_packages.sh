#!/bin/bash
# list_installed_packages_menu.sh - List Installed Packages Summary for Arch Linux
# This script lists:
#   - All official packages (from official repos) and their count.
#   - All foreign packages (typically from AUR) and their count.
#   - Orphaned packages and their count.
#
# All outputs are sorted for human readability.

# Define Colors
RESET="\033[0m"
BOLD="\033[1m"
GREEN="\033[32m"
YELLOW="\033[33m"
CYAN="\033[36m"
RED="\033[31m"

echo -e "${CYAN}${BOLD}Installed Packages Summary${RESET}"
echo "-----------------------------------"

# List official packages and count them.
echo -e "${GREEN}Official Packages (from official repos):${RESET}"
official_count=$(pacman -Qn | wc -l)
pacman -Qn | sort
echo ""
echo "Total Official Packages: ${BOLD}$official_count${RESET}"
echo "-----------------------------------"

# List AUR packages (foreign packages) and count them.
echo -e "${GREEN}AUR Packages (Foreign packages):${RESET}"
aur_count=$(pacman -Qm | wc -l)
pacman -Qm | sort
echo ""
echo "Total AUR Packages: ${BOLD}$aur_count${RESET}"
echo "-----------------------------------"

# List orphaned packages and count them.
echo -e "${GREEN}Orphaned Packages:${RESET}"
orphan_count=$(pacman -Qdtq | wc -l)
if [ "$orphan_count" -eq 0 ]; then
    echo "No orphan packages found."
else
    pacman -Qdtq | sort
fi
echo ""
echo "Total Orphaned Packages: ${BOLD}$orphan_count${RESET}"
echo "-----------------------------------"

# List total installed packages.
total_installed=$(pacman -Q | wc -l)
echo -e "${YELLOW}Total Installed Packages (Official + AUR): ${BOLD}$total_installed${RESET}"
echo "-----------------------------------"

read -n1 -r -p "Press any key to return..." key

