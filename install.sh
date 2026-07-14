#!/usr/bin/env bash
set -e

_RET=$(pwd)
_ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"   # dir of this script

source "${_ROOT_DIR}/lib/common/helpers.sh"

root_guard

case "$(uname -s)" in
  Darwin) . "${_ROOT_DIR}/lib/darwin/setup.sh" "$_ROOT_DIR" ;;
  Linux)  . "${_ROOT_DIR}/lib/linux/setup.sh" "$_ROOT_DIR" ;;
esac

cd "${_RET}"
