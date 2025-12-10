# Ship Design Enhancements

**Status:** 💡 Ideation
**Priority:** ⬆️ High (Core Gameplay Loop)
**Estimated Time:** TBD (varies by feature)
**Dependencies:** Existing ship designer system
**Goal:** Make ship design more delightful with obvious visual tradeoffs and constant interesting decisions

---

## Problem Statement

**Current State:**
- Ship design works but feels mechanical
- Tradeoffs exist but aren't visually obvious
- Players don't get immediate feedback on their design choices
- Limited ways to express creativity or strategy

**Desired State:**
- Every placement decision feels meaningful
- Visual feedback constantly shows tradeoffs (glass cannon vs turtle)
- Players experiment because they can SEE the consequences
- Multiple viable strategies with distinct visual identities

**Success Criteria:**
- Players say "oh that's cool!" when placing rooms
- Design phase takes 2-3 minutes (up from 60 seconds) because players are experimenting
- Players can identify their ship's strategy at a glance
- Winning feels earned through smart design choices

---

## Enhancement Ideas

### 🔥 **1. Heat & Power Flow Visualization**

**Priority:** Medium | **Complexity:** Medium | **Impact:** High

#### Concept
Reactors generate heat that spreads to adjacent rooms. Heat affects performance with both benefits and drawbacks.

#### Visual Design
- **Cold rooms:** Blue glow (normal performance)
- **Warm rooms:** Yellow glow (bonus performance, minor risk)
- **Hot rooms:** Red/orange glow (major bonus, high risk)
- **Power lines:** Pulse speed increases with heat
- **Particles:** Steam/heat shimmer effects on hot rooms

#### Game Mechanics
```
Heat Level | Effect
-----------|-------
Cold (0-2) | Normal operation
Warm (3-4) | +10% performance
Hot (5-6)  | +20% performance, 10% failure chance per turn
Critical(7+)| +30% performance, 30% failure + damage

Room-Specific Effects:
- Hot Weapon: +20% damage, -10% accuracy
- Hot Shield: +15% absorption, drains 2x faster
- Hot Engine: +1 initiative, 15% chance to stall
- Hot Reactor: Powers 6 tiles instead of 4, explodes if hit
```

#### Design Tradeoffs
- **Single reactor:** Efficient (low cost) but hot (risky)
- **Multiple reactors:** Cool (safe) but expensive
- **Clustered layout:** Compact but heat compounds
- **Spread layout:** Cooler but harder to power everything

#### Implementation Notes
- Add `heat_level` property to each room
- Heat spreads from reactors: adjacent = +2, diagonal = +1
- Heat accumulates from multiple sources
- Visual shader for heat glow (lerp between blue → yellow → red)
- Add "Heat Map" toggle button in designer UI

---

### 💎 **2. Room Adjacency Synergies**

**Priority:** High | **Complexity:** Low | **Impact:** Very High

#### Concept
Certain room combinations grant bonuses when placed adjacent to each other. Visual effects clearly show active synergies.

#### Visual Design
- **Connection lines:** Glowing lines between synergized rooms
  - Gold: Offensive synergy
  - Blue: Defensive synergy
  - Green: Utility synergy
- **Floating stat icons:** "+15% DMG" appears above synergized weapons
- **Room shimmer:** Gentle pulse animation on synergized rooms
- **Preview mode:** When dragging a room, potential synergies highlight in green

#### Synergy Table
```
Room A      | Room B      | Effect                    | Visual
------------|-------------|---------------------------|--------
Weapon      | Reactor     | +15% damage               | Gold line
Weapon      | Weapon      | +10% volley damage        | Orange line
Shield      | Shield      | +20% capacity             | Blue line
Shield      | Armor       | +25% effective HP         | Cyan line
Engine      | Engine      | First strike guaranteed   | Yellow line
Bridge      | Any         | +5% to adjacent room      | White line
Reactor     | Reactor     | Powers 6 tiles each       | Red line
Armor       | Armor       | +30% damage reduction     | Gray line
Weapon      | Bridge      | +10% accuracy             | Gold line
Engine      | Reactor     | +15% power efficiency     | Green line
```

#### Design Tradeoffs
- **Clustering for synergy:** High rewards but vulnerable to area damage
- **Spreading for safety:** Survives longer but weaker individual performance
- **Bridge placement:** Central = more synergies, but exposed
- **Weapon clustering:** Devastating alpha strike, but lose all if one section destroyed

#### Implementation Notes
- Add `adjacent_synergies` dictionary to Room class
- Check adjacencies after every room placement
- Draw Line2D nodes for active synergies
- Add Label nodes for floating stat bonuses
- Store synergy multipliers in `RoomData.gd`

---

### 🎯 **3. Damage Zones & Vulnerability**

**Priority:** High | **Complexity:** Low | **Impact:** High

#### Concept
Show players which grid sections enemies will target during design phase. Makes placement decisions tactical.

#### Visual Design
- **Zone overlays:** Semi-transparent colored rectangles
  - Red: High danger (top 2 rows) - 70% of attacks target here
  - Yellow: Medium danger (middle 2 rows) - 20% of attacks
  - Green: Low danger (bottom 2 rows) - 10% of attacks
- **Warning icons:** ⚠️ appears on rooms in danger zones
- **Toggle button:** "Show Threat Map" in designer UI
- **Predicted damage:** "This room will be hit ~3 times" tooltip

#### Targeting Logic
```
Enemy Weapon Targeting Priority:
1. Weapons (if in top half) - 40% chance
2. Bridge (always) - 20% chance
3. Shields (if powered) - 15% chance
4. Random powered room - 15% chance
5. Random any room - 10% chance

Zone Modifiers:
- Top 2 rows: 2x targeting weight
- Middle 2 rows: 1x targeting weight
- Bottom 2 rows: 0.5x targeting weight
```

#### Design Tradeoffs
- **Weapons in front (top):** Maximum damage output, but fragile
- **Weapons protected (bottom):** Survive longer, but penalties:
  - Weapons in bottom 2 rows: -20% damage
  - "Poor firing angle" tooltip
- **Shields in front:** Absorb first hits, protect weapons behind
- **Critical systems hidden:** Reactor/Bridge in back = safer but space-inefficient

#### Implementation Notes
- Add `ThreatMapOverlay` UI node
- ColorRect zones with adjustable opacity
- Calculate "expected hits per battle" stat per room
- Display in tooltip: "70% chance to be hit this battle"
- Add toggle button in top-right of designer

---

### 🔧 **4. Room Variants (Same Type, Different Stats)**

**Priority:** Medium | **Complexity:** High | **Impact:** Very High

#### Concept
Each room type has 2-4 variants with different stats, sizes, and tradeoffs. Dramatically increases build variety.

#### Visual Design
- **Different sprites:** Each variant has unique appearance
  - Heavy: Chunky, armored look
  - Light: Sleek, minimal design
  - Balanced: Standard military aesthetic
- **Color-coded borders:**
  - Red border: Offensive variant
  - Blue border: Defensive variant
  - Green border: Utility variant
- **Size differences:** Some variants are 2×1, L-shaped, etc.
- **Comparison tooltip:** Hover shows stat bars vs other variants

#### Weapon Variants
```
1. LIGHT LASER (2 pts, 1×1)
   - Damage: 8
   - Fire rate: Fast (every turn)
   - Accuracy: 95%
   - Power: 1
   - Visual: Thin blue beam emitter

2. HEAVY CANNON (4 pts, 2×1)
   - Damage: 25
   - Fire rate: Slow (every 3 turns)
   - Accuracy: 70%
   - Power: 2
   - Visual: Large barrel with ammo drums

3. MISSILE BAY (3 pts, 1×1)
   - Damage: 30 (ignores 50% shields)
   - Fire rate: Very slow (every 4 turns)
   - Accuracy: 85%
   - Power: 1
   - Visual: Missile racks

4. BEAM ARRAY (3 pts, 1×1)
   - Damage: 12
   - Fire rate: Normal (every 2 turns)
   - Accuracy: 100%
   - Special: Hits 2 random rooms
   - Power: 2
   - Visual: Crystal array
```

#### Shield Variants
```
1. ABLATIVE ARMOR (2 pts, 1×1)
   - Capacity: 100
   - Recharge: None (one-time use)
   - Damage reduction: 100%
   - Visual: Thick plating

2. ENERGY SHIELD (3 pts, 1×1)
   - Capacity: 50
   - Recharge: 10 per turn
   - Damage reduction: 100%
   - Visual: Blue force field

3. HARDLIGHT SHIELD (4 pts, 1×1)
   - Capacity: 30
   - Recharge: 15 per turn
   - Damage reduction: 100%
   - Special: Reflects 10% damage
   - Visual: Crystalline barrier

4. PHASE SHIELD (3 pts, 1×1)
   - Capacity: 40
   - Recharge: 5 per turn
   - Special: 30% chance to dodge attack entirely
   - Visual: Shimmering distortion
```

#### Engine Variants
```
1. SPRINT DRIVE (3 pts, 1×1)
   - Initiative: +3
   - Dodge: 0%
   - Special: First strike if no engine tie
   - Visual: High-thrust nozzles

2. EVASION DRIVE (2 pts, 1×1)
   - Initiative: +1
   - Dodge: 20%
   - Visual: Maneuvering thrusters

3. WARP CORE (4 pts, 2×1)
   - Initiative: +2
   - Special: Jump away at 25% HP (auto-win)
   - Visual: Glowing core
```

#### Reactor Variants
```
1. STANDARD REACTOR (2 pts, 1×1)
   - Powers: 4 adjacent tiles
   - Heat: Normal
   - Visual: Basic power core

2. FUSION CORE (3 pts, 1×1)
   - Powers: 6 adjacent tiles (orthogonal + diagonal)
   - Heat: High (+2 heat to adjacent)
   - Visual: Bright glowing sphere

3. COLD FUSION (4 pts, 1×1)
   - Powers: 4 adjacent tiles
   - Heat: None
   - Special: Adjacent rooms never overheat
   - Visual: Blue crystal core
```

#### Design Tradeoffs
- **Cost vs Power:** Heavy variants cost more but perform better
- **Size vs Flexibility:** 2×1 rooms are powerful but hard to place
- **Specialization vs Versatility:** Extreme variants vs balanced
- **Early vs Late game:** Cheap light weapons get you started, heavy weapons win late battles

#### Implementation Notes
- Extend `RoomData` to support variants
- Add `variant_type` enum
- New sprites for each variant (major art investment)
- Update placement system to handle non-1×1 rooms
- Add "Variant Select" panel when clicking room type in palette
- Comparison tooltip system

---

### 📊 **5. Live Ship Profile Visualization**

**Priority:** High | **Complexity:** Low | **Impact:** Very High

#### Concept
Real-time radar chart showing ship's stats as player designs. Instantly reveals if build is balanced or specialized.

#### Visual Design
- **Location:** Right side of screen, always visible
- **Radar Chart:** Pentagon with 5 axes
  - Offense (0-100)
  - Defense (0-100)
  - Speed (0-100)
  - Durability (0-100)
  - Efficiency (0-100)
- **Archetype Label:** Large text showing build type
- **Color coding:**
  - Balanced: Green
  - Specialized: Yellow
  - Extreme: Red (with warnings)

#### Layout
```
┌─ SHIP PROFILE ──────────────────┐
│                                  │
│        Offense                   │
│          /|\                     │
│         / | \                    │
│    Speed  |  Defense             │
│         \ | /                    │
│          \|/                     │
│      Durability                  │
│                                  │
│  Archetype: GLASS CANNON         │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│  Offense:    ████████░░  80%    │
│  Defense:    ██░░░░░░░░  20%    │
│  Speed:      ████░░░░░░  40%    │
│  Durability: ███░░░░░░░  30%    │
│  Efficiency: ██████░░░░  60%    │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│  ⚠️ CRITICAL WEAKNESSES:        │
│  • Low armor (only 1 room)      │
│  • No shield regeneration       │
│  • Vulnerable to long battles   │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│  PREDICTED PERFORMANCE:          │
│  ✓ Fast decisive battles         │
│  ✗ Attrition warfare             │
│  ✗ Multi-phase encounters        │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│  vs Scout:     85% win chance    │
│  vs Raider:    45% win chance    │
│  vs Dreadnought: 15% win chance  │
└──────────────────────────────────┘
```

#### Stat Calculations
```gdscript
# Offense: Damage output potential
offense = (weapon_count * avg_weapon_damage) / max_possible_damage

# Defense: Damage mitigation
defense = (shield_capacity + (armor_count * 20)) / max_possible_defense

# Speed: Turn order and dodge
speed = (engine_count * 20 + dodge_chance * 100) / max_possible_speed

# Durability: Total HP pool
durability = (base_hull + armor_bonus) / max_possible_hull

# Efficiency: Power usage vs generation
efficiency = powered_rooms / total_rooms
```

#### Archetype Detection
```
GLASS CANNON:    Offense ≥ 70%, Defense ≤ 30%
TURTLE:          Defense ≥ 70%, Offense ≤ 40%
SPEEDSTER:       Speed ≥ 70%, Durability ≤ 40%
BALANCED:        All stats 40-60%
JUGGERNAUT:      Durability ≥ 70%, Speed ≤ 30%
ALPHA STRIKER:   Offense ≥ 80%, Speed ≥ 60%
LAST STAND:      Durability ≥ 80%, Defense ≥ 70%
GUERRILLA:       Speed ≥ 70%, Efficiency ≥ 60%
```

#### Implementation Notes
- Add `ShipProfilePanel.gd` script
- Use Polygon2D for radar chart
- Recalculate stats on every room placement/removal
- Emit `profile_changed` signal
- Add AI analysis text generation
- Win chance calculations based on stat comparison

---

### 🧩 **6. Negative Space Design (Room Shape Tetris)**

**Priority:** Low | **Complexity:** Very High | **Impact:** Medium

#### Concept
Rooms come in different shapes (like Tetris pieces). Efficient packing = bonuses.

#### Visual Design
- **Varied shapes:** L-pieces, T-pieces, 2×1 rectangles, etc.
- **Ghost preview:** Shows rotation options while dragging
- **Efficiency meter:** Green bar showing "Space utilization: 85%"
- **Compact bonus:** Golden glow around ship when no gaps

#### Room Shapes
```
WEAPON:
- 1×1 (standard)
- 2×1 (heavy, horizontal)
- L-shape (turret)

SHIELD:
- 1×1 (standard)
- 2×2 (capital shield)

ENGINE:
- 1×1 (standard)
- 1×2 (thruster array)

REACTOR:
- 1×1 (standard)
- 2×2 (core, powers 8 adjacent)

ARMOR:
- 1×1 (plate)
- Tetris L, T, Z shapes (structural reinforcement)
```

#### Bonuses
```
100% fill (no gaps): +15% all stats
90-99% fill: +10% all stats
80-89% fill: +5% all stats
<80% fill: No bonus, "Inefficient design" warning
```

#### Implementation Notes
- Major refactor of grid placement system
- Add rotation controls (Q/E keys)
- Collision detection for non-rectangular shapes
- Calculate fill percentage
- Very art-intensive (new sprites for all shapes)

---

### ⚡ **7. Overload Mechanic (Risk/Reward Toggle)**

**Priority:** Medium | **Complexity:** Low | **Impact:** Medium

#### Concept
Right-click any room to toggle "Overload Mode" - massive bonus with explosive risk.

#### Visual Design
- **Overloaded state:** Red caution stripes, electrical sparks
- **Preview tooltip:** "⚡ OVERLOADED: +50% output, 30% failure chance"
- **Pulsing red border:** Danger indicator
- **Sparks particle effect:** Continuous electrical discharge

#### Overload Effects
```
OVERLOADED WEAPON:
+50% damage
-20% accuracy
30% chance to explode after firing (destroys room)

OVERLOADED SHIELD:
+100% capacity
Doesn't recharge
50% chance to fail catastrophically when depleted

OVERLOADED ENGINE:
+3 initiative (guaranteed first strike)
50% chance to fail (go last instead)
25% chance to explode at battle start

OVERLOADED REACTOR:
Powers 8 tiles (orthogonal + diagonal)
Explodes if hit (destroys adjacent rooms too)

OVERLOADED ARMOR:
+50 HP
If destroyed, ship takes +50 additional damage

OVERLOADED BRIDGE:
All rooms +10% performance
If bridge destroyed, instant loss (no last stand)
```

#### Design Tradeoffs
- **All-in strategy:** Overload everything for massive power, pray you win fast
- **Surgical overload:** Only overload 1-2 key rooms
- **Safe play:** No overloads, consistent performance
- **Calculated risk:** Overload protected rooms (in back, behind armor)

#### Implementation Notes
- Add `is_overloaded` boolean to Room class
- Right-click handler on room tiles
- Visual shader for sparking effect
- Roll failure chance at combat start/during battle
- Warning popup: "Are you sure? This room may explode!"

---

### 🎨 **8. Visual "Ship Personality" Feedback**

**Priority:** Low | **Complexity:** Medium | **Impact:** Low

#### Concept
Ship's visual style changes based on loadout. Reinforces archetype identity.

#### Visual Transformations
```
WEAPON-HEAVY (4+ weapons):
- Red accent lights
- Aggressive forward-leaning stance
- Weapon barrels glow
- Targeting reticles appear

SHIELD-HEAVY (4+ shields):
- Blue shimmering force field overlay
- Defensive "hunched" posture
- Shield emitters glow
- Protective aura effect

ENGINE-HEAVY (4+ engines):
- Speed trail particles
- Forward-leaning dynamic pose
- Engine glow intensifies
- Motion blur effect

ARMOR-HEAVY (5+ armor):
- Gray/silver metallic sheen
- Bulky reinforced appearance
- Rivets and plating details
- "Tank" feel

BALANCED:
- Clean military aesthetic
- Neutral posture
- Professional, no flashiness
```

#### Additional Feedback
```
Predicted Outcome Display:
┌─────────────────────────┐
│ COMBAT PREDICTIONS      │
├─────────────────────────┤
│ vs Scout:               │
│   Win Chance: 75%       │
│   Avg Battle Length: 4  │
│   Survival Odds: 85%    │
├─────────────────────────┤
│ Risk Assessment:        │
│   ⚠️⚠️⚠️ EXTREME       │
│   "Glass cannon build"  │
│   "Won't survive hits"  │
├─────────────────────────┤
│ Estimated Longevity:    │
│   3.5 battles until     │
│   catastrophic damage   │
└─────────────────────────┘
```

#### Implementation Notes
- Add post-processing shader effects
- Ship sprite color modulation
- Particle systems for auras/trails
- AI-generated analysis text
- Combat simulation for predictions

---

### 🔢 **9. Budget Pressure System (Mission Constraints)**

**Priority:** Medium | **Complexity:** Low | **Impact:** High

#### Concept
Missions impose unique constraints beyond simple point budget, forcing creative solutions.

#### Mission Constraint Types
```
MISSION 1: "Fast Attack"
- Budget: 20 points
- Required: 3+ engines
- Enemy: Fast scout ship
- Constraint visual: Speed icon overlay

MISSION 2: "Siege Warfare"
- Budget: 30 points
- Required: Battle lasts 10+ turns
- Constraint: Need regenerating shields OR 8+ armor
- Enemy: Fortified position
- Constraint visual: Clock icon

MISSION 3: "Ambush"
- Budget: 25 points
- Constraint: Enemy shoots first (you go last turn 1)
- Required: Survive first strike
- Enemy: Alpha strike specialist
- Constraint visual: Shield icon

MISSION 4: "Attrition"
- Budget: 30 points
- Constraint: No reactor repairs between waves
- Required: Fight 3 enemies in sequence
- Constraint visual: Battery icon

MISSION 5: "Asteroid Field"
- Budget: 28 points
- Constraint: Left side of ship takes 10 damage at start
- Required: Critical systems protected
- Constraint visual: Hazard overlay on left

MISSION 6: "EMP Strike"
- Budget: 30 points
- Constraint: All reactors shut down turn 3-5
- Required: Backup power OR battery systems
- Enemy: EMP corvette
- Constraint visual: Lightning icon

MISSION 7: "Close Quarters"
- Budget: 25 points
- Constraint: Only 4×4 grid (not 8×6)
- Enemy: Small but deadly
- Constraint visual: Reduced grid

MISSION 8: "Overheating"
- Budget: 30 points
- Constraint: All rooms gain +2 heat per turn
- Required: Heat management strategy
- Constraint visual: Thermometer icon
```

#### Visual Design
- **Constraint icons:** Large icon in corner showing active constraint
- **Grid overlays:** Visual indicators on restricted areas
- **Warning text:** "⚠️ This mission requires 3+ engines"
- **Preview simulation:** "With current build: FAIL (dies turn 2)"

#### Implementation Notes
- Add `MissionConstraints` data structure
- Validation system before launch
- Visual overlay system for constraints
- Combat simulator for preview
- Unlock constraints progressively

---

### 🏆 **10. "Signature Build" Achievement System**

**Priority:** Low | **Complexity:** Low | **Impact:** Medium

#### Concept
Reward creative and extreme builds with badges and recognition.

#### Achievement Categories

**ARCHETYPE MASTERY:**
```
"The Porcupine" - Win with 6+ weapons
"The Turtle" - Win with 5+ shields
"The Roadrunner" - Win with 4+ engines, <30 durability
"The Juggernaut" - Win with 8+ armor, <40 offense
"The Engineer" - Win with 4+ reactors
```

**EXTREME BUILDS:**
```
"Glass Cannon" - Win with <20 defense, >80 offense
"Untouchable" - Win without taking damage
"David vs Goliath" - Win with budget <20 vs hard enemy
"Efficiency Expert" - Win with 100% grid filled
"Minimalist" - Win with ≤10 rooms total
```

**RISKY WINS:**
```
"Walking Bomb" - Win with 3+ overloaded rooms
"One Hit Wonder" - Win with only 1 HP remaining
"Knife Fight" - Win by destroying bridge (mutual destruction victory)
"Hot Shot" - Win with all rooms at critical heat
```

**CREATIVE STRATEGIES:**
```
"Synergy Specialist" - Win with 5+ active synergies
"Power Grid" - Win with every room powered
"Asymmetric Warfare" - Win with 100% offense OR 100% defense
"Speedrun" - Win in ≤3 turns
```

#### Visual Design
- **Badge display:** Show earned badges on ship in combat
- **Hall of Fame:** Gallery of signature builds
- **Ship naming:** "USS Porcupine" auto-name for achievement ships
- **Stat tracking:** "32 battles with Glass Cannon builds"

#### Implementation Notes
- Add `AchievementManager` autoload
- Check conditions after every battle
- Persistent save data for unlocks
- Badge sprite system
- Ship name generator

---

## 🎯 **Recommended Implementation Priority**

### Phase 1: Quick Wins (1-2 days)
1. **Room Adjacency Synergies (#2)** - Huge impact, low complexity
2. **Live Ship Profile Visualization (#5)** - Essential feedback system
3. **Damage Zones (#3)** - Makes placement feel tactical

### Phase 2: Core Enhancements (1 week)
4. **Mission Constraints (#9)** - Adds variety without art
5. **Overload Mechanic (#7)** - Risk/reward decisions
6. **Achievement System (#10)** - Replayability reward

### Phase 3: Major Features (2-3 weeks)
7. **Room Variants (#4)** - Massive art investment, huge variety
8. **Heat System (#1)** - Complex but rewarding
9. **Ship Personality (#8)** - Polish and juice

### Phase 4: Advanced (Future)
10. **Negative Space Tetris (#6)** - Major refactor, optional

---

## 🎨 **Immediate Prototype: "Ship Scanner" Panel**

**Goal:** Get immediate feedback working with minimal effort.

**Implementation:**
```gdscript
# Add to ShipDesigner.gd

var ship_stats = {
    "offense": 0,
    "defense": 0,
    "speed": 0,
    "durability": 0
}

func calculate_ship_stats():
    var weapons = count_rooms(RoomType.WEAPON)
    var shields = count_rooms(RoomType.SHIELD)
    var engines = count_rooms(RoomType.ENGINE)
    var armor = count_rooms(RoomType.ARMOR)

    ship_stats["offense"] = min(100, weapons * 20)
    ship_stats["defense"] = min(100, shields * 25)
    ship_stats["speed"] = min(100, engines * 30)
    ship_stats["durability"] = min(100, 60 + armor * 10)

    update_ship_profile_ui()

func get_archetype() -> String:
    var o = ship_stats["offense"]
    var d = ship_stats["defense"]
    var s = ship_stats["speed"]
    var dur = ship_stats["durability"]

    if o >= 70 and d <= 30:
        return "GLASS CANNON"
    elif d >= 70 and o <= 40:
        return "TURTLE"
    elif s >= 70:
        return "SPEEDSTER"
    elif dur >= 80:
        return "JUGGERNAUT"
    elif o >= 40 and o <= 60 and d >= 40 and d <= 60:
        return "BALANCED"
    else:
        return "CUSTOM BUILD"
```

**UI Panel:**
- Right side of designer
- Updates in real-time
- Shows archetype name in large text
- 4 progress bars for stats
- Warning messages for extreme builds

---

## 📝 **Design Philosophy**

**Core Principle:** *Every choice should be visually obvious and emotionally impactful.*

**Guidelines:**
1. **Show, Don't Tell:** Visual feedback > numbers
2. **Immediate Feedback:** See consequences while designing, not after
3. **Meaningful Tradeoffs:** No "correct" answer, multiple viable strategies
4. **Encourage Experimentation:** Make it fun to try wild builds
5. **Celebrate Creativity:** Reward unconventional approaches

**Anti-patterns to Avoid:**
- ❌ Hidden mechanics (show everything)
- ❌ Optimal builds (balance for variety)
- ❌ Punishing experimentation (failure should teach)
- ❌ Math homework (intuitive > calculable)

---

## 🚀 **Next Steps**

1. **Review & Prioritize:** Discuss which features align with project scope
2. **Prototype Top 3:** Build synergies, ship profile, damage zones
3. **Playtest Early:** Get feedback before full implementation
4. **Iterate:** Tune numbers, polish visuals
5. **Expand:** Add more variants, constraints, achievements over time

---

## 📚 **Reference Links**

- FTL: Faster Than Light - Ship layout variety
- Into the Breach - Visible consequences
- Slay the Spire - Build archetypes
- Factorio - Visual optimization satisfaction
- Deep Rock Galactic - Build personality

---

**Document Version:** 1.0
**Last Updated:** 2025-12-09
**Status:** Awaiting review and prioritization
