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

# Main function to change GRUB theme
main() {
    section_header "Change GRUB Theme"

    # Check if GRUB is installed
    if ! command -v grub-mkconfig &>/dev/null; then
        echo -e "${RED}GRUB is not installed on your system!${RESET}"
        exit 1
    fi

    # List available GRUB themes
    echo -e "${CYAN}${BOLD}Available GRUB Themes:${RESET}"
    themes_dir="/boot/grub/themes"
    if [[ -d "$themes_dir" ]]; then
        themes=$(ls "$themes_dir")
        if [[ -z "$themes" ]]; then
            echo -e "${RED}No GRUB themes found in $themes_dir.${RESET}"
            exit 1
        fi
        echo "$themes"
    else
        echo -e "${RED}GRUB themes directory not found: $themes_dir${RESET}"
        exit 1
    fi

    # Prompt user to select a theme
    read -p "Enter the name of the theme to apply: " theme_name
    if [[ -d "$themes_dir/$theme_name" ]]; then
        echo -e "${CYAN}${BOLD}Applying GRUB theme: $theme_name${RESET}"
        sudo sed -i "s|^GRUB_THEME=.*|GRUB_THEME=\"$themes_dir/$theme_name/theme.txt\"|" /etc/default/grub
        sudo grub-mkconfig -o /boot/grub/grub.cfg
        echo -e "${GREEN}GRUB theme applied successfully.${RESET}"
    else
        echo -e "${RED}Theme '$theme_name' not found in $themes_dir.${RESET}"
    fi
}

# Run the main function
main
