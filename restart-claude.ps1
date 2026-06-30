# restart-claude.ps1
# Kills all Claude for Desktop processes and relaunches the app.
# Run this script via the desktop shortcut created by setup.ps1.

$pkg = Get-AppxPackage -Name "Claude" -ErrorAction SilentlyContinue
if (-not $pkg) {
    [System.Windows.Forms.MessageBox]::Show(
        "Claude for Desktop does not appear to be installed.",
        "Restart Claude", "OK", "Error"
    )
    exit 1
}

Get-Process -Name "claude" -ErrorAction SilentlyContinue |
    Where-Object { $_.Path -like "*WindowsApps*" } |
    Stop-Process -Force

Start-Sleep -Milliseconds 800

$familyName = $pkg.PackageFamilyName
Start-Process "explorer.exe" "shell:AppsFolder\${familyName}!Claude"
