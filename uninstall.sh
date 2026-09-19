#!/bin/bash
#
# SeaDrive Dolphin Integration Uninstaller
#
# Usage: ./uninstall.sh [username]
#   - No arguments:  uninstalls for the current user
#   - With username: uninstalls for that user (requires sudo)
#

set -e

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

SERVICE_MENU_FILE="$TARGET_HOME/.local/share/kio/servicemenus/seadrive.desktop"
BIN_FILE="$TARGET_HOME/.local/bin/seadrive-cmd"

echo "Uninstalling SeaDrive Dolphin Integration for user: $TARGET_USER"
echo ""

if [ "$NEED_SUDO" = true ]; then
    run_as() { sudo -u "$TARGET_USER" "$@"; }
else
    run_as() { "$@"; }
fi

run_as rm -f "$SERVICE_MENU_FILE" && echo "✓ Removed $SERVICE_MENU_FILE"
run_as rm -f "$BIN_FILE" && echo "✓ Removed $BIN_FILE"

# Rebuild KDE service cache
run_as kbuildsycoca6 --noincremental 2>/dev/null \
    || run_as kbuildsycoca5 --noincremental 2>/dev/null \
    || true

echo ""
echo "Uninstallation complete. Restart Dolphin to apply changes."
