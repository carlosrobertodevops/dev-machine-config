#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$HOME/dev-machine-config"
STATE_DIR="$PROJECT_ROOT/.state"

PROJECT_OPENCODE="$PROJECT_ROOT/opencode"
PROJECT_CLAUDE="$PROJECT_ROOT/claude"

LOCAL_OPENCODE="$HOME/.config/opencode"
LOCAL_CLAUDE="$HOME/.claude"

hash_dir() {
  local target="$1"
  find "$target" -type f -print0 \
    | sort -z \
    | xargs -0 shasum \
    | shasum \
    | awk '{print $1}'
}

check_one() {
  local name="$1"
  local project_dir="$2"
  local local_dir="$3"
  local state_file="$4"

  if [ ! -f "$state_file" ]; then
    echo "$name: sem snapshot anterior"
    return 10
  fi

  local old_hash
  local project_hash
  local local_hash

  old_hash="$(cat "$state_file")"
  project_hash="$(hash_dir "$project_dir")"
  local_hash="$(hash_dir "$local_dir")"

  echo "=================================================="
  echo "$name"
  echo "snapshot: $old_hash"
  echo "projeto : $project_hash"
  echo "local   : $local_hash"

  if [ "$project_hash" = "$local_hash" ]; then
    echo "STATUS: IGUAIS"
    return 0
  fi

  if [ "$project_hash" != "$old_hash" ] && [ "$local_hash" = "$old_hash" ]; then
    echo "STATUS: só PROJETO mudou"
    return 1
  fi

  if [ "$project_hash" = "$old_hash" ] && [ "$local_hash" != "$old_hash" ]; then
    echo "STATUS: só LOCAL mudou"
    return 2
  fi

  if [ "$project_hash" != "$old_hash" ] && [ "$local_hash" != "$old_hash" ]; then
    echo "STATUS: AMBOS mudaram"
    return 3
  fi

  echo "STATUS: indefinido"
  return 9
}

rc=0

check_one "OpenCode" "$PROJECT_OPENCODE" "$LOCAL_OPENCODE" "$STATE_DIR/opencode.last" || rc=$?
echo
check_one "Claude" "$PROJECT_CLAUDE" "$LOCAL_CLAUDE" "$STATE_DIR/claude.last" || true

exit 0
