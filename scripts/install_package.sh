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

# Function to update the keyring
update_keyring() {
    echo -e "${CYAN}${BOLD}Updating Arch Linux keyring...${RESET}"
    sudo pacman -Sy archlinux-keyring --noconfirm
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Failed to update the keyring. Please check your internet connection or system configuration.${RESET}"
        exit 1
    fi
    echo -e "${GREEN}Keyring updated successfully.${RESET}"
}

# Function to install an AUR helper
install_aur_helper() {
    echo -e "${CYAN}${BOLD}Installing AUR helper...${RESET}"
    read -p "Choose an AUR helper to install (yay/paru/pikaur): " aur_helper
    case $aur_helper in
        "yay")
            sudo pacman -S --needed git base-devel --noconfirm
            git clone https://aur.archlinux.org/yay.git /tmp/yay-install || { echo -e "${RED}Failed to clone yay repository.${RESET}"; exit 1; }
            cd /tmp/yay-install || { echo -e "${RED}Failed to enter yay directory.${RESET}"; exit 1; }
            makepkg -si --noconfirm
            ;;
        "paru")
            sudo pacman -S --needed git base-devel --noconfirm
            git clone https://aur.archlinux.org/paru.git /tmp/paru-install || { echo -e "${RED}Failed to clone paru repository.${RESET}"; exit 1; }
            cd /tmp/paru-install || { echo -e "${RED}Failed to enter paru directory.${RESET}"; exit 1; }
            makepkg -si --noconfirm
            ;;
        "pikaur")
            sudo pacman -S --needed git base-devel --noconfirm
            git clone https://aur.archlinux.org/pikaur.git /tmp/pikaur-install || { echo -e "${RED}Failed to clone pikaur repository.${RESET}"; exit 1; }
            cd /tmp/pikaur-install || { echo -e "${RED}Failed to enter pikaur directory.${RESET}"; exit 1; }
            makepkg -si --noconfirm
            ;;
        *)
            echo -e "${RED}Invalid choice. Exiting...${RESET}"
            exit 1
            ;;
    esac

    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}$aur_helper installed successfully.${RESET}"
    else
        echo -e "${RED}Failed to install $aur_helper. Please check your system configuration.${RESET}"
        exit 1
    fi
}

# Main function to search and install packages
main() {
    section_header "Search and Install Package"

    # Prompt user to enter a package name
    read -p "Enter the name of the package to search for: " package_name

    # Search for the package in official repositories
    echo -e "${CYAN}${BOLD}Searching for '$package_name' in official repositories...${RESET}"
    official_results=$(pacman -Ss "$package_name" 2>/dev/null | head -n 20) # Top 10 results (each result has 2 lines)

    if [[ -n "$official_results" ]]; then
        echo -e "\n${CYAN}${BOLD}Top Results from Official Repositories:${RESET}"
        # Format results with numbers
        formatted_results=$(echo "$official_results" | awk '{if (NR % 2 == 1) printf "%d) %s ", NR/2+1, $1; else print $0}' | column -t)
        echo "$formatted_results"

        # Prompt user to select a package by number
        read -p "Enter the number of the package to install (or 0 to skip): " package_number
        if [[ "$package_number" -gt 0 && "$package_number" -le $(echo "$official_results" | wc -l) ]]; then
            # Extract the selected package name
            package_to_install=$(echo "$official_results" | sed -n "$((package_number * 2 - 1))p" | awk '{print $1}')

            # Update keyring before installing
            update_keyring

            echo -e "${CYAN}${BOLD}Installing '$package_to_install' from official repositories...${RESET}"
            sudo pacman -S "$package_to_install" --noconfirm

            if [[ $? -eq 0 ]]; then
                echo -e "${GREEN}Package '$package_to_install' installed successfully.${RESET}"
            else
                echo -e "${RED}Failed to install '$package_to_install'.${RESET}"
            fi
            return
        elif [[ "$package_number" -eq 0 ]]; then
            echo -e "${CYAN}Skipping installation from official repositories.${RESET}"
        else
            echo -e "${RED}Invalid selection. Skipping installation.${RESET}"
        fi
    else
        echo -e "${RED}No packages found matching '$package_name' in official repositories.${RESET}"
    fi

    # Prompt user to search in AUR
    read -p "Would you like to search for '$package_name' in the AUR? (y/n): " aur_choice
    if [[ "$aur_choice" != "y" && "$aur_choice" != "Y" ]]; then
        echo -e "${CYAN}Skipping AUR search. Exiting...${RESET}"
        return
    fi

    # Check if an AUR helper is installed
    aur_helper=""
    for helper in yay paru pikaur; do
        if command -v "$helper" &>/dev/null; then
            aur_helper="$helper"
            break
        fi
    done

    if [[ -z "$aur_helper" ]]; then
        echo -e "${RED}No AUR helper found. Would you like to install one? (y/n): ${RESET}"
        read -p "> " choice
        if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
            install_aur_helper
            aur_helper=$(command -v yay || command -v paru || command -v pikaur)
        else
            echo -e "${CYAN}Skipping AUR support. Exiting...${RESET}"
            return
        fi
    fi

    # Search for the package in AUR
    echo -e "${CYAN}${BOLD}Searching for '$package_name' in the AUR...${RESET}"
    aur_results=$($aur_helper -Ss "$package_name" 2>/dev/null | head -n 20) # Top 10 results (each result has 2 lines)

    if [[ -z "$aur_results" ]]; then
        echo -e "${RED}No packages found matching '$package_name' in the AUR.${RESET}"
        return
    fi

    echo -e "\n${CYAN}${BOLD}Top Results from AUR:${RESET}"
    # Format results with numbers
    formatted_results=$(echo "$aur_results" | awk '{if (NR % 2 == 1) printf "%d) %s ", NR/2+1, $1; else print $0}' | column -t)
    echo "$formatted_results"

    # Prompt user to select a package by number
    read -p "Enter the number of the package to install (or 0 to skip): " package_number
    if [[ "$package_number" -gt 0 && "$package_number" -le $(echo "$aur_results" | wc -l) ]]; then
        # Extract the selected package name
        package_to_install=$(echo "$aur_results" | sed -n "$((package_number * 2 - 1))p" | awk '{print $1}')

        # Update keyring before installing
        update_keyring

        echo -e "${CYAN}${BOLD}Installing '$package_to_install' from AUR...${RESET}"
        $aur_helper -S "$package_to_install" --noconfirm

        if [[ $? -eq 0 ]]; then
            echo -e "${GREEN}Package '$package_to_install' installed successfully.${RESET}"
        else
            echo -e "${RED}Failed to install '$package_to_install'.${RESET}"
        fi
    elif [[ "$package_number" -eq 0 ]]; then
        echo -e "${CYAN}Skipping installation from AUR. Exiting...${RESET}"
    else
        echo -e "${RED}Invalid selection. Skipping installation.${RESET}"
    fi
}

# Run the main function
main
