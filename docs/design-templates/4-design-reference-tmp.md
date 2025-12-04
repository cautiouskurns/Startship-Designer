# Design Reference

**Quick reference for design decisions, rules, and parameters.**
**Update when values change during tuning.**

---

## Core Design Pillars

### 1. Engineering Fantasy Over Piloting
**What it means:** Player is aerospace engineer, not starship captain
**How we enforce it:**
- Auto-resolved combat (no manual control)
- Success through layout optimization
- Transparent systems (no hidden mechanics)

**Test:** If feature requires twitch skills or manual combat control → CUT

### 2. Meaningful Spatial Decisions
**What it means:** WHERE you place things matters as much as WHAT you place
**How we enforce it:**
- Power routing creates optimization puzzle
- Room adjacency affects synergies
- Multi-tile rooms create Tetris constraints
- Shaped hulls add placement challenges

**Test:** If placement is arbitrary (doesn't affect outcome) → REDESIGN

### 3. Clear Feedback Through Simplicity
**What it means:** Player always knows why they won/lost
**How we enforce it:**
- Transparent combat math (no RNG, no hidden rolls)
- Visual power connections
- Combat replay system
- Post-battle analysis

**Test:** If player says "I don't know why I lost" → ADD FEEDBACK

---

## Inviolable Design Rules

These NEVER change. Breaking them breaks the game.

1. **All combat math must be transparent** (no hidden RNG)
2. **Rooms must be rectangular** (for Tetris puzzle clarity)
3. **Budget must force trade-offs** (can't afford everything)
4. **Power must be visible** (routing is part of puzzle)
5. **Iteration loop must be <2 minutes** (fast testing)
6. **Failure must be explainable** (replay shows causality)

---

## Balance Parameters

### Room Costs (Budget Points)
```gdscript
const ROOM_COSTS = {
    BRIDGE: 5,
    WEAPON: 2,
    SHIELD: 3,
    ENGINE: 3,
    REACTOR: 4,
    ARMOR: 1,
    CONDUIT: 1,
    RELAY: 3,
    # Add new rooms here
}
```

### Combat Math
```gdscript
# Base values
const BASE_WEAPON_DAMAGE = 10
const BASE_SHIELD_ABSORPTION = 15
const BASE_HULL_HP = 60
const ARMOR_HP_BONUS = 20
const DAMAGE_PER_ROOM_DESTROYED = 20

# Damage calculation
func calculate_damage(attacker, defender):
    var base_damage = attacker.active_weapons * BASE_WEAPON_DAMAGE
    var shield_absorption = defender.active_shields * BASE_SHIELD_ABSORPTION
    var hull_damage = max(0, base_damage - shield_absorption)
    var rooms_destroyed = int(hull_damage / DAMAGE_PER_ROOM_DESTROYED)
    return {damage: hull_damage, rooms: rooms_destroyed}
```

### Synergy Bonuses
```gdscript
const SYNERGIES = {
    "WEAPON_WEAPON": {bonus_type: "FIRE_RATE", multiplier: 1.2},  # +20%
    "SHIELD_REACTOR": {bonus_type: "SHIELD_CAP", multiplier: 1.3}, # +30%
    "ENGINE_ENGINE": {bonus_type: "INITIATIVE", bonus: 2},         # +2 turns
    "WEAPON_ARMOR": {bonus_type: "DURABILITY", hits: 2},           # 2 hits to destroy
}
```

### Power System
```gdscript
const REACTOR_OUTPUT = 100  # power units
const RELAY_COVERAGE_RADIUS = 3  # tiles
const CONDUIT_EXTENDS = true  # conduits extend range
```

### Mission Budgets
```gdscript
const MISSION_BUDGETS = {
    1: 50,  # Tutorial - generous
    2: 25,  # Challenge - tight
    3: 30,  # Boss - moderate
    # Expand as missions added
}
```

---

## Tuning Guidelines

### When Enemy Too Easy:
1. Increase enemy HP (+20 per step)
2. Add more enemy weapons (+1 per step)
3. Give enemy better targeting (RANDOM → WEAPONS_FIRST)
4. Reduce player budget (-5 per step)

### When Enemy Too Hard:
1. Decrease enemy HP (-20 per step)
2. Remove enemy weapons (-1 per step)
3. Give enemy worse targeting (POWER_FIRST → RANDOM)
4. Increase player budget (+5 per step)

### When Feature Feels Tedious:
1. Can it be automated? (e.g., auto-routing)
2. Can placement be faster? (e.g., click-drag)
3. Can visual feedback be clearer?
4. Is it actually necessary? (scope cut?)

---

## Testing Checklist

Before marking ANY feature complete:

**Clarity Test:**
- [ ] Can I explain this to a new player in <30 seconds?
- [ ] Is the visual feedback clear?
- [ ] Do error messages make sense?

**Depth Test:**
- [ ] Does this create meaningful decisions?
- [ ] Is there an optimal strategy, or multiple valid approaches?
- [ ] Will players want to optimize this?

**Fun Test:**
- [ ] Is this satisfying to use?
- [ ] Does it feel tedious or exciting?
- [ ] Would I play this if it wasn't my game?

**Technical Test:**
- [ ] Can I balance it with JSON tweaks? (no code changes)
- [ ] Does it perform well? (60 FPS)
- [ ] Is it saved/loaded correctly?

---

## Common Pitfalls to Avoid

1. **Adding complexity without depth**
   - More systems ≠ more fun
   - Only add if creates meaningful decisions

2. **Breaking the fast iteration loop**
   - Don't add tedious manual steps
   - Keep design → test cycle under 2 minutes

3. **Obscuring cause and effect**
   - If player doesn't understand why they lost, add feedback
   - Transparency > realism

4. **Scope creep via "wouldn't it be cool if..."**
   - Every feature has cost
   - Stay focused on core loop

---

## Out of Scope (Don't Add These)

| Feature | Why Not |
|---------|---------|
| Crew management | Too complex for MVP, breaks fast iteration |
| Real-time combat | Against core pillar (auto-battle is intentional) |
| Multiplayer | Scope explosion, infrastructure cost |
| Procedural ship generation | Player creativity is the point |
| Meta-progression unlocks | Save for post-launch, adds grind |
| Story/narrative | Not core to engineering fantasy |

---

**When in doubt, ask: "Does this make the core loop better?"**
**If no → cut it.**