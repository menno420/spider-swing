# Chase the worst panel in the build, and find the instrument was wrong

> **Status:** `complete`

## Close-out

**Evidence:**

- measurement: real `FrontEndView` in a headless 1280×720 `SubViewport`, eight
  frames of layout, on the pinned `4.7.1.stable.official.a13da4feb`.
- contracts: one added and falsified twice — the Field Guide's section bodies
  must autowrap and expand horizontally, and the sections must sit in a real
  scroller. 219 → **220**.
- verify: **`python3 tools/verify.py --require-godot` — PASS, 220/220**.
  `bootstrap.py check --strict` passes.
- docs: `menu-ux-review-2026-08-02.md` § 2.5 correction and item 2 withdrawn.
- build: **not bumped.** Nothing player-visible changed — this session removed a
  backlog item and added a contract.

**The finding: the Field Guide is fine, and the audit's number was an artefact.**
The menu review listed the detail panel as **69 % empty**, the worst in the
build, and suspected something *"mis-wired between the sections and the panel"*.
It is not mis-wired. Re-measured:

| | detail panel | sections | used |
| --- | ---: | ---: | ---: |
| never shown *(what the audit measured)* | 1 723 px | 446 | 34 % |
| **rendered** | **583 px** | **500** | **110 %** |

Every section grows past its 104 px floor when the copy needs it — Real Animal
renders five wrapped lines at 158 px — and `get_visible_line_count()` equals
`get_line_count()` on all four. Nothing is clipped. The content *exceeds* its
401 px scroll viewport by a fifth, which is exactly what a detail panel with a
working scroller should do.

**The cause is the instrument, and it is worth more than the finding.** A
headless layout measurement of a screen that was **never displayed** reads
entirely plausible numbers off an unresolved layout — the panel reports 1 723 px
and the section bodies still hold empty text. Nothing errors. The numbers just
describe a screen nobody can see. Show the screen and settle the frames first.

**What I did not do, and why.** All five leftovers in the audit's § 4 open with
*"Each of these is a real product choice, not a contained technical one"*, and
the contrast item says outright that raising the border alpha changes the
material identity D-0044 chose, so **it is the owner's call whether the slate
look or the contrast floor wins**. Menno is asleep. I took the one item phrased
as a possible defect — *"something is mis-wired"* — because diagnosing a defect
is never a product decision, and stopped when the diagnosis came back clean.

**Per-region endless was also left alone deliberately.** Doctrine § 9 says it is
*"impossible to do well before `pressure(d)` exists"*, and `pressure(d)` is
Phase 2 while Phase 1 is the owner signing off. Building it now means either a
flat endless mode that never scales — which § 9 names as the wrong thing — or
inventing an unapproved curve.

**Next session should know:** the audit's backlog is now three items, all
owner-gated. The one genuinely free option recorded for Menno is that **Ancient
Forest could carry an endless mode today**, because its pool ladder
(control → mastery → deep at 10/20/35 km) is already distance-scaled and scoped
to that region alone — S5 predicted exactly this. It is still his call.

## 💡 Session idea

**A headless layout measurement needs a "was this actually laid out?" guard, and
it does not have one.** This repository now measures GUI geometry headlessly in
several places, and the failure mode found today is silent: an unshown screen
reports coherent-looking rectangles that describe nothing.

There is a cheap tell. An unlaid-out `_place`-anchored panel reported **1 723 px
of height inside a 720 px viewport** — a child taller than its viewport is a
contradiction no real layout produces. A shared helper that renders a screen,
settles frames, and then *asserts the root is not larger than the viewport*
before returning any measurement would have made today's 69 % impossible to
publish. That belongs beside the `SubViewport` pattern the layout tests already
use.

## ⟲ Previous-session review

The previous sessions in this run kept finding claims that had gone stale —
"the bot cannot pump" in seven documents, a 210-contract count, a superseded
difficulty verdict. This one found the same class of problem one level deeper:
a number that was **never right**, produced by a correct-looking method on an
unprepared subject, and then ranked second on a backlog.

**Workflow improvement:** every one of those was caught by *re-running the
measurement* rather than by re-reading the prose. The doc-trim session proposed
a `tools/check_doc_facts.py` for claims that can be diffed against source; this
adds the harder half — **a measured claim is only as good as the state the
instrument was pointed at**, so a measurement doc should record the *setup*
(here: was the screen shown?) as tightly as it records the method. The
course-audit baseline does this; the menu review did not, and that is precisely
where it went wrong.

- **📊 Model:** opus-5 · high · review/verify — Field Guide dead space withdrawn
