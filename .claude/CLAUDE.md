# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Personal dotfiles for macOS, NixOS, and non-NixOS Linux, built around a nix flake. **Naming convention**: "nixos" means NixOS machines (full system config via `nixosConfigurations`); plain "linux" means non-NixOS Linux machines, managed with standalone home-manager only (`homeConfigurations`) — don't conflate the two. `modules/linux/` is the umbrella for all Linux machines, with the NixOS system modules nested at `modules/linux/nixos/`. The macOS side is functional. The NixOS side (`nixosConfigurations.Sola`, host `Sola`, x86_64-linux) is under active development. On Linux the postHook symlinker does the core work (dotfile symlinks); `lib/linux/setup.sh` runs it plus misc setup tasks (it refuses to run on NixOS — those hosts use the flake), and there is deliberately no Linux rebuild script. Rebuild commands: on NixOS, `sudo --preserve-env=DOTFILES_DIR nixos-rebuild switch --flake .#Sola --impure`; on non-NixOS Linux, `home-manager switch --flake . --impure` — both with `DOTFILES_DIR` exported to the checkout.

## Commands

- `./install.sh` — full bootstrap: installs nix (Nix Community fork of the determinate installer) and Homebrew if missing, then builds and activates the flake.
- `rebuild` (symlinked to `~/.local/bin/rebuild` → `lib/darwin/rebuild.sh`) — rebuild and activate after editing any nix module. This is the day-to-day command.
- `nix flake check` — validate the flake without activating.
- `shellcheck lib/**/*.sh install.sh` — lint the shell scripts (shellcheck is installed system-wide).
- `nixfmt <file>` — format nix files; `stylua` config exists for `config/nvim` lua.

There is no test suite; verification is running `rebuild` and checking it activates cleanly.

## Architecture

The flake (`flake.nix`) defines three outputs: `darwinConfigurations.MacBook` (aarch64-darwin, hardcoded as `HOST` in `lib/darwin/rebuild.sh`), composed of the `modules/darwin/*.nix` modules; `nixosConfigurations.Sola` (x86_64-linux), whose entry point `modules/linux/nixos/configuration.nix` imports the other nixos modules itself; and `homeConfigurations.irakin` (x86_64-linux), the standalone home-manager config for non-NixOS Linux machines. All three use the shared `modules/home-manager/home.nix` for user `irakin` — the same username everywhere, deliberately.

**The impure-rebuild contract** is the main non-obvious mechanism: dotfiles are *not* managed by home-manager's file mechanisms. Instead, `home.nix` runs `lib/common/postHook.sh` as a home-manager activation hook, which symlinks the *live checkout* (not a nix store copy) into place:

- `config/*` → `~/.config/*` (e.g. `config/nvim` → `~/.config/nvim`)
- `home/*` → `~/.<name>` (leading dot added, e.g. `home/zshrc` → `~/.zshrc`)

To locate the checkout, `home.nix` reads `builtins.getEnv "DOTFILES_DIR"`, which is why `rebuild.sh` exports `DOTFILES_DIR`, passes `--impure`, and uses `sudo --preserve-env=DOTFILES_DIR`. Breaking any of those three pieces breaks the rebuild (there's an assertion in `home.nix` guarding it). Because everything is symlinked, edits to files in `config/` and `home/` take effect immediately — no rebuild needed unless you touched a `.nix` module.

`postHook.sh` refuses to clobber real files at a destination — it only replaces symlinks — so a "skipping, not a symlink" message means a pre-existing file must be moved aside by hand.

**Package split**: CLI tools go in `modules/darwin/packages.nix` via `environment.systemPackages` (nixpkgs preferred); GUI apps go in the `homebrew.casks` list in the same file, managed declaratively by nix-darwin. macOS system preferences (Finder, keyboard, TouchID-for-sudo, fonts) live in `modules/darwin/system.nix`; dock contents in `modules/darwin/dock.nix`.

**Shell scripts** follow a shared pattern: source `lib/common/helpers.sh` (colors, `error`, `has`, `root_guard`, `macos_guard`), take the repo root as `$1` with a fallback derived from the script's own path, and must never run as root. `rebuild.sh` resolves symlinks to find itself, since it's invoked via `~/.local/bin/rebuild`.

**Neovim config** (`config/nvim`) is an NvChad v2.5 starter — NvChad itself is loaded as a lazy.nvim plugin; custom bits live in `lua/plugins/` and `lua/configs/`.
