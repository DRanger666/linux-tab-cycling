#!/usr/bin/env bash
# cycle-tabs.sh next|prev [--debug]
set -euo pipefail

direction="${1:-next}"
debug=false
if [[ "${2:-}" == "--debug" ]]; then debug=true; fi

win=$(xdotool getactivewindow 2>/dev/null) || { $debug && echo "no active window"; exit 1; }

# try WM_CLASS
wmclass=$(xprop -id "$win" WM_CLASS 2>/dev/null || true)
# extract second quoted token if possible
if [[ $wmclass =~ \"([^\"]+)\"[[:space:]]*,[[:space:]]*\"([^\"]+)\" ]]; then
  wm="${BASH_REMATCH[2]}"
else
  wm=""
fi

# try pid -> process name
pid=$(xdotool getwindowpid "$win" 2>/dev/null || true)
proc=""
if [[ -n $pid && -r /proc/$pid/comm ]]; then
  proc=$(tr -d '\n' < /proc/$pid/comm)
fi

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Get the parent directory (Tab_Cycling root)
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
config="$ROOT_DIR/config/mapping.json"

send_key() {
  keyseq="$1"
  if $debug; then
    echo "sending to win $win: $keyseq"
  fi
  # use --clearmodifiers to avoid sticky modifiers interfering
  xdotool key --window "$win" --clearmodifiers "$keyseq"
}

# helper to lookup mapping via jq
lookup() {
  local kind="$1" name="$2" dir="$3"
  if [[ -f "$config" ]]; then
    val=$(jq -r --arg k "$name" --arg d "$dir" '.[$kind][$k][$d] // empty' --argjson kind "\"$kind\"" "$config" 2>/dev/null)
  fi
}

# Safe jq call without messing with quoting
map_next=$(jq -r --arg wm "$wm" --arg proc "$proc" --arg d "$direction" \
  '(.wm_class[$wm][$d] // .proc_name[$proc][$d] // .fallback[$d])' "$config" 2>/dev/null || true)

# If mapping produced null/empty, try lowercased matches
if [[ -z "$map_next" || "$map_next" == "null" ]]; then
  wm_lc=$(echo "$wm" | tr '[:upper:]' '[:lower:]')
  proc_lc=$(echo "$proc" | tr '[:upper:]' '[:lower:]')
  map_next=$(jq -r --arg wm "$wm_lc" --arg proc "$proc_lc" --arg d "$direction" \
    '(.wm_class[$wm][$d] // .proc_name[$proc][$d] // .fallback[$d])' "$config" 2>/dev/null || true)
fi

# final fallback
if [[ -z "$map_next" || "$map_next" == "null" ]]; then
  map_next="ctrl+Tab"
fi

# send
send_key "$map_next"