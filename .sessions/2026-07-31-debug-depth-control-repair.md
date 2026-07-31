# Debug depth control repair session

> **Status:** `in-progress`

## Goal

Reproduce the owner-reported device failures in `Start at exact distance` and
`Upgrade test level`, then repair their existing debug-only paths without
changing physics, balance, economy, ownership, or settlement architecture.

## Scope guard

UI-to-application wiring for the two depth controls, focused regression
contracts, required build identity if Android behavior changes, and close-out
documentation. The stable signer, real progression, tuning values, and normal
competitive flow remain unchanged.

## Previous-session review

**previous-session review:** PR #54 added the two controls with strong service
and persistence contracts, but the first owner device test reports that both
controls do not work properly. This session treats device behavior as the
finding to reproduce; passing lower-level contracts are not proof that the
actual touch-first interaction is usable.

## Planned verification

Exercise the real 1280×720 view and native input path under Godot 4.7.1, add a
contract that fails for the reproduced interaction, run the complete engine
suite and strict Substrate gate, then verify the exact Android artifact before
merge.

## 💡 Idea

Reserve the close-out idea until the shared failure mechanism is known; the most
valuable follow-up should come from the device/code mismatch rather than a guess.

- **📊 Model:** gpt-5 · high · bug fix
