# Simulation lab v2 — adaptive bot session

> **Status:** `in-progress`

## Goal

Make the lab's player model adapt to the configuration it is handed — so
upgrade comparisons measure the tuning, not a bot's stale habits — and add
the instrumentation Menno's monetization/consumable direction needs: reel
usage styles, defensive save-Bursts, pull-death and rescue-distance metrics,
fly earn rate, and a parameter sweep mode for grid tuning.

## Scope guard

This session may change `tools/simulate.gd`, its documentation, the decision
ledger (recording the owner's money-as-grind-skip direction), and living-doc
pointers. It must not change any gameplay value, simulation rule, contract,
build identity, save schema, or CI gate. The declared suite remains 91
contracts; the lab stays diagnostic, never a gate.

## About to happen

Derive the bot's Reel reserve and Burst aim from the resolved config, add
`--reel-style` / `--save-bursts` / `--sweep`, extend metrics, re-run the
level-0 vs maxed-upgrade comparison with the adaptive bot, verify both gates
on pinned Godot 4.7.1, then open the PR.

## Previous-session review

**previous-session review:** PR #41 landed the simulation lab v1 green on
both gates; its first findings (skill scaling, Springtail's shell visible in
statistics, the never-emptying Reel meter, the maxed-upgrade regression for
an unadapting bot) directly shaped this session's scope. Menno confirmed the
Reel meter should become a managed resource and asked for upgrade-adaptive
simulation. PR #44 (Anchorite sprite) moved main under this branch; the
branch was restarted from the new head per the merged-PR rule.
