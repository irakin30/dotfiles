#!/usr/bin/env bash
set -euo pipefail

if [ -n "${1:-}" ]; then
    _ROOT_DIR="$1"
else
    ## Resolve the real location of this script, following symlinks, so it can be
    ## symlinked onto $PATH (e.g. `ln -s .../lib/linux/rebuild.sh ~/.local/bin/rebuild`)
    ## and still find the repo root relative to itself. Only needed when the
    ## caller doesn't pass the repo root as $1.
    _SCRIPT_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
    _ROOT_DIR="$(cd "$_SCRIPT_DIR/../.." && pwd)"
fi

source "${_ROOT_DIR}/lib/common/helpers.sh"

## Guard Clauses
root_guard
linux_guard

## home.nix reads $DOTFILES_DIR (builtins.getEnv) to find lib/common/postHook.sh,
## since it must symlink the live checkout, not a store copy. --impure is required
## for that, and sudo's env_reset strips DOTFILES_DIR unless told to keep it.
export DOTFILES_DIR="$_ROOT_DIR"

## NixOS rebuilds the whole system; any other Linux is standalone home-manager.
if [ -f /etc/os-release ] && grep -q '^ID=nixos' /etc/os-release; then
    echo "${YELLOW}Activating flake (nixos-rebuild switch)...${RESET}"
    sudo --preserve-env=DOTFILES_DIR nixos-rebuild switch --flake "${_ROOT_DIR}#Terra" --impure
elif has home-manager; then
    echo "${YELLOW}Activating flake (home-manager switch)...${RESET}"
    home-manager switch --flake "${_ROOT_DIR}#Sola" --impure
else
    ## home-manager isn't on PATH until after its first switch, so it can't be
    ## called directly. `nix run` fetches and runs it straight from its flake;
    ## after this first switch, home-manager is on PATH for every run after.
    echo "${YELLOW}home-manager not found, bootstrapping it for the first time...${RESET}"
    nix run home-manager/master -- switch --flake "${_ROOT_DIR}#Sola" --impure
fi

echo "${GREEN}System activated.${RESET}"
