#!/bin/bash
# deepclean.sh - Comprehensive System Deep Clean for Arch Linux
# This script performs multiple safe cleanup tasks:
#   1. Clear Temporary Files (/tmp and /var/tmp)
#   2. Clear Pacman Cache
#   3. Clear System Logs (journalctl vacuum)
#   4. Clear Thumbnail Cache (~/.cache/thumbnails)
#   5. Remove Orphaned Packages (pacman)
#   6. Remove Old Kernels (pacman)
#   7. Clear AUR Cache (if using yay)
#   8. Clear User Cache (~/.cache contents)
#
# It displays a numbered, human‑readable menu with current sizes/counts for each task.
# The default selection (press Enter) runs "DeepClean" (all tasks).
# After executing one valid cleanup, the script returns to the main menu.
# If run via sudo, it uses the invoking user’s home directory.
#
# Make the script executable: chmod +x deepclean.sh

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

# Functions to get human-readable sizes or counts
get_dir_size() {
    du -sh "$1" 2>/dev/null | awk '{print $1}'
}

get_file_count() {
    find "$1" -type f 2>/dev/null | wc -l
}

# --- Cleanup Functions ---

clear_temp_files() {
    echo -e "\n${CYAN}${BOLD}Clearing Temporary Files...${RESET}"
    tmp_before=$(get_dir_size "/tmp")
    vartmp_before=$(get_dir_size "/var/tmp")
    echo "Current sizes: /tmp: $tmp_before, /var/tmp: $vartmp_before"
    sudo rm -rf /tmp/* /var/tmp/*
    sleep 2
    tmp_after=$(get_dir_size "/tmp")
    vartmp_after=$(get_dir_size "/var/tmp")
    echo "After cleanup: /tmp: $tmp_after, /var/tmp: $vartmp_after"
    read -n1 -r -p "Press Enter to continue..." key
}

clear_pacman_cache() {
    echo -e "\n${CYAN}${BOLD}Clearing Pacman Cache...${RESET}"
    CACHE_DIR="/var/cache/pacman/pkg"
    cache_before=$(get_dir_size "$CACHE_DIR")
    echo "Pacman cache size before: $cache_before"
    sudo paccache -r -k 2
    cache_after=$(get_dir_size "$CACHE_DIR")
    echo "Pacman cache size after: $cache_after"
    read -n1 -r -p "Press Enter to continue..." key
}

clear_system_logs() {
    echo -e "\n${CYAN}${BOLD}Clearing System Logs...${RESET}"
    journal_before=$(journalctl --disk-usage | awk '{print $4,$5}')
    echo "Journal log size before: $journal_before"
    vacuum_time="7d"
    sudo journalctl --vacuum-time=$vacuum_time
    journal_after=$(journalctl --disk-usage | awk '{print $4,$5}')
    echo "Journal log size after: $journal_after"
    read -n1 -r -p "Press Enter to continue..." key
}

clear_thumbnail_cache() {
    echo -e "\n${CYAN}${BOLD}Clearing Thumbnail Cache...${RESET}"
    THUMB_DIR="$USER_HOME/.cache/thumbnails"
    if [ ! -d "$THUMB_DIR" ]; then
        echo "No thumbnail cache directory found at $THUMB_DIR."
        read -n1 -r -p "Press Enter to continue..." key
        return
    fi
    thumb_before=$(get_dir_size "$THUMB_DIR")
    echo "Thumbnail cache size before: $thumb_before"
    rm -rf "$THUMB_DIR"/*
    sleep 1
    thumb_after=$(get_dir_size "$THUMB_DIR")
    echo "Thumbnail cache size after: $thumb_after"
    read -n1 -r -p "Press Enter to continue..." key
}

remove_orphaned_packages() {
    echo -e "\n${CYAN}${BOLD}Removing Orphaned Packages...${RESET}"
    orphans=$(pacman -Qdtq)
    if [ -z "$orphans" ]; then
        echo "No orphan packages found."
    else
        echo "Orphan packages found:"
        echo "$orphans"
        sudo pacman -Rns --noconfirm $orphans
        echo "Orphan packages removed."
    fi
    read -n1 -r -p "Press Enter to continue..." key
}

remove_old_kernels() {
    echo -e "\n${CYAN}${BOLD}Removing Old Kernel Packages...${RESET}"
    current_kernel=$(uname -r | cut -d'-' -f1)
    echo "Current kernel version: $current_kernel"
    installed_kernels=$(pacman -Q | grep -E '^linux(-lts)?' | awk '{print $1}')
    to_remove=()
    for kernel in $installed_kernels; do
        if ! pacman -Qi "$kernel" | grep -q "Version.*$current_kernel"; then
            to_remove+=("$kernel")
        fi
    done
    if [ ${#to_remove[@]} -eq 0 ]; then
        echo "No old kernel packages found."
    else
        echo "Old kernel packages found:"
        printf '%s\n' "${to_remove[@]}"
        sudo pacman -Rns --noconfirm "${to_remove[@]}"
        echo "Old kernel packages removed."
    fi
    read -n1 -r -p "Press Enter to continue..." key
}

clear_aur_cache() {
    echo -e "\n${CYAN}${BOLD}Clearing AUR Cache...${RESET}"
    if command_exists yay; then
        AUR_CACHE_DIR="$USER_HOME/.cache/yay"
        if [ -d "$AUR_CACHE_DIR" ]; then
            aur_cache_before=$(get_dir_size "$AUR_CACHE_DIR")
            echo "AUR cache size before: $aur_cache_before"
            yay -Sc --noconfirm
            aur_cache_after=$(get_dir_size "$AUR_CACHE_DIR")
            echo "AUR cache size after: $aur_cache_after"
        else
            echo "No AUR cache directory found at $AUR_CACHE_DIR."
        fi
    else
        echo -e "${YELLOW}yay is not installed. Skipping AUR cache cleanup.${RESET}"
    fi
    read -n1 -r -p "Press Enter to continue..." key
}

clear_user_cache() {
    echo -e "\n${CYAN}${BOLD}Clearing User Cache...${RESET}"
    USER_CACHE_DIR="$USER_HOME/.cache"
    cache_before=$(get_dir_size "$USER_CACHE_DIR")
    echo "User cache size before: $cache_before"
    read -p "This will remove all cached data in $USER_CACHE_DIR. Proceed? [Y/n]: " choice
    choice=${choice:-Y}
    if [[ "$choice" =~ ^[Yy]$ ]]; then
        rm -rf "$USER_CACHE_DIR"/*
        sleep 2
        cache_after=$(get_dir_size "$USER_CACHE_DIR")
        echo "User cache size after: $cache_after"
    else
        echo "User cache cleanup skipped."
    fi
    read -n1 -r -p "Press Enter to continue..." key
}

# Function to display a human-readable summary of cleanup targets
show_deepclean_summary() {
    echo -e "\n${CYAN}${BOLD}DeepClean Summary:${RESET}"
    echo "Temporary Files: /tmp: $(get_dir_size /tmp), /var/tmp: $(get_dir_size /var/tmp)"
    echo "Pacman Cache: $(get_dir_size /var/cache/pacman/pkg)"
    echo "System Logs (Journal): $(journalctl --disk-usage | awk '{print $4,$5}')"
    echo "Thumbnail Cache: $(get_dir_size "$USER_HOME/.cache/thumbnails")"
    echo "User Cache: $(get_dir_size "$USER_HOME/.cache")"
    if command_exists yay; then
        echo "AUR Cache: $(get_dir_size "$USER_HOME/.cache/yay")"
    else
        echo "AUR Cache: N/A (yay not installed)"
    fi
}

# Main Cleanup Menu - runs a single cleanup operation then returns to the main menu
cleanup_menu() {
    clear
    echo -e "${BLUE}${BOLD}Cleanup Menu${RESET}\n"
    echo "1. Remove Orphaned Packages"
    echo "2. Clear Temporary Files"
    echo "3. Clear Pacman Cache"
    echo "4. Clear System Logs"
    echo "5. Clear Thumbnail Cache"
    echo "6. Remove Old Kernels"
    echo "7. Clear AUR Cache"
    echo "8. Clear User Cache"
    echo "9. DeepClean (run all tasks with summary) [default]"
    echo "10. Back"
    echo ""
    read -p "Enter your choice (number) [default: 9]: " choice
    choice=${choice:-9}
    case $choice in
        1)
            remove_orphaned_packages
            ;;
        2)
            clear_temp_files
            ;;
        3)
            clear_pacman_cache
            ;;
        4)
            clear_system_logs
            ;;
        5)
            clear_thumbnail_cache
            ;;
        6)
            remove_old_kernels
            ;;
        7)
            clear_aur_cache
            ;;
        8)
            clear_user_cache
            ;;
        9)
            echo -e "\n${CYAN}${BOLD}DeepClean Selected!${RESET}"
            show_deepclean_summary
            read -p "Proceed with DeepClean (all tasks)? [Y/n]: " confirm
            confirm=${confirm:-Y}
            if [[ "$confirm" =~ ^[Yy]$ ]]; then
                clear_temp_files
                clear_pacman_cache
                clear_system_logs
                clear_thumbnail_cache
                remove_orphaned_packages
                remove_old_kernels
                clear_aur_cache
                clear_user_cache
                echo -e "${GREEN}${BOLD}DeepClean complete!${RESET}"
            else
                echo -e "${YELLOW}DeepClean canceled by user.${RESET}"
            fi
            ;;
        10)
            return 0
            ;;
        *)
            echo -e "${RED}Invalid option!${RESET}"
            read -n1 -r -p "Press Enter to continue..." key
            cleanup_menu
            return 0
            ;;
    esac
    # After one valid cleanup, return to the main menu
    return 0
}

# Run the Cleanup Menu once, then return to the main menu
cleanup_menu
echo -e "${GREEN}${BOLD}Cleanup complete!${RESET}"
exit 0

