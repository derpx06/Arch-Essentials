#!/usr/bin/env bash

# Define Colors
RESET="\033[0m"
BOLD="\033[1m"
CYAN="\033[36m"
GREEN="\033[32m"
RED="\033[31m"
YELLOW="\033[33m"

# Function to display section headers
section_header() {
    echo -e "${CYAN}${BOLD}\n$1${RESET}"
}

# Function to display error messages
error_msg() {
    echo -e "${RED}${BOLD}Error:${RESET} $1"
}

# Function to display success messages
success_msg() {
    echo -e "${GREEN}${BOLD}Success:${RESET} $1"
}

# Function to detect Linux distribution
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO_ID="${ID}"
    else
        error_msg "Could not detect Linux distribution!"
        exit 1
    fi
}

# Main function to change Plymouth theme
main() {
    section_header "Change Plymouth Theme"

    # Check for root privileges
    local SUDO_CMD=""
    if [[ $EUID -ne 0 ]]; then
        if ! command -v sudo &> /dev/null; then
            error_msg "sudo is not installed and you're not root!"
            exit 1
        fi
        SUDO_CMD="sudo"
    fi

    # Check if Plymouth is installed
    if ! command -v plymouth-set-default-theme &> /dev/null; then
        error_msg "Plymouth is not installed on your system!"
        echo -e "Install it with:"
        echo -e "  Debian/Ubuntu: ${YELLOW}sudo apt install plymouth plymouth-themes${RESET}"
        echo -e "  Arch Linux:    ${YELLOW}sudo pacman -S plymouth${RESET}"
        echo -e "  Fedora:        ${YELLOW}sudo dnf install plymouth${RESET}"
        exit 1
    fi

    # List available Plymouth themes
    section_header "Available Plymouth Themes"
    local themes=$(plymouth-set-default-theme --list)
    if [[ -z "$themes" ]]; then
        error_msg "No Plymouth themes found!"
        exit 1
    fi

    # Create theme selection menu
    PS3="$(echo -e "${CYAN}${BOLD}Enter the number of the theme to apply: ${RESET}")"
    select theme_name in $themes; do
        if [[ -n "$theme_name" ]]; then
            break
        else
            error_msg "Invalid selection! Try again."
        fi
    done

    # Apply selected theme
    section_header "Applying Theme"
    echo -e "  Selected theme: ${YELLOW}${theme_name}${RESET}"
    if ! $SUDO_CMD plymouth-set-default-theme "$theme_name"; then
        error_msg "Failed to set Plymouth theme!"
        exit 1
    fi

    # Update initramfs based on distribution
    section_header "Updating Initramfs"
    detect_distro
    case $DISTRO_ID in
        arch|manjaro)
            echo -e "  Detected distribution: ${YELLOW}Arch Linux${RESET}"
            $SUDO_CMD mkinitcpio -P
            ;;
        ubuntu|debian|pop|linuxmint)
            echo -e "  Detected distribution: ${YELLOW}${PRETTY_NAME}${RESET}"
            $SUDO_CMD update-initramfs -u
            ;;
        fedora|rhel|centos)
            echo -e "  Detected distribution: ${YELLOW}${PRETTY_NAME}${RESET}"
            $SUDO_CMD dracut --force
            ;;
        *)
            error_msg "Unsupported distribution: ${DISTRO_ID}"
            exit 1
            ;;
    esac

    # Check if initramfs update succeeded
    if [[ $? -ne 0 ]]; then
        error_msg "Failed to update initramfs!"
        exit 1
    fi

    success_msg "Plymouth theme changed to ${YELLOW}${theme_name}${GREEN}"
    echo -e "\n${BOLD}You may need to reboot to see the changes.${RESET}"
}

# Run the main function
main
