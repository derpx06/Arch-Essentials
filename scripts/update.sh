#!/bin/bash
# update.sh - A simple update script for Arch Linux

echo "Starting system update..."
sudo pacman-key --init
sudo pacman-key --populate
# Update package database and upgrade all packages
sudo pacman -Syu --noconfirm

if [ $? -eq 0 ]; then
    echo "System update completed successfully!"
else
    echo "System update encountered an error."
fi

echo "Update process finished."

