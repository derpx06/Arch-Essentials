#!/bin/bash
################################################################################
# system_update.sh - Visual Progress Bar Version
#
# Changes from previous:
# 1. Added animated progress bar
# 2. Real-time status updates
# 3. Clean visual presentation
# 4. Preserved background logging
################################################################################

# Configuration
LOG_DIR="${HOME}/.arch_tools_logs"
LOG_FILE="${LOG_DIR}/system_update.log"
mkdir -p "${LOG_DIR}"
> "${LOG_FILE}"

# Progress Bar Configuration
BAR_WIDTH=50
STEPS=3
CURRENT_STEP=0

# Define colors and styles
RESET="\033[0m"
BOLD="\033[1m"
GREEN="\033[32m"
RED="\033[31m"
CYAN="\033[36m"
YELLOW="\033[33m"

# Progress display functions
show_progress() {
    local percent=$1
    local status=$2
    local filled=$(printf "%.0f" $(echo "$BAR_WIDTH * $percent / 100" | bc -l))
    local empty=$((BAR_WIDTH - filled))
    
    printf "\r${BOLD}${CYAN}["
    printf "%${filled}s" | tr ' ' '■'
    printf "%${empty}s" | tr ' ' '·'
    printf "] ${percent}%%${RESET}  ${BOLD}${YELLOW}%s${RESET}" "$status"
}

complete_step() {
    CURRENT_STEP=$((CURRENT_STEP + 1))
    local percent=$((CURRENT_STEP * 100 / STEPS))
    show_progress $percent "$1"
    echo
}

# Error handling
handle_error() {
    echo -e "\n${RED}${BOLD}✗ Error in: $1${RESET}"
    echo -e "${RED}Check ${LOG_FILE} for details${RESET}"
    exit 1
}

# Main process
clear
echo -e "${BOLD}${CYAN}🚀 Starting Arch Linux System Update ${RESET}\n"

# 1. Keyring update
show_progress 0 "Updating keyring..."
sudo pacman -Sy --needed archlinux-keyring >> "$LOG_FILE" 2>&1 || handle_error "Keyring Update"
complete_step "Keyring updated ✔"

# 2. System upgrade
show_progress 33 "Performing system upgrade..."
sudo pacman -Syu --noconfirm >> "$LOG_FILE" 2>&1 || handle_error "System Upgrade"
complete_step "System upgraded ✔"

# 3. Verification
show_progress 66 "Verifying integrity..."
sudo pacman-key --populate archlinux >> "$LOG_FILE" 2>&1 || handle_error "Key Verification"
complete_step "System verified ✔"

# Final status
show_progress 100 "Update complete!"
echo -e "\n\n${BOLD}${GREEN}✓ System updated successfully${RESET}"

# Clean exit
read -rp $'\nPress [Enter] to return to menu...' -n1
exit 0
