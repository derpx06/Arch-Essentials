#!/bin/bash
# network_speed_test.sh - Network Speed Test Using speedtest-cli for Arch Linux
#
# This script uses speedtest-cli to perform a network speed test.
# If speedtest-cli is not installed, it will prompt the user to install it.
# Before installation, it refreshes the pacman keyring to help resolve any corruption issues.

# Define Colors
RESET="\033[0m"
BOLD="\033[1m"
BLUE="\033[34m"
GREEN="\033[32m"
RED="\033[31m"
CYAN="\033[36m"
YELLOW="\033[33m"

clear
echo -e "${BLUE}${BOLD}Network Speed Test Using speedtest-cli${RESET}\n"

# Function to check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Function to prompt for installation if command is missing.
# Before installing, refresh the pacman keyring to fix any potential corruption.
prompt_install() {
    local pkg_name="$1"
    local cmd_name="$2"
    if ! command_exists "$cmd_name"; then
        echo -e "${RED}$cmd_name is not installed.${RESET}"
        read -p "Do you want to install $pkg_name? (y/n): " choice
        if [[ "$choice" =~ ^[Yy]$ ]]; then
            echo -e "${CYAN}Refreshing pacman keyring...${RESET}"
            sudo pacman-key --refresh-keys
            echo -e "${CYAN}Installing $pkg_name...${RESET}"
            if ! sudo pacman -S --noconfirm "$pkg_name"; then
                echo -e "${RED}Installation of $pkg_name failed. Please check your keyring or try refreshing manually.${RESET}"
                exit 1
            fi
        else
            echo -e "${YELLOW}Cannot perform speed test without $cmd_name. Exiting.${RESET}"
            exit 1
        fi
    fi
}

# Ensure speedtest-cli is installed
prompt_install "speedtest-cli" "speedtest-cli"

# Run speedtest-cli and capture results
echo -e "${CYAN}Performing Network Speed Test...${RESET}"
speed_test_result=$(speedtest-cli --simple 2>&1)
exit_code=$?

if [ $exit_code -ne 0 ]; then
    echo -e "${RED}Speedtest-cli encountered an error:${RESET}"
    echo "$speed_test_result"
    exit 1
fi

# Display the results
echo -e "${GREEN}Network Speed Test Results:${RESET}"
echo "$speed_test_result"

read -n1 -r -p "Press any key to return..."

