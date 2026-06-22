#!/usr/bin/env bash

## Guard Clauses
if [ "$(id -u)" -eq 0 ]; then
    echo "Error: don't run as root." >&2
    exit 1
fi


if [ "$(uname -s)" != "Darwin" ]; then
    echo "Error: this script only supports macOS" >&2
    exit 1
fi

## Helper function to check if a command exists
has() { command -v "$1" >/dev/null 2>&1; }

### Check for nix & install
### Uses a fork of the determinate nix installer, which is easier to uninstall
if ! has nix; then
    arch=$(uname -m | sed 's/arm64/aarch64/')
    curl -sL -o nix-installer \
      "https://artifacts.nixos.org/nix-installer/nix-installer-${arch}-darwin"
    chmod +x nix-installer
    ./nix-installer
    rm ./nix-installer
fi

### Check for homebrew & install
### Homebrew will be the go-to for GUI apps on macOS, and will be managed with nix-darwin
if ! has brew; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
