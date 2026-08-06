#!/usr/bin/env bash

## Darwin-only links. Sourced by lib/common/postHook.sh, which provides
## link(), the colors, _ROOT_DIR, and the helpers -- not meant to be run
## on its own.

## Guard Clauses
if ! declare -F link >/dev/null 2>&1; then
    echo "ERROR: don't run this directly, it's sourced by lib/common/postHook.sh." >&2
    exit 1
fi
root_guard
macos_guard

# iCloud stuff -- skip if iCloud Drive isn't set up on this machine
ICLOUD_SRC="$HOME/Library/Mobile Documents/com~apple~CloudDocs"
if [ -d "$ICLOUD_SRC" ]; then
    echo "${YELLOW}Linking iCloud -> ${HOME}/iCloud${RESET}"
    link "$ICLOUD_SRC" "$HOME/iCloud"
else
    echo "${YELLOW}skipping iCloud, no iCloud Drive found${RESET}"
fi

# rebuild script
echo "${YELLOW}Linking rebuild -> ${HOME}/.local/bin/rebuild${RESET}"
mkdir -p "$HOME/.local/bin"
link "${_ROOT_DIR}/lib/darwin/rebuild.sh" "$HOME/.local/bin/rebuild"
