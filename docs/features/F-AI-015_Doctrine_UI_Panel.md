# F-AI-015: Doctrine UI Panel

**Status:** 🔴 Planned
**Priority:** ⬆️ High
**Estimated Time:** 1 day
**Dependencies:** F-AI-003 (Basic Doctrine System)
**Phase:** 4 - Visual Feedback

---

## Purpose

**Why does this feature exist?**
Players need to understand active doctrines and ship profiles at a glance. A dedicated UI panel displays this information persistently during combat.

**What does it enable?**
Panel shows both ships' doctrines, archetypes, active traits, and current combat state. Players learn game systems through observation and make informed design decisions post-combat.

**Success criteria:**
- Panel displays accurate doctrine and archetype for both ships
- Panel updates when doctrine switches mid-combat
- Info presented clearly without cluttering combat view
- 85% of players reference panel to understand AI behavior

---

## How It Works

### Overview

A compact UI panel on the left side of screen showing:
- **Player Ship Section**: Archetype, doctrine, stat ratings, active traits
- **Enemy Ship Section**: Same information
- **Combat State Section**: Win probability, momentum, desperation level, turn count

Panel updates dynamically as combat progresses.

### Layout

```
┌──────────────────────────┐
│ PLAYER: Glass Cannon    │
│ Doctrine: Alpha Strike  │
│ Traits: [🗡️Aggressive]  │
│ Stats: O:80 D:20 S:60   │
├──────────────────────────┤
│ ENEMY: Turtle            │
│ Doctrine: Defensive      │
│ Traits: [🛡️Defensive]    │
│ Stats: O:40 D:80 S:30    │
├──────────────────────────┤
│ Turn: 4 | Win: 65%       │
│ Momentum: ⬆️ GAINING      │
└──────────────────────────┘
```

**Position**: Left side, 300px wide, 400px tall
**Colors**: Player info in blue header, enemy in red, state in yellow

---

## Technical Implementation

**New Scene: `scripts/ui/DoctrinePanel.tscn`**
- Panel container with 3 sections (player, enemy, state)
- Labels for archetype, doctrine, traits, stats
- Auto-updates via signals from Combat.gd

### Data Displayed

1. **Ship Info**:
   - Archetype name (e.g., "Glass Cannon")
   - Doctrine name (e.g., "Alpha Strike")
   - Active traits (icons or short names)
   - Stat ratings: Offense, Defense, Speed (0-100%)

2. **Combat State**:
   - Turn number
   - Win probability percentage
   - Momentum indicator (↑/↓/→)
   - Desperation level (if applicable)

---

## Acceptance Criteria

- [ ] Panel displays correct archetype and doctrine for both ships
- [ ] Panel updates when doctrine switches mid-combat
- [ ] Panel shows current turn, win probability, momentum
- [ ] Panel readable and non-intrusive (doesn't block combat view)
- [ ] Stat ratings match ShipProfile calculations

---

## Implementation Notes

**Performance**: Static UI updates, minimal overhead.
**Design Philosophy**: Information-dense but scannable. Players glance, not stare.

---

## Change Log

| Date | Change | Reason |
|------|--------|--------|
| Dec 10 2025 | Initial spec | Feature planned |
