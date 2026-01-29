#!/bin/zsh

if [ $# -lt 1 ]; then
  echo -en "Error: missing new note name"
  exit 1
fi

# Combine all args into a single string
input="$*"

# Check not empty
if [ -z "$input" ]; then
  echo "Error: Input string cannot by empty"
  exit 1
fi

# lowercase-dash-separated-slug, filename & alias
slug=$(echo "$input" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/-\+/-/g' | sed 's/^-//;s/-$//')
filename="${slug}.md"

# Title, Pascal Case, frontmatter
title = $(echo "$input" | sed 's/\b\(.\)/\u\1/g')

inbox_path="$NOTES/0-Inbox"
note_path="$inbox_path/$filename"

touch "$note_path" || { echo "Error: Failed to create $note_path"; exit 1; }
NVIM_TITLE="$title" NVIM_ALIAS="$slug" nvim "$note_path"
