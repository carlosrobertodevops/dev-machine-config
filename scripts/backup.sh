#!/usr/bin/env bash
set -e

ts="$(date +%Y%m%d-%H%M%S)"

[ -e "$HOME/.config/opencode" ] && mv "$HOME/.config/opencode" "$HOME/.config/opencode.backup-$ts"
[ -e "$HOME/.claude" ] && mv "$HOME/.claude" "$HOME/.claude.backup-$ts"

echo "Backups criados com timestamp: $ts"