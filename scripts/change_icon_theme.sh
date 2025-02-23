#!/bin/bash
# icon_theme.sh - Script to change the GNOME icon theme with preview option and DBus workaround

# Define Colors
RESET="\033[0m"
BOLD="\033[1m"
CYAN="\033[36m"
GREEN="\033[32m"
RED="\033[31m"
YELLOW="\033[33m"

# Function to display section headers
section_header() {
    echo -e "${CYAN}${BOLD}$1${RESET}"
}

# Function to preview a sample icon from the theme
preview_theme() {
    local theme="$1"
    local themes_dir="/usr/share/icons"
    local theme_path="$themes_dir/$theme"
    local sample_icon=""

    # Try common directories for a sample icon (e.g., folder icon)
    if [[ -d "$theme_path/48x48/places" ]]; then
        sample_icon=$(find "$theme_path/48x48/places" -type f \( -iname "*folder*.png" -o -iname "*folder*.svg" \) | head -n 1)
    fi
    if [[ -z "$sample_icon" && -d "$theme_path/32x32/places" ]]; then
        sample_icon=$(find "$theme_path/32x32/places" -type f \( -iname "*folder*.png" -o -iname "*folder*.svg" \) | head -n 1)
    fi
    if [[ -z "$sample_icon" && -d "$theme_path/scalable/places" ]]; then
        sample_icon=$(find "$theme_path/scalable/places" -type f \( -iname "*folder*.png" -o -iname "*folder*.svg" \) | head -n 1)
    fi

    if [[ -n "$sample_icon" ]]; then
        echo -e "${CYAN}Previewing sample icon: $sample_icon${RESET}"
        # Open the sample icon with the default image viewer
        xdg-open "$sample_icon" >/dev/null 2>&1
    else
        echo -e "${YELLOW}No sample icon found for preview in theme '$theme'.${RESET}"
    fi
}

# Main function to change icon theme
main() {
    section_header "Change Icon Theme"

    # List available icon themes
    echo -e "${CYAN}${BOLD}Available Icon Themes:${RESET}"
    themes_dir="/usr/share/icons"
    if [[ -d "$themes_dir" ]]; then
        themes=$(ls "$themes_dir")
        if [[ -z "$themes" ]]; then
            echo -e "${RED}No icon themes found in $themes_dir.${RESET}"
            exit 1
        fi
        echo "$themes"
    else
        echo -e "${RED}Icon themes directory not found: $themes_dir${RESET}"
        exit 1
    fi

    # Prompt user to select a theme
    read -p "Enter the name of the icon theme to apply: " theme_name
    if [[ -d "$themes_dir/$theme_name" ]]; then
        # Ask if the user wants a preview of the theme (default: no)
        read -p "Do you want to preview the theme? [Y/n]: " preview_choice
        preview_choice=${preview_choice:-N}
        if [[ "$preview_choice" =~ ^[Yy]$ ]]; then
            preview_theme "$theme_name"
            echo -e "${CYAN}Close the preview and press any key to continue...${RESET}"
            read -n1 -r
        fi

        # Confirm applying the theme
        read -p "Apply icon theme '$theme_name'? [Y/n]: " apply_choice
        apply_choice=${apply_choice:-Y}
        if [[ "$apply_choice" =~ ^[Yy]$ ]]; then
            echo -e "${CYAN}${BOLD}Applying icon theme: $theme_name${RESET}"
            # If there's no active DBus session, run the gsettings command via dbus-launch
            if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
                dbus-launch gsettings set org.gnome.desktop.interface icon-theme "$theme_name"
            else
                gsettings set org.gnome.desktop.interface icon-theme "$theme_name"
            fi
            echo -e "${GREEN}Icon theme applied successfully.${RESET}"
        else
            echo -e "${YELLOW}Icon theme not applied.${RESET}"
        fi
    else
        echo -e "${RED}Theme '$theme_name' not found in $themes_dir.${RESET}"
    fi
}

# Run the main function
main

