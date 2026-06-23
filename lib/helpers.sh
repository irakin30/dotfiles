#!/usr/bin/env bash


# COLORS THAT EVERYTHING WILL USE
RESET=$'\e[0m'
RED=$'\e[0;31m'
GREEN=$'\e[0;32m'
YELLOW=$'\e[0;33m'

getDir() {
    local RET=$(pwd)
    local DIR="$(cd "$(dirname "$0")" && pwd)"   # dir of this script
    cd $RET
    echo $DIR
}

root_guard() {
    if [ "$(id -u)" -eq 0 ]; then
        echo "${RED}ERROR: Don't run as root.${RESET}" >&2;
        exit 1;
    fi
}

has() { command -v "$1" >/dev/null 2>&1; }
