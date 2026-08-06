#!/usr/bin/env bash

## Colors!
### Why not make things pretty while printing

RESET=$'\e[0m';
RED=$'\e[0;31m';
GREEN=$'\e[0;32m';
YELLOW=$'\e[0;33m';

## Helper Functions

error() {
    printf "${RED}ERROR: %s${RESET}\n" "$*" >&2;
    exit 1;
}

root_guard() {
    if [ "$(id -u)" -eq 0 ]; then
        error "Don't run as root.";
    fi
}

macos_guard() {
    if [ "$(uname -s)" != "Darwin" ]; then
        error "This script only supports macOS.";
    fi
}

linux_guard() {
    if [ "$(uname -s)" != "Linux" ]; then
        error "This script only supports Linux.";
    fi
}

has() {
    command -v "$1" >/dev/null 2>&1 ;
}
