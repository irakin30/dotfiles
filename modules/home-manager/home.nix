{ pkgs, lib, ... }:
let
  dotfilesDir = builtins.getEnv "DOTFILES_DIR";
in
{
  home.username = "irakin";
  home.homeDirectory = if pkgs.stdenv.isDarwin then "/Users/irakin" else "/home/irakin";

  home.packages = [
    pkgs.bat
    pkgs.fzf
    pkgs.lsd
    pkgs.zoxide
  ] ++ lib.optionals pkgs.stdenv.isDarwin [
    # macOS-only packages
  ];

  home.file = { };

  assertions = [
    {
      assertion = dotfilesDir != "";
      message = "DOTFILES_DIR environment variable must be set, and darwin-rebuild must be run with --impure, so home.nix can locate lib/common/postHook.sh.";
    }
  ];

  home.activation.postHook = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD bash "${dotfilesDir}/lib/common/postHook.sh"
  '';

  programs.home-manager.enable = true;
  home.stateVersion = "26.11";
}
