#ps2exe parameters
#exeFile    "Restart-Claude-Setup.exe"
#title      "Restart Claude – Installer"
#description "One-click restart shortcut for Claude for Desktop"
#version    "1.0.0"
#icon       "assets\icon.ico"
#noConsole

Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms

# ── Check Claude is installed ──────────────────────────────────────────────────
$pkg = Get-AppxPackage -Name "Claude" -ErrorAction SilentlyContinue
if (-not $pkg) {
    [System.Windows.Forms.MessageBox]::Show(
        "Claude for Desktop doesn't appear to be installed.`n`nPlease install it from https://claude.ai/download and run this again.",
        "Restart Claude – Installer", "OK", "Error") | Out-Null
    exit 1
}
$familyName = $pkg.PackageFamilyName
$claudeExe  = Join-Path $pkg.InstallLocation "app\Claude.exe"

# ── Install paths ──────────────────────────────────────────────────────────────
$installDir   = "$env:LOCALAPPDATA\ClaudeDesktopRestart"
$scriptDest   = "$installDir\restart-claude.ps1"
$iconDest     = "$installDir\restart-claude.ico"
$shortcutDest = "$env:USERPROFILE\Desktop\Restart Claude.lnk"

New-Item -ItemType Directory -Force -Path $installDir | Out-Null

# ── Write restart script ───────────────────────────────────────────────────────
@'
$pkg = Get-AppxPackage -Name "Claude" -ErrorAction SilentlyContinue
if ($pkg) {
    Get-Process -Name "claude" -ErrorAction SilentlyContinue |
        Where-Object { $_.Path -like "*WindowsApps*" } |
        Stop-Process -Force
    Start-Sleep -Milliseconds 800
    Start-Process "explorer.exe" "shell:AppsFolder\$($pkg.PackageFamilyName)!Claude"
}
'@ | Set-Content -Path $scriptDest -Encoding UTF8

# ── Build custom icon ──────────────────────────────────────────────────────────
function Save-BitmapAsIco {
    param([System.Drawing.Bitmap]$Bmp, [string]$Path)
    $ms  = New-Object System.IO.MemoryStream
    $Bmp.Save($ms, [System.Drawing.Imaging.ImageFormat]::Png)
    $png = $ms.ToArray(); $ms.Dispose()
    $len = $png.Length
    $header = [byte[]](0,0,1,0,1,0)
    $entry  = [byte[]](
        0,0,0,0,1,0,32,0,
        [byte]($len -band 0xFF),[byte](($len -shr 8) -band 0xFF),
        [byte](($len -shr 16) -band 0xFF),[byte](($len -shr 24) -band 0xFF),
        22,0,0,0
    )
    $fs = [System.IO.File]::OpenWrite($Path)
    $fs.Write($header,0,6); $fs.Write($entry,0,16); $fs.Write($png,0,$png.Length)
    $fs.Close()
}

$size = 256
$bmp  = New-Object System.Drawing.Bitmap($size, $size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g    = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode     = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.DrawImage(([System.Drawing.Icon]::ExtractAssociatedIcon($claudeExe)).ToBitmap(), 0, 0, $size, $size)
[float]$bx=182;[float]$by=182;[float]$br=52;[float]$arcR=30
$g.FillEllipse([System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(60,0,0,0)),$bx-$br+3,$by-$br+3,$br*2,$br*2)
$g.FillEllipse([System.Drawing.SolidBrush]::new([System.Drawing.Color]::White),$bx-$br,$by-$br,$br*2,$br*2)
$pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255,30,100,220),8.0)
$pen.StartCap     = [System.Drawing.Drawing2D.LineCap]::Round
$pen.CustomEndCap = New-Object System.Drawing.Drawing2D.AdjustableArrowCap(4.0,5.0,$true)
$g.DrawArc($pen,$bx-$arcR,$by-$arcR,$arcR*2,$arcR*2,270.0,290.0)
$g.Dispose(); $pen.Dispose()
Save-BitmapAsIco $bmp $iconDest
$bmp.Dispose()

# ── Create desktop shortcut ────────────────────────────────────────────────────
$shell    = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($shortcutDest)
$shortcut.TargetPath   = "powershell.exe"
$shortcut.Arguments    = "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$scriptDest`""
$shortcut.IconLocation = "$iconDest,0"
$shortcut.Description  = "Close and restart Claude for Desktop"
$shortcut.Save()

# ── Pin to taskbar ─────────────────────────────────────────────────────────────
$pinned = $false
try {
    $taskbarDir = "$env:APPDATA\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar"
    if (-not (Test-Path $taskbarDir)) { New-Item -ItemType Directory -Force $taskbarDir | Out-Null }
    Copy-Item $shortcutDest $taskbarDir -Force

    # Notify Explorer to refresh the taskbar
    $code = '[DllImport("shell32.dll")] public static extern void SHChangeNotify(int e,int f,IntPtr a,IntPtr b);'
    Add-Type -MemberDefinition $code -Name Shell32 -Namespace Win32 -ErrorAction SilentlyContinue
    [Win32.Shell32]::SHChangeNotify(0x8000000, 0x1000, [IntPtr]::Zero, [IntPtr]::Zero)
    $pinned = $true
} catch { }

# ── Done ───────────────────────────────────────────────────────────────────────
$msg = if ($pinned) {
    "✓ Restart Claude is installed!`n`n• Shortcut added to your Desktop`n• Icon pinned to your Taskbar`n`nClick it any time to restart Claude — useful after installing new skills or plugins."
} else {
    "✓ Restart Claude is installed!`n`n• Shortcut added to your Desktop`n`nTo pin it to your Taskbar:`nRight-click the Desktop shortcut → Show more options → Pin to taskbar"
}

[System.Windows.Forms.MessageBox]::Show($msg, "Restart Claude – Done!", "OK", "Information") | Out-Null
