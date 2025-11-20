#!/bin/bash

set -euo pipefail

BIN="$HOME/.local/bin"

if command -v zsh >/dev/null; then
  sudo chsh -s "$(command -v zsh)" "$USER"
fi

if ! command -v mise >/dev/null 2>&1; then
  echo "Error: mise not found" >&2
  exit 1
fi

if ! command -v chezmoi >/dev/null 2>&1; then
  echo "[install.sh] - Installing Chezmoi..."
  sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$BIN"
fi

echo "[install.sh] - Applying dotfiles"
"$BIN/chezmoi" -- init --apply git@github.com:druwan/dotfiles.git

"$BIN/mise" trust "$HOME/.config/mise/config.toml"
"$BIN/mise" install --yes

exit 0
