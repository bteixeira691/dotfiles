# Keymaps & Shortcuts

A single reference for the keybindings in this dotfiles setup.

- **Neovim**: custom maps plus the LazyVim/plugin keys worth memorizing.
- **Herdr**: from `dot_config/herdr/config.toml.tmpl`.
- **Ghostty**, **tmux**, **PowerShell**, **zsh**, **fzf/atuin**.
- Plugin-internal `<Plug>` mappings are intentionally omitted.

> Live Neovim maps: `<leader>sk` opens the keymap picker. `:map` and
> `:verbose map <key>` show the same data with the defining file.

---

## Neovim

### Personal maps

Source: `dot_config/nvim/lua/config/keymaps.lua`.

| Key | Mode | Action |
|---|---|---|
| `x` | n | Delete character without overwriting the yank register |
| `+` / `-` | n | Increment / decrement number |
| `<C-a>` | n | Select all |
| `<C-m>` | n | Jump forward in the jumplist (`<C-i>` replacement) |
| `H` | n | Highlight the word under the cursor |
| `<leader>bS` | n | Reload changed files from disk, then save |
| `<C-h>` `<C-j>` `<C-k>` `<C-l>` | n | Move between Neovim windows, then Herdr panes at the edge |
| `<leader>?` | n | Show buffer-local keymaps (which-key) |
| `<C-w><space>` | n | Window hydra in which-key |

### Windows and tabs

| Key | Action |
|---|---|
| `<leader>-` | Split window below |
| `<leader>\|` | Split window right |
| `<leader>wd` | Delete window |
| `<leader>wm` | Toggle zoom |
| `<leader><tab><tab>` | New tab |
| `<leader><tab>]` / `<leader><tab>[` | Next / previous tab |
| `<leader><tab>d` | Close tab |
| `<leader><tab>f` / `<leader><tab>l` | First / last tab |
| `<leader><tab>o` | Close other tabs |

### Files, buffers, and search

| Key | Action |
|---|---|
| `<leader><space>` | Find files (root dir) |
| `<leader>ff` / `<leader>fF` | Find files (root / cwd) |
| `<leader>fr` / `<leader>fR` | Recent files (root / cwd) |
| `<leader>fg` | Git files |
| `<leader>fb` / `<leader>fB` | Buffers / all buffers |
| `<leader>fc` | Find config file |
| `<leader>fn` | New file |
| `<leader>fp` | Projects |
| `<leader>ft` / `<leader>fT` | Terminal (root / cwd) |
| `<leader>e` / `<leader>E` | Neo-tree (root / cwd) |
| `<leader>/` | Grep (root dir) |
| `<leader>sg` / `<leader>sG` | Grep (root / cwd) |
| `<leader>sw` / `<leader>sW` | Grep word/selection (root / cwd) |
| `<leader>sd` / `<leader>sD` | Diagnostics / buffer diagnostics |
| `<leader>sr` | Search and replace |
| `<leader>sR` | Resume last search |
| `<leader>s/` | Search history |
| `<leader>sc` | Command history |
| `<leader>sk` | Keymaps |
| `<leader>sh` | Help pages |
| `<leader>sm` / `<leader>sj` | Marks / jumps |
| `<leader>sl` / `<leader>sq` | Location list / quickfix |
| `<leader>st` / `<leader>sT` | Todo / todo-fix-fixme |
| `<leader>s"` | Registers |
| `<leader>sa` / `<leader>sb` | Autocmds / buffer lines |
| `<leader>sC` / `<leader>sH` | Commands / highlights |
| `<leader>sM` / `<leader>sp` | Man pages / plugin specs |
| `<leader>si` / `<leader>su` | Icons / undotree |
| `<leader>,` | Buffers |
| `<leader>bb` | Switch to other buffer |
| `<leader>bd` / `<leader>bD` | Delete buffer / buffer and window |
| `<leader>bo` | Delete other buffers |
| `<leader>bl` / `<leader>br` | Delete buffers left / right |
| `<leader>bi` | Delete invisible buffers |
| `<leader>bp` / `<leader>bP` | Pin buffer / delete non-pinned |
| `<leader>bj` / `<leader>be` | Pick buffer / buffer explorer |

### LSP and code

| Key | Action |
|---|---|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gy` | Go to type definition |
| `gI` | Go to implementation |
| `gr` | References |
| `K` | Hover docs |
| `gK` | Signature help |
| `<C-k>` (insert) | Signature help |
| `<leader>ca` | Code action |
| `<leader>cA` | Source action |
| `<leader>cr` | Rename symbol |
| `<leader>cR` | Rename file |
| `<leader>cf` | Format buffer |
| `<leader>cF` | Format injected languages |
| `<leader>cc` / `<leader>cC` | Run CodeLens / refresh CodeLens |
| `<leader>cd` | Line diagnostics |
| `]d` / `[d` | Next / previous diagnostic |
| `]e` / `[e` | Next / previous error |
| `]w` / `[w` | Next / previous warning |
| `<leader>cl` | LSP info |
| `<leader>cm` | Mason |
| `<leader>cs` | Symbols (Aerial) |
| `<leader>cS` | LSP references/definitions (Trouble) |

### Git

| Key | Action |
|---|---|
| `<leader>gg` / `<leader>gG` | Lazygit (root / cwd) |
| `<leader>gs` | Git status |
| `<leader>gd` | Git diff hunks |
| `<leader>gb` | Git blame line |
| `<leader>gf` | Current file history |
| `<leader>gl` / `<leader>gL` | Log / log (cwd) |
| `<leader>gB` / `<leader>gY` | Browse / copy URL |
| `<leader>gD` | Diff against origin |
| `<leader>gS` | Git stash |
| `<leader>ge` | Git explorer |
| `<leader>gi` / `<leader>gI` | GitHub issues (open / all) |
| `<leader>gp` / `<leader>gP` | GitHub PRs (open / all) |
| `]h` / `[h` | Next / previous hunk |
| `]H` / `[H` | Last / first hunk |
| `<leader>ghs` | Stage hunk |
| `<leader>ghr` | Reset hunk |
| `<leader>ghS` | Stage buffer |
| `<leader>ghu` | Undo staged hunk |
| `<leader>ghR` | Reset buffer |
| `<leader>ghp` | Preview hunk inline |
| `<leader>ghb` / `<leader>ghB` | Blame line / buffer |
| `<leader>ghd` / `<leader>ghD` | Diff this / diff against `~` |
| `ih` (operator/visual) | Select hunk |

### Debug (nvim-dap)

| Key | Action |
|---|---|
| `<F5>` | Continue / start |
| `<F9>` | Toggle breakpoint |
| `<F10>` / `<F11>` / `<F12>` | Step over / into / out |
| `<leader>db` | Toggle breakpoint |
| `<leader>dc` | Run / continue |
| `<leader>dC` | Run to cursor |
| `<leader>di` / `<leader>do` / `<leader>dO` | Step into / out / over |
| `<leader>dB` | Breakpoint condition |
| `<leader>dr` | Toggle REPL |
| `<leader>du` | DAP UI |
| `<leader>dt` | Terminate |
| `<leader>dl` | Run last |
| `<leader>de` | Eval |
| `<leader>dg` | Go to line (no execute) |
| `<leader>dj` / `<leader>dk` | Down / up in stack |
| `<leader>dw` | Widgets |
| `<leader>dP` | Pause |
| `<leader>ds` | Session |
| `<leader>da` | Run with args |
| `<leader>dS` / `<leader>dX` | Switch / terminate all debug sessions |
| `<leader>dx` | Breakpoints panel |
| `<leader>dpp` / `<leader>dph` / `<leader>dps` | Profiler / highlights / scratch |

### .NET and Blazor

Source: `dot_config/nvim/lua/config/keymaps.lua` and `lua/plugins/dotnet.lua`.

| Key | Action |
|---|---|
| `<leader>kb` / `<leader>kB` | Build project / solution |
| `<leader>kc` / `<leader>kx` | Clean / clean + build |
| `<leader>kr` | Run service in Herdr |
| `<leader>kR` | Run service on a custom port |
| `<leader>kw` | Watch service in Herdr (`dotnet watch`) |
| `<leader>kl` | Focus a running service |
| `<leader>kp` | Peek service logs |
| `<leader>kX` | Stop all services |
| `<leader>kd` / `<leader>kdd` | Debug project + profile / default project |
| `<leader>ka` | Attach debugger |
| `<leader>kt` / `<leader>ktt` | Test runner |
| `<leader>kC` | Test coverage |
| `<leader>kA` / `<leader>kP` | Add / remove package |
| `<leader>ko` | Outdated packages |
| `<leader>ks` | User secrets |
| `<leader>kn` | New .NET item (Razor component/page/view) |
| `<leader>kv` | Dotnet menu |
| `<leader>kT` | Dotnet terminal |
| `<leader>kD` | EF: database update |
| `<leader>km` / `<leader>kM` | EF: add / list migrations |
| `<leader>re` (visual) | Extract function |
| `<leader>rv` (visual) | Extract variable |

Blazor snippet prefixes (completion menu / `mini.snippets`):

| Prefix | Expands to |
|---|---|
| `page` | `@page "/route"` |
| `using` | `@using Namespace` |
| `inject` | `@inject Service Name` |
| `code` | `@code { ... }` |
| `bind` / `bindevent` | `@bind` / `@bind:event` |
| `onclick` / `oninput` | Event handler attribute |
| `if` / `foreach` / `switch` | Razor control blocks |
| `rendermode` | `@rendermode InteractiveServer` |
| `component` | `<Component />` |
| `parameter` / `cascading` / `injectprop` | Component property attributes |
| `oninitialized` / `onparameters` / `dispose` | Lifecycle overrides |
| `implements` / `inherits` / `typeparam` / `layout` | Razor directives |

### Herdr annotations (inside Neovim)

From `herdr-nvim` defaults:

| Key | Action |
|---|---|
| `<leader>ac` | Comment current line / selection |
| `<leader>al` | List comments |
| `<leader>as` | Paste comments into the agent input |
| `<leader>aS` | Send and submit comments |
| `<leader>ai` | Reference line/selection at the agent cursor |

### Tests (Neotest)

| Key | Action |
|---|---|
| `<leader>tt` | Run file |
| `<leader>tr` | Run nearest |
| `<leader>tT` | Run all test files |
| `<leader>tl` | Run last |
| `<leader>to` / `<leader>tO` | Show output / output panel |
| `<leader>ts` | Toggle summary |
| `<leader>tw` | Toggle watch |
| `<leader>tS` | Stop |
| `<leader>td` | Debug nearest |
| `<leader>ta` | Attach to test |

### Toggles and sessions

| Key | Action |
|---|---|
| `<leader>uh` | Inlay hints |
| `<leader>uf` / `<leader>uF` | Auto-format (global / buffer) |
| `<leader>ud` | Diagnostics |
| `<leader>us` | Spell |
| `<leader>uw` | Wrap |
| `<leader>ul` / `<leader>uL` | Line numbers / relative numbers |
| `<leader>uT` | Treesitter highlighting |
| `<leader>ug` | Indent guides |
| `<leader>ua` | Mini Animate |
| `<leader>uD` | Dimming |
| `<leader>uz` / `<leader>uZ` | Zen / zoom |
| `<leader>ur` | Redraw / clear search / update diff |
| `<leader>qs` / `<leader>ql` | Restore session / last session |
| `<leader>qS` / `<leader>qd` | Select session / don't save |
| `<leader>qq` | Quit all |

### Dashboard

| Key | Action |
|---|---|
| `f` | Find file |
| `n` | New file |
| `g` | Find text |
| `r` | Recent files |
| `c` | Config |
| `s` | Restore session |
| `x` | Lazy Extras |
| `l` | Lazy |
| `q` | Quit |

---

## Herdr

Prefix: **`ctrl+t`**. Source: `dot_config/herdr/config.toml.tmpl`.

| Key | Action |
|---|---|
| `prefix+?` | Live help panel (all active bindings) |
| `prefix+s` | Settings |
| `prefix+r` | Reload config |
| `prefix+shift+r` | Resize mode |
| `prefix+d` / `prefix+q` | Detach |
| `prefix+w` | Workspace picker |
| `prefix+shift+n` | New workspace |
| `prefix+shift+d` | Close workspace |
| `prefix+u` | Goto |
| `prefix+shift+o` | Open notification target |
| `ctrl+shift+[` / `ctrl+shift+]` | Previous / next workspace |
| `ctrl+{` / `ctrl+}` | Previous / next workspace (alternate) |
| `prefix+c` | New tab |
| `prefix+p` / `prefix+n` | Previous / next tab |
| `prefix+1..9` | Switch tab |
| `prefix+,` / `prefix+shift+t` | Rename tab |
| `prefix+&` / `prefix+shift+x` | Close tab |
| `ctrl+shift+left` / `ctrl+shift+right` | Move tab |
| `prefix+h` `prefix+j` `prefix+k` `prefix+l` | Focus pane left/down/up/right |
| `ctrl+shift+h` `ctrl+shift+j` `ctrl+shift+k` `ctrl+shift+l` | Focus pane (alternate) |
| `ctrl+h` `ctrl+j` `ctrl+k` `ctrl+l` | Neovim-aware navigation (`herdr-nvim-nav`) |
| `prefix+tab` / `prefix+shift+tab` | Cycle pane next / previous |
| `prefix+;` | Last pane |
| `prefix+[` | Copy mode |
| `prefix+x` | Close pane |
| `prefix+z` | Zoom pane (requires ≥2 panes) |
| `prefix+shift+h/j/k/l` | Swap panes (Herdr default) |
| `ctrl+shift+alt+h/j/k/l` | Resize pane |
| `prefix+b` | Toggle Herdr sidebar |
| `prefix+\|` / `prefix+%` / `prefix+\` / `prefix+v` | Vertical split |
| `prefix+minus` / `prefix+"` / `prefix+_` | Horizontal split |
| `prefix+shift+e` | Edit scrollback |
| `prefix+e` | Toggle Neovim sidebar |
| `prefix+o` | Pick file from agent output |
| `prefix+g` | Lazygit in a pane |
| `prefix+shift+c` | Lazydocker in a pane |
| `ctrl+shift+up` / `ctrl+shift+down` | Move workspace up/down |

**Why zoom can look broken:** `prefix+z` only toggles zoom when the active tab
has more than one pane. On a single pane Herdr returns `single_pane` and does
nothing. Split first (`prefix+|` or `prefix+minus`), then zoom.

**Intentional remaps:** `prefix+r` reloads (Herdr's default is `prefix+shift+r`);
`prefix+shift+r` is resize mode; `prefix+g` is lazygit, so goto moved to
`prefix+u`; `prefix+e` is the Neovim sidebar, so scrollback moved to
`prefix+shift+e`; `prefix+o` picks a file, so notifications moved to
`prefix+shift+o`. Press `prefix+?` to see the merged result.

---

## Ghostty

Source: `dot_config/ghostty/config`. On macOS, `super` is **Cmd**.

| Key | Action |
|---|---|
| `Shift+Insert` | Paste from clipboard |
| `Ctrl+Insert` | Copy to clipboard |
| `Ctrl+Shift+C` | Copy to clipboard |
| `Ctrl+Shift+V` | Paste from clipboard |
| `Super+Ctrl+Shift+Alt+Arrow` | Resize split |
| `Super+Shift+Arrow` | Focus split in that direction |
| `Super+R` | Reload Ghostty config |

---

## tmux

Prefix: **`Ctrl+Space`** (secondary `Ctrl+b`). Source: `dot_config/tmux/tmux.conf`.

| Key | Action |
|---|---|
| `prefix q` | Reload config |
| `prefix h` / `prefix v` | Split horizontal / vertical |
| `prefix x` | Kill pane |
| `Ctrl+Alt+Arrow` | Select pane |
| `Ctrl+Alt+Shift+Arrow` | Resize pane |
| `prefix r` | Rename window |
| `prefix c` / `prefix k` | New / kill window |
| `Alt+1..9` | Select window |
| `Alt+Left` / `Alt+Right` | Previous / next window |
| `Alt+Shift+Left` / `Alt+Shift+Right` | Swap window |
| `prefix R` / `prefix K` | Rename / kill session |
| `prefix C` | New session |
| `prefix P` / `prefix N` | Previous / next session |
| `Alt+Up` / `Alt+Down` | Previous / next session |
| `v` / `y` in copy mode | Begin selection / copy |

---

## PowerShell

Source: `dot_config/powershell/profile.ps1`. PSReadLine is in **Vi** mode.

### Keys

| Key | Action |
|---|---|
| `Ctrl+d` | Delete character or exit |
| `Ctrl+z` | Undo |
| `Ctrl+f` | PSFzf file provider |
| `Ctrl+r` | PSFzf reverse history |
| `Esc` | Vi normal mode |
| `i` / `a` | Vi insert / append |

### Aliases and functions

| Name | Expands to |
|---|---|
| `ls`, `ll`, `la`, `lt`, `lta` | `eza` (or `Get-ChildItem` fallback) |
| `cat` | `bat` |
| `grep` | `rg` (or `Select-String`) |
| `vim`, `vi`, `v` | `nvim` |
| `nvimcfg` | `nvim ~/.config/nvim` |
| `g` | `git` |
| `gs`, `gd`, `gds` | `git status`, `diff`, `diff --staged` |
| `ga`, `gaa`, `gc`, `gcm` | `git add`, `add --all`, `commit`, `commit -m` |
| `gp`, `gpl`, `gb`, `gco`, `gcb`, `gl` | push, pull, branch, checkout, checkout -b, log |
| `lg` / `lzd` | `lazygit` / `lazydocker` |
| `j` | `just` |
| `d`, `dc`, `dcu`, `dcd`, `dps` | Docker helpers |
| `py`, `pyr`, `pip` | `uv run python`, `uv run`, `uv pip` |
| `which` | Show command type and source |
| `touch` | Create or update a file |
| `mkcd` | Create directory and cd into it |
| `reload` | Re-source the PowerShell profile |
| `serve` | Start `python -m http.server` (via `uv` when available) |

---

## zsh

Source: `dot_config/zsh/*.zsh`. Vi mode uses `jj` to leave insert mode.

### Keys

| Key | Action |
|---|---|
| `jj` | Leave insert mode (`zsh-vi-mode`) |
| `jk` | Escape bindkey |
| `Ctrl+r` | Atuin history search |
| `Ctrl+t` | fzf file picker |
| `Alt+c` | fzf directory jump |
| `Tab` | fzf-tab completion |
| `Ctrl+/` | Toggle preview in history picker |

### Common aliases

| Name | Expands to |
|---|---|
| `ls`, `ll`, `la`, `lt`, `lta` | `eza` listings |
| `l` | `ls -CF` |
| `cd` | `z` (zoxide) |
| `g`, `gs`, `gd`, `gds`, `ga`, `gaa`, `gc`, `gcm`, `gp`, `gpl` | Git helpers |
| `gb`, `gco`, `gcb`, `gl`, `glg`, `lg` | Branch, checkout, log, lazygit |
| `d`, `dc`, `dcu`, `dcd`, `dps` | Docker helpers |
| `v`, `vi`, `vim`, `nvimcfg` | Neovim |
| `t`, `ta`, `tl`, `tn`, `tk` | tmux helpers |
| `cat`, `grep`, `find` | `bat`, `rg`, `fd` |
| `py`, `pyi`, `pyr`, `pip`, `venv`, `venvrm` | uv/Python helpers |
| `n`, `nb`, `bunx` | Node/Bun |
| `da`, `dr`, `dst` | direnv |
| `ah`, `al`, `ast` | atuin |
| `j`, `jl` | just |
| `mp`, `arun` | mprocs, act |
| `lzd`, `dimg` | lazydocker, dive |
| `bench` | hyperfine warm benchmark |
| `reload` | Re-source `.zshrc` |

---

## fzf / Atuin

| Key | Action |
|---|---|
| `Ctrl+t` | Insert file path (fzf) |
| `Alt+c` | cd into a directory (fzf) |
| `Ctrl+r` | Atuin history search (overrides fzf history) |
| `Ctrl+/` | Toggle preview in Atuin history |

---

## Lazygit

Default lazygit keys; this repo does not remap them. `prefix+g` in Herdr opens it.

| Key | Action |
|---|---|
| `?` | Help |
| `q` | Quit |
| `j` / `k` | Move down / up |
| `h` / `l` | Previous / next panel |
| `Tab` | Next panel |
| `Enter` | Focus / confirm |
| `space` | Stage / unstage file |
| `a` | Stage all |
| `c` | Commit |
| `P` / `p` | Push / pull |
| `d` | Diff |
| `x` | Menu |
| `e` | Edit |
| `s` | Stash |
| `b` | Branches |
| `l` | Log |
| `R` | Refresh |

## Lazydocker

Default lazydocker keys; `prefix+shift+d` in Herdr opens it.

| Key | Action |
|---|---|
| `?` | Help |
| `[` / `]` | Previous / next panel |
| `j` / `k` | Move down / up |
| `Enter` | Focus |
| `r` | Restart container |
| `s` | Stop container |
| `d` | Remove container |
| `l` | Logs |
| `q` | Quit |

> Herdr's own built-in help is `prefix+?`; it lists the defaults not overridden
> in `config.toml`.

---

## Keeping this file accurate

- Neovim: `<leader>sk`, `:map`, `:verbose map <key>`.
- Herdr: `herdr config check` and the config comments.
- PowerShell: `Get-Alias` and `Get-Command`.
- zsh: `alias` and `bindkey`.

When a key changes, update the source config first, then this file.
