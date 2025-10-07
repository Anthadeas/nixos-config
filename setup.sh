#!/usr/bin/env bash

set -e  # Exit on any error

echo "=== NixOS Config Recovery Script ==="
echo ""

# Step 0: Ensure curl is available (for future runs)
if ! command -v curl &> /dev/null; then
    echo "[0/5] Installing curl..."
    nix-env -iA nixos.curl
fi

# Step 1: Install git
echo "[1/5] Installing git..."
nix-env -iA nixos.git
git --version || { echo "Git installation failed"; exit 1; }

# Step 2: Clone repo
echo "[2/5] Cloning nixos-config from GitHub..."
cd ~
if [ -d "nixos-config" ]; then
    echo "Warning: ~/nixos-config already exists. Removing..."
    rm -rf nixos-config
fi

git clone https://github.com/Anthadeas/nixos-config.git

# Step 3: Backup current config
echo "[3/5] Backing up current configuration..."
sudo cp /etc/nixos/configuration.nix /etc/nixos/configuration.nix.backup
echo "Backup saved to /etc/nixos/configuration.nix.backup"

# Step 4: Copy your config over BUT keep hardware-configuration.nix
echo "[4/5] Applying your configuration..."
sudo cp ~/nixos-config/configuration.nix /etc/nixos/configuration.nix

# IMPORTANT: Check if hardware-configuration.nix exists in /etc/nixos
if [ ! -f /etc/nixos/hardware-configuration.nix ]; then
    echo "ERROR: /etc/nixos/hardware-configuration.nix is missing!"
    echo "This file should have been created during NixOS installation."
    echo "Cannot proceed without it."
    exit 1
fi

echo "Using existing hardware-configuration.nix (has correct UUIDs for this PC)"

# Step 5: Rebuild
echo "[5/5] Rebuilding system (this will take 10-20 minutes)..."
echo "Downloading Steam, Discord, and all your packages..."
sudo nixos-rebuild switch

echo ""
echo "=== Setup Complete ==="
echo ""
echo "Your system is now configured with:"
echo "  - Steam + gaming tools"
echo "  - Discord, Signal, Brave"
echo "  - OBS Studio + Stream Deck scripts"
echo "  - All your other packages"
echo ""
echo "Reboot now? (y/n)"
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
    sudo reboot
else
    echo "Reboot skipped. Run 'sudo reboot' when ready."
fi
