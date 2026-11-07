#!/usr/bin/env bash
# Removes the Rex side of rex-open: the module in ~/.config/rex, the block
# in init.lua, and the saved directories. Uninstall the Claude Code plugin with
# /plugin.
set -euo pipefail
exec 2>&1
. "$(dirname "${BASH_SOURCE[0]}")/common.sh"

if [ -L "$MODULE_DST" ]; then
  echo "Left $MODULE_DST alone: it's a link (a development checkout)."
elif [ -f "$MODULE_DST" ]; then
  rm "$MODULE_DST"
  echo "Removed $MODULE_DST."
fi

if [ -f "$INIT" ] && grep -q '^-- >>> rex-open' "$INIT"; then
  rest=$(sed '/^-- >>> rex-open/,/^-- <<< rex-open/d' "$INIT")
  printf '%s\n' "$rest" > "$INIT"
  echo "Removed the rex-open block from $INIT."
fi

rm -rf "$STATE_DIR"

if command -v rex >/dev/null && rex config reload >/dev/null 2>&1; then
  echo "Reloaded Rex."
fi
echo "If you installed the Claude Code plugin, uninstall it with /plugin."
