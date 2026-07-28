# Phase 0.9 burst web independence session

> **Status:** `in-progress`

## Goal

Make one physical world tap produce exactly one authoritative gameplay intent on
Android, so a recovery web attached during Burst cannot be immediately released
by Godot's emulated mouse copy of the same touchscreen event.

## Previous-session review

**previous-session review:** PR #14 correctly separated ordinary web control from
the pull cooldown inside application and simulation state. The next real-device
recording shows that the adapter still delivers one touchscreen press twice,
which turns the accepted recovery attach into an immediate manual release.
