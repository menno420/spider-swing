# Upgrade breakthrough clarity session

> **Status:** `in-progress`

## Goal

Explain the real level 5/10/15/20 bonus in the Shop: each breakthrough purchase applies its track's listed per-step increase twice, without changing upgrade values, progression, saves, or swing behavior.

## Scope guard

This session may change centralized Shop copy, its front-end regression contract, development build identity, and living verification documentation. It must not change `SpiderCatalog.effective_steps()`, any per-step tuning value, upgrade costs, save schema, the frozen GDD, or unrelated gameplay and interface systems.

## Previous-session review

**previous-session review:** PR #34 corrected Balanced Flow's reversed wording. Menno's follow-up exposed the broader clarity gap: every card names a “breakthrough” and a future level, but never explains that the milestone adds one bonus tuning step and therefore applies the listed increase twice.

## About to happen

Open one ready implementation PR, add compact globally consistent breakthrough wording at both Shop-header and card level, prove levels 4/5/20 render the correct rule, build the Android artifact, then complete this card and remove the claim only after all evidence is green.

## 💡 Idea

Label the four existing silk knots `5`, `10`, `15`, and `20` in a later
presentation-only pass so each filled knot maps visibly to its earned level
without adding a tooltip or another touch target.

- **📊 Model:** gpt-5 · high · interface clarification
