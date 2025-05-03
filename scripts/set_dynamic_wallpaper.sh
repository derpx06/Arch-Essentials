#!/bin/bash
# dynamic_wallpaper_installer.sh - Installer for Dynamic Wallpapers on Arch Linux
# This script installs dynamic wallpapers for various desktop environments.
# It:
#   - Checks for required packages (git, feh, cronie, xorg-xrandr)
#   - Refreshes the pacman keyring before installing missing packages
#   - Verifies the repository is cloned; if incomplete, deletes and re-clones it
#   - Runs the repository's install.sh script as sudo
#
# If run as root (via sudo), it uses the invoking user's home directory.

# Define Colors
RESET="\033[0m"
BOLD="\033[1m"
BLUE="\033[34m"
GREEN="\033[32m"
RED="\033[31m"
CYAN="\033[36m"
YELLOW="\033[33m"

# Determine target user's home directory
if [ "$EUID" -eq 0 ] && [ -n "$SUDO_USER" ]; then
    USER_HOME=$(eval echo "~$SUDO_USER")
else
    USER_HOME=$HOME
fi

# Log file setup
LOG_FILE="$USER_HOME/.dynamic-wallpaper.log"
exec 1> >(tee -a "$LOG_FILE")
exec 2>&1

echo -e "${BLUE}${BOLD}Dynamic Wallpaper Installer${RESET}\n"

# Function to check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Function to prompt for installation if a command is missing; refresh keyring first.
# Defaults to yes if no input is provided.
prompt_install() {
    local pkg_name="$1"
    local cmd_name="$2"
    if ! command_exists "$cmd_name"; then
        echo -e "${RED}$cmd_name is not installed.${RESET}"
        read -p "Do you want to install $pkg_name? [Y/n]: " choice
        choice=${choice:-Y}
        if [[ "$choice" =~ ^[Yy]$ ]]; then
            echo -e "${CYAN}Refreshing pacman keyring...${RESET}"
            sudo pacman-key --init
            sudo pacman-key --populate
            echo -e "${CYAN}Installing $pkg_name...${RESET}"
            sudo pacman -S --noconfirm "$pkg_name" || { 
                log_message "Failed to install $pkg_name"
                echo -e "${RED}Failed to install $pkg_name. Exiting...${RESET}"
                exit 1
            }
            log_message "Successfully installed $pkg_name"
        else
            log_message "User declined to install $pkg_name"
            echo -e "${RED}Cannot proceed without $cmd_name. Exiting...${RESET}"
            exit 1
        fi
    fi
}

# Check for required packages
echo -e "${CYAN}Checking for required packages...${RESET}"
REQUIRED_PACKAGES=(git feh cronie xorg-xrandr gnome-settings-daemon)
for pkg in "${REQUIRED_PACKAGES[@]}"; do
    prompt_install "$pkg" "$pkg"
done

# Function to set wallpaper based on session type
set_wallpaper() {
    local wallpaper_path="$1"
    
    # Check if file exists and is readable
    if [ ! -f "$wallpaper_path" ] || [ ! -r "$wallpaper_path" ]; then
        log_message "Error: Wallpaper file not found or not readable: $wallpaper_path"
        echo -e "${RED}Error: Wallpaper file not found or not readable${RESET}"
        return 1
    }

    # Set wallpaper based on session type
    if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
        gsettings set org.gnome.desktop.background picture-uri "file://$wallpaper_path"
        gsettings set org.gnome.desktop.background picture-uri-dark "file://$wallpaper_path"
    else
        gsettings set org.gnome.desktop.background picture-uri "file://$wallpaper_path"
        feh --bg-scale "$wallpaper_path"
    fi

    # Verify wallpaper was set
    if [ $? -eq 0 ]; then
        log_message "Successfully set wallpaper: $wallpaper_path"
        echo -e "${GREEN}Wallpaper set successfully${RESET}"
    else
        log_message "Failed to set wallpaper: $wallpaper_path"
        echo -e "${RED}Failed to set wallpaper${RESET}"
        return 1
    fi
}

# Repository settings
REPO_URL="https://github.com/adi1090x/dynamic-wallpaper.git"
REPO_DIR="$USER_HOME/.local/share/dynamic-wallpaper"

# Create repository directory with proper permissions
mkdir -p "$REPO_DIR"
chmod 755 "$REPO_DIR"

# Function to check for valid wallpaper directory inside repo
find_wallpaper_dir() {
    if [ -d "wallpapers" ]; then
        echo "wallpapers"
    elif [ -d "wallpaper" ]; then
        echo "wallpaper"
    else
        echo ""
    fi
}

# Check if repository is already cloned and valid
if [ -d "$REPO_DIR" ]; then
    echo -e "${CYAN}Repository already exists. Checking validity...${RESET}"
    cd "$REPO_DIR" || exit
    REPO_WALLP_DIR=$(find_wallpaper_dir)
    if [ -z "$REPO_WALLP_DIR" ]; then
        echo -e "${YELLOW}Repository appears incomplete.${RESET}"
        read -p "Do you want to delete and re-clone it? [Y/n]: " reclone
        reclone=${reclone:-Y}
        if [[ "$reclone" =~ ^[Yy]$ ]]; then
            cd ..
            rm -rf "$REPO_DIR"
            log_message "Removed incomplete repository"
        else
            log_message "User declined to re-clone incomplete repository"
            echo -e "${RED}Cannot proceed without valid repository. Exiting...${RESET}"
            exit 1
        fi
    fi
fi

# Clone repository if it doesn't exist
if [ ! -d "$REPO_DIR" ]; then
    echo -e "${YELLOW}Warning: The dynamic-wallpaper repository is >1GB in size.${RESET}"
    read -p "Do you want to proceed with installation? [Y/n]: " confirm
    confirm=${confirm:-Y}
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        log_message "User cancelled installation"
        echo -e "${RED}Installation cancelled. Exiting...${RESET}"
        exit 0
    fi

    echo -e "${CYAN}Cloning dynamic-wallpaper repository...${RESET}"
    git clone "$REPO_URL" "$REPO_DIR" || {
        log_message "Failed to clone repository"
        echo -e "${RED}Failed to clone repository. Exiting...${RESET}"
        exit 1
    }
    log_message "Successfully cloned repository"
fi

# Set up automatic wallpaper changing (if desired)
read -p "Do you want to enable automatic wallpaper changing? [Y/n]: " auto_change
auto_change=${auto_change:-Y}
if [[ "$auto_change" =~ ^[Yy]$ ]]; then
    # Create the script that will change the wallpaper
    CHANGE_SCRIPT="$USER_HOME/.local/bin/change-wallpaper"
    mkdir -p "$(dirname "$CHANGE_SCRIPT")"
    
    cat > "$CHANGE_SCRIPT" << 'EOF'
#!/bin/bash
WALLPAPER_DIR="$HOME/.local/share/dynamic-wallpaper/wallpapers"
WALLPAPER=$(find "$WALLPAPER_DIR" -type f -name "*.jpg" -o -name "*.png" | shuf -n 1)
if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
    gsettings set org.gnome.desktop.background picture-uri "file://$WALLPAPER"
    gsettings set org.gnome.desktop.background picture-uri-dark "file://$WALLPAPER"
else
    gsettings set org.gnome.desktop.background picture-uri "file://$WALLPAPER"
    feh --bg-scale "$WALLPAPER"
fi
EOF

    chmod +x "$CHANGE_SCRIPT"
    
    # Add to user's crontab (change every hour)
    (crontab -l 2>/dev/null; echo "0 * * * * $CHANGE_SCRIPT") | crontab -
    
    log_message "Enabled automatic wallpaper changing"
    echo -e "${GREEN}Automatic wallpaper changing enabled${RESET}"
fi

echo -e "\n${GREEN}${BOLD}Dynamic Wallpaper installation completed!${RESET}"
echo -e "${CYAN}Log file available at: $LOG_FILE${RESET}"

exit 0
