{
  config,
  options,
  lib,
  pkgs,
  ...
}:

let
  refind-minimal = pkgs.fetchFromGitHub {
    owner = "evanpurkhiser";
    repo = "rEFInd-minimal";
    rev = "56a06a4bd9ed76c05523a22017056dbecca4145d";
    hash = "sha256-ALDa8bhgiHyIRmyGh8/1P56TvEG/gqC0qOqAWbtURyg=";
  };

  ## additionalFiles only copies single files (destinations are relative to
  ## <esp>/efi/refind/), so map every file of the theme repo into
  ## themes/rEFInd-minimal/. theme.conf hardcodes that directory name.
  themeFiles = lib.listToAttrs (
    map (file: {
      name = "themes/rEFInd-minimal/"
        + builtins.unsafeDiscardStringContext (lib.removePrefix "${refind-minimal}/" (toString file));
      value = file;
    }) (lib.filesystem.listFilesRecursive refind-minimal)
  );

  efi = config.boot.loader.efi;

  ## The nixpkgs refind module has no signing support, so wrap the installer
  ## it defines. Pull its script out of the module system's definition list
  ## instead of copy-pasting the module's internals.
  refindInstaller =
    (lib.findFirst (def: lib.hasInfix "boot/loader/refind" def.file)
      (throw "refind's installBootLoader definition not found; did the nixpkgs module move?")
      options.system.build.definitionsWithLocations
    ).value.installBootLoader;
in
{
  boot = {
    # Use latest kernel.
    kernelPackages = pkgs.linuxPackages_latest;

    # Bootloader: rEFInd, themed with rEFInd-minimal.
    loader.refind = {
      enable = true;
      extraConfig = "include themes/rEFInd-minimal/theme.conf";
      additionalFiles = themeFiles;
    };
    loader.efi.canTouchEfiVariables = true;
    ## Unlike the systemd-boot module, the refind module doesn't disable
    ## grub (which defaults to enabled) on its own.
    loader.grub.enable = false;
  };

  ## Secure boot with our own platform keys, managed by sbctl. One-time
  ## setup on the machine (as root):
  ##   1. sbctl create-keys
  ##   2. reboot into firmware setup, put secure boot into Setup Mode
  ##   3. sbctl enroll-keys --microsoft   # keep MS keys so option ROMs still load
  ##   4. rebuild, then re-enable secure boot in the firmware
  ## Until keys exist the signing hook is a no-op and boots work as before.

  ## sbctl on PATH for the one-time key setup and `sbctl status`.
  environment.systemPackages = [ pkgs.sbctl ];

  system.build.installBootLoader = lib.mkForce (
    pkgs.replaceVarsWith {
      src = ./install-refind-signed.sh;
      isExecutable = true;
      replacements = {
        inherit refindInstaller;
        bash = pkgs.bash;
        sbctl = pkgs.sbctl;
        esp = efi.efiSysMountPoint;
      };
    }
  );
}
