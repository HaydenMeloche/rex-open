#!/usr/bin/env bash
# SessionStart hook. After the plugin updates, copies the new Rex module over
# the one setup installed and reloads Rex. Does nothing before setup has run,
# after remove, or when the module is a link to a development checkout.
# Prints nothing: a SessionStart hook's output goes into Claude's context.
. "$(dirname "${BASH_SOURCE[0]}")/common.sh"

[ -f "$MODULE_DST" ] && [ ! -L "$MODULE_DST" ] || exit 0
cmp -s "$MODULE_SRC" "$MODULE_DST" && exit 0
cp "$MODULE_SRC" "$MODULE_DST" 2>/dev/null || exit 0
rex config reload >/dev/null 2>&1 || true
exit 0
