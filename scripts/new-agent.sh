#!/usr/bin/env bash
# new-agent — scaffold a new subagent from the template
# Usage: new-agent [flags] <agent-name> [description]
#
# Examples:
#   new-agent backend-engineer "Senior backend engineer for Node/Python/Go"
#   new-agent code-reviewer --read-only
#   new-agent frontend-engineer --no-write
#   new-agent data-engineer --full
#
# Creates:
#   ~/.config/opencode/agents/<name>.md
#
# Edit the file, then run `opencode` — the agent is now usable.

set -euo pipefail

OPENCODE_DIR="${OPENCODE_DIR:-$HOME/.config/opencode}"
AGENTS_DIR="$OPENCODE_DIR/agents"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

usage() {
  cat <<'EOF'
Usage: new-agent [flags] <agent-name> [description]

Arguments:
  agent-name      kebab-case agent name (e.g. "backend-engineer")
  description     one-line description (default: prompts)

Options:
  -h, --help      show this help
  --read-only     read+grep+glob only (deny edit/write/bash)
  --no-write      allow read+edit+bash, deny write
  --full          allow everything (default)
  -d, --dir       override the dotfiles directory (default: ~/dotfiles)

Permission presets:
  read-only       edit: deny, write: deny, bash: deny
  no-write        write: deny
  full            (default) all allow

Examples:
  new-agent backend-engineer
  new-agent code-reviewer --read-only
  new-agent data-engineer --full
  new-agent my-role "Custom role description"
EOF
}

if [[ $# -eq 0 ]] || [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
  usage
  exit 0
fi

# Parse flags first (flags and positional args can be in any order)
PRESET="full"
POSITIONAL=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --read-only) PRESET="read-only"; shift ;;
    --no-write)  PRESET="no-write"; shift ;;
    --full)      PRESET="full"; shift ;;
    -d|--dir)    DOTFILES_DIR="$2"; shift 2 ;;
    -h|--help)   usage; exit 0 ;;
    -*) echo "Unknown flag: $1"; usage; exit 1 ;;
    *)           POSITIONAL+=("$1"); shift ;;
  esac
done

if [[ ${#POSITIONAL[@]} -lt 1 ]]; then
  echo "Error: agent-name is required"
  usage
  exit 1
fi

set -- "${POSITIONAL[@]}"

# Now positional args
if [[ $# -lt 1 ]]; then
  echo "Error: agent-name is required"
  usage
  exit 1
fi

AGENT_NAME="$1"
DESCRIPTION="${2:-}"

if [[ -z "$DESCRIPTION" ]]; then
  echo -n "One-line description for '$AGENT_NAME': "
  read -r DESCRIPTION || true
fi

if [[ -z "$DESCRIPTION" ]]; then
  echo "Error: description is required"
  exit 1
fi

# Permission values per preset
# (OpenCode permission keys: read, edit, glob, grep, list, bash, task,
#  external_directory, todowrite, webfetch, websearch, lsp, skill, question)
case "$PRESET" in
  read-only)
    EDIT="deny"; BASH="deny" ;;
  no-write)
    EDIT="deny"; BASH="allow" ;;
  full)
    EDIT="allow"; BASH="allow" ;;
esac

# Compute paths
AGENT_FILE="$AGENTS_DIR/$AGENT_NAME.md"

# Check if it already exists
if [[ -f "$AGENT_FILE" ]]; then
  echo "Error: agent already exists: $AGENT_FILE"
  echo "  Edit it directly, or remove it first."
  exit 1
fi

# Find the template
TEMPLATE="$DOTFILES_DIR/templates/AGENT.md.tmpl"
if [[ ! -f "$TEMPLATE" ]]; then
  echo "Error: template not found: $TEMPLATE"
  echo "  Make sure the dotfiles repo is at $DOTFILES_DIR"
  exit 1
fi

# Compute title-case from name
AGENT_TITLE=$(echo "$AGENT_NAME" | awk -F'[-_/]' '{ for (i=1; i<=NF; i++) $i = toupper(substr($i,1,1)) substr($i,2) } 1' OFS=' ')
AGENT_ROLE=$(echo "$AGENT_NAME" | tr '-' ' ')

# Create the directory
mkdir -p "$AGENTS_DIR"

# Render the template
sed \
  -e "s|{{AGENT_NAME}}|$AGENT_NAME|g" \
  -e "s|{{AGENT_DESCRIPTION}}|$DESCRIPTION|g" \
  -e "s|{{AGENT_TITLE}}|$AGENT_TITLE|g" \
  -e "s|{{AGENT_ROLE}}|$AGENT_ROLE|g" \
  -e "s|{{EDIT}}|$EDIT|g" \
  -e "s|{{BASH}}|$BASH|g" \
  "$TEMPLATE" > "$AGENT_FILE"

echo ""
echo "✓ Created agent: $AGENT_NAME"
echo "  File:     $AGENT_FILE"
echo "  Preset:   $PRESET (edit=$EDIT, bash=$BASH)"
echo ""
echo "Next steps:"
echo "  1. Edit $AGENT_FILE with the actual content"
echo "  2. Update ~/.config/opencode/config.json to reference the agent"
echo "     (or it can be auto-discovered by name)"
echo "  3. Restart opencode to pick up the new agent"
