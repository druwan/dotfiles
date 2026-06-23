#!/bin/bash

set -euo pipefail

BIN="$HOME/.local/bin"

if command -v zsh >/dev/null && command -v chsh >/dev/null; then
  ZSH_PATH="$(command -v zsh)"
  CURRENT_SHELL="$(getent passwd "$USER" 2>/dev/null | cut -d: -f7 || echo "")"

  if [ "$CURRENT_SHELL" != "$ZSH_PATH" ]; then
    sudo usermod -s "$ZSH_PATH" "$USER" 2>/dev/null ||
      echo "[install.sh] - could not change shell to zsh"
  fi
fi

if ! command -v chezmoi >/dev/null 2>&1; then
  echo "[install.sh] - Installing Chezmoi..."
  sh -c "$(curl -fsLS get.chezmoi.io/lb)" -- init --apply git@github.com:druwan/dotfiles.git
fi

if ! command -v mise >/dev/null 2>&1; then
  echo "[install.sh] - Installing mise..."
  curl https://mise.run | sh || true
fi

export PATH="$BIN:$PATH"
MISE_BIN="$(command -v mise || true)"
if [ -n "$MISE_BIN" ]; then
  "$MISE_BIN" trust "$HOME/.config/mise/config.toml" || true
  "$MISE_BIN" install --yes || true
  echo "[install.sh] - Done"
else
  echo "[install.sh] - mise not found after install"
fi

# Cleanup
[ -f "$HOME/install.sh" ] && rm -f "$HOME/install.sh"

exit 0
