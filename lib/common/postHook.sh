#!/usr/bin/env bash
set -euo pipefail

## This script runs after nix, mainly does all the linking for everything in `dotfiles/config` and `dotfiles/home`
## `dotfiles/config` is tiered: `config/common` symlinks into `${XDG_CONFIG_HOME:-$HOME/.config}/`
## on every OS, then `config/darwin` or `config/linux` on top for the current OS
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

## Symlinks every top-level entry of src_dir into dst_dir, without recursing into them.
## --hide adds a leading "." to dst names, so repo sources can stay un-hidden 
## e.g. home/zshrc -> ~/.zshrc.
link_tree() {
    local hide=""
    if [ "$1" = "--hide" ]; then
        hide=1
        shift
    fi 

    local src_dir="$1"
    local dst_dir="$2"

    [ -d "$src_dir" ] || return 0
    mkdir -p "$dst_dir"

    local entry name
    while IFS= read -r -d '' entry; do
        name="$(basename "$entry")"
        [ "$name" = ".gitkeep" ] && continue   # placeholder to keep empty tiers in git, never linked
        [ -n "$hide" ] && name=".${name}"
        link "$entry" "$dst_dir/$name"
    done < <(find "$src_dir" -mindepth 1 -maxdepth 1 -print0)
}

case "$(uname -s)" in
  Darwin) _OS_TIER="darwin" ;;
  Linux)  _OS_TIER="linux" ;;
  *)      error "Unsupported OS: $(uname -s)" ;;
esac

echo "${YELLOW}Linking config/common -> ${CONFIG_DST}${RESET}"
link_tree "${_ROOT_DIR}/config/common" "$CONFIG_DST"

echo "${YELLOW}Linking config/${_OS_TIER} -> ${CONFIG_DST}${RESET}"
link_tree "${_ROOT_DIR}/config/${_OS_TIER}" "$CONFIG_DST"

echo "${YELLOW}Linking home/ -> ${HOME_DST}${RESET}"
link_tree --hide "${_ROOT_DIR}/home" "$HOME_DST"

## OS-specific links live in lib/<os>/postHook.sh, sourced so they can reuse link().
case "$(uname -s)" in
  Darwin) . "${_ROOT_DIR}/lib/darwin/postHook.sh" ;;
  Linux)  ;; # nothing linux-specific yet
esac

echo "${GREEN}Done linking dotfiles.${RESET}"
