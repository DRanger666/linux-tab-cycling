# Linux Tab Cycling Shortcut

A cross-application tab cycling solution for Linux desktop environments that provides consistent tab navigation across different applications using their specific keyboard shortcuts.

## Overview

This solution allows you to use the same global keyboard shortcuts to cycle through tabs in different applications (browsers, editors, terminals, etc.) by automatically detecting the active window and sending the appropriate keystrokes for that application.

## Features

- Detects the focused window using WM_CLASS or process name
- Supports application-specific tab navigation shortcuts
- Includes mappings for popular browsers, editors, and terminals
- Provides fallback behavior for unrecognized applications
- Includes debug mode for troubleshooting
- Easy to extend with additional application mappings

## Files

- [`bin/cycle-tabs.sh`](bin/cycle-tabs.sh) - Main script that detects active window and sends appropriate keystrokes
- [`config/mapping.json`](config/mapping.json) - Configuration file with application-specific key combinations
- [`tests/test_script.sh`](tests/test_script.sh) - Helper script for easier testing without losing window focus
- [`docs/test_instructions.md`](docs/test_instructions.md) - Detailed testing instructions
- [`docs/deployment_plan.md`](docs/deployment_plan.md) - Step-by-step deployment guide with technical details

## Quick Start

1. Install dependencies:
   ```bash
   sudo apt update
   sudo apt install xdotool jq
   ```

2. Test the functionality:
   ```bash
   # Make scripts executable
   chmod +x bin/cycle-tabs.sh tests/test_script.sh
   
   # Test with currently focused window
   ./tests/test_script.sh next
   
   # Test with specific application
   ./tests/test_script.sh next Firefox
   ```

3. Deploy to system locations:
   ```bash
   mkdir -p ~/.config/cycle-tabs ~/.local/bin
   cp config/mapping.json ~/.config/cycle-tabs/
   cp bin/cycle-tabs.sh ~/.local/bin/
   
   # Update script to use correct config path
   sed -i 's|$ROOT_DIR/config/mapping.json|$HOME/.config/cycle-tabs/mapping.json|' ~/.local/bin/cycle-tabs.sh
   ```

4. Set up global shortcuts in GNOME:
   - Open Settings → Keyboard → Keyboard Shortcuts → Custom Shortcuts
   - Add two shortcuts:
     - Name: Cycle tabs next, Command: ~/.local/bin/cycle-tabs.sh next, Shortcut: Ctrl+Super+Right
     - Name: Cycle tabs prev, Command: ~/.local/bin/cycle-tabs.sh prev, Shortcut: Ctrl+Super+Left

## Supported Applications

### Browsers
- Firefox, Google Chrome, Chromium: `Ctrl+Tab` / `Ctrl+Shift+Tab`

### Editors & Terminals
- VS Code, GNOME Terminal, Tilix, Terminator, Sublime Text: `Ctrl+Page_Down` / `Ctrl+Page_Up`

### Fallback
- Unrecognized applications: `Ctrl+Tab` / `Ctrl+Shift+Tab`

## Configuration

To add support for additional applications, edit [`config/mapping.json`](config/mapping.json) and add entries under the appropriate section:

```json
{
  "wm_class": {
    "your_app": {
      "next": "your_next_key",
      "prev": "your_prev_key"
    }
  }
}
```

## Troubleshooting

- Use debug mode to see what the script is detecting: `cycle-tabs.sh next --debug`
- Some applications may ignore synthetic keyboard events for security reasons
- Verify that xdotool can simulate keys in the target application
- Check that the script is executable and in your PATH

## License

This project is provided as-is for personal use.