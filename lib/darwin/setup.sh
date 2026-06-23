#!/usr/bin/env bash

## Guard Clauses
if [ "$(id -u)" -eq 0 ]; then
    echo "Error: don't run as root." >&2
    exit 1
fi


if [ "$(uname -s)" != "Darwin" ]; then
    echo "Error: this script only supports macOS" >&2
    exit 1
fi

_RET=$(pwd)
_DIR=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

echo "Checking Dependenices..."
. "$_DIR/dependencies.sh"

_DIR=$(cd .. && pwd)
cd $_RET
