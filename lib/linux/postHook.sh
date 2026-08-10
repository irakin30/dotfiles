#!/usr/bin/env bash

## Linux-only links. Sourced by lib/common/postHook.sh, which provides
## link(), the colors, _ROOT_DIR, and the helpers -- not meant to be run
## on its own.

## Guard Clauses
if ! declare -F link >/dev/null 2>&1; then
    echo "ERROR: don't run this directly, it's sourced by lib/common/postHook.sh." >&2
    exit 1
fi
root_guard
linux_guard

# rebuild script
echo "${YELLOW}Linking rebuild -> ${HOME}/.local/bin/rebuild${RESET}"
mkdir -p "$HOME/.local/bin"
link "${_ROOT_DIR}/lib/linux/rebuild.sh" "$HOME/.local/bin/rebuild"
