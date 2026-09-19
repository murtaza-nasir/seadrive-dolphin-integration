#!/bin/bash
set -e

echo "Installing SeaDrive Dolphin Integration..."

# Create directories
mkdir -p ~/.local/bin
mkdir -p ~/.local/share/kio/servicemenus

# Copy files
cp seadrive-cmd ~/.local/bin/
cp seadrive.desktop ~/.local/share/kio/servicemenus/

# Set permissions (executable required for Plasma 6)
chmod +x ~/.local/bin/seadrive-cmd
chmod +x ~/.local/share/kio/servicemenus/seadrive.desktop

# Configure KDE to allow script execution
if [ -f ~/.config/kiorc ]; then
    if grep -q "behaviourOnLaunch" ~/.config/kiorc; then
        sed -i 's/behaviourOnLaunch=.*/behaviourOnLaunch=execute/' ~/.config/kiorc
    else
        echo -e "\n[Executable scripts]\nbehaviourOnLaunch=execute" >> ~/.config/kiorc
    fi
else
    mkdir -p ~/.config
    echo -e "[Executable scripts]\nbehaviourOnLaunch=execute" > ~/.config/kiorc
fi

# Rebuild KDE service cache
echo "Rebuilding KDE service cache..."
kbuildsycoca6 --noincremental 2>/dev/null || kbuildsycoca5 --noincremental 2>/dev/null || true

echo ""
echo "Installation complete!"
echo ""
echo "Please restart Dolphin to see the new context menu options."
echo "Right-click any file in ~/SeaDrive/ to access SeaDrive options."
