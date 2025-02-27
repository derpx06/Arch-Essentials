#!/bin/bash
################################################################################
# system_update.sh - Fixed Version
#
# Changes from original:
# 1. Uses user-specific temp file location
# 2. Better sudo handling for log file access
# 3. Clearer error handling
# 4. Simplified keyring management
################################################################################

# Configuration
LOG_DIR="${HOME}/.arch_tools_logs"
LOG_FILE="${LOG_DIR}/system_update.log"
mkdir -p "${LOG_DIR}"
> "${LOG_FILE}"

# Define colors
RESET="\033[0m"
BOLD="\033[1m"
GREEN="\033[32m"
RED="\033[31m"
CYAN="\033[36m"

# Enhanced logging
log() {
    echo -e "$1" | sudo tee -a "${LOG_FILE}" >/dev/null
}

# Error checking with continuation
check_error() {
    local result=$?
    local operation="$1"
    if [ $result -ne 0 ]; then
        log "${RED}[ERROR] ${operation} failed (Code: ${result})${RESET}"
        return 1
    else
        log "${GREEN}[SUCCESS] ${operation} completed${RESET}"
        return 0
    fi
}

# Main process
clear
log "${CYAN}${BOLD}Starting Secure System Update...${RESET}"
log "------------------------------------------------------------"

# 1. Keyring update (critical first step)
sudo pacman -Sy --needed archlinux-keyring 2>&1 | sudo tee -a "${LOG_FILE}"
check_error "Keyring Update" || exit 1

# 2. System upgrade
log "\n${CYAN}Performing full system upgrade...${RESET}"
sudo pacman -Syu --noconfirm 2>&1 | sudo tee -a "${LOG_FILE}"
check_error "System Upgrade"

# 3. Post-update checks
log "\n${CYAN}Verifying system integrity...${RESET}"
sudo pacman-key --populate archlinux 2>&1 | sudo tee -a "${LOG_FILE}"
check_error "Keyring Verification"

# Final status
if grep -qi "error" "${LOG_FILE}"; then
    log "\n${RED}Completed with warnings - Check ${LOG_FILE}${RESET}"
else
    log "\n${GREEN}System updated successfully${RESET}"
fi

# User confirmation
read -rp $'\nPress [Enter] to return to menu...' -n1
exit 0
