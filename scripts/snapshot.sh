#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$HOME/Projetos/ai/dev-machine-config"
STATE_DIR="$PROJECT_ROOT/.state"

mkdir -p "$STATE_DIR"

hash_dir() {
  local target="$1"
  find "$target" -type f -print0 \
    | sort -z \
    | xargs -0 shasum \
    | shasum \
    | awk '{print $1}'
}

hash_dir "$PROJECT_ROOT/opencode" > "$STATE_DIR/opencode.last"
hash_dir "$PROJECT_ROOT/claude" > "$STATE_DIR/claude.last"

echo "Snapshot salvo em $STATE_DIR"
