#!/usr/bin/env bash

set -e  # Exit on any error

echo "=== Automated NixOS Installation & Configuration ==="
echo ""
echo "⚠️  WARNING: This will ERASE ALL DATA on the target disk!"
echo ""

# Detect available disks
echo "Available disks:"
lsblk -d -n -p -o NAME,SIZE,TYPE | grep disk
echo ""

# Prompt for disk
read -p "Enter the disk to install to (e.g., /dev/sda or /dev/nvme0n1): " DISK

if [ ! -b "$DISK" ]; then
    echo "Error: $DISK is not a valid block device"
    exit 1
fi

echo ""
echo "⚠️  FINAL WARNING: About to erase $DISK"
echo "Press Ctrl+C to cancel, or Enter to continue..."
read

# Detect if NVMe (partition naming is different)
if [[ "$DISK" == *"nvme"* ]]; then
    DISK_BOOT="${DISK}p1"
    DISK_ROOT="${DISK}p2"
else
    DISK_BOOT="${DISK}1"
    DISK_ROOT="${DISK}2"
fi

echo ""
echo "[1/8] Partitioning disk..."
sudo parted "$DISK" -- mklabel gpt
sudo parted "$DISK" -- mkpart ESP fat32 1MiB 512MiB
sudo parted "$DISK" -- set 1 esp on
sudo parted "$DISK" -- mkpart primary 512MiB 100%

echo "[2/8] Formatting partitions..."
sudo mkfs.fat -F 32 -n boot "$DISK_BOOT"
sudo mkfs.ext4 -F -L nixos "$DISK_ROOT"

echo "[3/8] Mounting filesystems..."
sudo mount /dev/disk/by-label/nixos /mnt
sudo mkdir -p /mnt/boot
sudo mount /dev/disk/by-label/boot /mnt/boot

echo "[4/8] Generating hardware configuration..."
sudo nixos-generate-config --root /mnt

echo "[5/8] Installing git..."
nix-env -iA nixos.git

echo "[6/8] Cloning your configuration..."
cd /tmp
if [ -d "nixos-config" ]; then
    rm -rf nixos-config
fi
git clone https://github.com/Anthadeas/nixos-config.git

echo "[7/8] Applying your configuration..."
# Backup generated config
sudo cp /mnt/etc/nixos/configuration.nix /mnt/etc/nixos/configuration.nix.original

# Copy your config
sudo cp /tmp/nixos-config/configuration.nix /mnt/etc/nixos/configuration.nix

# Keep the generated hardware-configuration.nix (has correct UUIDs)
echo "Using generated hardware-configuration.nix for this machine"

echo "[8/8] Installing NixOS (this will take 15-30 minutes)..."
echo "The system will download and install all packages from your config..."
echo ""
echo "⚠️  You will be prompted to set a ROOT password during installation."
echo "   Remember this password - you'll need it to login and set your user password."
echo ""
sudo nixos-install

echo ""
echo "=== Installation Complete! ==="
echo ""
echo "IMPORTANT - After reboot:"
echo "1. Login as 'root' with the password you just set"
echo "2. Set your user password: passwd nixos"
echo "3. Logout and login as 'nixos'"
echo ""
echo "Reboot now? (y/n)"

read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
    sudo reboot
else
    echo "When ready: sudo reboot"
fi
