# Windows / native PowerShell installer (for WSL users, run the Linux installer)
# Run from an elevated PowerShell: .\scripts\install-windows.ps1
$ErrorActionPreference = "Stop"

Write-Host "==> Installing Windows packages via winget" -ForegroundColor Cyan

$packages = @(
  "Git.Git",
  "Neovim.Neovim",
  "junegunn.fzf",
  "BurntSushi.ripgrep",
  "sharkdp.fd",
  "sharkdp.bat",
  "FiloSottile.age",
  "jqlang.jq",
  "Microsoft.VisualStudioCode",
  "GitHub.cli",
  "starship.starship",
  "ajeetdsouza.zoxide"
)

foreach ($pkg in $packages) {
  Write-Host "  -> $pkg" -ForegroundColor Gray
  # Redirect stderr to null to keep output clean
  $output = winget install --id $pkg --silent --accept-package-agreements --accept-source-agreements 2>&1
  if ($LASTEXITCODE -ne 0) {
    Write-Host "    (warning: $pkg returned $LASTEXITCODE — may already be installed)" -ForegroundColor Yellow
  }
}

# Ghostty is not on winget; download from GitHub releases
Write-Host "==> Installing Ghostty" -ForegroundColor Cyan
$ghosttyUrl = "https://github.com/ghostty-org/ghostty/releases/latest/download/ghostty-windows-x86_64.zip"
$tmp = "$env:TEMP\ghostty.zip"
try {
  Invoke-WebRequest -Uri $ghosttyUrl -OutFile $tmp -UseBasicParsing
  Expand-Archive -Path $tmp -DestinationPath "$env:LOCALAPPDATA\Programs\Ghostty" -Force
} catch {
  Write-Host "  (warning: Ghostty download failed — install manually from https://ghostty.org)" -ForegroundColor Yellow
}

# Add Ghostty to PATH
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -notlike "*Ghostty*") {
  [Environment]::SetEnvironmentVariable("Path", "$userPath;$env:LOCALAPPDATA\Programs\Ghostty\bin", "User")
}

# Oh-My-Posh (Windows gets Oh-My-Posh instead of Starship for full feature parity)
Write-Host "==> Installing Oh-My-Posh" -ForegroundColor Cyan
winget install JanDeDobbeleer.OhMyPosh --silent --accept-package-agreements 2>&1 | Out-Null

# Gas town (Windows note): gas town is Linux/macOS-first.
# For WSL, install the Linux binaries inside your WSL distro instead.
Write-Host "==> Note: gas town runs in WSL/Linux. See https://github.com/gastownhall/gastown" -ForegroundColor Yellow

Write-Host "`n✓ Windows packages installed. Restart your shell." -ForegroundColor Green
