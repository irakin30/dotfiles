#!/usr/bin/env bash
set -euo pipefail

_ROOT_DIR="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"

source "${_ROOT_DIR}/lib/common/helpers.sh"

## Guard Clauses
root_guard
linux_guard

## "linux" means non-NixOS machines; NixOS hosts rebuild with the flake instead.
if [ -f /etc/os-release ] && grep -q '^ID=nixos' /etc/os-release; then
    error "This is a NixOS machine, use nixos-rebuild with the flake instead."
fi

## Misc setup tasks go here as they come up (nothing needs installing yet).

## Symlink the dotfiles into place. home-manager re-runs this on every switch,
## but running it here means a plain checkout works without nix.
echo "${YELLOW}Linking dotfiles...${RESET}"
bash "${_ROOT_DIR}/lib/common/postHook.sh"
