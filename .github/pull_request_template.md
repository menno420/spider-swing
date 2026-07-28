## What this changes

<!-- What behaviour or capability changed, in plain language. If this is agent
     work, say what scope you declared and confirm you finished it. -->

## Why

<!-- The problem, or the GDD/issue this serves. Link the issue if there is one. -->

## Scope check

- [ ] The change stays inside its declared scope — no opportunistic extras
- [ ] No gameplay system was built ahead of its phase gate (GDD § 23)
- [ ] No production credential, keystore, token, or store integration is added
- [ ] Inward dependency direction holds (ADR 0002) — nothing depends outward
- [ ] No new autoload singleton, or a new ADR justifies one (GDD § 19)

## Verification

Paste the real result. An honest failure is a deliverable; a claimed pass that
did not run is not.

```
$ python3 tools/verify.py

$ python3 bootstrap.py check --strict

```

## Documentation

- [ ] Docs that disagree with this change are corrected **in this PR** — source
      outranks stale prose (drift resolution)
- [ ] A genuine design change is recorded in the decision ledger, not just in the
      PR description
- [ ] Substrate living ledgers still reflect reality: `docs/current-state.md`,
      `docs/CAPABILITIES.md`, `control/status.md`
- [ ] Session card in `.sessions/` is present and flipped to `complete` as the
      deliberate last change

## Device testing

- [ ] Not applicable — this change cannot affect feel
- [ ] Needs an owner playtest on a real device (say what to look for)

## Owner action needed

<!-- Only where a capability was actually attempted and denied, with the exact
     error. Give exact click instructions. If none: "None." -->

None.
