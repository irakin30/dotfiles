#!/usr/bin/env bash

_ROOT_DIR="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"

source "${_ROOT_DIR}/lib/common/helpers.sh"

## Guard Clauses
root_guard
macos_guard

## Hard coded for now, since this is meant for machine configurations.
HOST="Luna"

## home.nix reads $DOTFILES_DIR (builtins.getEnv) to find lib/common/postHook.sh,
## since it must symlink the live checkout, not a store copy. --impure is required
## for that, and sudo's env_reset strips DOTFILES_DIR unless told to keep it.
export DOTFILES_DIR="$_ROOT_DIR"

if has darwin-rebuild; then
    echo "${YELLOW}Activating flake (darwin-rebuild switch)...${RESET}"
    sudo --preserve-env=DOTFILES_DIR darwin-rebuild switch --flake "${_ROOT_DIR}#${HOST}" --impure
else
    ## darwin-rebuild isn't installed yet on a fresh machine, so it can't be called
    ## directly. `nix run` fetches and runs it straight from the nix-darwin flake;
    ## after this first switch, darwin-rebuild is on PATH for every run after.
    echo "${YELLOW}darwin-rebuild not found, bootstrapping nix-darwin for the first time...${RESET}"
    sudo --preserve-env=DOTFILES_DIR nix run "nix-darwin/master#darwin-rebuild" -- switch --flake "${_ROOT_DIR}#${HOST}" --impure
fi

echo "${GREEN}System activated.${RESET}"
