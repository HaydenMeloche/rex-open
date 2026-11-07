#!/bin/sh
# Installs rex-open for the Rex terminal:
#
#   curl -fsSL https://raw.githubusercontent.com/HaydenMeloche/rex-open/master/install.sh | sh
#
# It installs the Rex module (the picker, Alt+Cmd+O), which works in any pane.
# If Claude Code is installed, it also offers the Claude Code plugin, which
# lets the picker follow Claude when it changes directory and keeps the Rex
# module up to date. Run it again to update.
#
# Options:
#   --yes        install the Claude Code plugin without asking
#   --no-plugin  install only the Rex module
#
# Run from a checkout (./install.sh), it installs from that checkout instead
# of downloading.
set -eu

REPO=${REX_OPEN_REPO:-HaydenMeloche/rex-open}
BRANCH=${REX_OPEN_BRANCH:-master}
DEST=${XDG_DATA_HOME:-$HOME/.local/share}/rex-open
PLUGIN=rex-open@rex-open

ask=1 plugin=1
for arg in "$@"; do
  case $arg in
    --yes) ask=0 ;;
    --no-plugin) plugin=0 ;;
    *) echo "Unknown option: $arg" >&2; exit 2 ;;
  esac
done

command -v rex >/dev/null 2>&1 || {
  echo "rex isn't on your PATH. Install Rex first: https://www.superlogical.com/rex" >&2
  exit 1
}

# Where the files come from: this checkout, or a fresh download.
here=$(cd "$(dirname "$0")" 2>/dev/null && pwd || true)
if [ -n "$here" ] && [ -f "$here/scripts/setup.sh" ] && [ -f "$here/rex/rex_open.lua" ]; then
  root=$here
  source=$here
  echo "Installing from $root."
else
  echo "Downloading $REPO ($BRANCH)..."
  tmp=$(mktemp -d)
  trap 'rm -rf "$tmp"' EXIT
  curl -fsSL "https://codeload.github.com/$REPO/tar.gz/refs/heads/$BRANCH" | tar -xz -C "$tmp"
  rm -rf "$DEST"
  mkdir -p "$(dirname "$DEST")"
  mv "$tmp"/* "$DEST"
  root=$DEST
  source=$REPO
fi

echo
bash "$root/scripts/setup.sh"

# Asks a yes/no question on the terminal, even when piped into sh. Defaults to
# yes; without a terminal, says no.
confirm() {
  [ "$ask" = 0 ] && return 0
  [ -r /dev/tty ] || return 1
  printf '%s [Y/n] ' "$1" > /dev/tty
  read -r answer < /dev/tty || return 1
  case $answer in [nN]*) return 1 ;; *) return 0 ;; esac
}

if [ "$plugin" = 1 ] && command -v claude >/dev/null 2>&1; then
  echo
  if claude plugin list 2>/dev/null | grep -q "$PLUGIN"; then
    echo "Claude Code: the plugin is already installed. Update it with /plugin."
  elif confirm "Install the Claude Code plugin, so the picker follows Claude's cd?"; then
    claude plugin marketplace add "$source" >/dev/null 2>&1 || true
    claude plugin install "$PLUGIN"
    echo "Claude Code: installed. It takes effect in new Claude sessions."
  else
    echo "Claude Code: skipped. Later: claude plugin marketplace add $source && claude plugin install $PLUGIN"
  fi
fi

echo
echo "Done. Press Alt+Cmd+O in any Rex pane. Run this installer again to update."
