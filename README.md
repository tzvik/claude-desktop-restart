# Claude Desktop Restart

A one-click shortcut to instantly close and relaunch **Claude for Desktop** on Windows.

## Why this exists

Claude for Desktop has no native "Restart" button — only Quit. Every time you install a new **skill** or **plugin**, you have to:

1. Quit Claude
2. Find the app
3. Launch it again

That's a few too many clicks when you're in a flow. This shortcut collapses all three steps into a single click — close the current instance and start a fresh one, immediately.

## What it does

- Kills all running Claude for Desktop processes (leaves Claude Code CLI untouched)
- Waits briefly for a clean shutdown
- Relaunches Claude for Desktop via the Windows app shell
- Uses a custom icon (Claude logo + blue circular refresh arrow) so it's visually distinct from the regular Claude icon on your taskbar

## Requirements

- Windows 10 / 11
- [Claude for Desktop](https://claude.ai/download) installed (Windows Store / MSIX version)

## Install

**Right-click** `setup.ps1` → **Run with PowerShell**

That's it. A "Restart Claude" shortcut appears on your Desktop with a custom icon.

> **To pin to your taskbar:** right-click the shortcut → Show more options → Pin to taskbar

## Files

| File | Purpose |
|---|---|
| `setup.ps1` | One-time installer — creates the shortcut and icon on your Desktop |
| `restart-claude.ps1` | The actual restart logic (copied to `%LOCALAPPDATA%\ClaudeDesktopRestart\` by setup) |

## How it works

`restart-claude.ps1` uses `Get-AppxPackage` to locate Claude dynamically (no hardcoded paths), stops any process running from the `WindowsApps` folder, then relaunches via `explorer.exe shell:AppsFolder\<PackageFamilyName>!Claude`.

## License

MIT
