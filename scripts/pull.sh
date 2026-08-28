#!/usr/bin/env bash
# Pull an agent workspace from your OpenClaw host -> local.
# Read-only on the server.
#
#   export OPENCLAW_HOST=user@yourhost
#   ./pull.sh <agent-id>
set -euo pipefail

HOST="${OPENCLAW_HOST:-}"
if [[ -z "$HOST" ]]; then
  echo "error: set OPENCLAW_HOST first, e.g. export OPENCLAW_HOST=user@host" >&2
  exit 1
fi

AGENT_ID="${1:-}"
[[ -z "$AGENT_ID" ]] && { echo "usage: ./pull.sh <agent-id>" >&2; exit 1; }

EXCL=(--exclude '.git' --exclude 'openclaw-workspace-state.json')
DST="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/workspaces/$AGENT_ID"
mkdir -p "$DST"

rsync -av "${EXCL[@]}" -e ssh "$HOST:~/.openclaw/workspace-$AGENT_ID/" "$DST/"
echo "Pulled to $DST"
echo
echo "NOTE: pulled files may contain the trainee's personal health data."
echo "      workspaces/ is gitignored. Keep it that way."
