#!/bin/bash
# clear_temp_files.sh - Clear temporary files on Arch Linux.
# This script clears files from /tmp and /var/tmp, logs the directory sizes before and after cleanup,
# and calculates freed space. It prompts the user to proceed (default yes) and logs actions to a report file.

REPORT_FILE="$HOME/clear_temp_files_report.txt"

# Define Colors
RESET="\033[0m"
BOLD="\033[1m"
GREEN="\033[32m"
RED="\033[31m"
CYAN="\033[36m"
YELLOW="\033[33m"

echo -e "${CYAN}${BOLD}Clear Temporary Files${RESET}\n"
echo "Timestamp: $(date)" > "$REPORT_FILE"

# Directories to clean
TMP_DIR="/tmp"
VAR_TMP_DIR="/var/tmp"

# Function to get directory size (human-readable)
get_dir_size() {
    du -sh "$1" 2>/dev/null | awk '{print $1}'
}

echo -e "${CYAN}Calculating current temporary file sizes...${RESET}"
size_tmp_before=$(get_dir_size "$TMP_DIR")
size_vartmp_before=$(get_dir_size "$VAR_TMP_DIR")

echo -e "${GREEN}/tmp size before: ${BOLD}$size_tmp_before${RESET}"
echo -e "${GREEN}/var/tmp size before: ${BOLD}$size_vartmp_before${RESET}"

echo "Size before cleanup:" >> "$REPORT_FILE"
echo "/tmp: $size_tmp_before" >> "$REPORT_FILE"
echo "/var/tmp: $size_vartmp_before" >> "$REPORT_FILE"

# Prompt to clear temp directories; default yes.
read -p "Do you want to clear temporary files from /tmp and /var/tmp? [Y/n]: " confirm
confirm=${confirm:-Y}
if [[ "$confirm" =~ ^[Yy]$ ]]; then
    echo -e "${CYAN}Clearing /tmp...${RESET}"
    sudo rm -rf "$TMP_DIR"/*

    echo -e "${CYAN}Clearing /var/tmp...${RESET}"
    sudo rm -rf "$VAR_TMP_DIR"/*

    sleep 2

    size_tmp_after=$(get_dir_size "$TMP_DIR")
    size_vartmp_after=$(get_dir_size "$VAR_TMP_DIR")

    echo -e "${GREEN}/tmp size after: ${BOLD}$size_tmp_after${RESET}"
    echo -e "${GREEN}/var/tmp size after: ${BOLD}$size_vartmp_after${RESET}"

    echo "Size after cleanup:" >> "$REPORT_FILE"
    echo "/tmp: $size_tmp_after" >> "$REPORT_FILE"
    echo "/var/tmp: $size_vartmp_after" >> "$REPORT_FILE"

    echo -e "${GREEN}Temporary files cleared successfully.${RESET}"
    echo "Temporary files cleared successfully." >> "$REPORT_FILE"
else
    echo -e "${YELLOW}Skipping cleanup of temporary files.${RESET}"
    echo "User skipped cleanup." >> "$REPORT_FILE"
fi

read -n1 -r -p "Press any key to return..." key
exit 0

