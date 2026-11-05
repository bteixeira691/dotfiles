# =================== PowerShell 7 profile ===================
# Managed by chezmoi as ~/.config/powershell/profile.ps1.
#
# Windows: scripts/install-windows.ps1 writes a small shim at
#   $PROFILE.CurrentUserAllHosts  (Documents\PowerShell\profile.ps1)
# which dot-sources this file. macOS/Linux pwsh reads it directly.
#
# Keep this file fast: every optional module/tool is guarded, and nothing
# here makes a network call.

# --- Encoding ---------------------------------------------------------------
# Git diffs, Nerd Font icons, and Oh My Posh all expect UTF-8.
try {
  [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
  $OutputEncoding = [Console]::OutputEncoding
} catch {}

# --- PSReadLine -------------------------------------------------------------
if (Get-Module -ListAvailable -Name PSReadLine) {
  Import-Module PSReadLine -ErrorAction SilentlyContinue

  # Vi mode matches zsh-vi-mode. Switch to Emacs if you prefer.
  try {
    Set-PSReadLineOption -EditMode Vi
  } catch {
    Set-PSReadLineOption -EditMode Emacs
  }
  try {
    Set-PSReadLineOption -ViModeIndicator Cursor
  } catch {}

  Set-PSReadLineOption -BellStyle None
  Set-PSReadLineOption -HistorySearchCursorMovesToEnd
  try {
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle ListView
  } catch {}

  try {
    Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -Function DeleteCharOrExit
    Set-PSReadLineKeyHandler -Chord 'Ctrl+z' -Function Undo
  } catch {}
}

# --- Optional modules -------------------------------------------------------
foreach ($module in @('posh-git', 'Terminal-Icons')) {
  if (Get-Module -ListAvailable -Name $module) {
    Import-Module $module -ErrorAction SilentlyContinue
  }
}

# --- fzf / PSFzf ------------------------------------------------------------
if (Get-Module -ListAvailable -Name PSFzf) {
  Import-Module PSFzf -ErrorAction SilentlyContinue
  Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+f' `
                  -PSReadlineChordReverseHistory 'Ctrl+r'
}

if (Get-Command fzf -ErrorAction SilentlyContinue) {
  $env:FZF_DEFAULT_OPTS = '--height 60% --layout reverse --border rounded'
  $env:FZF_DEFAULT_COMMAND = 'fd --type f --hidden --follow --exclude .git'
  $env:FZF_CTRL_T_COMMAND = $env:FZF_DEFAULT_COMMAND
}

# --- Prompt: Oh My Posh (same theme as zsh) --------------------------------
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
  $ompConfig = Join-Path $HOME '.config/omp/omp.json'
  if (Test-Path $ompConfig) {
    oh-my-posh init pwsh --config $ompConfig | Invoke-Expression
  } else {
    oh-my-posh init pwsh | Invoke-Expression
  }
} elseif (Get-Command starship -ErrorAction SilentlyContinue) {
  Invoke-Expression (& starship init powershell)
}

# --- zoxide -----------------------------------------------------------------
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
  Invoke-Expression (& zoxide init powershell | Out-String)
}

# --- Environment ------------------------------------------------------------
$env:EDITOR = 'nvim'
$env:VISUAL = 'nvim'
$env:GIT_EDITOR = 'nvim'
$env:PAGER = 'less'
$env:DOTNET_CLI_TELEMETRY_OPTOUT = '1'
$env:DOTNET_NOLOGO = '1'
$env:PYTHONDONTWRITEBYTECODE = '1'
$env:NODE_OPTIONS = '--enable-source-maps'

$ripgrepConfig = Join-Path $HOME '.config/ripgrep/ripgreprc'
if (Test-Path $ripgrepConfig) { $env:RIPGREP_CONFIG_PATH = $ripgrepConfig }

$batConfig = Join-Path $HOME '.config/bat/config'
if (Test-Path $batConfig) { $env:BAT_CONFIG_PATH = $batConfig }
$env:BAT_THEME = 'TwoDark'

$lazygitConfig = Join-Path $HOME '.config/lazygit/config.yml'
if (Test-Path $lazygitConfig) { $env:LG_CONFIG_FILE = $lazygitConfig }

$starshipConfig = Join-Path $HOME '.config/starship.toml'
if (Test-Path $starshipConfig) { $env:STARSHIP_CONFIG = $starshipConfig }

# Git for Windows ships its own ssh; prefer it over the legacy system one.
$gitSsh = 'C:\Windows\System32\OpenSSH\ssh.exe'
if (Test-Path $gitSsh) { $env:GIT_SSH = $gitSsh }

# --- PATH -------------------------------------------------------------------
$paths = @(
  (Join-Path $HOME 'bin'),
  (Join-Path $HOME '.local/bin'),
  (Join-Path $HOME '.dotnet/tools'),
  (Join-Path $HOME '.cargo/bin'),
  (Join-Path $HOME '.bun/bin'),
  (Join-Path $HOME 'scoop/shims')
)
$currentPath = $env:PATH -split [IO.Path]::PathSeparator
foreach ($path in $paths) {
  if ((Test-Path $path) -and ($currentPath -notcontains $path)) {
    $env:PATH = $path + [IO.Path]::PathSeparator + $env:PATH
  }
}

# --- Listing ----------------------------------------------------------------
if (Get-Command eza -ErrorAction SilentlyContinue) {
  Remove-Item Alias:ls -Force -ErrorAction SilentlyContinue
  function ls {
    eza --icons=auto --group-directories-first @args
  }
  function ll {
    eza -alF --icons=auto --group-directories-first @args
  }
  function la {
    eza -a --icons=auto --group-directories-first @args
  }
  function lt {
    eza --tree --level=2 --icons=auto @args
  }
  function lta {
    eza --tree --level=2 -a --icons=auto @args
  }
} else {
  function ll { Get-ChildItem -Force @args }
  function la { Get-ChildItem -Force @args }
  function lt { Get-ChildItem -Recurse -Depth 2 @args }
}

if (Get-Command bat -ErrorAction SilentlyContinue) {
  Remove-Item Alias:cat -Force -ErrorAction SilentlyContinue
  Set-Alias -Name cat -Value bat -Force
}

if (Get-Command rg -ErrorAction SilentlyContinue) {
  Set-Alias -Name grep -Value rg
} else {
  Set-Alias -Name grep -Value Select-String
}

# --- Editor -----------------------------------------------------------------
if (Get-Command nvim -ErrorAction SilentlyContinue) {
  Set-Alias -Name vim -Value nvim
  Set-Alias -Name vi -Value nvim
  function v { nvim @args }
  function nvimcfg { nvim (Join-Path $HOME '.config/nvim') @args }
}

# --- Git --------------------------------------------------------------------
if (Get-Command git -ErrorAction SilentlyContinue) {
  Set-Alias -Name g -Value git

  function gs  { git status @args }
  function gd  { git diff @args }
  function gds { git diff --staged @args }
  function ga  { git add @args }
  function gaa { git add --all @args }
  function gc  { git commit @args }
  function gcm { git commit -m @args }
  function gp  { git push @args }
  function gpl { git pull @args }
  function gb  { git branch @args }
  function gco { git checkout @args }
  function gcb { git checkout -b @args }
  function gl  {
    git log --oneline --graph --decorate -20 @args
  }
}

if (Get-Command lazygit -ErrorAction SilentlyContinue) {
  Set-Alias -Name lg -Value lazygit
}

if (Get-Command just -ErrorAction SilentlyContinue) {
  Set-Alias -Name j -Value just
}

# --- Docker -----------------------------------------------------------------
if (Get-Command docker -ErrorAction SilentlyContinue) {
  function d   { docker @args }
  function dc  { docker compose @args }
  function dcu { docker compose up -d @args }
  function dcd { docker compose down @args }
  function dps {
    docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}' @args
  }
}

# --- Python / uv ------------------------------------------------------------
if (Get-Command uv -ErrorAction SilentlyContinue) {
  function py  { uv run python @args }
  function pyr { uv run @args }
  function pip { uv pip @args }
}

# --- Utilities --------------------------------------------------------------
function which ($Command) {
  Get-Command $Command -ErrorAction SilentlyContinue |
    Select-Object Name, CommandType, Source
}

function touch ($Path) {
  if (Test-Path $Path) {
    (Get-Item $Path).LastWriteTime = Get-Date
  } else {
    New-Item -ItemType File -Path $Path | Out-Null
  }
}

function mkcd ($Path) {
  New-Item -ItemType Directory -Force -Path $Path | Out-Null
  Set-Location $Path
}

function reload {
  . $PROFILE.CurrentUserAllHosts
}

function serve {
  param([int]$Port = 8000)
  python -m http.server $Port
}
