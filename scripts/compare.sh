#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$HOME/dev-machine-config"

PROJECT_OPENCODE="$PROJECT_ROOT/opencode"
PROJECT_CLAUDE="$PROJECT_ROOT/claude"

LOCAL_OPENCODE="$HOME/.config/opencode"
LOCAL_CLAUDE="$HOME/.claude"

compare_dir() {
  local label="$1"
  local src_a="$2"
  local src_b="$3"

  echo "=================================================="
  echo "Comparando: $label"
  echo "A: $src_a"
  echo "B: $src_b"
  echo "--------------------------------------------------"

  if [ ! -d "$src_a" ]; then
    echo "ERRO: diretório A não existe: $src_a"
    return 2
  fi

  if [ ! -d "$src_b" ]; then
    echo "ERRO: diretório B não existe: $src_b"
    return 2
  fi

  if diff -qr "$src_a" "$src_b" >/dev/null; then
    echo "STATUS: IGUAL"
    return 0
  else
    echo "STATUS: DIFERENTE"
    echo
    diff -qr "$src_a" "$src_b" || true
    return 1
  fi
}

overall=0

compare_dir "OpenCode" "$PROJECT_OPENCODE" "$LOCAL_OPENCODE" || overall=1
echo
compare_dir "Claude" "$PROJECT_CLAUDE" "$LOCAL_CLAUDE" || overall=1

echo
echo "=================================================="

if [ "$overall" -eq 0 ]; then
  echo "RESULTADO FINAL: tudo igual."
else
  echo "RESULTADO FINAL: existem diferenças."
fi

exit "$overall"
