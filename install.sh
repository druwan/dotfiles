#!/bin/bash

set -euo pipefail

BIN="$HOME/.local/bin"

if command -v zsh >/dev/null; then
  sudo chsh -s "$(command -v zsh)" "$USER"
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
fi
echo "[install.sh] - Done"

exit 0
