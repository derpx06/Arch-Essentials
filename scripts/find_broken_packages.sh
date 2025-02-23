#!/bin/bash
# find_broken_packages.sh - Identify and repair broken packages using pacman (for Arch-based systems)

REPORT_FILE="$HOME/broken_packages_report.txt"
: > "$REPORT_FILE"

echo "Checking for broken packages on this system..." | tee "$REPORT_FILE"
echo "Timestamp: $(date)" | tee -a "$REPORT_FILE"

# Ensure pacman is available
if ! command -v pacman >/dev/null 2>&1; then
    echo -e "${RED}Pacman not found. This script is for pacman-based systems.${RESET}" | tee -a "$REPORT_FILE"
    exit 1
fi

# Find broken packages (packages with missing files)
broken_pkgs=$(pacman -Qk 2>&1 | grep -v ' 0 missing files' | awk '{print $1}' | sort -u)

if [ -n "$broken_pkgs" ]; then
    echo -e "\nBroken packages detected:" | tee -a "$REPORT_FILE"
    echo "$broken_pkgs" | tee -a "$REPORT_FILE"
    echo -e "\nAttempting to reinstall broken packages..." | tee -a "$REPORT_FILE"
    sudo pacman -S --needed $broken_pkgs | tee -a "$REPORT_FILE"
    
    echo -e "\nRe-checking for broken packages:" | tee -a "$REPORT_FILE"
    new_broken=$(pacman -Qk 2>&1 | grep -v ' 0 missing files' | awk '{print $1}' | sort -u)
    if [ -n "$new_broken" ]; then
        echo -e "${RED}Some packages remain broken:${RESET}" | tee -a "$REPORT_FILE"
        echo "$new_broken" | tee -a "$REPORT_FILE"
    else
        echo -e "${GREEN}All broken packages have been fixed.${RESET}" | tee -a "$REPORT_FILE"
    fi
else
    echo -e "${GREEN}No broken packages found.${RESET}" | tee -a "$REPORT_FILE"
fi

echo -e "\nDetailed broken packages report saved to: ${REPORT_FILE}"
read -n1 -r -p "Press any key to return..."

