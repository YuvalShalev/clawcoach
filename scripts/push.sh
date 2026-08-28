#!/usr/bin/env bash
# Push local agent workspace edits -> your OpenClaw host.
# DEFAULT IS A DRY RUN. Pass --apply to actually write.
#
#   export OPENCLAW_HOST=user@yourhost
#   ./push.sh <agent-id> [--apply]
set -euo pipefail

HOST="${OPENCLAW_HOST:-}"
if [[ -z "$HOST" ]]; then
  echo "error: set OPENCLAW_HOST first, e.g. export OPENCLAW_HOST=user@host" >&2
  exit 1
fi

AGENT_ID="${1:-}"
[[ -z "$AGENT_ID" || "$AGENT_ID" == --* ]] && { echo "usage: ./push.sh <agent-id> [--apply]" >&2; exit 1; }

MODE="--dry-run"
BANNER="DRY RUN (no changes written) - pass --apply to write"
for a in "$@"; do [ "$a" = "--apply" ] && { MODE=""; BANNER="APPLYING CHANGES"; }; done

# Never push state, git metadata, or the agent's own memory writes.
EXCL=(--exclude '.git' --exclude 'openclaw-workspace-state.json' --exclude 'memory/')

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/workspaces/$AGENT_ID"
[[ -d "$SRC" ]] || { echo "error: no local workspace at $SRC" >&2; exit 1; }

echo "== $BANNER =="
# No --delete: never remove files on the server.
rsync -av $MODE "${EXCL[@]}" -e ssh "$SRC/" "$HOST:~/.openclaw/workspace-$AGENT_ID/"

if [ -n "$MODE" ]; then
  echo; echo "Dry run only. Re-run with --apply to write."
else
  echo; echo "Pushed. For a clean reload: ssh $HOST 'openclaw gateway restart'"
fi
