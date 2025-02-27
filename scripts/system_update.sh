#!/bin/bash
################################################################################
# system_update.sh
#
# This script updates and upgrades your Arch Linux system, prioritizing the
# keyring update to prevent signature verification errors. It logs all actions
# and checks for errors, providing a clear summary upon completion.
#
# Changes made to fix issues:
# 1. Correct order: Update archlinux-keyring first to avoid signature errors.
# 2. Removed unnecessary pacman-key --init which can reset the keyring.
# 3. Keyring population after package update ensures latest keys are active.
# 4. Streamlined logging and error checking for clarity.
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
        exit 1
    else
        log "${GREEN}[SUCCESS] $1 completed.${RESET}"
    fi
}

# Begin system update process
log "${CYAN}${BOLD}Starting Arch Linux System Update...${RESET}"
log "------------------------------------------------------------"

# 1. Update archlinux-keyring first to prevent key errors during upgrade
log "\n${CYAN}Updating archlinux-keyring package...${RESET}"
sudo pacman -Sy archlinux-keyring --noconfirm 2>&1 | tee -a "$LOG_FILE"
check_error "archlinux-keyring Update"

# 2. Populate the latest keys from the updated keyring package
log "\n${CYAN}Populating Arch Linux keys...${RESET}"
sudo pacman-key --populate archlinux 2>&1 | tee -a "$LOG_FILE"
check_error "Keyring Population"

# 3. Perform full system upgrade with the refreshed keyring
log "\n${CYAN}Running full system upgrade (sudo pacman -Syu)...${RESET}"
sudo pacman -Syu --noconfirm 2>&1 | tee -a "$LOG_FILE"
check_error "System Upgrade"

# 4. Check log for any errors encountered
log "\n${CYAN}Checking log for errors...${RESET}"
if grep -qi "error" "$LOG_FILE"; then
    log "${RED}Errors detected. Review log at ${LOG_FILE}.${RESET}"
else
    log "${GREEN}All operations completed without errors.${RESET}"
fi

# 5. Final summary
log "\n------------------------------------------------------------"
log "${BOLD}Update Summary:${RESET}"
log " - Updated archlinux-keyring to latest version."
log " - Refreshed Pacman keyring with new keys."
log " - Performed full system upgrade."
log " - Log file: ${LOG_FILE}"
log "------------------------------------------------------------"

# Pause before exiting
echo -e "\nPress ${BOLD}Enter${RESET} to return to the menu..."
read -r

exit 0
