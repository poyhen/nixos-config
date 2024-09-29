{ pkgs, ... }:

let
  monitorsXmlContent = builtins.readFile ./monitors.xml;
  monitorsConfig = pkgs.writeText "gdm_monitors.xml" monitorsXmlContent;
in
{
  imports = [
    ./hardware-configuration.nix
  ];

  #monitors stuff
  systemd.tmpfiles.rules = [ "L+ /run/gdm/.config/monitors.xml - - - - ${monitorsConfig}" ];

  #nix
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nixpkgs.config.allowUnfree = true;
  system.switch = {
    enable = false;
    enableNg = true;
  };
  systemd.services.nix-daemon = {
    environment.TMPDIR = "/var/tmp";
  };

  #boot and kernel
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 2;
  boot.initrd.systemd.enable = true;
  boot.tmp.useTmpfs = true;
  boot.tmp.tmpfsSize = "100%";
  boot.kernelPackages = pkgs.linuxPackages_cachyos;
  chaotic.scx.enable = true;

  #system
  networking.networkmanager.enable = true;
  networking.hostName = "arce";
  networking.firewall.checkReversePath = false;
  networking.nftables.enable = true;
  networking.networkmanager.wifi.backend = "iwd";

  zramSwap.enable = true;
  services.fstrim.enable = true;
  services.dbus.implementation = "broker";
  services.printing.enable = true;

  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  #services.desktopManager.cosmic.enable = true;
  #services.displayManager.cosmic-greeter.enable = true;
  services.xserver = {
    xkb.layout = "us";
    xkb.variant = "";
  };

  nixpkgs.config.packageOverrides = pkgs: {
    intel-vaapi-driver = pkgs.intel-vaapi-driver.override { enableHybridCodec = true; };
  };
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver
      libvdpau-va-gl
    ];
  };
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  };

  time.timeZone = "Europe/Istanbul";
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

  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  security.pam.loginLimits = [
    {
      domain = "*";
      item = "memlock";
      type = "-";
      value = "-1";
    }
  ];

  #my system/user and packages
  environment.systemPackages = with pkgs; [
    dive
    podman-tui
    podman-compose
  ];

  virtualisation.containers.enable = true;
  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  programs.fish.enable = true;
  programs.fish.shellAliases = {
    ls = "lsd -al";
    cat = "bat";
  };
  programs.direnv.enable = true;
  programs.direnv.enableFishIntegration = true;
  programs.starship.enable = true;

  services.gnome.gnome-remote-desktop.enable = true;
  programs.firefox.enable = true;

  users.mutableUsers = false;
  users.users.frkn = {
    isNormalUser = true;
    description = "frkn";
    hashedPassword = "$6$NSFZDfM1gztLih3o$1OvuK/1.KxFo3veRLOEIqU4EBXlDOm0K8X.F75yxHPxG81DpIViVGpkTyV2vZwp6g0UIsS34jncpi/0vrpcac/";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = with pkgs; [
      fd
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
      zed-editor.fhs
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
      gnome-weather
      loupe
      feather
      cloudflared
      gnome-remote-desktop
      remmina
      distrobox
      lsd
      nerdfonts
      bat
      signal-desktop
      warp-terminal
      kitty
      zenity
      nnn
      zoxide
      nixd
      nixfmt-rfc-style
      qbittorrent
      code-cursor
      rust-analyzer
    ];
  };

  #flatpak
  services.flatpak.enable = true;
  xdg.portal.enable = true;
  xdg.portal.xdgOpenUsePortal = true;
  services.flatpak.update.onActivation = true;
  services.flatpak.remotes = [
    {
      name = "flathub";
      location = "https://flathub.org/repo/flathub.flatpakrepo";
    }
    {
      name = "flathub-beta";
      location = "https://flathub.org/beta-repo/flathub-beta.flatpakrepo";
    }
  ];
  services.flatpak.packages = [
    {
      appId = "com.brave.Browser";
      origin = "flathub-beta";
    }
    "de.haeckerfelix.Fragments"
    "org.telegram.desktop"
  ];

  #yes
  system.stateVersion = "24.05";

}
