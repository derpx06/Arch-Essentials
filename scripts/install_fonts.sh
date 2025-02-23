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

# Main function to manage fonts
main() {
    section_header "Font Management"

    # Check if GNOME Terminal is installed (for gsettings)
    if ! command -v gsettings &>/dev/null; then
        echo -e "${RED}GNOME Terminal or gsettings is not installed! This feature may not work.${RESET}"
        exit 1
    fi

    # List available fonts
    echo -e "${CYAN}${BOLD}Available Fonts:${RESET}"
    fonts=$(fc-list : family | sort -u)
    if [[ -z "$fonts" ]]; then
        echo -e "${RED}No fonts found on your system! Please install fonts first.${RESET}"
        exit 1
    fi
    echo "$fonts"

    # Prompt user to select a font
    read -p "Enter the name of the font to apply: " font_name
    if echo "$fonts" | grep -q "$font_name"; then
        echo -e "${CYAN}${BOLD}Applying font: $font_name${RESET}"
        gsettings set org.gnome.desktop.interface monospace-font-name "$font_name"
        gsettings set org.gnome.desktop.interface font-name "$font_name"
        echo -e "${GREEN}Font applied successfully.${RESET}"
    else
        echo -e "${RED}Font '$font_name' not found in the list of available fonts.${RESET}"
    fi
}

# Run the main function
main
