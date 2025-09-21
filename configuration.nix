# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
boot.loader.systemd-boot.enable = true;
boot.loader.efi.canTouchEfiVariables = true;



  #Enable experimental features (I put this in)
  nix.settings.experimental-features = [ "nix-command" "flakes" ];


  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.nixos = {
    isNormalUser = true;
    description = "Nixos";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      kdePackages.kate
    #  thunderbird
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;



  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
  signal-desktop
  gamemode
  mangohud
  discord
  openrgb
  nextcloud-client
  proton-pass
  git
  joplin-desktop
  brave
  btop
  pkgs.streamdeck-ui
  obs-studio
  alacritty
  nodejs_22
  fish
  fastfetch
  tmux
  libreoffice
  calibre
  freetube
  rpi-imager
  ethtool
  obsidian
  plexamp

   (python3.withPackages (ps: with ps; [
    ps.elgato
    # If not available, I will help you install via pip
  ]))

  (pkgs.writeScriptBin "toggle-elgato-light" ''
  #!${python3.withPackages (ps: with ps; [ ps.elgato ])}/bin/python3
  import asyncio
  from elgato import Elgato
  async def main():
    e = Elgato("172.20.2.66")
    info = await e.state()
    await e.light(on=not info.on)
  asyncio.run(main())
'')
 # scripts to change brightness on Stream Deck
(pkgs.writeScriptBin "elgato-light-brightness-up" ''
  #!${python3.withPackages (ps: with ps; [ ps.elgato ])}/bin/python3
  import asyncio
  from elgato import Elgato

  async def main():
      async with Elgato("172.20.2.66") as e:
          state = await e.state()
          new_brightness = min(100, state.brightness + 10)
          await e.light(brightness=new_brightness)
  asyncio.run(main())
'')

(pkgs.writeScriptBin "elgato-light-brightness-down" ''
  #!${python3.withPackages (ps: with ps; [ ps.elgato ])}/bin/python3
  import asyncio
  from elgato import Elgato

  async def main():
      async with Elgato("172.20.2.66") as e:
          state = await e.state()
          new_brightness = max(0, state.brightness - 10)
          await e.light(brightness=new_brightness)
  asyncio.run(main())
'')
  ];


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

   # Load I2C kernel modules for OpenRGB (I did this - ChatGPT helped)
  boot.kernelModules = [ "i2c-dev" "i2c-piix4" ];

  # This is to allow my Streamdeck to work. Got it from ChatGPT
  services.udev.extraRules = ''
  SUBSYSTEM=="usb", ATTRS{idVendor}=="0fd9", MODE="0666"
'';

 # This is to search for local hostnames on my network. Needed it for Elgato Stream Deck. Gave by ChatGPT.
services.avahi = {
  enable = true;
  nssmdns = true;
  publish.enable = true;
};

fonts.packages = with pkgs; [
  # ... your existing fonts
  jetbrains-mono
];

  # Steam and graphics support - This is better than installing steam as a package above
programs.steam = {
  enable = true;
  remotePlay.openFirewall = true;
  dedicatedServer.openFirewall = true;
  localNetworkGameTransfers.openFirewall = true;
  protontricks.enable = true;
  extraCompatPackages = with pkgs; [ proton-ge-bin ];
};

# Add OpenRGB udev rules (I did this - ChatGPT helped)
  services.udev.packages = [ pkgs.openrgb ];

hardware.graphics = {
  enable = true;
  enable32Bit = true;
};

# Enable Wake-on-LAN for your Ethernet interface
networking.interfaces.enp7s0.wakeOnLan.enable = true;

hardware.steam-hardware.enable = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Personal Notes:
  # Created Github SSH which was saved to '/home/nixos/.ssh'. I added it to Nextcloud>Documents


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}
