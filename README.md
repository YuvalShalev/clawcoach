# clawcoach

**Your own strength coach — in the app you already have open.**

It writes your programme, texts you when it's time to train, and rebuilds
next week around what you actually lifted this week. Miss a session and it
adjusts. Hit every rep at RPE 6 and it adds weight. Tell it your shoulder
hurts and it swaps the movement — then remembers, permanently.

No app to install. No subscription. No feed. Just a coach that messages
you first, built on [OpenClaw](https://github.com/openclaw/openclaw) and
running on hardware you own — your training data never leaves it.

> ### ⚠️ Not professional advice
>
> clawcoach is a hobby project driven by a language model. It is **not** a
> trainer, physiotherapist, or doctor, it is **not** a medical device, and
> it is **no substitute for professional advice**. It can be confidently
> wrong.
>
> **You use it entirely at your own risk and are responsible for your own
> safety.** Consult a physician before starting any exercise programme.
> If it hurts, stop.
>
> Read [DISCLAIMER.md](DISCLAIMER.md) in full before using it — and
> especially before setting it up for someone else.

```
you                          coach
─────────────────────────────────────────────────────────
                             12:00  Training day. Day A:
                               DB Floor Press  3x8 @ 15lb  RPE 7
                               DB Row          3x8 @ 20lb  RPE 7
                               Band Pull-Apart 3x15
                               Bike 20 min easy

done, floor press felt
easy at 15

                             Logged. Floor press → 17.5lb Friday.
                             e1RM up 4% in two weeks.
```

## Why this beats asking a chatbot about fitness

A chatbot waits for you. This one comes looking.

- **It chases you.** It schedules its own check-ins and fires them
  whether or not you feel like training. That's the entire difference
  between a programme and a good intention.
- **It builds on your actual numbers.** Every session is logged. It reads
  your recent history before prescribing anything, so week 4 is a
  response to weeks 1–3 — not a fresh guess that happens to look similar.
- **It does the maths.** Estimated 1RM, volume load, weekly training
  load — computed in code, not eyeballed. It will tell you your e1RM rose
  4% before you'd have noticed.
- **It programs like a coach, not a search result.** Progressive
  overload, RPE/RIR-based loading, deloads, WHO/ACSM cardio baselines —
  and it cites its source when new evidence changes your programme.
- **It respects your time.** Numbers over adjectives. No pep talks, no
  "Great question!", no restating what you just said. Most messages are
  under eight lines.

## Guardrails

Not optional extras — they are the reason this is safe to hand to a
family member.

- Never programs through pain. Soreness is fine; pain is a stop.
- Never invents a number. If it doesn't have the data, it asks.
- Refers out for anything medical — plainly, one line, no hedging.
- **Under 18:** body composition is off the table entirely, and pain means
  stop and tell a parent — not the adult 12-week referral window.
- Never pushes weight loss unless the trainee raises it first.

## Prerequisites

This is a coach agent **for** OpenClaw — it does not install OpenClaw.
Before anything here works you need:

1. **A running OpenClaw gateway** on a machine you control (a spare
   laptop or small server is plenty). Check with `openclaw gateway
   status` — expect `running` and `probe ok`.
2. **A model API key** configured in OpenClaw, e.g. Anthropic. The coach
   is a normal agent; it uses whatever model your gateway is set up with.
3. **The Docker sandbox image built.** Channel-originated sessions run
   sandboxed, and without the image **every message fails** with
   "Something went wrong":

   ```bash
   git clone --depth 1 https://github.com/openclaw/openclaw.git ~/openclaw
   sudo apt install -y docker-buildx     # docker.io ships without buildx
   bash ~/openclaw/scripts/sandbox-setup.sh
   docker images | grep openclaw-sandbox
   ```

   If you just added yourself to the `docker` group, **reboot** — the
   systemd user manager that spawns the gateway keeps its old group set,
   and restarting the gateway is not enough.
4. **A Telegram account** for whoever will use the coach, and the ability
   to create a bot via [@BotFather](https://t.me/BotFather).
5. **SSH access** to the host, since setup runs there.

You do *not* need a public IP or an open port. Keep the gateway on
loopback and reach it over a VPN or tunnel — see [SECURITY.md](SECURITY.md).

## Quick start

```bash
git clone https://github.com/YuvalShalev/clawcoach.git
cd clawcoach
./scripts/setup-agent.sh coach-sam      # run on your OpenClaw host
```

That creates the workspace, copies the agent files in, and puts it under
git so a bad edit is recoverable. It is the only automated step.

The remaining three need your own secrets, so they are deliberately
manual — a script taking a bot token as an argument would leave it in
shell history:

1. Create the Telegram bot and **verify the token before it touches
   config**: `curl -s "https://api.telegram.org/bot<TOKEN>/getMe"`
2. Get the trainee's numeric Telegram ID from
   [@userinfobot](https://t.me/userinfobot) — this is the allowlist, and
   without it anyone who finds your bot can talk to it.
3. Add the agent to `openclaw.json` with `openclaw config patch`, then
   `openclaw gateway restart`.

⚠️ `agents.list` is an array, and **arrays replace on patch** — read your
current list and write it back in full, or you will delete your other
agents.

[docs/SETUP.md](docs/SETUP.md) has the exact JSON and the mistakes worth
avoiding. Budget about 15 minutes.

## Layout

```
agent/          the coach itself — AGENTS.md is the control surface
  AGENTS.md     method: intake, programming, logging, review
  SOUL.md       personality and hard limits
  PROFILE.md    ─┐
  PLAN.md        │ empty templates; the agent fills these in
  LOG.md         │
  METRICS.md    ─┘
scripts/        setup-agent.sh, push.sh, pull.sh
docs/SETUP.md   installation, tools, scheduling, troubleshooting
SECURITY.md     the tradeoffs, honestly — including the unsolved ones
DISCLAIMER.md   health & safety — read before running it for anyone
```

## Adding a second person

One agent per person — `LOG.md` holds one training history, so two people
cannot share a workspace. Each needs their own bot, workspace, and
Telegram ID.

The agent files are **identical for everyone**. Age is data, not method:
intake records it in `PROFILE.md` and the under-18 rules key off that. No
per-person forks to maintain.

## Tuning it

`agent/AGENTS.md` is the control surface. When behaviour is wrong, edit
that file and restart the gateway. Expect iterations — most of what is in
there now came from watching it get something wrong.

## Security

It handles health data and has web access. Read
[SECURITY.md](SECURITY.md) before running it for someone else — it
documents the `rw` workspace tradeoff and what prompt injection can still
do.

For health and safety, and what you take on by setting this up for
another person, see [DISCLAIMER.md](DISCLAIMER.md).

## Status

Running daily against a real training block. The agent files are stable;
the setup scripts are lightly tested outside their original host.

## License

MIT
