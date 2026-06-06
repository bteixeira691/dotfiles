#!/usr/bin/env bash
# new-skill — scaffold a new skill from the template
# Usage: new-skill <skill-name> [description]
#
# Examples:
#   new-skill auth-patterns
#   new-skill "booking-domain" "Core scheduling and booking domain logic"
#   new-skill agent-browser/core
#   new-skill auth-patterns --alt
#
# Creates:
#   ~/.agents/skills/<name>/SKILL.md  (or .opencode/skills/<name>/SKILL.md with --alt)
#   Updates ~/.config/opencode/skills-lock.json with the new entry
#
# Edit the file, then run `opencode` — the skill is now usable.

set -euo pipefail

OPENCODE_DIR="${OPENCODE_DIR:-$HOME/.config/opencode}"
SKILLS_DIR="${SKILLS_DIR:-$HOME/.agents/skills}"
ALT_SKILLS_DIR="$HOME/.opencode/skills"
LOCK_FILE="$OPENCODE_DIR/skills-lock.json"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

usage() {
  cat <<'EOF'
Usage: new-skill [--alt] [--license MIT] [--dir <path>] <skill-name> [description]

Arguments:
  skill-name      kebab-case skill name (e.g. "auth-patterns", "booking-domain")
                  Use "/" for hierarchical skills (e.g. "agent-browser/core")
  description     one-line description (default: prompts)

Options:
  -h, --help      show this help
  -a, --alt       install to ~/.opencode/skills/ instead of ~/.agents/skills/
  -l, --license   license string (default: MIT)
  -d, --dir       override the dotfiles directory (default: ~/dotfiles)

Examples:
  new-skill auth-patterns
  new-skill "booking-domain" "Core scheduling and booking domain logic"
  new-skill agent-browser/slack
  new-skill my-skill "desc" --alt --license Apache-2.0
EOF
}

if [[ $# -eq 0 ]] || [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
  usage
  exit 0
fi

# Parse flags first (flags and positional args can be in any order)
ALT=false
LICENSE="MIT"
POSITIONAL=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    -a|--alt) ALT=true; shift ;;
    -l|--license) LICENSE="$2"; shift 2 ;;
    -d|--dir) DOTFILES_DIR="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    -*) echo "Unknown flag: $1"; usage; exit 1 ;;
    *)  POSITIONAL+=("$1"); shift ;;
  esac
done

if [[ ${#POSITIONAL[@]} -lt 1 ]]; then
  echo "Error: skill-name is required"
  usage
  exit 1
fi

set -- "${POSITIONAL[@]}"

SKILL_NAME="$1"
DESCRIPTION="${2:-}"

if [[ -z "$DESCRIPTION" ]]; then
  echo -n "One-line description for '$SKILL_NAME': "
  read -r DESCRIPTION || true
fi

if [[ -z "$DESCRIPTION" ]]; then
  echo "Error: description is required"
  exit 1
fi

# Pick skills dir
if [[ "$ALT" == true ]]; then
  SKILLS_DIR="$ALT_SKILLS_DIR"
fi

# Compute paths
SKILL_DIR="$SKILLS_DIR/$SKILL_NAME"
SKILL_FILE="$SKILL_DIR/SKILL.md"

# Check if it already exists
if [[ -f "$SKILL_FILE" ]]; then
  echo "Error: skill already exists: $SKILL_FILE"
  echo "  Edit it directly, or remove it first."
  exit 1
fi

# Find the template
TEMPLATE="$DOTFILES_DIR/templates/SKILL.md.tmpl"
if [[ ! -f "$TEMPLATE" ]]; then
  echo "Error: template not found: $TEMPLATE"
  echo "  Make sure the dotfiles repo is at $DOTFILES_DIR"
  exit 1
fi

# Compute title-case from name (kebab-case → Title Case)
SKILL_TITLE=$(echo "$SKILL_NAME" | awk -F'[-_/]' '{ for (i=1; i<=NF; i++) $i = toupper(substr($i,1,1)) substr($i,2) } 1' OFS=' ')

# Create the directory
mkdir -p "$SKILL_DIR"

# Render the template
sed \
  -e "s|{{SKILL_NAME}}|$SKILL_NAME|g" \
  -e "s|{{SKILL_DESCRIPTION}}|$DESCRIPTION|g" \
  -e "s|{{SKILL_TITLE}}|$SKILL_TITLE|g" \
  -e "s|{{SKILL_INTRO}}|Describe the skill here. When should the agent use it? What does it teach? (Edit this section.)|g" \
  "$TEMPLATE" > "$SKILL_FILE"

# Compute hash
HASH=$(sha256sum "$SKILL_FILE" | awk '{print $1}')

# Update skills-lock.json
mkdir -p "$OPENCODE_DIR"
if [[ ! -f "$LOCK_FILE" ]]; then
  cat > "$LOCK_FILE" <<'EOF'
{
  "version": 1,
  "schema": "https://opencode.ai/skills-lock.schema.json",
  "skills": {}
}
EOF
fi

# Use python for safe JSON manipulation
python3 - "$LOCK_FILE" "$SKILL_NAME" "$DESCRIPTION" "$HASH" "$SKILL_FILE" "$LICENSE" <<'PYEOF'
import json, sys
from datetime import datetime, timezone
from pathlib import Path

lock_file, name, desc, hash_, path, license_ = sys.argv[1:7]
data = json.loads(Path(lock_file).read_text())
data.setdefault("skills", {})[name] = {
    "source": "local",
    "sourceType": "local",
    "skillPath": path,
    "computedHash": hash_,
    "installedAt": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
    "version": "0.1.0",
    "description": desc,
    "license": license_,
}
Path(lock_file).write_text(json.dumps(data, indent=2) + "\n")
print(f"  → updated {lock_file}")
PYEOF

echo ""
echo "✓ Created skill: $SKILL_NAME"
echo "  File:    $SKILL_FILE"
echo "  Lock:    $LOCK_FILE"
echo "  Hash:    $HASH"
echo ""
echo "Next steps:"
echo "  1. Edit $SKILL_FILE with the actual content"
echo "  2. The skill is auto-available in opencode sessions"
echo "  3. To share it: copy the file to a git repo and update the lock entry"
