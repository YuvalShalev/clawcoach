#!/usr/bin/env bash
# Create a new coach agent on an OpenClaw host.
# Run this ON the OpenClaw server, not from your laptop.
set -euo pipefail

AGENT_ID="${1:-}"
if [[ -z "$AGENT_ID" ]]; then
  echo "usage: $0 <agent-id>       e.g. $0 coach-sam" >&2
  exit 1
fi
if ! [[ "$AGENT_ID" =~ ^[a-z0-9][a-z0-9-]*$ ]]; then
  echo "error: agent id must be lowercase alphanumeric with dashes" >&2
  exit 1
fi

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OPENCLAW_HOME="${OPENCLAW_HOME:-$HOME/.openclaw}"
WORKSPACE="$OPENCLAW_HOME/workspace-$AGENT_ID"
AGENT_DIR="$OPENCLAW_HOME/agents/$AGENT_ID/agent"

if [[ -e "$WORKSPACE" ]]; then
  echo "error: $WORKSPACE already exists - refusing to overwrite" >&2
  exit 1
fi

echo "==> creating workspace $WORKSPACE"
mkdir -p "$WORKSPACE" "$AGENT_DIR"
cp "$REPO_ROOT/agent/"*.md "$WORKSPACE/"

echo "==> initialising git (so bad edits are recoverable)"
git -C "$WORKSPACE" init -q
git -C "$WORKSPACE" add -A
git -C "$WORKSPACE" commit -q -m "initial: coach agent files" || true

cat <<EOF

Workspace ready: $WORKSPACE

Remaining steps (not automated - they need YOUR secrets):

  1. Create a Telegram bot with @BotFather, get the token.
  2. Verify the token BEFORE putting it in config:
       curl -s "https://api.telegram.org/bot<TOKEN>/getMe"
     Expect "ok":true and the right username. 401 = revoked, 404 = malformed.
  3. Get the trainee's numeric Telegram ID from @userinfobot.
  4. Add the agent + channel to openclaw.json with:
       openclaw config patch --stdin --dry-run   (then again without --dry-run)
     See docs/SETUP.md for the exact JSON.

  WARNING: agents.list is an ARRAY - patching it REPLACES the whole list.
  Always write out every existing agent, not just the new one.

  5. openclaw gateway restart

EOF
