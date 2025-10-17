# Makefile for Linux Tab Cycling Shortcut

.PHONY: install test clean help

# Default target
all: test

# Install the scripts to system locations
install:
	@echo "Installing Linux Tab Cycling Shortcut..."
	mkdir -p ~/.config/cycle-tabs ~/.local/bin
	cp config/mapping.json ~/.config/cycle-tabs/
	cp bin/cycle-tabs.sh ~/.local/bin/
	sed -i 's|$$ROOT_DIR/config/mapping.json|$$HOME/.config/cycle-tabs/mapping.json|' ~/.local/bin/cycle-tabs.sh
	chmod +x ~/.local/bin/cycle-tabs.sh
	@echo "Installation complete. Set up global shortcuts in GNOME Settings."

# Test the functionality
test:
	@echo "Testing Linux Tab Cycling Shortcut..."
	chmod +x bin/cycle-tabs.sh tests/test_script.sh
	@echo "Test with currently focused window:"
	./tests/test_script.sh next
	@echo "Test with a specific application (if available):"
	@echo "Run: ./tests/test_script.sh next Firefox"

# Clean up installed files
clean:
	@echo "Removing installed files..."
	rm -f ~/.local/bin/cycle-tabs.sh
	rm -rf ~/.config/cycle-tabs
	@echo "Cleanup complete."

# Set up GNOME shortcuts (interactive)
setup-shortcuts:
	@echo "Setting up GNOME shortcuts..."
	@echo "Please manually add these shortcuts in Settings → Keyboard → Keyboard Shortcuts → Custom Shortcuts:"
	@echo "1. Name: Cycle tabs next"
	@echo "   Command: ~/.local/bin/cycle-tabs.sh next"
	@echo "   Shortcut: Ctrl+Super+Right"
	@echo ""
	@echo "2. Name: Cycle tabs prev"
	@echo "   Command: ~/.local/bin/cycle-tabs.sh prev"
	@echo "   Shortcut: Ctrl+Super+Left"

# Show help
help:
	@echo "Linux Tab Cycling Shortcut - Makefile targets:"
	@echo ""
	@echo "  install         Install scripts to system locations"
	@echo "  test            Test the functionality"
	@echo "  clean           Remove installed files"
	@echo "  setup-shortcuts Show instructions for setting up GNOME shortcuts"
	@echo "  help            Show this help message"