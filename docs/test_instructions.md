# Testing the Linux Tab Cycling Shortcut

## Files Created
1. `mapping.json` - Application-specific tab navigation mappings with comments
2. `cycle-tabs.sh` - Bash script that detects active window and sends appropriate keystrokes

## Prerequisites
Both required dependencies are already installed:
- xdotool: /usr/bin/xdotool
- jq: /usr/bin/jq

## Testing Steps

### 1. Basic Script Test
The script has been made executable and a basic test was performed. No output indicates normal operation.

### 2. Manual Testing
To test the script manually, you have several options:

#### Option A: Using a second terminal (Recommended)
1. Open an application with tabs (e.g., Firefox, Chrome, VS Code)
2. Open a separate terminal window for running the test commands
3. Focus the application you want to test
4. In the terminal, run the script with debug mode:
   ```bash
   ./cycle-tabs.sh next --debug
   ./cycle-tabs.sh prev --debug
   ```

#### Option B: Using sleep to give yourself time to focus
1. Open an application with tabs
2. In the terminal, run with a delay to give yourself time to focus the application:
   ```bash
   sleep 3 && ./cycle-tabs.sh next --debug
   sleep 3 && ./cycle-tabs.sh prev --debug
   ```
3. After running the command, quickly click on the target application window

#### Option C: Using xdotool to focus a window (Advanced)
1. Get the window ID of your target application:
   ```bash
   xdotool search --name "Firefox" | head -1
   ```
2. Focus the window and run the script:
   ```bash
   xdotool windowfocus [WINDOW_ID] && ./cycle-tabs.sh next --debug
   ```

#### Option D: Using the provided test script (Easiest)
We've created a helper script (`test_script.sh`) that makes testing much easier:
```bash
# Test with Firefox (will focus Firefox first)
./test_script.sh next Firefox

# Test with VS Code
./test_script.sh prev "Visual Studio Code"

# Test with currently focused window
./test_script.sh next
```

The test script automatically focuses the specified window before running the tab cycling command, so you don't need to manually switch windows.

### 3. Expected Behavior
- The script should detect the active window's application
- It should look up the appropriate key combination in mapping.json
- It should send the keystroke to cycle tabs in that application

### 4. Application-Specific Mappings
The mapping.json includes support for:
- Browsers (Firefox, Chrome, Chromium): Ctrl+Tab / Ctrl+Shift+Tab
- Editors/Terminals (VS Code, GNOME Terminal, Tilix, Terminator, Sublime Text): Ctrl+Page_Down / Ctrl+Page_Up
- Fallback: Ctrl+Tab / Ctrl+Shift+Tab for unrecognized applications

### 5. Moving to Final Location
Once testing is complete:
1. Create the config directory: `mkdir -p ~/.config/cycle-tabs`
2. Move mapping.json: `mv mapping.json ~/.config/cycle-tabs/`
3. Create bin directory: `mkdir -p ~/.local/bin`
4. Move script: `mv cycle-tabs.sh ~/.local/bin/`
5. Update script to use the correct config path (change `$PWD/mapping.json` to `$HOME/.config/cycle-tabs/mapping.json`)

### 6. Setting Up Global Shortcuts
After moving files to their final locations, set up GNOME keyboard shortcuts:
- Use either the GUI method (Settings → Keyboard → Keyboard Shortcuts → Custom Shortcuts)
- Or use the gsettings commands provided in the plan

## Troubleshooting
- If the script doesn't work, check if xdotool can simulate keys in the target application
- Some applications may ignore synthetic keyboard events for security reasons
- Use the --debug flag to see what the script is detecting and sending