#!/bin/bash
# remove_orphaned_packages.sh - Remove orphaned packages on pacman-based systems.
# This script lists orphan packages (installed as dependencies but no longer required)
# and prompts the user (default yes) to remove them. It logs the actions to a report file.

# Determine target user's home directory if running via sudo.
if [ "$EUID" -eq 0 ] && [ -n "$SUDO_USER" ]; then
    USER_HOME=$(eval echo "~$SUDO_USER")
else
    USER_HOME=$HOME
fi

REPORT_FILE="$USER_HOME/remove_orphaned_packages_report.txt"

# Define Colors
RESET="\033[0m"
BOLD="\033[1m"
GREEN="\033[32m"
RED="\033[31m"
CYAN="\033[36m"
YELLOW="\033[33m"

echo -e "${CYAN}${BOLD}Remove Orphaned Packages${RESET}\n"
echo "Timestamp: $(date)" > "$REPORT_FILE"

# Ensure pacman is available.
if ! command -v pacman &> /dev/null; then
    echo -e "${RED}Pacman is not installed. This script is for pacman-based systems.${RESET}"
    exit 1
fi

# Get list of orphan packages.
orphans=$(pacman -Qdtq)

if [ -z "$orphans" ]; then
    echo -e "${GREEN}No orphan packages found.${RESET}"
    echo "No orphan packages found." >> "$REPORT_FILE"
    exit 0
fi

echo -e "${YELLOW}The following orphan packages were found:${RESET}"
echo "$orphans"
echo "Orphan packages found:" >> "$REPORT_FILE"
echo "$orphans" >> "$REPORT_FILE"

# Prompt to remove orphan packages; default is yes.
read -p "Do you want to remove these orphan packages? [Y/n]: " confirm
confirm=${confirm:-Y}
if [[ "$confirm" =~ ^[Yy]$ ]]; then
    echo -e "${CYAN}Removing orphan packages...${RESET}"
    sudo pacman -Rns --noconfirm $orphans
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Orphan packages removed successfully.${RESET}"
        echo "Orphan packages removed successfully." >> "$REPORT_FILE"
    else
        echo -e "${RED}Failed to remove some orphan packages.${RESET}"
        echo "Failed to remove some orphan packages." >> "$REPORT_FILE"
        exit 1
    fi
else
    echo -e "${YELLOW}Skipping removal of orphan packages.${RESET}"
    echo "User skipped removal of orphan packages." >> "$REPORT_FILE"
fi

read -n1 -r -p "Press any key to return..." key
exit 0

