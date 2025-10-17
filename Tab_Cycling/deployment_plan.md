# Deployment Plan for Linux Tab Cycling Shortcut

## Current Status
Files have been created in the workspace:
- `mapping.json` - Application-specific tab navigation mappings with comments
- `cycle-tabs.sh` - Bash script that detects active window and sends appropriate keystrokes
- `test_instructions.md` - Testing documentation
- `test_script.sh` - Helper script for easier testing

## Testing Results ✅
The tab cycling functionality has been successfully tested with:
- Chrome (using Ctrl+Tab / Ctrl+Shift+Tab)
- VS Code (using Ctrl+Page_Down / Ctrl+Page_Up)

Both applications correctly respond to the script commands and switch tabs as expected.

## Next Steps for Deployment

### 1. Create Required Directories
```bash
mkdir -p ~/.config/cycle-tabs
mkdir -p ~/.local/bin
```

### 2. Move Files to Final Locations
```bash
# Move the mapping file
mv mapping.json ~/.config/cycle-tabs/

# Move the script
mv cycle-tabs.sh ~/.local/bin/
```

### 3. Update Script Configuration Path
The script currently uses `$PWD/mapping.json` which points to the current working directory. This needs to be updated to:
```bash
config="$HOME/.config/cycle-tabs/mapping.json"
```

### 4. Verify Script After Moving
```bash
# Test the script in its new location
~/.local/bin/cycle-tabs.sh next --debug
~/.local/bin/cycle-tabs.sh prev --debug
```

### 5. Set Up Global Shortcuts
Choose one of two methods:

#### Method A: GUI (Recommended for quick setup)
1. Open Settings → Keyboard → Keyboard Shortcuts → Custom Shortcuts
2. Add two shortcuts:
   - Name: Cycle tabs next
     Command: /home/$USER/.local/bin/cycle-tabs.sh next
     Shortcut: Ctrl+Super+Right
   - Name: Cycle tabs prev
     Command: /home/$USER/.local/bin/cycle-tabs.sh prev
     Shortcut: Ctrl+Super+Left

#### Method B: gsettings (Automatable)
Use the gsettings commands to register the shortcuts programmatically:

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

### 6. Final Testing
After setting up the global shortcuts:
1. Open applications with tabs (browser, terminal, editor)
2. Use the global shortcuts to verify they work correctly
3. Test with different applications to ensure the mappings work as expected

## Troubleshooting After Deployment
- If shortcuts don't work, check that the script is executable
- Verify the mapping.json file is in the correct location
- Use debug mode to check if the script is detecting applications correctly
- Some applications may ignore synthetic keyboard events for security reasons

## Customization Options
- Add more applications to the mapping.json file as needed
- Modify key combinations to match personal preferences
- Extend the script to support regex matching on window titles if needed
- The test_script.sh can also be moved to ~/.local/bin/ for continued use after deployment

## Success! 🎉
The Linux Tab Cycling Shortcut system is working correctly and ready for deployment. The script successfully:
- Detects the active window
- Identifies the application type
- Sends the appropriate keystrokes for tab navigation
- Works with different applications using their specific key combinations

## Technical Details

### How It Works
The script:
- Detects the focused window
- Tries WM_CLASS then process name for identification
- Looks up a JSON mapping to find the appropriate keystrokes
- Sends the keystroke with xdotool using --clearmodifiers
- Has a safe fallback for unrecognized applications

### Script Notes
- mapping.json is editable - add keys under "wm_class" using parts of WM_CLASS or under "proc_name" using process names from /proc/<pid>/comm
- Use lowercase keys for reliability
- xdotool's key names: use Page_Down, Page_Up, Tab, Return, etc.
- `--clearmodifiers` avoids an active modifier stuck on interfering with the sent key
- For debugging add `--debug` when running the script

### Edge Cases and Tips
- Some apps ignore synthetic events for security. If an app does that, you need an app-level solution (change its shortcuts or use an extension/remote API)
- If you prefer consistent behavior across apps, configure the apps you use most to the same keyset (for example set browser and editor to use Ctrl+PageDown for next tab)
- If a program uses MRU tab switching and you want linear switching, change the mapping (for example VS Code default MRU is ctrl+Tab; set mapping to ctrl+Page_Down for linear)
- You can extend the JSON to include per-window-title patterns if needed
- This works on X11 and GNOME session