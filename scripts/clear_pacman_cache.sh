#!/bin/bash
# clear_pacman_cache.sh - Clear pacman cache on Arch Linux
# This script displays the current pacman cache size,
# then prompts the user (default yes) to remove all cached packages except the latest two versions.
# It logs the before and after cache size to a report file in the user's home directory.

# Determine target user's home directory if run via sudo.
if [ "$EUID" -eq 0 ] && [ -n "$SUDO_USER" ]; then
    USER_HOME=$(eval echo "~$SUDO_USER")
else
    USER_HOME=$HOME
fi

REPORT_FILE="$USER_HOME/clear_pacman_cache_report.txt"
echo "Timestamp: $(date)" > "$REPORT_FILE"

# Define Colors
RESET="\033[0m"
BOLD="\033[1m"
GREEN="\033[32m"
RED="\033[31m"
CYAN="\033[36m"
YELLOW="\033[33m"

echo -e "${CYAN}${BOLD}Clear Pacman Cache${RESET}\n"

# Ensure paccache is installed (it comes with pacman-contrib)
if ! command -v paccache &> /dev/null; then
    echo -e "${RED}paccache is not installed. Please install pacman-contrib.${RESET}"
    exit 1
fi

# Show current cache size
CACHE_DIR="/var/cache/pacman/pkg"
size_before=$(du -sh "$CACHE_DIR" 2>/dev/null | awk '{print $1}')
echo -e "${CYAN}Current pacman cache size: ${BOLD}$size_before${RESET}"
echo "Cache size before cleanup: $size_before" >> "$REPORT_FILE"

# Prompt user to clear cache (default yes)
read -p "Do you want to clear pacman cache (keep 2 latest versions per package)? [Y/n]: " choice
choice=${choice:-Y}
if [[ "$choice" =~ ^[Yy]$ ]]; then
    echo -e "${CYAN}Removing old packages from cache...${RESET}"
    sudo paccache -r -k 2
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Pacman cache cleaned successfully.${RESET}"
    else
        echo -e "${RED}Failed to clean pacman cache.${RESET}"
    fi
else
    echo -e "${YELLOW}Skipping pacman cache cleanup.${RESET}"
fi

# Show new cache size
size_after=$(du -sh "$CACHE_DIR" 2>/dev/null | awk '{print $1}')
echo -e "${CYAN}New pacman cache size: ${BOLD}$size_after${RESET}"
echo "Cache size after cleanup: $size_after" >> "$REPORT_FILE"

read -n1 -r -p "Press any key to return..." key
exit 0

