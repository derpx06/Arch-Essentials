#!/bin/bash
# check_logs.sh - Collect and log recent system error logs in a human-friendly format.
# This script gathers system error logs from journalctl and kernel messages from dmesg,
# then saves the results in a report file in your home directory.

# Set the report file path
REPORT_FILE="$HOME/check_logs_report.txt"

# Function to log messages to both the terminal and the report file
log_message() {
    echo -e "$1" | tee -a "$REPORT_FILE"
}

# Clear any existing report file
: > "$REPORT_FILE"

# Welcome message
log_message "📝 Collecting recent error logs..."
log_message "⏰ Timestamp: $(date)"

# Section: Journalctl Error Logs
log_message "\n🔍 === Recent journalctl error logs (last 50 lines) ==="
journalctl -p err -n 50 | tee -a "$REPORT_FILE"

# Section: Kernel Messages from dmesg
log_message "\n🔍 === Recent kernel messages (last 50 lines) ==="
dmesg | tail -n 50 | tee -a "$REPORT_FILE"

# Final message
log_message "\n✅ Detailed error logs have been saved to: ${REPORT_FILE}"
read -n1 -r -p "Press any key to exit..."
