#!/bin/bash

# Define Colors
RESET="\033[0m"
BOLD="\033[1m"
BLUE="\033[34m"
GREEN="\033[32m"
RED="\033[31m"
CYAN="\033[36m"

# Define the autostart directory for the current user
AUTOSTART_DIR="$HOME/.config/autostart"

# Function to ensure the autostart directory exists
ensure_autostart_dir() {
    if [[ ! -d "$AUTOSTART_DIR" ]]; then
        echo -e "${CYAN}Creating autostart directory at $AUTOSTART_DIR...${RESET}"
        mkdir -p "$AUTOSTART_DIR"
    fi
}

# Function to list startup applications
list_startup_apps() {
    ensure_autostart_dir
    echo -e "${CYAN}Startup Applications:${RESET}"
    if [[ -z "$(ls -A "$AUTOSTART_DIR")" ]]; then
        echo -e "${YELLOW}No startup applications found.${RESET}"
    else
        ls "$AUTOSTART_DIR"
    fi
}

# Main menu for managing startup applications
while true; do
    echo -e "${BLUE}${BOLD}Manage Startup Applications${RESET}\n"
    PS3="Select an option: "
    options=("Add Startup Application" "Remove Startup Application" "List Startup Applications" "Back")
    select opt in "${options[@]}"; do
        case $opt in
            "Add Startup Application")
                ensure_autostart_dir
                read -p "Enter application name: " app_name
                read -p "Enter command to run: " app_command
                desktop_file="$AUTOSTART_DIR/$app_name.desktop"
                cat <<EOF > "$desktop_file"
[Desktop Entry]
Type=Application
Exec=$app_command
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=$app_name
EOF
                echo -e "${GREEN}Added $app_name to startup applications.${RESET}"
                break
                ;;
            "Remove Startup Application")
                ensure_autostart_dir
                list_startup_apps
                read -p "Enter the .desktop file name to remove: " desktop_file
                if [[ -f "$AUTOSTART_DIR/$desktop_file" ]]; then
                    rm "$AUTOSTART_DIR/$desktop_file"
                    echo -e "${GREEN}Removed $desktop_file from startup applications.${RESET}"
                else
                    echo -e "${RED}File $desktop_file does not exist!${RESET}"
                fi
                break
                ;;
            "List Startup Applications")
                list_startup_apps
                break
                ;;
            "Back")
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid option!${RESET}"
                ;;
        esac
    done
done
