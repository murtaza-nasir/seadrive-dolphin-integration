#!/bin/bash
#
# SeaDrive Dolphin Integration Installer
# Adds right-click context menu options for SeaDrive in KDE Dolphin
#
# Usage: ./install.sh [username]
#   - No arguments:  installs for the current user
#   - With username: installs for that user (requires sudo)
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Determine target user
if [ -n "$1" ]; then
    TARGET_USER="$1"
    TARGET_HOME=$(getent passwd "$TARGET_USER" | cut -d: -f6)
    NEED_SUDO=true

    if [ -z "$TARGET_HOME" ]; then
        echo "Error: User '$TARGET_USER' does not exist."
        exit 1
    fi
else
    TARGET_USER="$USER"
    TARGET_HOME="$HOME"
    NEED_SUDO=false
fi

SERVICE_MENU_DIR="$TARGET_HOME/.local/share/kio/servicemenus"
BIN_DIR="$TARGET_HOME/.local/bin"
KIORC="$TARGET_HOME/.config/kiorc"

echo "Installing SeaDrive Dolphin Integration for user: $TARGET_USER"
echo ""

if [ "$NEED_SUDO" = true ]; then
    run_as() { sudo -u "$TARGET_USER" "$@"; }
else
    run_as() { "$@"; }
fi

# Create directories
run_as mkdir -p "$SERVICE_MENU_DIR" "$BIN_DIR" "$TARGET_HOME/.config"

# Copy files
run_as cp "$SCRIPT_DIR/seadrive-cmd" "$BIN_DIR/"
run_as cp "$SCRIPT_DIR/seadrive.desktop" "$SERVICE_MENU_DIR/"

# Set permissions.
# NOTE: the .desktop file MUST be executable under Plasma 6, otherwise Dolphin
# reports "You are not authorized to execute this file". Do not lower this to 644.
run_as chmod 755 "$BIN_DIR/seadrive-cmd"
run_as chmod 755 "$SERVICE_MENU_DIR/seadrive.desktop"

echo "✓ Installed seadrive-cmd to $BIN_DIR/"
echo "✓ Installed seadrive.desktop to $SERVICE_MENU_DIR/"

# Configure KDE to allow script execution
if run_as test -f "$KIORC"; then
    if run_as grep -q "behaviourOnLaunch" "$KIORC"; then
        run_as sed -i 's/behaviourOnLaunch=.*/behaviourOnLaunch=execute/' "$KIORC"
    else
        run_as tee -a "$KIORC" >/dev/null <<<$'\n[Executable scripts]\nbehaviourOnLaunch=execute'
    fi
else
    run_as tee "$KIORC" >/dev/null <<<$'[Executable scripts]\nbehaviourOnLaunch=execute'
fi
echo "✓ Configured $KIORC"

# Rebuild KDE service cache
echo "Rebuilding KDE service cache..."
run_as kbuildsycoca6 --noincremental 2>/dev/null \
    || run_as kbuildsycoca5 --noincremental 2>/dev/null \
    || echo "  (skipped -- run kbuildsycoca6 as $TARGET_USER in a desktop session)"

echo ""
echo "Installation complete!"
echo ""
echo "Next steps:"
echo "  1. Make sure SeaDrive is installed and running for $TARGET_USER"
echo "  2. Restart Dolphin (close all windows and reopen)"
echo "  3. Right-click any file in ~/SeaDrive to see the SeaDrive menu"
