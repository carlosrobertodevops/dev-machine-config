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

check_status() {
  local project_dir="$1"
  local local_dir="$2"
  local state_file="$3"

  local old_hash
  local project_hash
  local local_hash

  old_hash="$(cat "$state_file")"
  project_hash="$(hash_dir "$project_dir")"
  local_hash="$(hash_dir "$local_dir")"

  if [ "$project_hash" = "$local_hash" ]; then
    echo "equal"
    return
  fi

  if [ "$project_hash" != "$old_hash" ] && [ "$local_hash" = "$old_hash" ]; then
    echo "project"
    return
  fi

  if [ "$project_hash" = "$old_hash" ] && [ "$local_hash" != "$old_hash" ]; then
    echo "local"
    return
  fi

  if [ "$project_hash" != "$old_hash" ] && [ "$local_hash" != "$old_hash" ]; then
    echo "both"
    return
  fi

  echo "unknown"
}

op_status="$(check_status "$PROJECT_OPENCODE" "$LOCAL_OPENCODE" "$STATE_DIR/opencode.last")"
cl_status="$(check_status "$PROJECT_CLAUDE" "$LOCAL_CLAUDE" "$STATE_DIR/claude.last")"

echo "OpenCode: $op_status"
echo "Claude  : $cl_status"

if [ "$op_status" = "equal" ] && [ "$cl_status" = "equal" ]; then
  echo "Tudo igual. Nada a fazer."
  exit 0
fi

if [ "$op_status" = "both" ] || [ "$cl_status" = "both" ]; then
  echo "ERRO: projeto e máquina mudaram ao mesmo tempo. Abortando sincronização."
  exit 1
fi

echo "Sincronização permitida."
exit 0
