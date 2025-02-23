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

echo -e "${BLUE}${BOLD}Dynamic Wallpaper Installer${RESET}\n"

# Function to check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
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
            sudo pacman -S --noconfirm "$pkg_name" || { echo -e "${RED}Failed to install $pkg_name. Exiting...${RESET}"; exit 1; }
        else
            echo -e "${RED}Cannot proceed without $cmd_name. Exiting...${RESET}"
            exit 1
        fi
    fi
}

# Check for required packages
echo -e "${CYAN}Checking for required packages...${RESET}"
REQUIRED_PACKAGES=(git feh cronie xorg-xrandr)
for pkg in "${REQUIRED_PACKAGES[@]}"; do
    prompt_install "$pkg" "$pkg"
done

# Repository settings
REPO_URL="https://github.com/adi1090x/dynamic-wallpaper.git"
REPO_DIR="dynamic-wallpaper"

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
    echo -e "${CYAN}Repository already cloned. Entering ${BOLD}$REPO_DIR${RESET}${CYAN} directory...${RESET}"
    cd "$REPO_DIR" || exit
    REPO_WALLP_DIR=$(find_wallpaper_dir)
    if [ -z "$REPO_WALLP_DIR" ]; then
        echo -e "${YELLOW}The repository appears incomplete (no wallpaper directory found).${RESET}"
        read -p "Do you want to delete the existing repository and re-clone it? [Y/n]: " reclone
        reclone=${reclone:-Y}
        if [[ "$reclone" =~ ^[Yy]$ ]]; then
            cd ..
            rm -rf "$REPO_DIR"
        else
            echo -e "${RED}Cannot proceed without a valid repository structure. Exiting...${RESET}"
            exit 1
        fi
    fi
fi

# Clone repository if it doesn't exist
if [ ! -d "$REPO_DIR" ]; then
    echo -e "${YELLOW}Warning: The dynamic-wallpaper repository is expected to be >1GB in size.${RESET}"
    read -p "Do you want to clone and install dynamic wallpapers? [Y/n]: " confirm
    confirm=${confirm:-Y}
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        echo -e "${RED}Installation canceled by the user. Exiting...${RESET}"
        exit 0
    fi
    echo -e "${CYAN}Cloning dynamic-wallpaper repository...${RESET}"
    git clone "$REPO_URL" || { echo -e "${RED}Failed to clone repository. Exiting...${RESET}"; exit 1; }
    cd "$REPO_DIR" || exit
fi

# Run the repository's install.sh script as sudo
echo -e "${CYAN}Running the repository's install.sh script...${RESET}"
sudo chmod +x install.sh
sudo ./install.sh || { echo -e "${RED}Failed to run install.sh. Exiting...${RESET}"; exit 1; }
echo -e "\n${GREEN}${BOLD}see you gnome settings!"
echo -e "\n${GREEN}${BOLD}Dynamic Wallpaper installation completed successfully!${RESET}"
exit 0
