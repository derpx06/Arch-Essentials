#!/bin/bash
# deep_debug.sh - Comprehensive System Debugging & Hardware Health Checker
#
# This script performs extensive diagnostics:
#   - Collects system/hardware info (CPU, Memory, Motherboard, etc.)
#   - Checks CPU temperature, fan speeds, and if available, GPU status.
#   - Verifies disk health via SMART; if a disk fails, its full output is saved.
#   - Gathers network interface info and connectivity tests.
#   - Checks services, processes, logs, and package issues (orphan packages, missing dependencies,
#     broken packages) on pacman-based systems.
#
# All detected issues and detailed dumps are written to $REPORT_FILE.
#
# Requirements: sudo privileges for some commands, lm-sensors, smartmontools, lshw, etc.
#
# Set REPORT_FILE path in home directory
REPORT_FILE="$HOME/debug_report.txt"

# Color variables for terminal output
RESET="\033[0m"
BOLD="\033[1m"
BLUE="\033[34m"
GREEN="\033[32m"
RED="\033[31m"
CYAN="\033[36m"
YELLOW="\033[33m"

# Global array to accumulate summary issues
declare -a SUMMARY_ISSUES=()

# Clear previous report file
: > "$REPORT_FILE"

# Function to append text to the report file
log_report() {
    echo -e "$1" >> "$REPORT_FILE"
}

# Function to display section headers on terminal (and log to file)
section_header() {
    echo -e "\n${BLUE}${BOLD}=== $1 ===${RESET}"
    log_report "\n=== $1 ==="
}

# Function to check command result and record issues if any
check_result() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓${RESET} $1"
        log_report "✓ $1"
    else
        echo -e "${RED}✗${RESET} $2"
        log_report "✗ $2"
        SUMMARY_ISSUES+=("$2")
    fi
}

# Function: System Information and Hardware Overview
system_info() {
    section_header "System Information"
    echo -e "${CYAN}Kernel & OS Info:${RESET}"
    uname -a | tee -a "$REPORT_FILE"
    echo -e "\n${CYAN}OS Details:${RESET}"
    (lsb_release -a 2>/dev/null || cat /etc/os-release) | tee -a "$REPORT_FILE"
    echo -e "\n${CYAN}CPU Info (lscpu):${RESET}"
    lscpu | tee -a "$REPORT_FILE"
    echo -e "\n${CYAN}Motherboard Info (dmidecode -t baseboard):${RESET}"
    sudo dmidecode -t baseboard 2>/dev/null | tee -a "$REPORT_FILE"
    echo -e "\n${CYAN}Complete Hardware Overview (lshw -short):${RESET}"
    if command -v lshw >/dev/null 2>&1; then
        sudo lshw -short 2>/dev/null | tee -a "$REPORT_FILE"
    else
        echo -e "${YELLOW}lshw not installed. Install it for detailed hardware info.${RESET}"
        log_report "lshw not installed"
        SUMMARY_ISSUES+=("lshw not installed")
    fi
}

# Function: CPU Health Check including temperature
cpu_health() {
    section_header "CPU Health Check"
    echo -e "${CYAN}CPU Info (lscpu):${RESET}"
    lscpu | tee -a "$REPORT_FILE"
    if command -v sensors >/dev/null 2>&1; then
        echo -e "\n${CYAN}Temperature & Fan Data (sensors):${RESET}"
        sensors | tee -a "$REPORT_FILE"
        high_temp=$(sensors | grep -E "Core [0-9]+:" | awk '{print $3}' | sed 's/+//;s/°C//' | awk '$1 > 80 {print $1}')
        if [ -n "$high_temp" ]; then
            echo -e "${RED}Warning: High CPU temperature detected: ${high_temp}°C${RESET}"
            log_report "High CPU temperature: ${high_temp}°C"
            SUMMARY_ISSUES+=("High CPU temperature: ${high_temp}°C")
        else
            echo -e "${GREEN}CPU temperature is within normal range.${RESET}"
            log_report "CPU temperature is normal"
        fi
    else
        echo -e "${YELLOW}sensors command not found. Install lm-sensors for CPU monitoring.${RESET}"
        log_report "sensors not installed"
        SUMMARY_ISSUES+=("sensors command missing")
    fi
}

# Function: Memory Health Check
memory_health() {
    section_header "Memory Health Check"
    echo -e "${CYAN}Memory Usage (free -h):${RESET}"
    free -h | tee -a "$REPORT_FILE"
    echo -e "\n${CYAN}Memory Details (dmidecode -t memory):${RESET}"
    sudo dmidecode -t memory 2>/dev/null | tee -a "$REPORT_FILE"
    mem_errors=$(dmesg | grep -i -E "memory error|ECC")
    if [ -n "$mem_errors" ]; then
        echo -e "${RED}Memory errors found in dmesg:${RESET}"
        echo "$mem_errors" | tee -a "$REPORT_FILE"
        SUMMARY_ISSUES+=("Memory errors detected")
    else
        echo -e "${GREEN}No memory errors detected in dmesg.${RESET}"
        log_report "No memory errors detected"
    fi
}

# Function: Disk Health Check using smartctl
disk_health() {
    section_header "Disk Health Check"
    if command -v smartctl >/dev/null 2>&1; then
        disks=$(lsblk -d -n -o NAME | grep -E '^sd|^nvme')
        if [ -z "$disks" ]; then
            echo -e "${YELLOW}No disks detected by lsblk.${RESET}"
            log_report "No disks detected"
            SUMMARY_ISSUES+=("No disks detected")
        else
            for disk in $disks; do
                echo -e "${CYAN}SMART Status for /dev/$disk:${RESET}"
                smartctl -H /dev/$disk 2>/dev/null | tee -a "$REPORT_FILE"
                status=$(smartctl -H /dev/$disk 2>/dev/null | grep "SMART overall-health self-assessment test result" | awk -F: '{print $2}')
                if [[ "$status" != *"PASSED"* ]]; then
                    echo -e "${RED}Disk /dev/$disk health check failed: $status${RESET}"
                    log_report "Disk /dev/$disk health failure: $status"
                    echo -e "${CYAN}Full SMART data for /dev/$disk:${RESET}" | tee -a "$REPORT_FILE"
                    smartctl -a /dev/$disk 2>/dev/null >> "$REPORT_FILE"
                    SUMMARY_ISSUES+=("Disk /dev/$disk failure: $status")
                else
                    echo -e "${GREEN}Disk /dev/$disk passed SMART health check.${RESET}"
                    log_report "Disk /dev/$disk passed SMART check"
                fi
            done
        fi
    else
        echo -e "${YELLOW}smartctl not found. Install smartmontools for disk health checks.${RESET}"
        log_report "smartctl not installed"
        SUMMARY_ISSUES+=("smartctl missing")
    fi
}

# Function: Fan Health Check via sensors
fan_health() {
    section_header "Fan Health Check"
    if command -v sensors >/dev/null 2>&1; then
        echo -e "${CYAN}Fan Speeds (sensors):${RESET}"
        sensors | grep -i fan | tee -a "$REPORT_FILE"
        zero_fans=$(sensors | grep -i fan | grep "0 RPM")
        if [ -n "$zero_fans" ]; then
            echo -e "${RED}Warning: Some fans are reported as 0 RPM:${RESET}"
            echo "$zero_fans" | tee -a "$REPORT_FILE"
            SUMMARY_ISSUES+=("One or more fans are not running (0 RPM)")
        else
            echo -e "${GREEN}All fans appear to be running normally.${RESET}"
            log_report "Fan speeds normal"
        fi
    else
        echo -e "${YELLOW}sensors command not found. Install lm-sensors for fan monitoring.${RESET}"
        log_report "sensors missing for fan check"
        SUMMARY_ISSUES+=("sensors missing for fan health")
    fi
}

# Function: GPU Health Check (if Nvidia tools available)
gpu_health() {
    section_header "GPU Health Check"
    if command -v nvidia-smi >/dev/null 2>&1; then
        echo -e "${CYAN}NVIDIA GPU Status (nvidia-smi):${RESET}"
        nvidia-smi | tee -a "$REPORT_FILE"
    else
        echo -e "${YELLOW}nvidia-smi not found. Checking for VGA devices via lspci:${RESET}"
        lspci | grep -i vga | tee -a "$REPORT_FILE"
    fi
}

# Function: USB Devices Check
usb_health() {
    section_header "USB Devices Check"
    if command -v lsusb >/dev/null 2>&1; then
        echo -e "${CYAN}Connected USB Devices (lsusb):${RESET}"
        lsusb | tee -a "$REPORT_FILE"
    else
        echo -e "${YELLOW}lsusb not found. Install usbutils to list USB devices.${RESET}"
        log_report "lsusb missing"
        SUMMARY_ISSUES+=("usbutils not installed")
    fi
}

# Function: Network Health Check
network_health() {
    section_header "Network Health Check"
    echo -e "${CYAN}Network Interfaces (ip -br link show):${RESET}"
    ip -br link show | tee -a "$REPORT_FILE"
    echo -e "\n${CYAN}DNS Resolution Test (ping -c 1 google.com):${RESET}"
    if ping -c 1 google.com >/dev/null 2>&1; then
        echo -e "${GREEN}Network connectivity and DNS resolution are OK.${RESET}"
        log_report "Network connectivity OK"
    else
        echo -e "${RED}Network connectivity or DNS resolution issues detected.${RESET}"
        log_report "Network connectivity/DNS issue"
        SUMMARY_ISSUES+=("Network connectivity/DNS issue")
    fi
}

# Function: Service and Process Check
service_check() {
    section_header "Service and Process Check"
    echo -e "${CYAN}Failed Services (systemctl --failed):${RESET}"
    failed=$(systemctl --failed --no-legend)
    if [ -n "$failed" ]; then
        echo "$failed" | tee -a "$REPORT_FILE"
        SUMMARY_ISSUES+=("Some services have failed")
    else
        echo -e "${GREEN}No failed services detected.${RESET}"
        log_report "No failed services"
    fi
    echo -e "\n${CYAN}Top CPU-consuming processes:${RESET}"
    ps -eo pid,comm,%cpu --sort=-%cpu | head -n 6 | tee -a "$REPORT_FILE"
}

# Function: Log Check for errors
log_check() {
    section_header "System Log Check"
    echo -e "${CYAN}Recent error logs (journalctl -p err -n 20):${RESET}"
    journalctl -p err -n 20 | tee -a "$REPORT_FILE"
}

# Function: Orphan Packages Check and Removal (Pacman-based)
orphan_check() {
    section_header "Orphan Packages Check"
    if command -v pacman >/dev/null 2>&1; then
        orphans=$(pacman -Qdtq)
        if [ -n "$orphans" ]; then
            echo -e "${RED}Orphan packages detected:${RESET}"
            echo "$orphans" | tee -a "$REPORT_FILE"
            echo -e "${CYAN}Attempting removal of orphan packages...${RESET}"
            sudo pacman -Rns $orphans
            check_result "Orphan package removal attempted" "Failed to remove some orphan packages"
        else
            echo -e "${GREEN}No orphan packages found.${RESET}"
            log_report "No orphan packages found"
        fi
    else
        echo -e "${YELLOW}Pacman not found. Skipping orphan package check.${RESET}"
        log_report "Pacman not found for orphan check"
    fi
}

# Function: Repair Broken Packages
repair_packages() {
    section_header "Broken Packages Repair"
    if command -v pacman >/dev/null 2>&1; then
        broken_pkgs=$(pacman -Qk 2>&1 | grep -v ' 0 missing files' | awk '{print $1}' | sort -u)
        if [ -n "$broken_pkgs" ]; then
            echo -e "${RED}Broken packages detected:${RESET}"
            echo "$broken_pkgs" | tee -a "$REPORT_FILE"
            echo -e "${CYAN}Attempting to reinstall broken packages...${RESET}"
            sudo pacman -S --needed $broken_pkgs
            check_result "Reinstallation attempted" "Failed to reinstall some packages"
        else
            echo -e "${GREEN}No broken packages found.${RESET}"
            log_report "No broken packages found"
        fi
    else
        echo -e "${YELLOW}Pacman not found. Skipping broken package check.${RESET}"
        log_report "Pacman not found for package repair"
    fi
}

# Function: Check Missing Dependencies
repair_dependencies() {
    section_header "Missing Dependencies Check"
    if command -v pacman >/dev/null 2>&1; then
        missing_deps=$(pacman -Qqn | pacman -Tq 2>&1)
        if [ -n "$missing_deps" ]; then
            echo -e "${RED}Missing dependencies detected:${RESET}"
            echo "$missing_deps" | tee -a "$REPORT_FILE"
            echo -e "${CYAN}Attempting to install missing dependencies...${RESET}"
            sudo pacman -S $missing_deps
            check_result "Dependency installation attempted" "Some dependencies could not be installed"
        else
            echo -e "${GREEN}All dependencies are satisfied.${RESET}"
            log_report "Dependencies satisfied"
        fi
    else
        echo -e "${YELLOW}Pacman not found. Skipping dependency check.${RESET}"
        log_report "Pacman not found for dependency check"
    fi
}

# Function: Prompt user to view the saved report file
prompt_view_report() {
    echo -e "\n${CYAN}${BOLD}Detailed debug report has been saved to:${RESET} ${REPORT_FILE}"
    read -p "Would you like to view the report now? (y/n): " answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        # Use the default pager (less) to show the report
        less "$REPORT_FILE"
    fi
}

# Function: Print a comprehensive summary and save error report
print_summary() {
    section_header "Diagnostic Summary"
    if [ ${#SUMMARY_ISSUES[@]} -eq 0 ]; then
        echo -e "${GREEN}${BOLD}System appears healthy. No critical issues detected.${RESET}"
        log_report "System appears healthy. No critical issues."
    else
        echo -e "${RED}${BOLD}Summary of Issues Detected:${RESET}"
        log_report "Summary of Issues Detected:"
        for issue in "${SUMMARY_ISSUES[@]}"; do
            echo -e "- $issue"
            log_report "- $issue"
        done
    fi
}

# Main deep debug function
deep_debug() {
    echo -e "${BOLD}Starting Comprehensive System Debug...${RESET}" | tee -a "$REPORT_FILE"
    system_info
    cpu_health
    memory_health
    disk_health
    fan_health
    gpu_health
    usb_health
    network_health
    service_check
    log_check
    orphan_check
    repair_dependencies
    repair_packages
    print_summary
    prompt_view_report
    echo -e "\n${GREEN}${BOLD}Deep Debug Complete!${RESET}" | tee -a "$REPORT_FILE"
    read -n1 -r -p "Press any key to return to the main menu..." key
    # If sourced, use 'return' instead of exit
    return 0 2>/dev/null || exit 0
}

# Run deep debug
deep_debug

