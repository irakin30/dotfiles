# dotfiles 

> [!NOTE]
> This repository mainly contains my macOS dotfiles. 
> My dotfiles for linux will be added once I've configured them.

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

This installs nix and homebrew if they're not already present, then builds and activates the flake, symlinking everything in `config/` and `home/` into place.
My preferred nix installer is the [Nix Community fork of the determinate installer.](https://github.com/NixOS/nix-installer)

## Rebuilding 

I have a dedicated rebuild script linked to `~/.local/bin/rebuild`, so you can just run that. All of the configs are symlinked, so you can just edit them directly.

## Uninstalling

> [!NOTE] 
> An automated uninstaller will be in the works soon.

### MacOS

There's no automated uninstall yet. The Community fork of the Determinate Nix installer used by `install.sh` ships its own uninstaller (`/nix/nix-installer uninstall`), 
and Homebrew's install script supports `NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"`. 
Symlinks created by `lib/common/postHook.sh` can be removed by hand. 

