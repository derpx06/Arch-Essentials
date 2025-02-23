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

# Main function to change cursor theme
main() {
    section_header "Change Cursor Theme"

    # List available cursor themes
    echo -e "${CYAN}${BOLD}Available Cursor Themes:${RESET}"
    themes_dir="/usr/share/icons"
    if [[ -d "$themes_dir" ]]; then
        themes=$(ls "$themes_dir")
        if [[ -z "$themes" ]]; then
            echo -e "${RED}No cursor themes found in $themes_dir.${RESET}"
            exit 1
        fi
        echo "$themes"
    else
        echo -e "${RED}Cursor themes directory not found: $themes_dir${RESET}"
        exit 1
    fi

    # Prompt user to select a theme
    read -p "Enter the name of the cursor theme to apply: " theme_name
    if [[ -d "$themes_dir/$theme_name" ]]; then
        echo -e "${CYAN}${BOLD}Applying cursor theme: $theme_name${RESET}"
        gsettings set org.gnome.desktop.interface cursor-theme "$theme_name"
        echo -e "${GREEN}Cursor theme applied successfully.${RESET}"
    else
        echo -e "${RED}Theme '$theme_name' not found in $themes_dir.${RESET}"
    fi
}

# Run the main function
main
