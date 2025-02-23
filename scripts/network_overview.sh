#!/bin/bash
# network_diagnostics.sh - Advanced Network Diagnostics Script for Arch Linux
# This script checks network connectivity, IP configuration, latency, open ports, speed test,
# DNS resolution, and HTTP connectivity. It captures each test’s output into global variables,
# then prints a comprehensive summary at the bottom.
# If a required command is not installed, the user is prompted to install it via pacman.

# Define Colors
RESET="\033[0m"
BOLD="\033[1m"
BLUE="\033[34m"
GREEN="\033[32m"
RED="\033[31m"
CYAN="\033[36m"
YELLOW="\033[33m"

# Global variables to store test results
internet_status=""
ip_address=""
connection_type=""
firewall_status=""
avg_latency=""
packet_loss=""
default_gateway=""
dns_servers=""
open_ports=""
speed_test_output=""
dns_result=""
http_status=""

# Function to check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Function to prompt user to install a missing package
prompt_install() {
    local pkg_name=$1
    local cmd_name=$2
    if ! command_exists "$cmd_name"; then
        echo -e "${RED}$cmd_name is not installed.${RESET}"
        read -p "Do you want to install $pkg_name? (y/n): " choice
        if [[ "$choice" =~ ^[Yy]$ ]]; then
            echo -e "${CYAN}Installing $pkg_name...${RESET}"
            sudo pacman -S --noconfirm "$pkg_name"
        else
            echo -e "${YELLOW}Skipping installation of $pkg_name. Some tests may not work.${RESET}"
        fi
    fi
}

# Ensure required packages are installed
prompt_install "network-manager" "nmcli"
prompt_install "ufw" "ufw"
prompt_install "nmap" "nmap"
prompt_install "speedtest-cli" "speedtest-cli"
prompt_install "bind-tools" "dig"
prompt_install "traceroute" "traceroute"
prompt_install "curl" "curl"
prompt_install "net-tools" "netstat"

# Clear screen and display header
clear
echo -e "${BLUE}${BOLD}Advanced Network Diagnostics${RESET}\n"

# Test basic internet connectivity
test_internet_connection() {
    echo -e "${CYAN}Testing Internet Connection (ping 8.8.8.8)...${RESET}"
    if ping -c 4 8.8.8.8 > /dev/null 2>&1; then
        echo -e "${GREEN}Internet connection is working.${RESET}"
        internet_status="Working"
    else
        echo -e "${RED}No internet connection detected.${RESET}"
        internet_status="Not Working"
    fi
}

# Show primary IP address
show_ip_address() {
    echo -e "${CYAN}Checking IP Address...${RESET}"
    ip_address=$(hostname -I | awk '{print $1}')
    if [[ -z "$ip_address" ]]; then
        echo -e "${RED}Could not determine IP address.${RESET}"
    else
        echo -e "${GREEN}Your IP Address: ${BOLD}$ip_address${RESET}"
    fi
}

# Determine network type (Wi-Fi/Ethernet)
check_network_type() {
    echo -e "${CYAN}Determining Network Type...${RESET}"
    if command_exists nmcli; then
        connection_type=$(nmcli -t -f DEVICE,TYPE connection show --active | awk -F: '{print $2}')
        if [[ "$connection_type" == "wifi" ]]; then
            echo -e "${GREEN}Connected via Wi-Fi.${RESET}"
            connection_type="Wi-Fi"
        elif [[ "$connection_type" == "ethernet" ]]; then
            echo -e "${GREEN}Connected via Ethernet.${RESET}"
            connection_type="Ethernet"
        else
            echo -e "${RED}Could not determine connection type.${RESET}"
            connection_type="Unknown"
        fi
    else
        echo -e "${RED}nmcli is not installed. Cannot determine connection type.${RESET}"
        connection_type="nmcli not installed"
    fi
}

# Check firewall status
check_firewall_status() {
    echo -e "${CYAN}Checking Firewall Status...${RESET}"
    if command_exists ufw; then
        FIREWALL_STATUS=$(ufw status | grep -i "active")
        if [[ -n "$FIREWALL_STATUS" ]]; then
            echo -e "${GREEN}Firewall is enabled.${RESET}"
            firewall_status="Enabled"
        else
            echo -e "${RED}Firewall is disabled.${RESET}"
            firewall_status="Disabled"
        fi
    else
        echo -e "${RED}ufw is not installed. Cannot check firewall status.${RESET}"
        firewall_status="ufw not installed"
    fi
}

# Check network latency and packet loss
check_latency_packet_loss() {
    echo -e "${CYAN}Checking Network Latency and Packet Loss (ping 8.8.8.8)...${RESET}"
    PING_OUTPUT=$(ping -c 4 8.8.8.8)
    avg_latency=$(echo "$PING_OUTPUT" | tail -1 | awk '{print $4}' | cut -d '/' -f 2)
    packet_loss=$(echo "$PING_OUTPUT" | grep -oP '\d+(?=% packet loss)')
    if [[ -n "$avg_latency" ]]; then
        echo -e "${GREEN}Average Latency: ${BOLD}${avg_latency} ms${RESET}"
    else
        echo -e "${RED}Failed to determine latency.${RESET}"
        avg_latency="Unknown"
    fi
    if [[ -n "$packet_loss" ]]; then
        echo -e "${GREEN}Packet Loss: ${BOLD}${packet_loss}%${RESET}"
    else
        echo -e "${RED}Failed to determine packet loss.${RESET}"
        packet_loss="Unknown"
    fi
}

# Check default gateway and DNS servers
check_gateway_dns() {
    echo -e "${CYAN}Checking Default Gateway and DNS...${RESET}"
    default_gateway=$(ip route | grep default | awk '{print $3}')
    if command_exists nmcli; then
        dns_servers=$(nmcli dev show | grep 'IP4.DNS' | awk '{print $2}' | paste -sd ", " -)
    else
        dns_servers=$(grep 'nameserver' /etc/resolv.conf | awk '{print $2}' | paste -sd ", " -)
    fi
    echo -e "${GREEN}Default Gateway: ${BOLD}$default_gateway${RESET}"
    echo -e "${GREEN}DNS Servers: ${BOLD}$dns_servers${RESET}"
}

# Scan for open ports using nmap
scan_open_ports() {
    echo -e "${CYAN}Scanning for Open Ports (nmap localhost)...${RESET}"
    OPEN_PORTS=$(nmap localhost | grep "open")
    if [[ -n "$OPEN_PORTS" ]]; then
        echo -e "${GREEN}Open Ports:${RESET}"
        echo "$OPEN_PORTS"
    else
        echo -e "${GREEN}No open ports detected on localhost.${RESET}"
        OPEN_PORTS="None"
    fi
}

# Perform a speed test using speedtest-cli
speed_test() {
    echo -e "${CYAN}Performing Speed Test...${RESET}"
    if command_exists speedtest-cli; then
        speed_test_output=$(speedtest-cli --simple)
        echo "$speed_test_output"
    else
        echo -e "${RED}speedtest-cli is not installed. Install it with: sudo pacman -S speedtest-cli${RESET}"
        speed_test_output="Not Available"
    fi
}

# Perform DNS lookup using dig
dns_lookup() {
    echo -e "${CYAN}Performing DNS Lookup for google.com...${RESET}"
    dns_result=$(dig +short google.com)
    if [[ -n "$dns_result" ]]; then
        echo -e "${GREEN}DNS Resolution for google.com: ${BOLD}$dns_result${RESET}"
    else
        echo -e "${RED}DNS lookup failed for google.com.${RESET}"
        dns_result="Failed"
    fi
}

# Trace route to google.com
trace_route() {
    echo -e "${CYAN}Tracing Route to google.com...${RESET}"
    traceroute google.com
}

# Check HTTP connectivity using curl
check_http_connectivity() {
    echo -e "${CYAN}Checking HTTP Connectivity (curl https://www.google.com)...${RESET}"
    http_status=$(curl -s -o /dev/null -w "%{http_code}" https://www.google.com)
    if [[ "$http_status" -eq 200 ]]; then
        echo -e "${GREEN}HTTP connectivity is working (Status: 200).${RESET}"
    else
        echo -e "${RED}HTTP connectivity issue detected (Status: $http_status).${RESET}"
    fi
}

# Gather detailed network statistics
gather_network_stats() {
    echo -e "${CYAN}Gathering Detailed Network Statistics...${RESET}"
    echo -e "\n${CYAN}Network Interfaces and Stats (ip -s link):${RESET}"
    ip -s link | tee /tmp/network_stats.txt
    echo -e "\n${CYAN}Routing Table (ip route):${RESET}"
    ip route | tee -a /tmp/network_stats.txt
    echo -e "\n${CYAN}TCP Connections (netstat -tunlp):${RESET}"
    if command_exists netstat; then
        netstat -tunlp | tee -a /tmp/network_stats.txt
    else
        echo -e "${YELLOW}netstat not installed, skipping TCP connection check.${RESET}"
    fi
    echo -e "\nDetailed network stats saved to /tmp/network_stats.txt"
}

# Function to print a comprehensive summary of all test results
print_network_summary() {
    echo -e "\n${BLUE}${BOLD}--- Network Diagnostics Summary ---${RESET}"
    echo -e "${GREEN}Internet Connection: ${BOLD}$internet_status${RESET}"
    echo -e "${GREEN}IP Address: ${BOLD}$ip_address${RESET}"
    echo -e "${GREEN}Connection Type: ${BOLD}$connection_type${RESET}"
    echo -e "${GREEN}Firewall Status: ${BOLD}$firewall_status${RESET}"
    echo -e "${GREEN}Average Latency: ${BOLD}${avg_latency} ms${RESET}"
    echo -e "${GREEN}Packet Loss: ${BOLD}${packet_loss}%${RESET}"
    echo -e "${GREEN}Default Gateway: ${BOLD}$default_gateway${RESET}"
    echo -e "${GREEN}DNS Servers: ${BOLD}$dns_servers${RESET}"
    echo -e "${GREEN}Open Ports: ${BOLD}$OPEN_PORTS${RESET}"
    echo -e "${GREEN}Speed Test Results: ${BOLD}\n$speed_test_output${RESET}"
    echo -e "${GREEN}DNS Lookup (google.com): ${BOLD}$dns_result${RESET}"
    echo -e "${GREEN}HTTP Connectivity Status: ${BOLD}$http_status${RESET}"
    echo -e "\n${BLUE}${BOLD}--- End of Summary ---${RESET}"
}

# Run all network functions
test_internet_connection
echo ""
show_ip_address
echo ""
check_network_type
echo ""
check_firewall_status
echo ""
check_latency_packet_loss
echo ""
check_gateway_dns
echo ""
scan_open_ports
echo ""
speed_test
echo ""
dns_lookup
echo ""
trace_route
echo ""
check_http_connectivity
echo ""
gather_network_stats

# Print the final summary at the bottom
print_network_summary

# End of network diagnostics script

