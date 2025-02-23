#!/bin/bash
# clear_system_logs.sh - Clear old system logs using journalctl on Arch Linux
# This script uses journalctl to vacuum logs older than a specified time (default 7 days).
# It logs the action and the disk space used by logs before and after the cleanup.

# Determine target user's home directory if run via sudo.
if [ "$EUID" -eq 0 ] && [ -n "$SUDO_USER" ]; then
    USER_HOME=$(eval echo "~$SUDO_USER")
else
    USER_HOME=$HOME
fi

REPORT_FILE="$USER_HOME/clear_system_logs_report.txt"
echo "Timestamp: $(date)" > "$REPORT_FILE"

# Define Colors
RESET="\033[0m"
BOLD="\033[1m"
GREEN="\033[32m"
RED="\033[31m"
CYAN="\033[36m"
YELLOW="\033[33m"

echo -e "${CYAN}${BOLD}Clear System Logs${RESET}\n"

# Check current journal log size
JOURNAL_SIZE_BEFORE=$(journalctl --disk-usage | awk '{print $4, $5}')
echo -e "${CYAN}Current journal log size: ${BOLD}$JOURNAL_SIZE_BEFORE${RESET}"
echo "Journal size before cleanup: $JOURNAL_SIZE_BEFORE" >> "$REPORT_FILE"

# Prompt user for vacuum duration (default 7 days)
read -p "Vacuum journal logs older than (default 7 days): " vacuum_time
vacuum_time=${vacuum_time:-7d}

# Confirm removal (default yes)
read -p "Proceed with vacuuming logs older than $vacuum_time? [Y/n]: " choice
choice=${choice:-Y}
if [[ "$choice" =~ ^[Yy]$ ]]; then
    echo -e "${CYAN}Vacuuming journal logs older than $vacuum_time...${RESET}"
    sudo journalctl --vacuum-time=$vacuum_time
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}System logs vacuumed successfully.${RESET}"
        echo "Journal logs vacuumed successfully." >> "$REPORT_FILE"
    else
        echo -e "${RED}Failed to vacuum system logs.${RESET}"
        echo "Failed to vacuum system logs." >> "$REPORT_FILE"
    fi
else
    echo -e "${YELLOW}Skipping system logs cleanup.${RESET}"
    echo "User skipped system logs cleanup." >> "$REPORT_FILE"
fi

# Check journal log size after vacuuming
JOURNAL_SIZE_AFTER=$(journalctl --disk-usage | awk '{print $4, $5}')
echo -e "${CYAN}Journal log size after cleanup: ${BOLD}$JOURNAL_SIZE_AFTER${RESET}"
echo "Journal size after cleanup: $JOURNAL_SIZE_AFTER" >> "$REPORT_FILE"

read -n1 -r -p "Press any key to return..." key
exit 0

