# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Personal dotfiles for macOS, NixOS, and non-NixOS Linux, built around a nix flake. **Naming convention**: "nixos" means NixOS machines (full system config via `nixosConfigurations`); plain "linux" means non-NixOS Linux machines, managed with standalone home-manager only (`homeConfigurations`) — don't conflate the two. `modules/linux/` is the umbrella for all Linux machines, with the NixOS system modules nested at `modules/linux/nixos/`. The macOS side is functional. The NixOS side is under active development.

The three flake outputs are named after hosts: `Luna` (macOS), `Terra` (NixOS), and `Sola` (the standalone home-manager config, intended mostly for servers). The day-to-day command everywhere is `rebuild` (symlinked to `~/.local/bin/rebuild` by the postHook). Under the hood it runs:

- macOS (`lib/darwin/rebuild.sh`): `sudo --preserve-env=DOTFILES_DIR darwin-rebuild switch --flake .#Luna --impure`.
- Linux (`lib/linux/rebuild.sh`), dispatching on `/etc/os-release`: on NixOS, `sudo --preserve-env=DOTFILES_DIR nixos-rebuild switch --flake .#Terra --impure`; on any other Linux, `home-manager switch --flake .#Sola --impure` (bootstrapped via `nix run home-manager/master` if home-manager isn't on PATH yet).

All rebuilds need `DOTFILES_DIR` exported to the checkout (see the impure-rebuild contract below). On Linux, `lib/linux/setup.sh` (invoked by `install.sh`) covers both cases: on NixOS it hands off to the flake rebuild above (whose activation hook does the symlinking); on non-NixOS Linux it installs nix if missing (same installer fork as darwin, x86_64 or aarch64), runs the postHook symlinker, then activates Sola via `lib/linux/rebuild.sh`. Don't confuse it with `modules/linux/setup.sh`, which is a dummy stub that just exits 1.

## Commands

- `./install.sh` — full bootstrap: dispatches to `lib/<os>/setup.sh`. On macOS that installs nix (Nix Community fork of the determinate installer) and Homebrew if missing, then builds and activates the flake.
- `rebuild` (symlinked to `~/.local/bin/rebuild` → `lib/<os>/rebuild.sh` by the postHook) — rebuild and activate after editing any nix module. This is the day-to-day command on every OS. The darwin script hardcodes `HOST="Luna"`; the linux one dispatches NixOS → `Terra`, other Linux → `Sola`.
- `nix flake check` — validate the flake without activating.
- `shellcheck lib/**/*.sh install.sh` — lint the shell scripts (shellcheck is installed system-wide).
- `nixfmt <file>` — format nix files; `stylua` config exists for `config/nvim` lua.

There is no test suite; verification is running `rebuild` and checking it activates cleanly.

## Architecture

The flake (`flake.nix`) defines three outputs: `darwinConfigurations.Luna` (aarch64-darwin), composed of the `modules/darwin/*.nix` modules; `nixosConfigurations.Terra` (x86_64-linux), whose entry point `modules/linux/nixos/configuration.nix` imports the other nixos modules itself (`users.nix`, `boot.nix`, `system.nix`, `packages.nix`, plus `hardware-configuration.nix`); and `homeConfigurations.Sola` (x86_64-linux), the standalone home-manager config for non-NixOS Linux machines. All three use the shared `modules/home-manager/home.nix`, which takes `username` (and optionally `homeDirectory`, read via `@args` since named-arg defaults don't fire in the module system) as module inputs passed through `extraSpecialArgs`: `irakin` on macOS, `istabr` on NixOS, and `builtins.getEnv "USER"` for Sola — so on servers, Sola configures whatever user runs the switch.

**The impure-rebuild contract** is the main non-obvious mechanism: dotfiles are *not* managed by home-manager's file mechanisms. Instead, `home.nix` runs `lib/common/postHook.sh` as a home-manager activation hook, which symlinks the *live checkout* (not a nix store copy) into place:

- `config/` is tiered by OS: `config/common/*` → `~/.config/*` everywhere (e.g. `config/common/nvim` → `~/.config/nvim`), then `config/darwin/*` or `config/linux/*` on top for the current OS (e.g. `config/linux/hypr` → `~/.config/hypr`). `.gitkeep` placeholders are never linked.
- `home/*` → `~/.<name>` (leading dot added, e.g. `home/zshrc` → `~/.zshrc`)

To locate the checkout, `home.nix` reads `builtins.getEnv "DOTFILES_DIR"`, which is why every rebuild exports `DOTFILES_DIR`, passes `--impure`, and uses `sudo --preserve-env=DOTFILES_DIR`. Breaking any of those three pieces breaks the rebuild (there's an assertion in `home.nix` guarding it). Because everything is symlinked, edits to files in `config/` and `home/` take effect immediately — no rebuild needed unless you touched a `.nix` module.

`postHook.sh` refuses to clobber real files at a destination — it only replaces symlinks — so a "skipping, not a symlink" message means a pre-existing file must be moved aside by hand. OS-specific links live in `lib/<os>/postHook.sh`, *sourced* by the common script so they can reuse its `link()`; the darwin one links iCloud Drive → `~/iCloud` and its `rebuild.sh` → `~/.local/bin/rebuild`; the linux one links its own `rebuild.sh` the same way.

**macOS package split**: CLI tools go in `modules/darwin/packages.nix` via `environment.systemPackages` (nixpkgs preferred); GUI apps go in the `homebrew.casks` list in the same file, managed declaratively by nix-darwin. macOS system preferences (Finder, keyboard, TouchID-for-sudo, fonts) live in `modules/darwin/system.nix`; dock contents in `modules/darwin/dock.nix`.

**NixOS (Terra)**: boots via limine with secure boot (sbctl, auto-generated/enrolled keys) and a Windows dual-boot entry (`boot.nix`); desktop is Hyprland (with UWSM and xwayland) behind greetd + noctalia-greeter, with pipewire audio and NetworkManager (`system.nix` enables greetd and installs the noctalia shell package; `packages.nix` configures `programs.noctalia-greeter` via the `noctalia-greeter` flake input's nixosModule). The desktop shell is [noctalia](https://github.com/noctalia-dev/noctalia): the shell and greeter *packages* come from nixpkgs (`pkgs.noctalia` — the native 5.x shell, not `pkgs.noctalia-shell` — and `pkgs.noctalia-greeter`) so they're cached downloads, while the `noctalia-greeter` flake input exists only for its NixOS module (nixpkgs has none), whose `mkDefault` package is overridden. The shell is autostarted from the Hyprland config, which drives it at runtime via `noctalia msg` IPC keybinds (launcher, control center, volume/brightness). Screenshots are [HyprQuickFrame](https://github.com/Ronin-CK/HyprQuickFrame) (flake input `hyprquickframe`, self-contained wrapper), on SUPER+SHIFT+S/W/C. The Hyprland config is the Lua variant, split across `config/linux/hypr/`: `hyprland.lua` requires `monitors`, `vars`, `config`, `autostart`, `keybindings`, and `windowrules`, all symlinked into place like everything else.

**Shell scripts** follow a shared pattern: source `lib/common/helpers.sh` (colors, `error`, `has`, `root_guard`, `macos_guard`, `linux_guard`), take the repo root as `$1` with a fallback derived from the script's own path, and must never run as root. `rebuild.sh` resolves symlinks to find itself, since it's invoked via `~/.local/bin/rebuild`.

**Neovim config** (`config/nvim`) is an NvChad v2.5 starter — NvChad itself is loaded as a lazy.nvim plugin; custom bits live in `lua/plugins/` and `lua/configs/`.
