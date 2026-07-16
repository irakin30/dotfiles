#!/usr/bin/env bash
set -euo pipefail

_ROOT_DIR="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"

source "${_ROOT_DIR}/lib/common/helpers.sh"

## Guard Clauses
root_guard
macos_guard

## Run dependencies
echo "${YELLOW}Checking dependencies...${RESET}"
. "${_ROOT_DIR}/lib/darwin/dependencies.sh" "$_ROOT_DIR"

## Build and activate the flake
. "${_ROOT_DIR}/lib/darwin/rebuild.sh" "$_ROOT_DIR"
