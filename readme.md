# NixOS Configuration

Personal NixOS configuration for gaming/streaming desktop setup.

## Hardware
- Ryzen 7 5800X
- AMD 7900 XTX
- Samsung Odyssey G9 ultrawide

## Features
- KDE Plasma 6
- Steam + gaming optimizations (gamemode, mangohud)
- OBS Studio with Elgato Stream Deck integration
- Self-hosting tools
- Privacy-focused apps (Signal, Brave, Proton Pass)

## Fresh Installation (from live USB)

Boot the NixOS installer and run:

**Using curl:**
\`\`\`bash
nix-shell -p curl --run "bash <(curl -L https://raw.githubusercontent.com/Anthadeas/nixos-config/master/install.sh)"
\`\`\`

**Using wget:**
\`\`\`bash
nix-shell -p wget --run "bash <(wget -qO- https://raw.githubusercontent.com/Anthadeas/nixos-config/master/install.sh)"
\`\`\`

The script will:
1. Prompt for disk selection
2. Partition and format the disk
3. Install NixOS with full configuration
4. Takes 15-30 minutes depending on network speed

## Existing Installation

On an already-installed NixOS system, run:

\`\`\`bash
bash <(curl -L https://raw.githubusercontent.com/Anthadeas/nixos-config/master/setup.sh)
\`\`\`

This applies your configuration to an existing system.

## After Installation

1. Reboot and remove USB drive
2. Login with configured username
3. Set your password: `sudo passwd yourusername`
4. Enjoy!

## Files

- `configuration.nix` - Main system configuration
- `hardware-configuration.nix` - Hardware-specific settings (auto-generated per machine)
- `install.sh` - Automated installation script
- `setup.sh` - Configuration deployment script for existing installs

## Notes

- Hardware configuration is machine-specific and auto-generated during install
- SSH keys stored separately (not in this repo)
- Repo uses `master` branch
