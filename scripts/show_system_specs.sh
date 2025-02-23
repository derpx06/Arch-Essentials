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

# Main System Specs Display
echo -e "${GREEN}${BOLD}=== SYSTEM SPECIFICATIONS ===${RESET}\n"

# Hostname
section_header "Hostname"
hostname && echo ""

# OS & Kernel
section_header "Operating System & Kernel"
cat /etc/os-release | grep "PRETTY_NAME" | cut -d= -f2 | tr -d '"' && uname -r && echo ""

# CPU Details
section_header "CPU Information"
lscpu | grep -E "Model name|Socket|Core|Thread|Flags" | sed 's/^[ \t]*//' && echo ""

# Memory Details
section_header "Memory Information"
free -h | awk '/Mem:/ {print "Total: " $2 ", Used: " $3 ", Free: " $4}' && echo ""

# Disk Details
section_header "Disk Usage"
df -h --output=source,size,used,avail,pcent | column -t && echo ""
section_header "Disk Partitions"
lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT && echo ""

# Network Interfaces
section_header "Network Interfaces"
ip -br addr show | awk '{print $1 ": " $3}' && echo ""
section_header "Network Interface Speeds"
ethtool $(ip -br link | awk '$1 != "lo" {print $1; exit}') 2>/dev/null | grep "Speed" || echo "No speed information available." && echo ""

# GPU Details
section_header "Graphics Card"
lspci | grep -i vga && lspci | grep -i "3d controller" && echo ""
section_header "GPU Driver Details"
lspci -k | grep -A 3 "VGA" | grep "Kernel driver" || echo "No GPU driver information available." && echo ""

# Final Message
echo -e "${YELLOW}${BOLD}=== SYSTEM SPECIFICATIONS COMPLETE ===${RESET}"
