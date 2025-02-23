#!/bin/bash
# customize_terminal_colors.sh - Script to customize GNOME Terminal colors with multiple schemes (numberized selection)

# Define Colors for output
RESET="\033[0m"
BOLD="\033[1m"
CYAN="\033[36m"
GREEN="\033[32m"
RED="\033[31m"
YELLOW="\033[33m"

# Function to display a section header
section_header() {
    echo -e "${CYAN}${BOLD}$1${RESET}"
}

# Predefined color schemes (palette is a JSON array of 16 colors)
declare -A palette
declare -A background
declare -A foreground

# Solarized Dark
palette["Solarized Dark"]='["#073642", "#dc322f", "#859900", "#b58900", "#268bd2", "#d33682", "#2aa198", "#eee8d5", "#002b36", "#cb4b16", "#586e75", "#657b83", "#839496", "#6c71c4", "#93a1a1", "#fdf6e3"]'
background["Solarized Dark"]="'#002b36'"
foreground["Solarized Dark"]="'#839496'"

# Solarized Light
palette["Solarized Light"]='["#eee8d5", "#dc322f", "#859900", "#b58900", "#268bd2", "#d33682", "#2aa198", "#073642", "#fdf6e3", "#cb4b16", "#586e75", "#657b83", "#839496", "#6c71c4", "#93a1a1", "#002b36"]'
background["Solarized Light"]="'#fdf6e3'"
foreground["Solarized Light"]="'#657b83'"

# Dracula
palette["Dracula"]='["#282a36", "#ff5555", "#50fa7b", "#f1fa8c", "#bd93f9", "#ff79c6", "#8be9fd", "#f8f8f2", "#6272a4", "#ff6e6e", "#69ff94", "#ffffa5", "#d6acff", "#ff92df", "#a4ffff", "#ffffff"]'
background["Dracula"]="'#282a36'"
foreground["Dracula"]="'#f8f8f2'"

# Gruvbox Dark
palette["Gruvbox Dark"]='["#282828", "#cc241d", "#98971a", "#d79921", "#458588", "#b16286", "#689d6a", "#a89984", "#928374", "#fb4934", "#b8bb26", "#fabd2f", "#83a598", "#d3869b", "#8ec07c", "#ebdbb2"]'
background["Gruvbox Dark"]="'#282828'"
foreground["Gruvbox Dark"]="'#a89984'"

# Gruvbox Light
palette["Gruvbox Light"]='["#fbf1c7", "#cc241d", "#98971a", "#d79921", "#458588", "#b16286", "#689d6a", "#7c6f64", "#928374", "#fb4934", "#b8bb26", "#fabd2f", "#83a598", "#d3869b", "#8ec07c", "#3c3836"]'
background["Gruvbox Light"]="'#fbf1c7'"
foreground["Gruvbox Light"]="'#3c3836'"

# Nord
palette["Nord"]='["#3B4252", "#BF616A", "#A3BE8C", "#EBCB8B", "#81A1C1", "#B48EAD", "#88C0D0", "#E5E9F0", "#4C566A", "#BF616A", "#A3BE8C", "#EBCB8B", "#81A1C1", "#B48EAD", "#8FBCBB", "#ECEFF4"]'
background["Nord"]="'#2E3440'"
foreground["Nord"]="'#D8DEE9'"

# One Dark
palette["One Dark"]='["#282C34", "#e06c75", "#98c379", "#e5c07b", "#61afef", "#c678dd", "#56b6c2", "#abb2bf", "#545862", "#be5046", "#98c379", "#d19a66", "#61afef", "#c678dd", "#56b6c2", "#ffffff"]'
background["One Dark"]="'#282C34'"
foreground["One Dark"]="'#abb2bf'"

# Monokai
palette["Monokai"]='["#272822", "#f92672", "#a6e22e", "#fd971f", "#66d9ef", "#9e6ffe", "#5e7175", "#f8f8f2", "#75715e", "#f92672", "#a6e22e", "#fd971f", "#66d9ef", "#9e6ffe", "#5e7175", "#f8f8f2"]'
background["Monokai"]="'#272822'"
foreground["Monokai"]="'#f8f8f2'"

# Function to get the default GNOME Terminal profile ID
get_default_profile() {
    local default
    # First try using gsettings
    default=$(gsettings get org.gnome.Terminal.Legacy.ProfilesList default 2>/dev/null | tr -d "'")
    if [ -n "$default" ]; then
        echo "$default"
        return
    fi

    # Next, try using dconf read
    default=$(dconf read /org/gnome/terminal/legacy/profiles:/default 2>/dev/null | tr -d "'")
    if [ -n "$default" ]; then
        echo "$default"
        return
    fi

    # If still empty, list available profiles and let the user choose one
    local profiles=()
    while IFS= read -r line; do
        # Remove leading colon and trailing slash
        line="${line#:}"
        line="${line%/}"
        profiles+=("$line")
    done < <(dconf list /org/gnome/terminal/legacy/profiles:/ 2>/dev/null | grep '^:')

    if [ ${#profiles[@]} -eq 0 ]; then
        echo ""
    else
        echo "No default profile found. Available profiles:" >&2
        for i in "${!profiles[@]}"; do
            printf "%2d) %s\n" $((i+1)) "${profiles[$i]}" >&2
        done
        read -p "Enter the number of the terminal profile to use: " pchoice
        local pindex=$((pchoice - 1))
        if [ $pindex -ge 0 ] && [ $pindex -lt ${#profiles[@]} ]; then
            echo "${profiles[$pindex]}"
        else
            echo ""
        fi
    fi
}

# Function to apply a chosen scheme to the default profile
apply_scheme() {
    local scheme="$1"
    local default_profile
    default_profile=$(get_default_profile)
    if [ -z "$default_profile" ]; then
        echo -e "${RED}Failed to get default GNOME Terminal profile.${RESET}"
        exit 1
    fi
    local profile_path="/org/gnome/terminal/legacy/profiles:/:$default_profile/"

    echo -e "${CYAN}Applying scheme: $scheme${RESET}"
    # Disable using theme colors
    dconf write "$profile_path/use-theme-colors" "false"
    dconf write "$profile_path/palette" "${palette[$scheme]}"
    dconf write "$profile_path/background-color" "${background[$scheme]}"
    dconf write "$profile_path/foreground-color" "${foreground[$scheme]}"
    echo -e "${GREEN}Terminal colors updated to scheme: $scheme${RESET}"
}

# Main function
main() {
    section_header "Customize Terminal Colors"

    # Build an array of scheme names from the associative array keys
    local scheme_names=()
    for key in "${!palette[@]}"; do
        scheme_names+=("$key")
    done

    echo -e "${CYAN}${BOLD}Available Terminal Color Schemes:${RESET}"
    for i in "${!scheme_names[@]}"; do
        printf "%2d) %s\n" $((i+1)) "${scheme_names[$i]}"
    done
    echo

    read -p "Enter the number of the color scheme to apply: " choice

    # Validate the input (must be a number within the list)
    if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}Invalid input. Please enter a valid number.${RESET}"
        exit 1
    fi

    local index=$((choice-1))
    if [ $index -lt 0 ] || [ $index -ge ${#scheme_names[@]} ]; then
        echo -e "${RED}Choice out of range. Please try again.${RESET}"
        exit 1
    fi

    local selected_scheme="${scheme_names[$index]}"
    apply_scheme "$selected_scheme"
}

main

