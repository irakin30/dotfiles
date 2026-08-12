{inputs, config, pkgs, ...}: 

{
  networking = {
    hostName = "Terra"; # Define your hostname. 
    networkmanager.enable = true;
  };

  time.timeZone = "America/New_York";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
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
  };

  # greetd itself is enabled by the noctalia-greeter module (packages.nix)
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  # File-chooser portal backend: xdg-desktop-portal-hyprland doesn't implement
  # FileChooser, and its portals.conf already falls back to gtk for it.
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  
  environment.systemPackages = [
    # The native shell (5.x), NOT pkgs.noctalia-shell (the old Quickshell one).
    # From nixpkgs rather than the noctalia flake so it's a cached download.
    pkgs.noctalia
    # Screenshot tool; its wrapper bundles quickshell, grim, imagemagick,
    # wl-clipboard, satty, and libnotify on PATH.
    inputs.hyprquickframe.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  # Same fonts as the darwin side (modules/darwin/system.nix)
  fonts.packages = with pkgs; [
    nerd-fonts.symbols-only
    nerd-fonts.jetbrains-mono
  ];

  # Removable-drive mounting for dolphin
  services.udisks2.enable = true;

  # Backs the bluetooth panel in noctalia's control center
  hardware.bluetooth.enable = true;
  
  services.xserver = {
    enable = true;
    xkb = {
      layout = "us";
      variant = "";
    };
  # Enable touchpad support (enabled default in most desktopManager).
  # libinput.enable = true;
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
    jack.enable = true;
  };

  #Enable Polkit
  security.polkit.enable = true;
  
  services.upower.enable = true; 
  services.power-profiles-daemon.enable = true;
}

