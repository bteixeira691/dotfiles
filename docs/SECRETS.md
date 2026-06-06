# =================== Secrets with chezmoi + age ===================

## One-time setup

```bash
# 1. Generate your age key pair
mkdir -p ~/.config/chezmoi
age-keygen -o ~/.config/chezmoi/key.txt
# This prints your public key (age1...). KEEP IT SAFE.

# 2. Back up key.txt somewhere secure (1Password, USB drive, etc.)
#    YOU CANNOT DECRYPT WITHOUT IT.

# 3. Add your public key to .chezmoi/chezmoi.toml.tmpl
#    Uncomment the [age] block and paste your public key.
```

## Add a secret

```bash
# Create or edit a file in private_*/ (anything starting with private_ is encrypted)
chezmoi edit --apply ~/dotfiles/private_dot_ssh/config
# ...write the secret...

# Or directly:
echo "API_TOKEN=secret" | chezmoi age encrypt --output ~/dotfiles/private_dot_secrets/api_token.age
```

## Common patterns

### SSH config (per-machine)
```bash
# Create private_dot_ssh/config
chezmoi edit --apply ~/dotfiles/private_dot_ssh/config
```

The `private_` prefix means chezmoi:
- Encrypts it with age before committing
- Never shows it in `chezmoi diff` without explicit flag

### GitHub tokens
```bash
mkdir -p ~/dotfiles/private_dot_config/gh
echo "github.com:\n  oauth_token: ghp_xxx" > ~/dotfiles/private_dot_config/gh/yml.tmpl
chezmoi encrypt ~/dotfiles/private_dot_config/gh/yml.tmpl
```

## Backup the key

```bash
# Print the public key (safe to share, identifies the recipient)
cat ~/.config/chezmoi/key.txt | age-keygen -y

# Print the private key (NEVER share, NEVER commit)
cat ~/.config/chezmoi/key.txt
```

## Decrypt on a new machine

Copy `key.txt` to `~/.config/chezmoi/` on the new machine. chezmoi will
automatically decrypt and apply the secret files when you run
`chezmoi apply`.

## Recover from a lost key

If you lose the key, you cannot decrypt the secrets. Plan ahead:
- Store key.txt in 1Password / Bitwarden / encrypted USB
- Print a paper copy in a safe
- Use a secret manager (1Password CLI) as the source of truth instead

## File-naming convention

chezmoi uses path prefixes to control encryption:
- `dot_*`        → symlink to `~/.*`  (NOT encrypted)
- `private_*`    → encrypted with age
- `*.tmpl`       → template (use Go templates for per-machine content)
- `*.age`        → pre-encrypted file

Examples:
```
dot_zshrc                       # ~/.zshrc (visible in diff)
dot_zshrc.tmpl                  # ~/.zshrc (rendered with variables)
private_dot_ssh/config          # ~/.ssh/config (encrypted, perms 600)
private_dot_netrc               # ~/.netrc (encrypted)
```

## Use on multiple machines

Each machine can have the same public key (so all machines can decrypt),
OR each machine can have its own key pair (you'd need to add the public
key from each machine to the chezmoi config as a recipient).

Easiest: one key, copied to all machines.
