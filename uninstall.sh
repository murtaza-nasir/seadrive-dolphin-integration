#!/bin/bash

echo "Uninstalling SeaDrive Dolphin Integration..."

rm -f ~/.local/bin/seadrive-cmd
rm -f ~/.local/share/kio/servicemenus/seadrive.desktop

# Rebuild KDE service cache
kbuildsycoca6 --noincremental 2>/dev/null || kbuildsycoca5 --noincremental 2>/dev/null || true

echo "Uninstallation complete. Restart Dolphin to apply changes."
