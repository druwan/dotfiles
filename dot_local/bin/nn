#!/bin/zsh

if [ $# -ne 1 ]; then
  echo -en "\nError: missing \"new note name\"\n"
  exit 1
fi

# Combine all args into a single string
input="$1"

# Check not empty
if [ -z "$input" ]; then
  echo "Error: Input string cannot by empty"
  exit 1
fi

# Convert input to PascalCase
title=$(echo "$input" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/-\+/-/g' | sed 's/^-//;s/-$//')
filename="${title}.md"


inbox_path="$NOTES/0-Inbox"
note_path="$inbox_path/$filename"

touch "$note_path" || { echo "Error: Failed to create $note_path"; exit 1; }
nvim "$note_path"
