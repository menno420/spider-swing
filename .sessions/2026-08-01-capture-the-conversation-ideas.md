# Capture the session's undocumented ideas before they evaporate

> **Status:** `complete`

## Goal

The owner's final request of the day: scan the whole conversation and document
every genuinely new, valuable idea in a form he can review and act on with future
sessions. His framing — most of it he already knew, so losing it costs re-explaining
time rather than the idea itself. That makes this a **time-saving** task, and the
bar is completeness on the valuable subset, not volume.

## Scope guard

Documentation only. Five idea files plus the backlog index. No code, no physics,
no decisions taken on his behalf — every fork is recorded with a stated default.

## Previous-session review

**previous-session review:** the three cards before this one each ended with a
💡 idea that named a process lesson and left it in the card. That is the right
home for process lessons. It is the wrong home for **product** ideas, which is
why this session moved them into `docs/ideas/` where the lifecycle and the
frontmatter can score them.

## What was captured

Five interlocking files, all `state: routed`, `origin: owner`:

1. **`fairness-charter-2026-08-01.md`** — the highest-leverage item. Four
   published rules, with the Clash Royale mechanism (it was not greed, it was a
   **retroactive rule change**) and ShiftLife's `PRODUCT.md` precedent, where
   charter rule 4 forced a Pro feature to stay free. A draft is ready to lift;
   the wording is an owner fork.
2. **`live-content-and-events-2026-08-01.md`** — six typed event categories,
   twice a year each. Carries the economy finding: maxing costs ~21 minutes, so
   nothing is currently worth €1 to skip, which promotes **OQ-10 from a pacing
   question to a business-model one**. The arithmetic table is `assumed` and
   marked so.
3. **`competitive-layer-2026-08-01.md`** — narrow boards, seeded records, ghosts,
   downgradeable upgrades, per-spider campaign levels, milestones. Carries a ⚠
   determinism prerequisite.
4. **`distribution-and-first-contact-2026-08-01.md`** — the install funnel
   finding and three private routes that do not conflict with holding the launch.
5. **`player-feedback-loop-2026-08-01.md`** — reviews as a stated promise,
   phrased to survive scale; the curated voting slate; the summarisation trap.

All five linked from `docs/ideas/README.md` with a paragraph explaining how they
interlock and which to read first.

## The three findings inside them worth surfacing

- **Seeded records are a property already held, not a feature to add.**
  `CourseStream` derives every polygon, guide, fly and boost from chunk index
  plus course seed; the trace format records seed, upgrades, difficulty and
  preset and replays deterministically. Fixed track + ghost + leaderboard is
  the Trackmania shape, on mobile, where almost nothing else has it.
- **Downgradeable upgrades are a prerequisite, not a nice-to-have.** The
  "no upgrades" board is unreachable for a maxed player today, because
  progression is one-way.
- **The install funnel is probably eating the playtest signal.** Actions
  artifacts require a GitHub login. The one person who clearly got through gave
  by far the richest feedback — including real criticism, which is what proves
  the circle delivers honest negatives.

## What was deliberately NOT captured

Per the owner: *"no need to lock in everything I've told you since most of it
would only be noise."* Left out — his AI-subscription costs, the Steam joke-game
plan (different repo, and its only actionable notes are a per-title fee and
keeping a separate publisher identity), the estate history recap, and the whole
correction record of this session, which already lives in the three preceding
cards.

## Verification

`python3 tools/verify.py --require-godot` → exit 0, **184 contracts**.
`python3 bootstrap.py check --strict` → exit 0. Documentation only.

## Owner questions

None new as `OQ-` entries — deliberately. Every fork here (charter wording, which
event runs first, whether to verify the Play closed-test thresholds) is recorded
**inside its idea file with a stated default**, because these are not blocking
product forks; they are choices attached to work that has not started. Promoting
them to `owner-questions.md` before the work is real would be queue noise.

## 💡 Idea

**The ideas that survived this session are the ones that turned out to already
have infrastructure.** Seeded boards ride `CourseStream` determinism.
Verifiable records ride the trace format built for the lab. Downgradeable
upgrades ride a config already derived per-track at run start. Review triage
rides `idea-engine`/`sim-lab` per OD-10. None of that was built for these
purposes.

The generalisable habit: **before costing a new idea, check what already exists
for another reason.** Four of five files here changed from "large feature" to
"expose a property we already have" once the seam was found — and the finding
took minutes each. Worth proposing to substrate-kit as an intake step, since
`intake`'s MAP stage already maps ideas to *skills* and could equally map them
to *existing capabilities*.

## Next slice

Not mine. The owner reviews this list in the morning and may add to it. The
build queue is unchanged: **drive → 0 and the bird, one PR**, prompt ready in the
mechanics brief.

- **📊 Model:** opus-5 · high · idea/planning — capture the conversation's product ideas
