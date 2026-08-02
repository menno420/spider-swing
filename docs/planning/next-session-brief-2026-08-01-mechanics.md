# Earned speed and the bird — brief, executed 2026-08-02

> **Status:** `reference`
>
> ## ✅ Executed — this is a record, not an entry point
>
> The work this brief specified shipped in `0.26.0-earned-speed-bird-playtest`
> and has been iterated on since (the speed cap got its own curve in 0.34.0).
> **Do not take work from this document.** The design it argued for is now the
> binding spec,
> [`../game-design/earned-speed-and-the-bird.md`](../game-design/earned-speed-and-the-bird.md);
> what remains undecided is in [`../owner-questions.md`](../owner-questions.md)
> as OQ-13 … OQ-16.
>
> Its slice prompts, coupling-site checklists and measurement instructions have
> been removed — they described work that is done, and the durable rules in them
> now live in [`../technical/testing.md`](../technical/testing.md).

## Why it exists — the owner's words

The redirect that produced this brief, verbatim:

> *"I think right now the visuals are not the most important part anymore
> especially since the first 10K visuals are essentially done. One visual thing
> that does need to be done properly right now is the creation of the bird, and
> one that actually moves in a bird like way, follows the spiders position and
> moves at a slightly increasing speed."*

> *"For the game mechanics: the important thing right now is that the speed at
> which the spider travels also increases overtime, which should probably happen
> in a player controlled way by upgrades, swing control, reel and burst timing
> etc. So the game still increases in difficulty through speed just in a
> different way."*

One visual job and one mechanical job. Both shipped: continuous drive is zero,
speed is earned from release quality, swing control, Reel and pull timing, and
the former invisible left kill line is a four-pose pursuing bird.

## Three mistakes this brief made, kept because they are the useful part

**1 · "One slice, one green PR" was wrong here, and it cost a day.** The rule
was withdrawn the same day it was written. It imported the superseded handoff's
*device-verdict-between-slices* rhythm into headless work where that premise no
longer held, and it delivered the owner a mechanic he could not test instead of
the two things he asked for. What replaces it: **ship a testable whole, and keep
the parts separable by debug tunables rather than by separate PRs.** That is why
the bird ships with OFF/SLOW/BASE/FAST presets and direct speed, acceleration
and gap controls on Test Run — separability lives in the build, not in the
branch structure.

**2 · The build order was right; the verification order was not.** Slice 1
(earned release quality) shipped while the drive was still on, and OQ-16 asks
whether that release *feels* rewarding. It could not have felt rewarding then:
the drive only fires *below* `target_speed`, so a good release landed in an
untouched band and survived on drag — but a bad release cost nothing, because
the floor rebuilt at 470 px/s. The good-versus-bad contrast was a fraction of
what it becomes without the drive, and the award's own ceiling
(`target_speed_at(d) + maximum_horizontal_overspeed`) sat *inside* the owner's
playing band for the first kilometre. **Asking for the verdict then would have
tested the mechanic in the one configuration engineered to make it feel weak,
and a weak verdict would have sent someone tuning a value that was not at
fault.** Generalised: before requesting a feel verdict, check that the shipped
configuration can express the thing being judged.

**3 · "The bot cannot pump" is superseded as a justification.** The brief
repeatedly justified *never tune the bird from a bot run* with that phrase. The
blind spot closed on 2026-08-02 — model v4 pumps (`pump_window_deg`). **The rule
is unchanged and the reason has moved:** v4 still runs 26 m/s below the
reference curve in the band where the owner sustains 78.6 m/s, and still gets
the upgrade sign wrong. See
[`../measurements/2026-08-02-bot-model-v4-pumping.md`](../measurements/2026-08-02-bot-model-v4-pumping.md)
and the standing ban in
[`../technical/simulation-lab.md`](../technical/simulation-lab.md).
