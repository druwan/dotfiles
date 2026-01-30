#!/bin/zsh
set -euo pipefail

if [ $# -lt 1 ]; then
  echo -en "Error: missing new note name"
  exit 1
fi

# Combine all args into a single string
input="$*"

# lowercase-dash-separated-slug, filename & alias
slug=$(echo "$input" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/-\+/-/g' | sed 's/^-//;s/-$//')
filename="${slug}.md"

title=$(echo "$input" | sed 's/\b\(.\)/\u\1/g')

inbox_path="$NOTES/0-Inbox"
note_path="$inbox_path/$filename"

if [ ! -f "$note_path" ]; then
  export NVIM_TITLE="$title"
  export NVIM_ALIAS="$slug"
  nvim "$note_path"
else
  nvim "$note_path"
fi

