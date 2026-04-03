#!/bin/bash

echo "🚀 Setup da máquina iniciado..."

# 1. Instalar Homebrew deps
brew bundle

# 2. Clonar repo se não existir
if [ ! -d "$HOME/dev-machine-config" ]; then
  git clone git@github.com:SEUUSER/dev-machine-config.git
fi

cd ~/dev-machine-config

# 3. Symlinks (força overwrite)
ln -sf ~/dev-machine-config/claude ~/.config/claude
ln -sf ~/dev-machine-config/opencode ~/.config/opencode
ln -sf ~/dev-machine-config/shell/.zshrc ~/.zshrc

# 4. Instalar plugins OpenCode
opencode plugins install --from opencode/plugins.json

# 5. Sincronizar MCPs
opencode mcp sync

# 6. Direnv (se usar)
direnv allow || true

echo "✅ Máquina pronta"