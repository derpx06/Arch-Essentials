#!/bin/bash

# Define Colors
RESET="\033[0m"
BOLD="\033[1m"
GREEN="\033[32m"
CYAN="\033[36m"
YELLOW="\033[33m"

# Function to display section headers
section_header() {
    echo -e "${CYAN}${BOLD}$1${RESET}"
}

# Main System Overview
echo -e "${GREEN}${BOLD}=== SYSTEM OVERVIEW ===${RESET}\n"

# Hostname
section_header "Hostname"
hostname && echo ""

# OS & Kernel
section_header "OS & Kernel"
uname -o && uname -r && echo ""

# CPU
section_header "CPU"
lscpu | grep "Model name" | cut -d: -f2 | xargs && echo ""

# Memory
section_header "Memory"
free -h | awk '/Mem:/ {print "Total: " $2 ", Used: " $3 ", Free: " $4}' && echo ""

# Disk
section_header "Disk"
df -h --output=source,size,used,avail,pcent | column -t | head -n 5 && echo ""

# Network
section_header "Network"
ip -br addr show | awk '{print $1 ": " $3}' && echo ""

# Packages
section_header "Packages"
pacman -Qe | wc -l | xargs -I {} echo "Installed: {}" && echo ""

# Uptime
section_header "Uptime"
uptime -p && echo ""

# Updates
section_header "Updates"
updates=$(checkupdates 2>/dev/null | wc -l)
[[ $updates -eq 0 ]] && echo "No updates." || echo "$updates updates available." && echo ""

# Logs
section_header "Logs"
journalctl -p 3 -b --no-pager | tail -n 3 || echo "Failed to retrieve logs." && echo ""

# Final Message
echo -e "${YELLOW}${BOLD}=== COMPLETE ===${RESET}"
