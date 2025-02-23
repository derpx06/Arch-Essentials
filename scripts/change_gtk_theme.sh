#!/bin/bash
# gtk_theme.sh - Script to change the GNOME GTK theme with DBus workaround

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

# Function to check if a command exists
command_exists() {
    command -v "$1" &>/dev/null
}

# Main function to change GTK theme
main() {
    section_header "Change GTK Theme"

    # Ensure gsettings is available
    if ! command_exists gsettings; then
        echo -e "${RED}Error: gsettings is not installed or not in your PATH.${RESET}"
        exit 1
    fi

    # Define theme directories (system and user)
    system_themes="/usr/share/themes"
    user_themes="$HOME/.themes"
    theme_list=()

    # Function to collect themes from a directory
    collect_themes() {
        local dir="$1"
        if [[ -d "$dir" ]]; then
            for theme in "$dir"/*; do
                if [[ -d "$theme" ]]; then
                    theme_list+=("$(basename "$theme")")
                fi
            done
        fi
    }

    # Collect themes from both system and user directories
    collect_themes "$system_themes"
    collect_themes "$user_themes"

    if [[ ${#theme_list[@]} -eq 0 ]]; then
        echo -e "${RED}No GTK themes found in $system_themes or $user_themes.${RESET}"
        exit 1
    fi

    # Display available themes
    echo -e "${CYAN}${BOLD}Available GTK Themes:${RESET}"
    for theme in "${theme_list[@]}"; do
        echo "$theme"
    done

    # Prompt user to select a theme
    read -p "Enter the name of the GTK theme to apply: " theme_name

    # Determine which directory contains the selected theme
    if [[ -d "$system_themes/$theme_name" ]]; then
        theme_dir="$system_themes/$theme_name"
    elif [[ -d "$user_themes/$theme_name" ]]; then
        theme_dir="$user_themes/$theme_name"
    else
        echo -e "${RED}Theme '$theme_name' not found in either $system_themes or $user_themes.${RESET}"
        exit 1
    fi

    echo -e "${CYAN}${BOLD}Applying GTK theme: $theme_name${RESET}"
    # Use dbus-launch if DBUS_SESSION_BUS_ADDRESS is not set
    if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
        dbus-launch gsettings set org.gnome.desktop.interface gtk-theme "$theme_name"
    else
        gsettings set org.gnome.desktop.interface gtk-theme "$theme_name"
    fi
    echo -e "${GREEN}GTK theme applied successfully.${RESET}"
}

# Run the main function
main

