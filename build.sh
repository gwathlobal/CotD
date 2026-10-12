#!/usr/bin/env bash
# Builds the cotd release executable via SBCL, without needing a manual REPL.
# Output: src/cotd (next to data/ and help/, which the release build locates
# relative to the executable's own path).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="$SCRIPT_DIR/src"

cd "$SRC_DIR"

sbcl --non-interactive \
  --eval '(push (truename "./") asdf:*central-registry*)' \
  --eval '(asdf:load-system :cotd)' \
  --eval '(cotd:make-exec)'

echo "Built: $SRC_DIR/cotd"
