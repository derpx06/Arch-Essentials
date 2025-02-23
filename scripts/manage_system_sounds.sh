#!/bin/bash

# Define Colors
RESET="\033[0m"
BOLD="\033[1m"
BLUE="\033[34m"
GREEN="\033[32m"
RED="\033[31m"
CYAN="\033[36m"

# Ensure DBus is available (fixes dconf warnings)
export $(dbus-launch)

# Function to enable system sounds
enable_system_sounds() {
    gsettings set org.gnome.desktop.sound event-sounds true
    echo -e "${GREEN}System sounds enabled.${RESET}"
}

# Function to mute system sounds
mute_system_sounds() {
    gsettings set org.gnome.desktop.sound event-sounds false
    echo -e "${GREEN}System sounds muted.${RESET}"
}

# Function to customize startup sound
customize_startup_sound() {
    echo -e "${CYAN}Customizing startup sound...${RESET}"

    # Prompt user for the path to the sound file
    read -p "Enter the full path to the startup sound file (e.g., /usr/share/sounds/startup.ogg): " sound_file

    if [[ ! -f "$sound_file" ]]; then
        echo -e "${RED}File not found: $sound_file${RESET}"
        return 1
    fi

    # Backup the original startup sound file
    ORIGINAL_SOUND_FILE="/usr/share/sounds/freedesktop/stereo/desktop-login.oga"
    BACKUP_SOUND_FILE="$HOME/.local/share/sounds/desktop-login-backup.oga"

    if [[ -f "$ORIGINAL_SOUND_FILE" && ! -f "$BACKUP_SOUND_FILE" ]]; then
        echo -e "${CYAN}Backing up the original startup sound file...${RESET}"
        mkdir -p "$(dirname "$BACKUP_SOUND_FILE")"
        cp "$ORIGINAL_SOUND_FILE" "$BACKUP_SOUND_FILE"
    fi

    # Replace the startup sound file
    sudo cp "$sound_file" "$ORIGINAL_SOUND_FILE"
    echo -e "${GREEN}Startup sound customized successfully.${RESET}"
}

# Main menu for managing system sounds
while true; do
    echo -e "${BLUE}${BOLD}Manage System Sounds${RESET}\n"
    PS3="Select an option: "
    options=("Enable System Sounds" "Mute System Sounds" "Customize Startup Sound" "Back")
    
    select opt in "${options[@]}"; do
        case $opt in
            "Enable System Sounds")
                enable_system_sounds
                ;;
            "Mute System Sounds")
                mute_system_sounds
                ;;
            "Customize Startup Sound")
                customize_startup_sound
                ;;
            "Back")
                echo -e "${CYAN}Returning to the main menu...${RESET}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid option! Please try again.${RESET}"
                ;;
        esac

        # Break out of the select loop after processing the option
        break
    done
done
