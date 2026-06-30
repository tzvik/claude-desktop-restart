# Claude Desktop Restart

A one-click shortcut to instantly close and relaunch **Claude for Desktop** on Windows.

<p align="center">
  <img src="assets/shortcut-preview.png" alt="Restart Claude shortcut as it appears on the desktop" />
</p>

---

## Why this exists

Claude for Desktop has no built-in "Restart" button — only **Quit**. Every time you install a new **skill** or **plugin**, you have to:

1. Quit Claude manually
2. Find the Claude app
3. Click to launch it again

That's a few too many steps when you're in a flow. This shortcut collapses all of that into **a single click** — it closes the current Claude instance and immediately starts a fresh one.

---

## What you get

A desktop shortcut with a custom icon — the Claude logo with a blue circular refresh arrow badge in the corner, so it's easy to tell apart from the regular Claude icon.

<p align="left">
  <img src="assets/icon.png" width="96" alt="Restart Claude icon — Claude logo with a blue circular refresh arrow in the corner" />
</p>

---

## Requirements

- Windows 10 or Windows 11
- [Claude for Desktop](https://claude.ai/download) installed from the **Microsoft Store** (or directly from Anthropic's website using the `.exe` installer — both work)

---

## How to install — one file, one click

### Step 1 — Download the installer

👉 **[Download Restart-Claude-Setup.exe](https://github.com/tzvik/claude-desktop-restart/raw/master/Restart-Claude-Setup.exe)**

Save it anywhere — your Desktop or Downloads folder is fine.

### Step 2 — Run it

Double-click **`Restart-Claude-Setup.exe`**.

> **If Windows shows a blue security warning** ("Windows protected your PC"):
> - Click **"More info"**
> - Then click **"Run anyway"**
>
> This appears because the file isn't from the Microsoft Store. It's a self-contained script — no internet access, no admin rights required. You can inspect the full source in `installer.ps1`.

### Step 3 — Done

A confirmation message will appear. The shortcut is now on your Desktop and pinned to your Taskbar automatically.

---

### Alternative: install from source (PowerShell)

If you prefer to run the script directly:

1. Click the green **`< > Code`** button → **"Download ZIP"**
2. Unzip, then right-click **`setup.ps1`** → **"Run with PowerShell"**

---

## How to use it

Simply **double-click** the "Restart Claude" shortcut on your Desktop whenever you want to restart Claude.

That's it. Claude will close and reopen automatically within about a second.

---

## How to pin it to your taskbar (optional)

If you want one-click access from the taskbar at the bottom of your screen:

1. Right-click the **"Restart Claude"** shortcut on your Desktop
2. Click **"Show more options"**
3. Click **"Pin to taskbar"**

The icon will appear at the bottom of your screen alongside your other pinned apps.

---

## Troubleshooting

**"The shortcut appeared but nothing happens when I click it"**
Make sure Claude for Desktop is actually running before you click the shortcut. If Claude isn't open, the shortcut will still work — it just won't have anything to close first, so Claude will simply open fresh.

**"I see a PowerShell error about execution policy"**
Open the **Start menu**, search for **"PowerShell"**, right-click it and choose **"Run as administrator"**, then paste this and press Enter:
```
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```
Then try running `setup.ps1` again.

**"Claude opened but my skills/plugins still aren't showing"**
Wait a few seconds after Claude opens — it needs a moment to load everything on startup.

---

## How it works (for the curious)

`restart-claude.ps1` uses PowerShell to:
1. Find the Claude app using Windows' built-in app registry (`Get-AppxPackage`) — no hardcoded paths, so it works on any machine
2. Stop all Claude for Desktop processes (it leaves Claude Code / terminal sessions untouched)
3. Wait 800ms for a clean shutdown
4. Relaunch Claude via the Windows shell (`explorer.exe shell:AppsFolder\...`)

---

## License

MIT — do whatever you want with it.
