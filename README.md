# dotfiles 

> [!NOTE]
> The macOS side of this repository is stable. 
> The Linux side (NixOS and standalone home-manager for servers) is under active development.

This repository contains my main dotfiles for the machines I use. Feel free to look at them freely and/or copy them to your liking. 

## Install Guide

### MacOS

You need Command Line tools to install everything (including git) on macOS so you can install it with the following:

```bash
xcode-select --install

```



> [!WARNING]
> Don't run the following as root.
> I haven't tested it, nor do I really recommend it. 

```bash
git clone --depth 1 https://github.com/irakin30/dotfiles
cd dotfiles
./install.sh
``` 

This installs nix and homebrew if they're not already present, then builds and activates the flake, symlinking `config/` and `home/` into place. 
`config/` is tiered: `config/common/` links everywhere, then `config/darwin/` or `config/linux/` on top for the current OS.
My preferred nix installer is the [Nix Community fork of the determinate installer.](https://github.com/NixOS/nix-installer)

### Linux

> [!NOTE]
> Flakes need to be enabled for this to work. The nix installer used on non-NixOS distros enables them by default, 
> but on NixOS you'll need them in your existing configuration before the first run: 
> `nix.settings.experimental-features = [ "nix-command" "flakes" ];` 
> (or as a one-off: `--extra-experimental-features "nix-command flakes"` on the rebuild command).

Same clone-and-install as macOS (you'll need `git` and `curl` present):

```bash
git clone --depth 1 https://github.com/irakin30/dotfiles
cd dotfiles
./install.sh
``` 

On NixOS this hands off to `nixos-rebuild switch` for the full system flake. 
On any other distro it installs nix if it's missing, symlinks the dotfiles into place, then activates the standalone home-manager config for whatever user ran it.

## Rebuilding 

I have a dedicated rebuild script linked to `~/.local/bin/rebuild` on every OS, so you can just run that after editing any nix module. All of the configs are symlinked, so you can just edit them directly. 

## Uninstalling

> [!NOTE] 
> An automated uninstaller will be in the works soon.

There's no automated uninstall yet. The Community fork of the Determinate Nix installer used by `install.sh` ships its own uninstaller (`/nix/nix-installer uninstall`) on both macOS and Linux, 
and on macOS Homebrew's install script supports `NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"`. 
Symlinks created by `lib/common/postHook.sh` can be removed by hand. 
