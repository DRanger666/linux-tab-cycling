Good. Below is a ready-to-run, GNOME on X11 friendly solution that is more robust than the simple script you already saw. It:

* detects the focused window,
* tries WM_CLASS then process name,
* looks up a JSON mapping you can edit to add apps,
* sends the appropriate keystroke with xdotool using --clearmodifiers,
* has a safe fallback.

Install dependency

```bash
sudo apt update
sudo apt install xdotool jq
```

Create the mapping directory and example mapping

```bash
mkdir -p ~/.config/cycle-tabs
cat > ~/.config/cycle-tabs/mapping.json <<'JSON'
{
  "wm_class": {
    "firefox": {"next": "ctrl+Tab", "prev": "ctrl+shift+Tab"},
    "google-chrome": {"next": "ctrl+Tab", "prev": "ctrl+shift+Tab"},
    "chromium": {"next": "ctrl+Tab", "prev": "ctrl+shift+Tab"},
    "code": {"next": "ctrl+Page_Down", "prev": "ctrl+Page_Up"},
    "gnome-terminal": {"next": "ctrl+Page_Down", "prev": "ctrl+Page_Up"},
    "tilix": {"next": "ctrl+Page_Down", "prev": "ctrl+Page_Up"},
    "terminator": {"next": "ctrl+Page_Down", "prev": "ctrl+Page_Up"},
    "sublime_text": {"next": "ctrl+Page_Down", "prev": "ctrl+Page_Up"}
  },
  "proc_name": {
    "code": {"next": "ctrl+Page_Down", "prev": "ctrl+Page_Up"},
    "firefox": {"next": "ctrl+Tab", "prev": "ctrl+shift+Tab"},
    "chromium": {"next": "ctrl+Tab", "prev": "ctrl+shift+Tab"}
  },
  "fallback": {"next": "ctrl+Tab", "prev": "ctrl+shift+Tab"}
}
JSON
```

Save this script as `~/.local/bin/cycle-tabs.sh` and make it executable

```bash
mkdir -p ~/.local/bin
cat > ~/.local/bin/cycle-tabs.sh <<'BASH'
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

config="$HOME/.config/cycle-tabs/mapping.json"

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
BASH

chmod +x ~/.local/bin/cycle-tabs.sh
```

Notes on the script

* mapping.json is editable, add keys under "wm_class" using parts of WM_CLASS or under "proc_name" using process names from /proc/<pid>/comm. Use lowercase keys for reliability.
* xdotool's key names: use Page_Down, Page_Up, Tab, Return, etc.
* `--clearmodifiers` avoids an active modifier stuck on interfering with the sent key.
* For debugging add `--debug` when running the script.

Bind the script to GNOME global shortcuts
Method A: GUI (recommended for quick setup)

1. Open Settings -> Keyboard -> Keyboard Shortcuts -> Custom Shortcuts.
2. Add two shortcuts:

   * Name: Cycle tabs next
     Command: /home/youruser/.local/bin/cycle-tabs.sh next
     Shortcut: set to e.g. Ctrl+Super+Right
   * Name: Cycle tabs prev
     Command: /home/youruser/.local/bin/cycle-tabs.sh prev
     Shortcut: set to e.g. Ctrl+Super+Left

Method B: gsettings (automatable)
Replace USER with your username or use $HOME in a shell snippet. Example script to add two custom bindings:

```bash
# paths
p0="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
p1="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"

# register list (append if already present)
existing=$(gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings)
if [[ $existing == "@as []" ]]; then
  gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['$p0','$p1']"
else
  # naive append if the paths are not already present
  if [[ $existing != *"$p0"* ]]; then
    new=${existing%]}
    new="${new}, '$p0']"
    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "$new"
  fi
  if [[ $existing != *"$p1"* ]]; then
    new=$(gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings)
    new=${new%]}
    new="${new}, '$p1']"
    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "$new"
  fi
fi

# set first binding
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$p0 name "Cycle tabs next"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$p0 command "/home/$USER/.local/bin/cycle-tabs.sh next"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$p0 binding "<Control><Super>Right"

# set second binding
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$p1 name "Cycle tabs prev"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$p1 command "/home/$USER/.local/bin/cycle-tabs.sh prev"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$p1 binding "<Control><Super>Left"
```

Edge cases and tips

* Some apps ignore synthetic events for security. If an app does that, you need an app-level solution (change its shortcuts or use an extension/remote API).
* If you prefer consistent behavior across apps, configure the apps you use most to the same keyset (for example set browser and editor to use Ctrl+PageDown for next tab). Then use only that key in the script as a single fallback.
* If a program uses MRU tab switching and you want linear switching, change the mapping (for example VS Code default MRU is ctrl+Tab; set mapping to ctrl+Page_Down for linear).
* You can extend the JSON to include per-window-title patterns if needed.
* This works on X11 and GNOME session since you confirmed GNOME X11.

If you want, I will:

* produce a variant that uses a YAML mapping and supports regex matching on window title,
* change VS Code mapping to MRU or linear depending on your preference,
* or give you a one-liner to register the GNOME shortcuts exactly for your user (I can drop the gsettings snippet into a single script and return it).

Which of these would you like next?
