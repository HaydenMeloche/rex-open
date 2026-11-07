# Shared paths for the rex-open scripts. Sourced, not run.
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
MODULE_SRC="$PLUGIN_ROOT/rex/rex_open.lua"
REX_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/rex"
MODULE_DST="$REX_DIR/rex_open.lua"
INIT="$REX_DIR/init.lua"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/rex-open"
