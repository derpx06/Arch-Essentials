#!/bin/bash

# Define Colors
RESET="\033[0m"
GREEN="\033[32m"
RED="\033[31m"

# Display starting message
echo -e "${GREEN}Clearing pacman cache...${RESET}"

# Run the pacman cache cleaning command
sudo pacman -Sc

# Check if the command succeeded
if [[ $? -eq 0 ]]; then
    echo -e "${GREEN}Pacman cache cleared successfully!${RESET}"
else
    echo -e "${RED}Failed to clear pacman cache. Please try again.${RESET}"
fi

# Wait for user input before exiting
read -n1 -r -p "Press any key to continue..." key

