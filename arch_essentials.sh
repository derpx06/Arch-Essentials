#!/bin/bash
# Define Colors
RESET="\033[0m"
BOLD="\033[1m"
BLUE="\033[34m"
GREEN="\033[32m"
RED="\033[31m"
CYAN="\033[36m"

# Define ASCII Art for Arch Linux
ASCII_ART=$(cat << 'EOF'
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⣇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⣿⣿⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣿⣿⣿⣿⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢿⣿⣿⣿⣿⣿⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣷⣤⣙⢻⣿⣿⣿⣿⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⢀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⢠⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⡄⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⢠⣿⣿⣿⣿⣿⡿⠛⠛⠿⣿⣿⣿⣿⣿⡄⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⢠⣿⣿⣿⣿⣿⠏⠀⠀⠀⠀⠙⣿⣿⣿⣿⣿⡄⠀⠀⠀⠀⠀
⠀⠀⠀⠀⣰⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⢿⣿⣿⣿⣿⠿⣆⠀⠀⠀⠀
⠀⠀⠀⣴⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣷⣦⡀⠀⠀⠀
⠀⢀⣾⣿⣿⠿⠟⠛⠋⠉⠉⠀⠀⠀⠀⠀⠀⠉⠉⠙⠛⠻⠿⣿⣿⣷⡀⠀
⣠⠟⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠙⠻⣄⠀⠀
Arch Linux Essentials⠀⠀⠀⠀⠀⠀
EOF
)

# Function to display the ASCII art and menu
show_banner() {
    clear
    echo -e "${BLUE}$ASCII_ART${RESET}"
    echo -e "${CYAN}${BOLD}Welcome to Arch Tools!${RESET}\n"
}

# Function to call scripts from the 'scripts' folder
run_script() {
    script_name=$1
    if [[ -f "scripts/$script_name.sh" ]]; then
        # Display selected option in a box
        echo -e "${GREEN}${BOLD}┌──────────────────────────────────────────────────────┐${RESET}"
        echo -e "${GREEN}${BOLD}│ Running: $script_name                                  │${RESET}"
        echo -e "${GREEN}${BOLD}└──────────────────────────────────────────────────────┘${RESET}"
        sleep 1
        bash "scripts/$script_name.sh"
    else
        echo -e "${RED}Script $script_name.sh not found!${RESET}"
    fi
    read -n1 -r -p "Press any key to continue..." key
}

# Submenu functions
customize_menu() {
    while true; do
        show_banner
        echo -e "${CYAN}${BOLD}Customize Menu${RESET}\n"
        choice=$(echo -e "Customize Terminal Colors\nChange GRUB Theme\nBoot Animation\nInstall Fonts\nManage Startup Applications\nSet Dynamic Wallpaper\nManage System Sounds\nBack" | \
                 fzf --height 20 --border --ansi --prompt="Customize > ")
        case $choice in
            "Customize Terminal Colors")
                run_script "customize_terminal_colors"
                ;;
            "Change GRUB Theme")
                run_script "change_grub_theme"
                ;;
            "Boot Animation")
                run_script "change_plymouth_theme"
                ;;
            "Install Fonts")
                run_script "install_fonts"
                ;;
            "Manage Startup Applications")
                run_script "manage_startup_apps"
                ;;
            "Set Dynamic Wallpaper")
                run_script "set_dynamic_wallpaper"
                ;;
            "Manage System Sounds")
                run_script "manage_system_sounds"
                ;;
            "Back")
                break
                ;;
            *)
                echo -e "${RED}Invalid option!${RESET}"
                read -n1 -r -p "Press any key to continue..." key
                ;;
        esac
    done
}


update_install_menu() {
    while true; do
        show_banner
        echo -e "${CYAN}${BOLD}Update/Install Menu${RESET}\n"
        choice=$(echo -e "System Update\nUpgrade Packages\nClean Package Cache\nInstall\nBack" | \
                 fzf --height 20 --border --ansi --prompt="Update/Install > ")
        case $choice in
            "System Update")
                run_script "system_update"
                ;;
            "Upgrade Packages")
                run_script "upgrade_packages"
                ;;
            "Clean Package Cache")
                run_script "clean_package_cache"
                ;;
            "Install")
                run_script "install_package"
                ;;
            "Back")
                break
                ;;
            *)
                echo -e "${RED}Invalid option!${RESET}"
                read -n1 -r -p "Press any key to continue..." key
                ;;
        esac
    done
}

debug_menu() {
    while true; do
        show_banner
        echo -e "${CYAN}${BOLD}Debug Menu${RESET}\n"
        choice=$(echo -e "Check Logs\nFind Broken Packages\nDeep Debug\nBack" | \
                 fzf --height 20 --border --ansi --prompt="Debug > ")
        case $choice in
            "Check Logs")
                run_script "check_logs"
                ;;
            "Find Broken Packages")
                run_script "find_broken_packages"
                ;;
            "Deep Debug")
                run_script "deep_debug"
                ;;
            "Back")
                break
                ;;
            *)
                echo -e "${RED}Invalid option!${RESET}"
                read -n1 -r -p "Press any key to continue..." key
                ;;
        esac
    done
}

cleanup_menu() {
    while true; do
        show_banner
        echo -e "${CYAN}${BOLD}Cleanup Menu${RESET}\n"
        choice=$(echo -e "Remove Orphaned Packages\nClear Temporary Files\nClear Pacman Cache\nClear System Logs\nDeep Clean\nBack" | \
                 fzf --height 20 --border --ansi --prompt="Cleanup > ")
        case $choice in
            "Remove Orphaned Packages")
                run_script "remove_orphaned_packages"
                ;;
            "Clear Temporary Files")
                run_script "clear_temp_files"
                ;;
            "Clear Pacman Cache")
                run_script "clear_pacman_cache"
                ;;
            "Clear System Logs")
                run_script "clear_system_logs"
                ;;
                "Deep Clean")
                run_script "deep_clean"
                ;;
            "Back")
                break
                ;;
            *)
                echo -e "${RED}Invalid option!${RESET}"
                read -n1 -r -p "Press any key to continue..." key
                ;;
        esac
    done
}

network_menu() {
    while true; do
        show_banner
        echo -e "${CYAN}${BOLD}Network Menu${RESET}\n"
        choice=$(echo -e "Test Internet Connection\nShow IP Address\nNetwork Overview\nNetwork Speed\nBack" | \
                 fzf --height 20 --border --ansi --prompt="Network > ")
        case $choice in
            "Test Internet Connection")
                run_script "test_internet_connection"
                ;;
            "Show IP Address")
                run_script "show_ip_address"
                ;;
            "Network Speed")
                run_script "network_speed"
                ;;
        	"Network Overview")
        	run_script "network_overview"
        	;;
            "Back")
                break
                ;;
            *)
                echo -e "${RED}Invalid option!${RESET}"
                read -n1 -r -p "Press any key to continue..." key
                ;;
        esac
    done
}

system_info_menu() {
    while true; do
        show_banner
        echo -e "${CYAN}${BOLD}System Info Menu${RESET}\n"
        choice=$(echo -e "Show System Specs\nOverview\nList Installed Packages\nBack" | \
                 fzf --height 20 --border --ansi --prompt="System Info > ")
        case $choice in
            "Show System Specs")
                run_script "show_system_specs"
                ;;
            "Overview")
                run_script "system_overview"
                ;;
            "List Installed Packages")
                run_script "list_installed_packages"
                ;;
            "Back")
                break
                ;;
            *)
                echo -e "${RED}Invalid option!${RESET}"
                read -n1 -r -p "Press any key to continue..." key
                ;;
        esac
    done
}

# Main menu function
main_menu() {
    while true; do
        show_banner
        choice=$(echo -e "Customize\nUpdate/Install\nDebug\nCleanup\nNetwork\nSystem Info\nExit" | \
                 fzf --height 20 --border --ansi --prompt="Main Menu > ")
        case $choice in
            "Customize")
                customize_menu
                ;;
            "Update/Install")
                update_install_menu
                ;;
            "Debug")
                debug_menu
                ;;
            "Cleanup")
                cleanup_menu
                ;;
            "Network")
                network_menu
                ;;
            "System Info")
                system_info_menu
                ;;
            "Exit")
                echo -e "${CYAN}Goodbye from Arch Tools!${RESET}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid option!${RESET}"
                read -n1 -r -p "Press any key to continue..." key
                ;;
        esac
    done
}

# Run the main menu
main_menu
