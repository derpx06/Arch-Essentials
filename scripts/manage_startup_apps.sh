#!/bin/bash

# Define Colors
RESET="\033[0m"
BOLD="\033[1m"
BLUE="\033[34m"
GREEN="\033[32m"
RED="\033[31m"
CYAN="\033[36m"

# Define the autostart directories
USER_AUTOSTART_DIR="$HOME/.config/autostart"
SYSTEM_AUTOSTART_DIR="/etc/xdg/autostart"

# Log file setup
LOG_FILE="$HOME/.startup-apps.log"
exec 1> >(tee -a "$LOG_FILE")
exec 2>&1

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Function to ensure the autostart directory exists with proper permissions
ensure_autostart_dir() {
    if [[ ! -d "$USER_AUTOSTART_DIR" ]]; then
        mkdir -p "$USER_AUTOSTART_DIR"
        chmod 700 "$USER_AUTOSTART_DIR"
        log_message "Created autostart directory: $USER_AUTOSTART_DIR"
    fi
}

# Function to validate desktop file
validate_desktop_file() {
    local file="$1"
    local errors=0
    
    # Check required fields
    if ! grep -q "^\[Desktop Entry\]" "$file"; then
        echo -e "${RED}Error: Missing [Desktop Entry] section${RESET}"
        ((errors++))
    fi
    
    if ! grep -q "^Type=" "$file"; then
        echo -e "${RED}Error: Missing Type field${RESET}"
        ((errors++))
    fi
    
    if ! grep -q "^Name=" "$file"; then
        echo -e "${RED}Error: Missing Name field${RESET}"
        ((errors++))
    fi
    
    if ! grep -q "^Exec=" "$file"; then
        echo -e "${RED}Error: Missing Exec field${RESET}"
        ((errors++))
    }
    
    return $errors
}

# Function to list startup applications
list_startup_apps() {
    ensure_autostart_dir
    echo -e "${CYAN}${BOLD}User Startup Applications:${RESET}"
    if [[ -d "$USER_AUTOSTART_DIR" && "$(ls -A "$USER_AUTOSTART_DIR")" ]]; then
        for file in "$USER_AUTOSTART_DIR"/*.desktop; do
            if [[ -f "$file" ]]; then
                name=$(grep "^Name=" "$file" | cut -d= -f2)
                exec=$(grep "^Exec=" "$file" | cut -d= -f2)
                enabled=$(grep "^X-GNOME-Autostart-enabled=" "$file" | cut -d= -f2)
                enabled=${enabled:-true}
                
                if [[ "$enabled" == "true" ]]; then
                    echo -e "${GREEN}● ${RESET}$name ($exec)"
                else
                    echo -e "${RED}○ ${RESET}$name ($exec) [Disabled]"
                fi
            fi
        done
    else
        echo "No user startup applications found."
    fi
    
    echo -e "\n${CYAN}${BOLD}System Startup Applications:${RESET}"
    if [[ -d "$SYSTEM_AUTOSTART_DIR" && "$(ls -A "$SYSTEM_AUTOSTART_DIR")" ]]; then
        for file in "$SYSTEM_AUTOSTART_DIR"/*.desktop; do
            if [[ -f "$file" ]]; then
                name=$(grep "^Name=" "$file" | cut -d= -f2)
                echo "  $name"
            fi
        done
    else
        echo "No system startup applications found."
    fi
}

# Function to add startup application
add_startup_app() {
    ensure_autostart_dir
    
    echo -e "${CYAN}Adding New Startup Application${RESET}"
    read -p "Enter application name: " app_name
    read -p "Enter command to run: " app_command
    read -p "Enter application description (optional): " app_description
    
    desktop_file="$USER_AUTOSTART_DIR/${app_name// /_}.desktop"
    
    # Create desktop file with proper permissions
    cat > "$desktop_file" << EOF
[Desktop Entry]
Type=Application
Name=$app_name
Exec=$app_command
Terminal=false
X-GNOME-Autostart-enabled=true
EOF

    if [[ -n "$app_description" ]]; then
        echo "Comment=$app_description" >> "$desktop_file"
    fi
    
    # Set proper permissions
    chmod 644 "$desktop_file"
    
    # Validate the created file
    if validate_desktop_file "$desktop_file"; then
        log_message "Added startup application: $app_name"
        echo -e "${GREEN}Successfully added $app_name to startup applications.${RESET}"
    else
        log_message "Failed to create valid desktop file for: $app_name"
        echo -e "${RED}Failed to create valid startup entry. Check the log file.${RESET}"
        rm "$desktop_file"
    fi
}

# Function to remove startup application
remove_startup_app() {
    ensure_autostart_dir
    echo -e "${CYAN}${BOLD}Available Startup Applications:${RESET}"
    list_startup_apps
    
    echo -e "\n${CYAN}Enter the name of the application to remove:${RESET}"
    read -p "> " app_name
    
    # Convert input to desktop file name format
    desktop_file="$USER_AUTOSTART_DIR/${app_name// /_}.desktop"
    
    if [[ -f "$desktop_file" ]]; then
        rm "$desktop_file"
        log_message "Removed startup application: $app_name"
        echo -e "${GREEN}Successfully removed $app_name from startup applications.${RESET}"
    else
        log_message "Failed to remove startup application (not found): $app_name"
        echo -e "${RED}Application $app_name not found in startup applications.${RESET}"
    fi
}

# Function to toggle startup application
toggle_startup_app() {
    ensure_autostart_dir
    echo -e "${CYAN}${BOLD}Available Startup Applications:${RESET}"
    list_startup_apps
    
    echo -e "\n${CYAN}Enter the name of the application to toggle:${RESET}"
    read -p "> " app_name
    
    desktop_file="$USER_AUTOSTART_DIR/${app_name// /_}.desktop"
    
    if [[ -f "$desktop_file" ]]; then
        current_state=$(grep "^X-GNOME-Autostart-enabled=" "$desktop_file" | cut -d= -f2)
        current_state=${current_state:-true}
        
        if [[ "$current_state" == "true" ]]; then
            sed -i 's/^X-GNOME-Autostart-enabled=.*/X-GNOME-Autostart-enabled=false/' "$desktop_file"
            echo -e "${GREEN}Disabled $app_name at startup.${RESET}"
        else
            sed -i 's/^X-GNOME-Autostart-enabled=.*/X-GNOME-Autostart-enabled=true/' "$desktop_file"
            echo -e "${GREEN}Enabled $app_name at startup.${RESET}"
        fi
        
        log_message "Toggled startup state for: $app_name"
    else
        log_message "Failed to toggle application (not found): $app_name"
        echo -e "${RED}Application $app_name not found in startup applications.${RESET}"
    fi
}

# Main menu
while true; do
    echo -e "\n${BLUE}${BOLD}Manage Startup Applications${RESET}"
    echo "1. List Startup Applications"
    echo "2. Add Startup Application"
    echo "3. Remove Startup Application"
    echo "4. Toggle Startup Application"
    echo "5. Exit"
    
    read -p "Select an option (1-5): " choice
    
    case $choice in
        1)
            list_startup_apps
            ;;
        2)
            add_startup_app
            ;;
        3)
            remove_startup_app
            ;;
        4)
            toggle_startup_app
            ;;
        5)
            echo -e "${GREEN}Exiting...${RESET}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option!${RESET}"
            ;;
    esac
done
