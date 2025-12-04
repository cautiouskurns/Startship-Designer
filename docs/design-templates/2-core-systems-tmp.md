# Core Systems

**Living document. Update when systems change significantly.**

---

## System 1: Ship Design

### Overview
[1-2 paragraph explanation]

### Components
| Component | Size | Cost | Function |
|-----------|------|------|----------|
| Reactor | 4×4 | 4 | Generates 100 power |
| Relay | 2×2 | 3 | Distributes power in radius 3 |
| [etc] | | | |

### Rules
- [Rule 1]
- [Rule 2]
- [Rule 3]

### Power System
[How power routing works]
- Reactors generate power
- Relays distribute in radius
- Systems within radius are powered
- Damage breaks connections

**Detailed Spec:** See [features/implemented/ship-design-system.md]

---

## System 2: Combat

### Overview
[1-2 paragraph explanation]

### Turn Resolution
1. [Step 1]
2. [Step 2]
3. [Step 3]

### Damage Calculation
```
Base Damage = active_weapons × 10
Shield Absorption = active_shields × 15
Hull Damage = max(0, Base Damage - Shield Absorption)
Rooms Destroyed = Hull Damage / 20
```

### Targeting Strategies
- **RANDOM:** [How it works]
- **WEAPONS_FIRST:** [How it works]
- **POWER_FIRST:** [How it works]

**Detailed Spec:** See [features/implemented/combat-system.md]

---

## System 3: [Next System]

[Repeat pattern]

---

## System Interactions

### Power + Combat
- Unpowered weapons don't fire
- Damaged relays cut power to zones
- Power loss creates cascade failures

### [Other Interaction]
[How systems affect each other]

---

**This document explains HOW systems work. For WHY, see Game Overview.**