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
Use the gsettings commands from the original plan to register the shortcuts programmatically.

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