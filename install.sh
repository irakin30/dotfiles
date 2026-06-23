#!/usr/bin/env bash
set -e

_RET=$(pwd)
_DIR="$(cd "$(dirname "$0")" && pwd)"   # dir of this script

source "${_DIR}/lib/helpers.sh"

root_guard

case "$(uname -s)" in
  Darwin) . "${_DIR}/lib/darwin/setup.sh" ;;
  Linux)  . "${_DIR}/lib/linux/setup.sh" ;;
esac

cd ${_RET}
