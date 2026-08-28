# Security & privacy

This agent handles health data and has web access. Both matter. Here is
what is actually true about it — including the parts that are not solved.

## What this repo does not contain

No API keys, no bot tokens, no personal data. The agent files here are
templates; `PROFILE.md`, `PLAN.md`, `LOG.md` and `METRICS.md` ship empty.

`workspaces/` and `**/memory/` are gitignored, because a pulled workspace
contains the trainee's real training log, injuries, bodyweight, and
conversation history. **If you fork this, keep those ignore rules.**

Before your first push, check what you are about to publish:

```bash
git ls-files | xargs grep -lE 'sk-ant|[0-9]{8,10}:AA[A-Za-z0-9_-]{30,}'
```

Nothing should match.

## Where secrets actually live

In `openclaw.json` on the host — never in this repo, never mirrored to a
laptop. It holds the model API key and every bot token. Edit it in place
with `openclaw config patch`.

Storing them as environment references was considered and rejected: an
agent running as your user can read `/proc/self/environ` as easily as it
can read a file. The real control is the tool policy and the sandbox, not
the storage location.

If a token is ever exposed — pasted into a chat, committed, screenshotted —
revoke it with @BotFather and issue a new one. Rotation is cheap.

## The `rw` tradeoff — read this one

The coach needs `workspaceAccess: "rw"`, because a coach that cannot write
its own tracking files cannot track anything.

**The risk is real and documented.** The agent has web egress. A poisoned
page could in principle instruct it to rewrite its own `AGENTS.md`, and
that file loads on every future session — so a single bad fetch becomes
persistent. This is a known attack class, not a hypothetical.

**The mitigation is detection, not prevention:**

1. The workspace is a git repo (see `scripts/setup-agent.sh`), so any edit
   is diffable and revertable.
2. An hourly host cron job commits whatever changed:

   ```bash
   # crontab -e
   17 * * * * cd ~/.openclaw/workspace-<id> && git add -A && \
     git diff --cached --quiet || git commit -q -m "snapshot: $(date +%F-%H%M)"
   ```

3. `AGENTS.md` tells the agent to write only the four data files and
   `memory/`, and that its instruction files are the operator's.

**Any diff touching `AGENTS.md` or `SOUL.md` is a red flag.** Nothing
legitimate produces one — you author those yourself. Check with
`git log --oneline` and `git diff` in the workspace.

The better answer is `workspaceAccess: "rw-output"` — read-only
instructions plus a writable data subdirectory, which is the standard
pattern. It is proposed for OpenClaw but **not shipped**; the schema
currently accepts only `none | ro | rw`. Switch when it lands.

## Prompt injection is not solved

The sandbox limits blast radius. It does not prevent the hijack. The
`AGENTS.md` injection rules help and are not a guarantee. Treat anything
the agent read from the web as untrusted.

## Recommended posture

| Setting | Value | Why |
| :--- | :--- | :--- |
| `gateway.bind` | `loopback` | never expose the port; use a VPN/tunnel for remote access |
| `tools.elevated.enabled` | `false` | elevated lets `exec` escape the sandbox, making the tool policy decorative |
| `sandbox.mode` | `non-main` | every channel-originated session is containerised |
| `dmPolicy` | `allowlist` | most hostile input never arrives — this is the primary defence |
| `commands.ownerAllowFrom` | your ID only | talking to the bot ≠ being allowed to run `/config` |

Do not relax one of these without understanding what it was doing.

## Health data

This is not a medical device and the agent is told to say so. It refers out
for anything medical, never programs through pain, and for anyone under 18
it will not discuss body composition at all and escalates pain to a parent
rather than applying an adult wait-and-see window.

If you run this for someone else — especially a minor — that is their
health data on your server. Tell them what is stored and who can read it.

## Reporting

Found a problem? Open an issue. Don't include real tokens or personal data
in the report.
