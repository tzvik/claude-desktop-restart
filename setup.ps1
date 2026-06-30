# setup.ps1
# One-time installer: creates the "Restart Claude" shortcut on your desktop.
# Run this once, then click the shortcut (or pin it to your taskbar) whenever you need to restart Claude.

#Requires -Version 5.1
Add-Type -AssemblyName System.Drawing

# ── Locate Claude ──────────────────────────────────────────────────────────────
$pkg = Get-AppxPackage -Name "Claude" -ErrorAction SilentlyContinue
if (-not $pkg) {
    Write-Error "Claude for Desktop is not installed. Install it from https://claude.ai/download and re-run this script."
    exit 1
}
$familyName = $pkg.PackageFamilyName
$claudeExe  = Join-Path $pkg.InstallLocation "app\Claude.exe"

# ── Paths ──────────────────────────────────────────────────────────────────────
$installDir  = "$env:LOCALAPPDATA\ClaudeDesktopRestart"
$scriptDest  = "$installDir\restart-claude.ps1"
$iconDest    = "$installDir\restart-claude.ico"
$shortcutPath = "$env:USERPROFILE\Desktop\Restart Claude.lnk"

New-Item -ItemType Directory -Force -Path $installDir | Out-Null

# ── Copy restart script ────────────────────────────────────────────────────────
Copy-Item -Path "$PSScriptRoot\restart-claude.ps1" -Destination $scriptDest -Force

# ── Build custom icon (Claude logo + blue circular refresh arrow badge) ────────
function Save-BitmapAsIco {
    param([System.Drawing.Bitmap]$Bmp, [string]$Path)
    $ms  = New-Object System.IO.MemoryStream
    $Bmp.Save($ms, [System.Drawing.Imaging.ImageFormat]::Png)
    $png = $ms.ToArray(); $ms.Dispose()
    $len = $png.Length
    $header = [byte[]](0,0, 1,0, 1,0)
    $entry  = [byte[]](
        0,0,0,0, 1,0, 32,0,
        [byte]($len -band 0xFF), [byte](($len -shr 8) -band 0xFF),
        [byte](($len -shr 16) -band 0xFF), [byte](($len -shr 24) -band 0xFF),
        22,0,0,0
    )
    $fs = [System.IO.File]::OpenWrite($Path)
    $fs.Write($header, 0, 6); $fs.Write($entry, 0, 16); $fs.Write($png, 0, $png.Length)
    $fs.Close()
}

$size = 256
$bmp = New-Object System.Drawing.Bitmap($size, $size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g   = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode    = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

$g.DrawImage(([System.Drawing.Icon]::ExtractAssociatedIcon($claudeExe)).ToBitmap(), 0, 0, $size, $size)

[float]$bx = 182; [float]$by = 182; [float]$br = 52; [float]$arcR = 30

$g.FillEllipse([System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(60,0,0,0)), $bx-$br+3, $by-$br+3, $br*2, $br*2)
$g.FillEllipse([System.Drawing.SolidBrush]::new([System.Drawing.Color]::White), $bx-$br, $by-$br, $br*2, $br*2)

$pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255,30,100,220), 8.0)
$pen.StartCap      = [System.Drawing.Drawing2D.LineCap]::Round
$pen.CustomEndCap  = New-Object System.Drawing.Drawing2D.AdjustableArrowCap(4.0, 5.0, $true)
$g.DrawArc($pen, $bx-$arcR, $by-$arcR, $arcR*2, $arcR*2, 270.0, 290.0)

$g.Dispose(); $pen.Dispose()
Save-BitmapAsIco $bmp $iconDest

# ── Create desktop shortcut ────────────────────────────────────────────────────
$shell    = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($shortcutPath)
$shortcut.TargetPath    = "powershell.exe"
$shortcut.Arguments     = "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$scriptDest`""
$shortcut.IconLocation  = "$iconDest,0"
$shortcut.Description   = "Close and restart Claude for Desktop"
$shortcut.Save()

# Refresh icon cache
$code = '[DllImport("shell32.dll")] public static extern void SHChangeNotify(int e, int f, IntPtr a, IntPtr b);'
Add-Type -MemberDefinition $code -Name Shell32 -Namespace Win32 -ErrorAction SilentlyContinue
[Win32.Shell32]::SHChangeNotify(0x8000000, 0x1000, [IntPtr]::Zero, [IntPtr]::Zero)

Write-Host ""
Write-Host "✓ Restart Claude shortcut created on your Desktop." -ForegroundColor Green
Write-Host "  To pin it to the taskbar: right-click the shortcut → Show more options → Pin to taskbar"
Write-Host ""
