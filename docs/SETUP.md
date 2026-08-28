# Setup

Adding a coach agent to an existing OpenClaw host. Roughly 15 minutes.

## Prerequisites

- A working OpenClaw gateway.
- The Docker sandbox image built (see [Sandbox](#sandbox) below).
- SSH access to the host.

## 1. Create the workspace

On the OpenClaw host:

```bash
git clone https://github.com/YuvalShalev/clawcoach.git
cd clawcoach
./scripts/setup-agent.sh coach-sam
```

This creates `~/.openclaw/workspace-coach-sam`, copies the agent files in,
and puts it under git so a bad edit is recoverable.

## 2. Create the Telegram bot

Talk to [@BotFather](https://t.me/BotFather) → `/newbot` → copy the token.

**Verify the token before it touches config:**

```bash
curl -s "https://api.telegram.org/bot<TOKEN>/getMe"
```

Expect `"ok":true` and the username you just chose.

| Response | Meaning |
| :--- | :--- |
| `"ok":true` | good |
| `401 Unauthorized` | revoked or wrong token |
| `404` | malformed — usually truncated on paste, or a placeholder left in |

Skipping this check turns a one-second problem into a long log hunt. A bad
token shows up as `[account] starting provider` with **no username in
brackets**, plus a storm of 404s. Success looks like
`[coach-sam] starting provider (@your_bot_name)`.

## 3. Get the trainee's Telegram ID

They message [@userinfobot](https://t.me/userinfobot); it replies with a
numeric ID. You need this for the allowlist — without it, anyone who finds
the bot can talk to it.

## 4. Wire it into config

⚠️ **`agents.list` is an array, and arrays REPLACE on patch.** Read the
current list first and write it back out in full, or you will delete your
other agents.

```bash
openclaw config get agents.list
```

Then patch — **always `--dry-run` first**:

```bash
openclaw config patch --stdin --dry-run <<'JSON'
{
  "agents": {
    "list": [
      { "id": "main", "default": true },
      { "id": "coach-sam",
        "name": "Coach",
        "workspace": "/home/YOUR_USER/.openclaw/workspace-coach-sam",
        "agentDir": "/home/YOUR_USER/.openclaw/agents/coach-sam/agent",
        "model": "anthropic/claude-sonnet-5",
        "sandbox": { "workspaceAccess": "rw" } }
    ]
  }
}
JSON
```

Re-run without `--dry-run` once it validates.

⚠️ **Never share an `agentDir` between agents** — it causes auth and
session collisions.

### Why `workspaceAccess: "rw"`

The coach's whole method is "read PROFILE.md and the last few LOG.md
entries before prescribing." Under `ro` it can't write any of them, so it
re-runs intake from scratch every session — it will hand out a four-week
block one night and have no idea it exists the next morning.

`ro` is not a safety setting here; it is a broken setting. See
[SECURITY.md](../SECURITY.md) for what that costs and how to mitigate it.

## 5. Restart

```bash
openclaw gateway restart
openclaw gateway status     # expect: running, probe ok
```

Message the bot. It should start intake with the age question.

## Sandbox

Channel-originated sessions run in Docker. Without the image, **every
message fails** with "Something went wrong."

```bash
git clone --depth 1 https://github.com/openclaw/openclaw.git ~/openclaw
sudo apt install -y docker-buildx     # docker.io ships without buildx
bash ~/openclaw/scripts/sandbox-setup.sh
docker images | grep openclaw-sandbox
```

If you just added yourself to the `docker` group, **reboot**. `usermod -aG`
only affects new logins, and the systemd *user* manager that spawns the
gateway keeps its old group set — restarting the gateway is not enough.

## Tools

The coach needs these; grant no more:

```
group:fs        read, write, edit, apply_patch
group:runtime   exec, process, code_execution
group:web       web_fetch, web_search, x_search
group:messaging message
cron            (bare tool id — see below)
```

Deny `gateway` explicitly.

Tool groups are all-or-nothing, but **bare tool ids also work** — an entry
that isn't a known group passes through as a tool id. This matters:
`group:automation` bundles `cron` + `gateway` + `heartbeat_respond`, so
granting scheduling via the group would also hand the agent control of the
gateway that sandboxes it. Grant `cron` alone and deny `gateway`; `deny`
beats `allow` in the resolver.

⚠️ `allow` is an array too — it replaces. Write the full list.

## Scheduling

The agent can create its own reminders once it has `cron` — just ask it in
chat. From the CLI:

```bash
openclaw cron add "0 12 * * 1,4,5" --name coach-midday --agent coach-sam \
  --tz "America/Toronto" --channel telegram --to <TELEGRAM_ID> --announce \
  --message "Training day. Today's session:"
```

The command is `cron`, not `automations` — `openclaw automations` does not
exist.

⚠️ For non-default agents, cron jobs must use `sessionTarget: "isolated"`
with `payload.kind: "agentTurn"`. `"main"` is rejected with
`INVALID_REQUEST`.

Prefer `--session-key agent:<id>:telegram:direct:<TELEGRAM_ID>` so the job
lands in the same thread the trainee already uses.

One-shot jobs with `deleteAfterRun: true` vanish from `cron list` after
firing — an empty list does not mean nothing ran. Check the logs.

## When things break

```bash
openclaw logs --follow      # then reproduce; beats guessing
openclaw doctor
openclaw config schema | jq '.properties.agents'
```

The schema ships inside the binary and cannot drift. Published docs can and
do — trust the schema.
