#!/usr/bin/env bash

usage() {
  cat <<EOF
Usage: yt-links.sh [OPTIONS] <url> [url2 url3 ...]

Download YouTube videos using yt-dlp.

OPTIONS:
  -h, --help    Show this help message

EXAMPLES:
  yt-links.sh https://www.youtube.com/watch?v=NrR_RdRRE2w
  yt-links.sh https://youtu.be/abc123 https://youtu.be/def456
EOF
}

if [ $# -lt 1 ]; then
  echo "ERROR: Missing yt link(s)"
  usage
  exit 1
fi

case "$1" in
-h | --help)
  usage
  exit 0
  ;;
esac

for link in "$@"; do
  echo -en "Downloading $link"
  yt-dlp --format "bv*[ext=mp4]+ba[ext=m4a]/[ext=mp4]" "$link" -o /tmp/
done
