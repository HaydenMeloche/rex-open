#!/bin/bash
# Claude Code hook (SessionStart, CwdChanged, PostToolUse for Bash,
# SessionEnd). Records Claude's current directory for its Rex pane, so the Rex
# actions in rex/rex_open.lua can open the agent's directory.
#
# PostToolUse is there because Claude Code 2.1 doesn't send CwdChanged when
# only a plugin listens for it. Every hook's input has Claude's current
# directory in cwd, so after a Bash command that cd'd, it's already the new
# one.
#
#   save-cwd.sh         read the hook's JSON on stdin and save its cwd
#   save-cwd.sh clear   remove the saved directory
#
# The file holds two lines: the pid of the pane's foreground process (Claude),
# and the directory. The Rex action ignores the file unless that process is
# still the one running in the pane. Outside Rex, this does nothing.
[ -n "$REX_BLOCK" ] || exit 0
dir="${XDG_STATE_HOME:-$HOME/.local/state}/rex-open"
file="$dir/${REX_BLOCK#block:}"

if [ "$1" = clear ]; then
  rm -f "$file"
  exit 0
fi

cwd=$(jq -r '.new_cwd // .cwd // empty' 2>/dev/null)
[ -n "$cwd" ] || exit 0

# It runs after every Bash command; skip the Rex lookup when nothing moved.
[ -f "$file" ] && [ "$(sed -n 2p "$file")" = "$cwd" ] && exit 0

pid=$(rex block call ${REX_SESSION:+-s "$REX_SESSION"} -b "$REX_BLOCK" process 2>/dev/null |
  jq -r '.foreground.pid // empty' 2>/dev/null)

mkdir -p "$dir"
printf '%s\n%s\n' "$pid" "$cwd" > "$file.tmp" && mv "$file.tmp" "$file"
