# Headless simulation lab session

> **Status:** `in-progress`

## Goal

Answer Menno's automated-testing request with a working tool: a headless
batch-run simulation lab that drives the authoritative simulation with an
imperfect scripted player and reports distance, death-cause, and resource
metrics — so balance changes can be compared in seconds before spending an
owner device playtest.

## Scope guard

This session may add `tools/simulate.gd`, its documentation, and living-doc
pointers. It must not change any gameplay value, simulation rule, test
contract, build identity, save schema, or CI gate. The declared suite remains
91 contracts; the lab is diagnostic instrumentation, never a third gate.

## About to happen

Build the lab on the reviewed `SimulationWorld`/`CourseStream` seam, prove it
discriminates skill tiers, spider profiles, and upgrade levels in this
container on pinned Godot 4.7.1, run both gates, then open the PR.

## Previous-session review

**previous-session review:** PR #40 (Reel speed playtest correction) merged
cleanly: level-zero Balanced Reel now 320 px/s over the 2.0-second meter, max
Garden Silk Winder 416 px/s inside the owner-tested band, all 91 contracts
green and the Android artifact verified. Its remaining owner review — whether
320/416 px/s reads as arc control on device — is untouched by this session.
