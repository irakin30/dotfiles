#!/usr/bin/env bash
set -e

[ "$(id -u)" -eq 0 ] && { echo "Don't run as root." >&2; exit 1; }

DIR="$(cd "$(dirname "$0")" && pwd)"   # dir of this script
. "$DIR/lib/helpers.sh"                 # source shared functions

case "$(uname -s)" in
  Darwin) . "$DIR/sys/darwin/setup.sh" ;;
  Linux)  . "$DIR/sys/linux/setup.sh" ;;
esac
