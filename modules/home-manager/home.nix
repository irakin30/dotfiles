## username (and optionally homeDirectory) are module inputs, passed per-host
## via extraSpecialArgs in flake.nix. homeDirectory is read through @args because
## a `? default` on a named module arg never fires -- the module system supplies
## every named arg itself.
{ pkgs, lib, username, ... }@args:
let
  dotfilesDir = builtins.getEnv "DOTFILES_DIR";
  homeDirectory =
    args.homeDirectory or (if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}");
in
{
  home.username = username;
  home.homeDirectory = homeDirectory;

  home.packages = with pkgs; [
    bat 
    fzf 
    lsd 
    zoxide
    fastfetch
    fd
    neovim
    ripgrep 
  ] 
  ++ lib.optionals pkgs.stdenv.isDarwin [
    # macOS-only packages 
  ];

  home.file = { };

  assertions = [
    {
      assertion = username != "";
      message = "username module input must be non-empty -- for Sola it comes from $USER, which needs --impure to be read.";
    }
    {
      assertion = dotfilesDir != "";
      message = "DOTFILES_DIR environment variable must be set, and darwin-rebuild or nixos-rebuild must be run with --impure, so home.nix can locate lib/common/postHook.sh.";
    }
  ];

  home.activation.postHook = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD bash "${dotfilesDir}/lib/common/postHook.sh"
  '';

  programs.home-manager.enable = true;
  home.stateVersion = "26.11";
}
