# SeaDrive Dolphin Integration

Custom context menu integration for SeaDrive in KDE Dolphin file manager.

> **Status: personal project, provided as-is.** I wrote this for my own use on my own
> setup. It is published in case it is useful to someone else, but it comes with no
> guarantee of support, maintenance, or future updates, and no warranty of any kind.
> Issues and pull requests may go unanswered. Use at your own risk.

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
./install.sh                    # current user
sudo ./install.sh username      # another user
```

## After Installation

1. Make sure SeaDrive is running and you are logged in
2. Restart Dolphin (close all file manager windows and reopen)
3. Navigate to `~/SeaDrive`
4. Right-click any file or folder -- you should see the "SeaDrive" submenu

## Uninstallation

```bash
./uninstall.sh                  # current user
sudo ./uninstall.sh username    # another user
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

## Customization

### Change the mount point

If SeaDrive is mounted somewhere other than `~/SeaDrive`, edit `seadrive-cmd`:

```python
SEADRIVE_MOUNT = os.path.expanduser("~/SeaDrive")
```

### Add or remove menu items

Edit `seadrive.desktop`. The `Actions=` line controls which actions appear; each
has a corresponding `[Desktop Action X]` block.

## Future Work: Seafile Sync Client Support

This integration works only with **SeaDrive** (the FUSE virtual drive), not with the
**Seafile sync client** (`seafile-applet` / `seaf-daemon`). Every command is sent to
SeaDrive's extension socket, and `seadrive-cmd` rejects any path outside the SeaDrive
mount.

The sync client has no equivalent on Linux. It listens on
`<worktree>/.seafile-data/seafile_client.sock`, but that is single-instance IPC only --
`strings /usr/bin/seafile-applet` contains none of the extension verbs
(`get-share-link`, `show-history`, `uncache`, ...) that `seadrive-gui` exports. Sending
the same framed commands to it succeeds at the socket level and does nothing. Shell
integration for the sync client exists only on Windows and macOS.

A sync-client variant would therefore have to bypass the socket and work from the
client's own SQLite databases plus the server's Web API:

- `<worktree>/.seafile-data/repo.db` -- the `RepoProperty` table stores each library's
  `worktree` and `server-url`, so a path maps to a repo id by longest-worktree-prefix
  match (the same approach `get_repo_info()` uses against SeaDrive's `AccountRepos`).
- `<worktree>/.seafile-data/accounts.db` -- the `Accounts` table holds the server URL
  and an API token for authenticated calls.

Feasibility per action:

| Action | Sync client |
| --- | --- |
| View File History | Yes -- URL built from `repo.db`, no server call |
| Copy Internal Link | Yes -- `/lib/<repo_id>/file/<path>`, no server call |
| Copy Share Link | Yes -- `POST /api/v2.1/share-links/` with the stored token |
| Lock / Unlock File | Yes -- `PUT /api2/repos/<repo_id>/file/`, `operation=lock` |
| Download to Cache | N/A -- synced files are always local |
| Evict from Cache | N/A -- same |

Note that service menus cannot be filtered by path, so shipping both would show both
submenus everywhere. The simplest fix is for each command to exit silently when the
path falls outside the client it belongs to.

## Contributing

Pull requests and issues are welcome, but see the status note at the top: this is a
personal project and I make no commitment to review, respond, or merge. Forking is
entirely reasonable if you need changes.

## License

MIT -- see [LICENSE](LICENSE). The software is provided "as is", without warranty of
any kind.
