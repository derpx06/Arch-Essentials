#!/bin/bash

# Define Colors
RESET="\033[0m"
BOLD="\033[1m"
CYAN="\033[36m"
GREEN="\033[32m"
RED="\033[31m"

# Function to display section headers
section_header() {
    echo -e "${CYAN}${BOLD}$1${RESET}"
}

# Main function to change Plymouth theme
main() {
    section_header "Change Plymouth Theme"

    # Check if Plymouth is installed
    if ! command -v plymouth-set-default-theme &>/dev/null; then
        echo -e "${RED}Plymouth is not installed on your system!${RESET}"
        exit 1
    fi

    # List available Plymouth themes
    echo -e "${CYAN}${BOLD}Available Plymouth Themes:${RESET}"
    themes=$(plymouth-set-default-theme --list)
    if [[ -z "$themes" ]]; then
        echo -e "${RED}No Plymouth themes found.${RESET}"
        exit 1
    fi
    echo "$themes"

    # Prompt user to select a theme
    read -p "Enter the name of the theme to apply: " theme_name
    if echo "$themes" | grep -q "$theme_name"; then
        echo -e "${CYAN}${BOLD}Applying Plymouth theme: $theme_name${RESET}"
        sudo plymouth-set-default-theme "$theme_name"
        sudo mkinitcpio -P
        echo -e "${GREEN}Plymouth theme applied successfully.${RESET}"
    else
        echo -e "${RED}Theme '$theme_name' not found.${RESET}"
    fi
}

# Run the main function
main
