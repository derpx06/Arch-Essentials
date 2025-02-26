#!/bin/bash
################################################################################
# system_update.sh
#
# This script updates and upgrades your Arch Linux system, refreshes the
# pacman keyring, and checks for any errors encountered during the process.
#
# What it does:
#   1. Runs a full system update and upgrade (pacman -Syu).
#   2. Initializes and populates the pacman keyring.
#   3. Updates the archlinux-keyring package.
#   4. Logs all output and checks for errors.
#   5. Provides a concise overview of the operations performed.
#   6. Waits for the user to press Enter before returning.
#
# Usage:
#   bash system_update.sh
################################################################################

# Define colors for output
RESET="\033[0m"
BOLD="\033[1m"
GREEN="\033[32m"
RED="\033[31m"
CYAN="\033[36m"

# Log file for detailed output
LOG_FILE="/tmp/system_update_log.txt"
> "$LOG_FILE"  # Clear the log file at the start

# Function to log and display output
log() {
    echo -e "$1" | tee -a "$LOG_FILE"
}

# Function to check exit code and log error if found
check_error() {
    if [ $? -ne 0 ]; then
        log "${RED}[ERROR] $1 failed.${RESET}"
    else
        log "${GREEN}[SUCCESS] $1 completed.${RESET}"
    fi
}

# Begin system update process
log "${CYAN}${BOLD}Starting System Update and Upgrade...${RESET}"
log "------------------------------------------------------------"

# 1. System Update & Upgrade
log "${CYAN}Running system update & upgrade (sudo pacman -Syu)...${RESET}"
sudo pacman -Syu --noconfirm 2>&1 | tee -a "$LOG_FILE"
check_error "System Update & Upgrade"

# 2. Refresh and Improve the Keyring
log "\n${CYAN}Refreshing pacman keyring...${RESET}"
# Initialize the keyring (if not already done)
sudo pacman-key --init 2>&1 | tee -a "$LOG_FILE"
check_error "Keyring Initialization"

# Populate keyring with the Arch Linux keys
sudo pacman-key --populate archlinux 2>&1 | tee -a "$LOG_FILE"
check_error "Keyring Population"

# Update the archlinux-keyring package
log "\n${CYAN}Updating archlinux-keyring package...${RESET}"
sudo pacman -Sy archlinux-keyring --noconfirm 2>&1 | tee -a "$LOG_FILE"
check_error "archlinux-keyring Update"

# 3. Check for Errors in the Log
log "\n${CYAN}Checking log for errors...${RESET}"
if grep -i "error" "$LOG_FILE" >/dev/null; then
    log "${RED}Errors were detected during the update process. Please review the log at ${LOG_FILE}.${RESET}"
else
    log "${GREEN}No errors detected during the update process.${RESET}"
fi

# 4. Overview of Actions Performed
log "\n------------------------------------------------------------"
log "${BOLD}Overview of System Update:${RESET}"
log " - System update & upgrade executed."
log " - Pacman keyring initialized and populated."
log " - archlinux-keyring package updated."
log "For more details, please check the log file at: ${LOG_FILE}"
log "------------------------------------------------------------"

# 5. Wait for the user to press Enter to continue
echo -e "\nPress ${BOLD}Enter${RESET} key to return to the main menu..."
read -r

exit 0

