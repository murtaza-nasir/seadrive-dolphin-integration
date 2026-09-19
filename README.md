# SeaDrive Dolphin Integration

Custom context menu integration for SeaDrive in KDE Dolphin file manager.

## Features

Right-click context menu options for files/folders in SeaDrive:
- **Copy Share Link** - Get public share link
- **Copy Internal Link** - Get internal organization link
- **Download to Cache** - Cache file locally
- **Evict from Cache** - Remove from local cache
- **Lock File** - Lock file for editing
- **Unlock File** - Release file lock
- **View File History** - Open file revision history in browser

## Installation

```bash
./install.sh
```

## Manual Installation

1. Copy the command script:
```bash
cp seadrive-cmd ~/.local/bin/
chmod +x ~/.local/bin/seadrive-cmd
```

2. Copy the service menu:
```bash
mkdir -p ~/.local/share/kio/servicemenus
cp seadrive.desktop ~/.local/share/kio/servicemenus/
chmod +x ~/.local/share/kio/servicemenus/seadrive.desktop
```

3. Install dependencies:
```bash
sudo pacman -S wl-clipboard  # For Wayland clipboard support
```

4. Configure KDE to allow script execution:
```bash
# Edit ~/.config/kiorc and set:
# [Executable scripts]
# behaviourOnLaunch=execute
```

5. Rebuild KDE service cache:
```bash
kbuildsycoca6 --noincremental
```

6. Restart Dolphin

## Requirements

- KDE Plasma 6
- Dolphin file manager
- SeaDrive GUI client
- Python 3
- wl-clipboard (Wayland) or xclip (X11)

## Notes

### Plasma 6 Service Menu Bug

In Plasma 6, service menu `.desktop` files **must be executable** (`chmod +x`), otherwise you'll get "You are not authorized to execute this file" error.

### SeaDrive History URL Bug

SeaDrive has a bug where it incorrectly encodes the file history URL. This integration works around it by building the correct URL directly from SeaDrive's database.

## How It Works

1. The service menu (`seadrive.desktop`) adds context menu options in Dolphin
2. Menu actions call `seadrive-cmd` with the appropriate command
3. `seadrive-cmd` communicates with SeaDrive GUI via Unix socket (`~/.seadrive/seadrive_ext.sock`)
4. For `show-history`, it builds the correct URL directly from SeaDrive's repo database

## Troubleshooting

### "Not authorized to execute" error
```bash
chmod +x ~/.local/share/kio/servicemenus/seadrive.desktop
```

### Menu doesn't appear
```bash
kbuildsycoca6 --noincremental
# Then restart Dolphin
```

### Commands don't work
Check if SeaDrive GUI is running and the socket exists:
```bash
ls -la ~/.seadrive/seadrive_ext.sock
```

## License

MIT
