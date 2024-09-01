# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  monitorsXmlContent = builtins.readFile ./monitors.xml;
  monitorsConfig = pkgs.writeText "gdm_monitors.xml" monitorsXmlContent;
in {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  systemd.tmpfiles.rules =
    [ "L+ /run/gdm/.config/monitors.xml - - - - ${monitorsConfig}" ];

  boot.kernelPackages = pkgs.linuxPackages_cachyos;
  chaotic.scx.enable = true;

  networking.firewall.checkReversePath = false;

  zramSwap.enable = true;

  nixpkgs.config.packageOverrides = pkgs: {
    intel-vaapi-driver =
      pkgs.intel-vaapi-driver.override { enableHybridCodec = true; };
  };
  hardware.graphics = {
    # hardware.graphics on unstable
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      libvdpau-va-gl
    ];
  };
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  }; # Force intel-media-driver

  #Enable Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 2;

  networking.hostName = "arce"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Istanbul";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "tr_TR.UTF-8";
    LC_IDENTIFICATION = "tr_TR.UTF-8";
    LC_MEASUREMENT = "tr_TR.UTF-8";
    LC_MONETARY = "tr_TR.UTF-8";
    LC_NAME = "tr_TR.UTF-8";
    LC_NUMERIC = "tr_TR.UTF-8";
    LC_PAPER = "tr_TR.UTF-8";
    LC_TELEPHONE = "tr_TR.UTF-8";
    LC_TIME = "tr_TR.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver = {
    xkb.layout = "us";
    xkb.variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
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

  services.gnome.gnome-remote-desktop.enable = true;
  programs.direnv.enable = true;
  programs.direnv.enableFishIntegration = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;
  users.mutableUsers = false;
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.frkn = {
    isNormalUser = true;
    description = "frkn";
    hashedPassword =
      "$6$NSFZDfM1gztLih3o$1OvuK/1.KxFo3veRLOEIqU4EBXlDOm0K8X.F75yxHPxG81DpIViVGpkTyV2vZwp6g0UIsS34jncpi/0vrpcac/";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      brave
      git
      bitwarden-desktop
      authenticator
      micro
      mpv
      yt-dlp
      mission-center
      ptyxis
      localsend
      vulkan-tools
      btop
      zed-editor
      mesa-demos
      just
      (vscode-with-extensions.override {
        vscodeExtensions = with vscode-extensions; [
          rust-lang.rust-analyzer
          usernamehw.errorlens
          ms-python.python
          ms-python.vscode-pylance
          charliermarsh.ruff
          denoland.vscode-deno
          bradlc.vscode-tailwindcss
          supermaven.supermaven
        ];
      })
      ffmpeg
      vesktop
      spotify
      python312
      gnome.gnome-weather
      loupe
      feather
      cloudflared
      gnome.gnome-remote-desktop
      remmina
      distrobox
      ticktick
      lsd
      nerdfonts
      bat
      signal-desktop
      warp-terminal
      kitty
      gnome.zenity
      nnn
      zoxide
    ];
  };

  programs.starship.enable = true;

  security.pam.loginLimits = [{
    domain = "*";
    item = "memlock";
    type = "-";
    value = "-1";
  }];

  programs.fish.enable = true;
  programs.fish.shellAliases = {
    ls = "lsd -al";
    cat = "bat";
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  virtualisation.containers.enable = true;
  virtualisation = {
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #  wget
    dive
    podman-tui
    podman-compose
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

  # experimental stuff
  networking.nftables.enable = true;

  system.switch = {
    enable = false;
    enableNg = true;
  };

  boot.initrd.systemd.enable = true;

  networking.networkmanager.wifi.backend = "iwd";

  boot.tmp.useTmpfs = true;
  systemd.services.nix-daemon = { environment.TMPDIR = "/var/tmp"; };

  services.fstrim.enable = true;

  services.dbus.implementation = "broker";

  xdg.portal.enable = true;
  xdg.portal.xdgOpenUsePortal = true;
  services.flatpak.enable = true;

}
