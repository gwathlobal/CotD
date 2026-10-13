#!/usr/bin/env bash
# Builds the cotd release executable via SBCL, without needing a manual REPL.
# Output: src/cotd (next to data/ and help/, which the release build locates
# relative to the executable's own path).
#
# Works on Linux and should work on macOS as well - see the macOS notes in
# COMPILING.txt. SDL2 has to be installed (see COMPILING.txt). Set SBCL to point at
# a specific SBCL if it is not on PATH.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd "$SCRIPT_DIR/src"

"${SBCL:-sbcl}" --non-interactive --load ../build.lisp

echo "Built: $SCRIPT_DIR/src/cotd"
