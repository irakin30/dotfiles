#!/usr/bin/env bash

## This script runs after nix, mainly does all the linking for everything in `dotfiles/config` and `dotfiles/home`
## everything in `dotfiles/config` symlinks into `${XDG_CONFIG_HOME:-$HOME/.config}/`
## everything in `dotfiles/home` symlinks into `$HOME/`

_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"   # dir of this script
_ROOT_DIR="$(cd "${_DIR}/../.." && pwd)"

source "${_DIR}/helpers.sh"

root_guard

CONFIG_DST="${XDG_CONFIG_HOME:-$HOME/.config}"
HOME_DST="$HOME"

## Links a single src path to dst, refusing to clobber anything that isn't
## already a symlink managed by this script.
link() {
    local src="$1"
    local dst="$2"

    if [ -L "$dst" ]; then
        if [ "$(readlink "$dst")" = "$src" ]; then
            echo "${GREEN}already linked${RESET}: $dst"
            return
        fi
        rm "$dst"
    elif [ -e "$dst" ]; then
        echo "${YELLOW}skipping, not a symlink${RESET}: $dst"
        return
    fi

    ln -s "$src" "$dst"
    echo "${GREEN}linked${RESET}: $dst -> $src"
}

## Symlinks every top-level entry (files and directories, including
## dotfiles) of src_dir into dst_dir, without recursing into them.
link_tree() {
    local src_dir="$1"
    local dst_dir="$2"

    [ -d "$src_dir" ] || return 0
    mkdir -p "$dst_dir"

    local entry
    while IFS= read -r -d '' entry; do
        link "$entry" "$dst_dir/$(basename "$entry")"
    done < <(find "$src_dir" -mindepth 1 -maxdepth 1 -print0)
}

echo "${YELLOW}Linking config/ -> ${CONFIG_DST}${RESET}"
link_tree "${_ROOT_DIR}/config" "$CONFIG_DST"

echo "${YELLOW}Linking home/ -> ${HOME_DST}${RESET}"
link_tree "${_ROOT_DIR}/home" "$HOME_DST"

echo "${GREEN}Done linking dotfiles.${RESET}"
