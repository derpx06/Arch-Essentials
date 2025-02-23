#!/bin/bash
# check_logs.sh - Collect and log recent system error logs

# Set the report file in the home directory
REPORT_FILE="$HOME/check_logs_report.txt"

# Clear any existing report file
: > "$REPORT_FILE"

echo "Collecting recent error logs..." | tee "$REPORT_FILE"
echo "Timestamp: $(date)" | tee -a "$REPORT_FILE"

# Collect recent system error logs using journalctl
echo -e "\n=== Recent journalctl error logs (last 50 lines) ===" | tee -a "$REPORT_FILE"
journalctl -p err -n 50 | tee -a "$REPORT_FILE"

# Collect recent kernel messages from dmesg
echo -e "\n=== Recent kernel messages (last 50 lines) ===" | tee -a "$REPORT_FILE"
dmesg | tail -n 50 | tee -a "$REPORT_FILE"

echo -e "\nDetailed error logs have been saved to: ${REPORT_FILE}"
read -n1 -r -p "Press any key to return..."

