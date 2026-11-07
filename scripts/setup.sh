#!/usr/bin/env bash
# Sets up the Rex side of rex-open: copies the Rex module into
# ~/.config/rex and adds a block that loads it to init.lua. Safe to run again:
# it updates the module and leaves an existing block, and your edits to it,
# alone. Run by /rex-open:setup, which shows what it prints. It reports a
# problem and exits 0, because a non-zero exit cancels the slash command.
set -euo pipefail
exec 2>&1
. "$(dirname "${BASH_SOURCE[0]}")/common.sh"

command -v rex >/dev/null || { echo "rex isn't on your PATH. Install Rex first: https://www.superlogical.com/rex"; exit 0; }
command -v jq >/dev/null || { echo "jq isn't installed. It's needed to record Claude's directory; install it (for example: brew install jq) and run setup again."; exit 0; }

mkdir -p "$REX_DIR"
if [ -L "$MODULE_DST" ]; then
  echo "Left $MODULE_DST alone: it's a link (a development checkout)."
else
  cp "$MODULE_SRC" "$MODULE_DST"
  echo "Installed the Rex module at $MODULE_DST."
fi

touch "$INIT"
if grep -q '^-- >>> rex-open' "$INIT"; then
  echo "$INIT already loads it; left your settings there unchanged."
else
  cat >> "$INIT" <<'LUA'

-- >>> rex-open: a picker for the files, folders, links, commands and SQL in a pane's output.
require("rex_open").setup{
  -- Alt+Cmd+O opens a picker: the focused pane's directory, then the files,
  -- folders, links, commands and SQL in its output. Enter opens to the right,
  -- Ctrl-T in a new tab, Ctrl-D below, and Ctrl-Y copies.
  picker = {
    -- A key, a list of keys, or false to leave it unbound.
    key  = "alt+cmd+o",
    -- float: a popup over the window, and Enter opens to the right.
    -- right, left, down, up or tab: the picker opens there, and so does Enter.
    open = "float",
    -- How a file opens. By default: in $VISUAL or $EDITOR at the line, or
    -- read-only vim when neither is set. To choose, set view: $1 is the file
    -- and $2 the line. Others: 'nvim -R "+${2:-1}" -- "$1"', 'hx "$1:${2:-1}"'.
    -- view = 'vim -R "+${2:-1}" -- "$1"',
  },
}
-- <<< rex-open
LUA
  echo "Added a rex-open block to $INIT. Change its settings there."
fi

if ! check=$(rex config check "$INIT" 2>&1); then
  echo "Rex reports a problem in $INIT:"
  echo "$check" | grep -iE 'error|warn' || echo "$check"
  exit 0
fi
if rex config reload >/dev/null 2>&1; then
  echo "Reloaded Rex. Keys bound now:"
  rex keymap 2>/dev/null | awk '$2 ~ /^rex_open/ { printf "  %-18s %s\n", $1, $2 }' || true
else
  echo "Couldn't reload Rex. Run 'rex config reload' on the machine running the Rex server."
fi
