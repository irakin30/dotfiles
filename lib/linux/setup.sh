#!/usr/bin/env bash
set -euo pipefail

_ROOT_DIR="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"

source "${_ROOT_DIR}/lib/common/helpers.sh"

## Guard Clauses
root_guard
linux_guard

export DOTFILES_DIR=${_ROOT_DIR}
## "linux" means non-NixOS machines; NixOS hosts hand off to the flake rebuild
## instead (via rebuild.sh), which already runs the postHook symlinker as an
## activation hook.
if [ -f /etc/os-release ] && grep -q '^ID=nixos' /etc/os-release; then
    ## modules/nixos/hardware-configuration.nix is a tracked symlink to
    ## /etc/nixos/hardware-configuration.nix, which is machine-generated and
    ## not in the repo -- on a fresh install the link is broken and the flake
    ## can't evaluate. -e follows the symlink, so it catches exactly that.
    if [ ! -e "${_ROOT_DIR}/modules/nixos/hardware-configuration.nix" ]; then
        echo "${YELLOW}hardware-configuration.nix link is broken, generating it...${RESET}"
        sudo nixos-generate-config
    fi
    . "${_ROOT_DIR}/lib/linux/rebuild.sh" "$_ROOT_DIR"
    exit 0
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
      "https://artifacts.nixos.org/nix-installer/nix-installer-${arch}-linux" \
      || error "Failed to download nix-installer"
    chmod +x nix-installer
    ./nix-installer install
    rm ./nix-installer

    ## The installer only wires nix into future shells (via /etc/profile etc);
    ## source its daemon profile now so this same script can go on to use nix
    ## without the user having to restart their shell.
    source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

    echo "${GREEN}Nix installed!${RESET}"
fi

## Symlink the dotfiles into place. home-manager re-runs this on every switch,
## but running it here means the links exist even if the switch below fails.
echo "${YELLOW}Linking dotfiles...${RESET}"
bash "${_ROOT_DIR}/lib/common/postHook.sh"

## Build and activate the Sola home-manager config.
. "${_ROOT_DIR}/lib/linux/rebuild.sh" "$_ROOT_DIR"
