# Health & safety disclaimer

**Read this before using clawcoach or giving it to anyone else.**

## This is not professional advice

clawcoach is a hobbyist software project that generates training
suggestions using a large language model. It is **not**:

- a licensed personal trainer, coach, physiotherapist, or physician
- a medical device, and it is not registered or approved as one by any
  regulator
- a substitute for professional medical, physiotherapy, nutritional, or
  strength-and-conditioning advice
- supervised by any qualified human who reviews what it tells you

Nothing it outputs is a diagnosis, a treatment, or a prescription.

## It can be wrong

It runs on a language model. Language models make confident, plausible,
incorrect statements. This one may:

- prescribe a load, volume, or progression that is wrong for you
- miss a contraindication, or fail to connect a symptom to an exercise
- misjudge an injury it was told about, or forget one it was not
- be manipulated by content it reads from the web (see
  [SECURITY.md](SECURITY.md) — prompt injection is not a solved problem)

The guardrails in `agent/AGENTS.md` and `agent/SOUL.md` reduce these
risks. **They do not eliminate them.** Do not treat them as a safety
certification.

## Your responsibility

By using this software, you accept that:

- **You use it entirely at your own risk.**
- **You are responsible for your own safety** — deciding whether an
  exercise is appropriate for you, using correct form, choosing loads,
  and stopping when something hurts.
- **You should consult a physician before starting any new exercise
  programme**, and especially if you have or suspect a heart condition,
  high blood pressure, diabetes, a joint or back problem, are pregnant,
  are recovering from injury or surgery, are taking medication that
  affects exercise capacity, or are otherwise unsure.
- **If it hurts, stop.** Pain is not something to push through, whatever
  the agent says. Sharp pain, chest pain, dizziness, shortness of breath,
  numbness, or fainting mean stop and seek medical attention.
- **The exercise demonstration links are YouTube searches**, pointing to
  third-party videos nobody here made, reviewed, or endorses.

## If you run it for someone else

Running clawcoach for a family member, a friend, or anyone else makes you
responsible for what you have set up:

- Show them this disclaimer. Do not let them assume a qualified human is
  behind it.
- Their training log, injuries, and bodyweight will be stored on your
  server. Tell them what is kept and who can read it.
- **For anyone under 18:** get a parent or guardian's informed consent.
  The agent refuses body-composition topics for minors and escalates pain
  to a parent rather than applying an adult wait-and-see window — but
  those rules are a floor, not adult supervision. A minor may treat an
  authoritative-sounding agent far more literally than an adult would.

## No warranty

This software is provided "as is", without warranty of any kind, express
or implied. The authors and copyright holders accept no liability for any
claim, damages, injury, or other liability arising from its use. See
[LICENSE](LICENSE).

## In short

It is a useful tool for organising and tracking your training. It is not
a professional, it is not supervising you, and it cannot see you. Use
your own judgement, and get a real professional involved when it matters.
