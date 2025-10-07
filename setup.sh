#!/usr/bin/env bash

set -e  # Exit on any error

echo "=== NixOS Config Recovery Script ==="
echo ""

# Step 0: Ensure curl is available
if ! command -v curl &> /dev/null; then
    echo "[0/6] Installing curl..."
    nix-env -iA nixos.curl
fi

# Step 1: Install git
echo "[1/6] Installing git..."
nix-env -iA nixos.git
git --version || { echo "Git installation failed"; exit 1; }

# Step 2: Clone repo
echo "[2/6] Cloning nixos-config from GitHub..."
cd ~
if [ -d "nixos-config" ]; then
    echo "Warning: ~/nixos-config already exists. Removing..."
    rm -rf nixos-config
fi

git clone https://github.com/Anthadeas/nixos-config.git

# Step 3: Ensure hardware-configuration.nix exists
echo "[3/6] Checking hardware configuration..."
if [ ! -f /etc/nixos/hardware-configuration.nix ]; then
    echo "hardware-configuration.nix missing! Generating..."
    sudo nixos-generate-config
    echo "Generated hardware-configuration.nix for this PC"
else
    echo "hardware-configuration.nix found"
fi

# Step 4: Backup current config
echo "[4/6] Backing up current configuration..."
if [ -f /etc/nixos/configuration.nix ]; then
    sudo cp /etc/nixos/configuration.nix /etc/nixos/configuration.nix.backup
    echo "Backup saved to /etc/nixos/configuration.nix.backup"
fi

# Step 5: Copy your config over
echo "[5/6] Applying your configuration..."
sudo cp ~/nixos-config/configuration.nix /etc/nixos/configuration.nix
echo "Kept/generated hardware-configuration.nix (has correct UUIDs for this PC)"

# Step 6: Rebuild
echo "[6/6] Rebuilding system (this will take 10-20 minutes)..."
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
