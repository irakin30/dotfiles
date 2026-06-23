#!/usr/bin/env bash

_RET=$(pwd)
_DIR="$(cd "$(dirname ${BASH_SOURCE[0]})" && pwd)"   # dir of this script

source "${_DIR}/../helpers.sh"

## Guard Clauses
root_guard

if [ "$(uname -s)" != "Darwin" ]; then
    echo "${RED}Error: this script only supports macOS${RESET}" >&2
    exit 1
fi


### Check for nix & install
### Uses a fork of the determinate nix installer, which is easier to uninstall
echo "${YELLOW}Checking for nix...${RESET}"
if has nix; then
    echo "${GREEN}Nix found!${RESET}"
fi

if ! has nix; then
    echo "${RED}Nix not found...${RESET}"
    echo "${YELLOW}Installing nix...${RESET}"
    arch=$(uname -m | sed 's/arm64/aarch64/')
    curl -sL -o nix-installer \
      "https://artifacts.nixos.org/nix-installer/nix-installer-${arch}-darwin"
    chmod +x nix-installer
    ./nix-installer
    rm ./nix-installer
fi

### Check for homebrew & install
### Homebrew will be the go-to for GUI apps on macOS, and will be managed with nix-darwin
echo "${YELLOW}Checking for homebrew...${RESET}"
if has brew; then
    echo "${GREEN}Homebrew found!${RESET}"
fi
if ! has brew; then
    echo "${RED}Homebrew not found${RESET}"
    echo "${YELLOW}Installing homebrew...${RESET}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
