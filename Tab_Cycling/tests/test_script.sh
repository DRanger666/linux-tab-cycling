#!/usr/bin/env bash
# Helper script to test the tab cycling functionality without losing focus

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Get the parent directory (Tab_Cycling root)
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

# Path to the cycle-tabs script
CYCLE_SCRIPT="$ROOT_DIR/bin/cycle-tabs.sh"

# Function to display usage
usage() {
    echo "Usage: $0 [next|prev] [window_name]"
    echo ""
    echo "Examples:"
    echo "  $0 next Firefox    # Cycle to next tab in Firefox"
    echo "  $0 prev \"Visual Studio Code\"  # Cycle to previous tab in VS Code"
    echo "  $0 next           # Cycle to next tab in currently focused window"
    echo ""
    echo "If window_name is provided, the script will focus that window first"
    echo "before executing the tab cycling command."
}

# Parse arguments
DIRECTION="${1:-next}"
WINDOW_NAME="$2"

# Validate direction
if [[ "$DIRECTION" != "next" && "$DIRECTION" != "prev" ]]; then
    echo "Error: Direction must be 'next' or 'prev'"
    usage
    exit 1
fi

# If window name is provided, focus that window first
if [[ -n "$WINDOW_NAME" ]]; then
    echo "Looking for window: $WINDOW_NAME"
    WINDOW_ID=$(xdotool search --name "$WINDOW_NAME" | head -1)
    
    if [[ -z "$WINDOW_ID" ]]; then
        echo "Error: Window '$WINDOW_NAME' not found"
        exit 1
    fi
    
    echo "Focusing window (ID: $WINDOW_ID)"
    xdotool windowfocus "$WINDOW_ID"
    # Small delay to ensure the window is focused
    sleep 0.5
fi

# Run the cycle-tabs script with debug mode
echo "Executing: $CYCLE_SCRIPT $DIRECTION --debug"
"$CYCLE_SCRIPT" "$DIRECTION" --debug