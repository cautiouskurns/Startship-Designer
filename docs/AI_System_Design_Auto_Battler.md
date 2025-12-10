# AI System Design for Auto-Battler Combat

**Generated:** December 10, 2025
**Game Type:** Auto-Battler (Player designs ship, AI controls combat for BOTH sides)
**Core Principle:** AI must be interesting to WATCH, not just challenging to FIGHT

---

## Table of Contents

1. [Design Philosophy](#design-philosophy)
2. [Current AI System](#current-ai-system)
3. [Core AI Architecture](#core-ai-architecture)
4. [AI System Components](#ai-system-components)
5. [Ship Personality & Doctrine](#ship-personality--doctrine)
6. [Decision-Making Framework](#decision-making-framework)
7. [Advanced AI Behaviors](#advanced-ai-behaviors)
8. [Visual Feedback & Player Understanding](#visual-feedback--player-understanding)
9. [Implementation Roadmap](#implementation-roadmap)
10. [Design Validation](#design-validation)

---

## Design Philosophy

### **Auto-Battler AI Requirements**

In an auto-battler, AI serves a fundamentally different purpose than traditional games:

| Traditional Game | Auto-Battler |
|------------------|--------------|
| AI is opponent | AI is performer |
| Challenge is primary goal | Entertainment is primary goal |
| Player fights AI | Player watches AI |
| AI skill = difficulty | AI clarity = understanding |
| Win/lose matters most | HOW you win/lose matters most |

### **Core Principles**

1. **Clarity Over Complexity**
   - Player must understand WHY AI made each decision
   - Decisions should be predictable and learnable
   - Visual feedback explains AI reasoning

2. **Variety Through Design**
   - Different ship builds produce different AI behaviors
   - Player sees their design philosophy reflected in combat
   - No two battles look the same

3. **Drama & Narrative**
   - AI creates exciting moments (clutch saves, calculated risks)
   - Close battles feel tense and uncertain
   - Dominant victories feel earned and satisfying

4. **Strategic Depth**
   - AI exploits synergies and build strengths
   - Reacts dynamically to combat state
   - Makes "smart" plays that feel intentional

5. **Player Agency Through Design**
   - Player's ship design choices MATTER to how AI fights
   - Placement decisions affect AI targeting and power management
   - Build philosophy determines combat style

---

## Current AI System

### **What Exists Now**

```gdscript
// Current Enemy AI (from Combat.gd)
enum TargetingPriority {
    RANDOM,         // Scout: Pick any room randomly
    WEAPONS_FIRST,  // Raider: Prioritize weapons
    POWER_FIRST     // Dreadnought: Prioritize reactors/relays
}

func _select_target_room(defender: ShipData, attacker: ShipData) -> int:
    var targeting_priority = attacker.targeting_priority
    var active_room_ids = []

    // Get list of active rooms (excluding Bridge)
    for room_id in defender.room_instances:
        if room_data["type"] != BRIDGE:
            active_room_ids.append(room_id)

    // Filter by priority
    if targeting_priority == WEAPONS_FIRST:
        return filter_for_weapons(active_room_ids)
    elif targeting_priority == POWER_FIRST:
        return filter_for_power(active_room_ids)
    else:
        return random_choice(active_room_ids)
```

### **Current Limitations**

1. **Static Targeting** - Priority set once, never changes
2. **No Threat Assessment** - Doesn't evaluate which rooms are most dangerous
3. **No Power Management** - AI doesn't use reactor overload, power routing, etc.
4. **No Player Ship AI** - Player ship uses same basic system
5. **No Build Awareness** - Doesn't recognize if it's a glass cannon vs turtle
6. **No Predictive Thinking** - Doesn't look ahead ("If I kill reactor, 3 weapons unpower")
7. **No Risk/Reward** - Never makes interesting gambles or sacrifices

---

## Core AI Architecture

### **Proposed Multi-Layer AI System**

```
┌─────────────────────────────────────────────────────────────┐
│                    COMBAT AI DIRECTOR                       │
│  (Orchestrates all AI decisions for both ships)             │
└─────────────────────────────────────────────────────────────┘
                            │
        ┌───────────────────┴───────────────────┐
        ▼                                       ▼
┌──────────────────┐                   ┌──────────────────┐
│   PLAYER AI      │                   │    ENEMY AI      │
│  (Autonomous)    │                   │  (Autonomous)    │
└──────────────────┘                   └──────────────────┘
        │                                       │
        │                                       │
┌───────┴────────┐                      ┌──────┴───────┐
│  Ship Profile  │                      │ Ship Profile │
│  Analyzer      │                      │  Analyzer    │
└────────────────┘                      └──────────────┘
        │                                       │
        ├─ Detect Archetype                   ├─ Detect Archetype
        ├─ Identify Strengths                  ├─ Identify Strengths
        ├─ Identify Weaknesses                 └─ Identify Weaknesses
        └─ Calculate Combat Doctrine
                │
        ┌───────┴────────┐
        │  Decision Tree  │
        └────────────────┘
                │
    ┌───────────┼───────────┐
    ▼           ▼           ▼
┌────────┐ ┌────────┐ ┌────────┐
│Targeting│ │Power   │ │Tactical│
│System   │ │Mgmt    │ │Actions │
└────────┘ └────────┘ └────────┘
```

### **AI Decision Cycle (Every Turn)**

```
1. ANALYZE PHASE (Pre-Turn)
   ├─ Evaluate current combat state
   ├─ Assess threats (enemy weapons, shields, HP)
   ├─ Check own resources (HP, powered rooms, cooldowns)
   └─ Calculate win/lose probability

2. STRATEGY PHASE (Decision Making)
   ├─ Select combat doctrine based on state
   ├─ Determine primary objective (offense/defense/efficiency)
   └─ Calculate risk tolerance

3. TARGETING PHASE (Action Selection)
   ├─ Generate list of valid targets
   ├─ Score each target by doctrine + situation
   ├─ Select optimal target(s)
   └─ Determine special actions (overcharge, power routing)

4. EXECUTION PHASE (Action)
   ├─ Execute selected actions
   ├─ Show visual feedback (thought bubbles, highlights)
   └─ Log decision reasoning to combat log

5. REFLECTION PHASE (Post-Turn)
   ├─ Evaluate outcome (did plan work?)
   └─ Update strategy confidence for next turn
```

---

## AI System Components

### **1. Ship Profile Analyzer**

**Purpose:** Understand what kind of ship we are and what we're good at

#### **Build Detection**

```gdscript
class ShipProfile:
    # Archetype Detection (from player's ShipProfilePanel logic)
    var archetype: Archetype  # GLASS_CANNON, TURTLE, SPEEDSTER, BALANCED, etc.

    # Stat Profile
    var offense_rating: float    # 0.0-1.0
    var defense_rating: float    # 0.0-1.0
    var speed_rating: float      # 0.0-1.0
    var durability_rating: float # 0.0-1.0
    var efficiency_rating: float # 0.0-1.0

    # Key Strengths (what we're good at)
    var primary_strength: StatType    # Our highest stat
    var secondary_strength: StatType  # Our second highest stat

    # Critical Weaknesses (what we're vulnerable to)
    var critical_weakness: StatType   # Our lowest stat

    # Tactical Assets
    var synergy_count: Dictionary     # How many of each synergy type
    var reactor_count: int            # How many reactors (power redundancy)
    var critical_rooms: Array[int]    # Rooms we MUST protect

    # Combat Capabilities
    var can_alpha_strike: bool        # High burst damage
    var can_tank: bool                # High shields + HP
    var can_outlast: bool             # Efficiency + durability
    var has_power_redundancy: bool    # Multiple reactors

func analyze_ship(ship_data: ShipData) -> ShipProfile:
    var profile = ShipProfile.new()

    # Calculate stat ratings (using ShipProfilePanel logic)
    profile.offense_rating = _calculate_offense(ship_data)
    profile.defense_rating = _calculate_defense(ship_data)
    profile.speed_rating = _calculate_speed(ship_data)
    profile.durability_rating = _calculate_durability(ship_data)
    profile.efficiency_rating = _calculate_efficiency(ship_data)

    # Detect archetype
    profile.archetype = _detect_archetype(profile)

    # Identify strengths
    var stats = [
        {"type": StatType.OFFENSE, "value": profile.offense_rating},
        {"type": StatType.DEFENSE, "value": profile.defense_rating},
        {"type": StatType.SPEED, "value": profile.speed_rating},
        {"type": StatType.DURABILITY, "value": profile.durability_rating}
    ]
    stats.sort_custom(func(a, b): return a.value > b.value)

    profile.primary_strength = stats[0].type
    profile.secondary_strength = stats[1].type
    profile.critical_weakness = stats[3].type  # Lowest stat

    # Analyze tactical assets
    var synergies = ship_data.calculate_synergy_bonuses()
    profile.synergy_count = synergies["counts"]
    profile.reactor_count = ship_data.count_room_type(RoomData.RoomType.REACTOR)

    # Determine capabilities
    profile.can_alpha_strike = (profile.offense_rating > 0.7 and profile.speed_rating > 0.5)
    profile.can_tank = (profile.defense_rating > 0.6 and profile.durability_rating > 0.6)
    profile.can_outlast = (profile.efficiency_rating > 0.8 and profile.durability_rating > 0.5)
    profile.has_power_redundancy = (profile.reactor_count >= 2)

    return profile
```

#### **Example Profiles**

```
GLASS CANNON PROFILE:
├─ Archetype: GLASS_CANNON
├─ Stats: Offense=90%, Defense=20%, Speed=60%, Durability=30%
├─ Primary Strength: OFFENSE
├─ Critical Weakness: DEFENSE
├─ Capabilities: can_alpha_strike=true, can_tank=false
└─ Tactical Note: Must end fights quickly

TURTLE PROFILE:
├─ Archetype: TURTLE
├─ Stats: Offense=30%, Defense=85%, Speed=20%, Durability=80%
├─ Primary Strength: DEFENSE
├─ Critical Weakness: SPEED
├─ Capabilities: can_tank=true, can_outlast=true
└─ Tactical Note: Win by attrition

BALANCED PROFILE:
├─ Archetype: BALANCED
├─ Stats: Offense=60%, Defense=55%, Speed=50%, Durability=60%
├─ Primary Strength: OFFENSE (slightly)
├─ Critical Weakness: SPEED (slightly)
├─ Capabilities: Flexible, no dominant strategy
└─ Tactical Note: Adapt to opponent
```

---

### **2. Combat State Evaluator**

**Purpose:** Continuously assess "who's winning" and adjust strategy accordingly

#### **State Metrics**

```gdscript
class CombatState:
    # Win Probability
    var win_probability: float  # 0.0-1.0 (0% to 100% chance to win)

    # HP Comparison
    var hp_advantage: float     # Positive = we're ahead, negative = behind
    var hp_ratio: float         # Our HP / Enemy HP

    # Damage Race
    var dps_advantage: float    # Our DPS - Enemy DPS
    var time_to_kill_enemy: int # Estimated turns to kill enemy
    var time_to_die: int        # Estimated turns until we die

    # Resource State
    var power_stability: float  # How stable is our power grid? (1.0 = very stable)
    var threat_level: float     # How dangerous is enemy? (0.0-1.0)

    # Momentum
    var momentum: float         # Positive = winning, negative = losing
    var desperation: float      # 0.0-1.0, increases as we lose

func evaluate_combat_state(our_ship: ShipData, enemy_ship: ShipData, turn: int) -> CombatState:
    var state = CombatState.new()

    # HP Analysis
    state.hp_ratio = float(our_ship.current_hp) / float(enemy_ship.current_hp)
    state.hp_advantage = our_ship.current_hp - enemy_ship.current_hp

    # Damage Calculation
    var our_dps = _calculate_dps(our_ship)
    var enemy_dps = _calculate_dps(enemy_ship)
    state.dps_advantage = our_dps - enemy_dps

    # Time to Kill
    state.time_to_kill_enemy = int(enemy_ship.current_hp / max(1, our_dps))
    state.time_to_die = int(our_ship.current_hp / max(1, enemy_dps))

    # Win Probability (simplified model)
    if state.time_to_die > state.time_to_kill_enemy:
        state.win_probability = 0.9  # We win the damage race
    elif state.time_to_die < state.time_to_kill_enemy:
        state.win_probability = 0.1  # We lose the damage race
    else:
        state.win_probability = 0.5  # Even match

    # Adjust by HP ratio
    state.win_probability *= (state.hp_ratio * 0.5 + 0.5)
    state.win_probability = clamp(state.win_probability, 0.05, 0.95)

    # Momentum (are we gaining or losing ground?)
    if state.hp_ratio > 1.5 and state.dps_advantage > 0:
        state.momentum = 1.0  # Dominating
    elif state.hp_ratio < 0.66 and state.dps_advantage < 0:
        state.momentum = -1.0  # Getting crushed
    else:
        state.momentum = (state.hp_ratio - 1.0) + (state.dps_advantage / 20.0)

    # Desperation (increases as we're losing)
    var hp_desperation = 1.0 - (float(our_ship.current_hp) / float(our_ship.max_hp))
    var win_desperation = 1.0 - state.win_probability
    state.desperation = (hp_desperation + win_desperation) / 2.0

    return state
```

#### **State-Based Strategy Adjustment**

```
Combat State → Strategy Shift:

DOMINATING (Win Prob > 80%, HP Advantage > 40%):
├─ Strategy: "PRESS ADVANTAGE"
├─ Focus: Maximize damage, end fight quickly
├─ Targeting: Continue current strategy
└─ Risk: Can afford aggressive plays

WINNING (Win Prob > 60%, HP Advantage > 20%):
├─ Strategy: "MAINTAIN LEAD"
├─ Focus: Consistent pressure, avoid mistakes
├─ Targeting: Optimal damage-per-turn
└─ Risk: Balanced, no desperate plays

EVEN (Win Prob 40-60%, HP within 20%):
├─ Strategy: "TACTICAL PRECISION"
├─ Focus: Exploit weaknesses, maximize efficiency
├─ Targeting: High-value targets (reactors, synergies)
└─ Risk: Calculated gambles to gain edge

LOSING (Win Prob < 40%, HP Disadvantage > 20%):
├─ Strategy: "DEFENSIVE ADAPTATION"
├─ Focus: Survive longer, reduce incoming damage
├─ Targeting: Enemy weapons first
└─ Risk: Defensive plays, preserve HP

DESPERATE (Win Prob < 20%, HP < 30%):
├─ Strategy: "ALL-IN GAMBLE"
├─ Focus: Maximize burst damage, swing momentum
├─ Targeting: Critical targets (Bridge, Reactors)
├─ Risk: High-risk plays (overcharge, focus fire)
└─ Mentality: "Nothing to lose"
```

---

### **3. Threat Assessment System**

**Purpose:** Evaluate which enemy rooms pose the greatest threat

#### **Threat Scoring**

```gdscript
class ThreatScore:
    var room_id: int
    var room_type: RoomData.RoomType
    var threat_value: float     # 0.0-100.0
    var threat_category: String # "IMMEDIATE", "HIGH", "MEDIUM", "LOW"
    var reasoning: String       # Why this target is threatening

func calculate_threat_scores(enemy_ship: ShipData, our_ship: ShipData) -> Array[ThreatScore]:
    var threats = []

    for room_id in enemy_ship.room_instances:
        var room_data = enemy_ship.room_instances[room_id]
        var room_type = room_data["type"]

        # Skip empty/destroyed rooms
        if room_type == RoomData.RoomType.EMPTY:
            continue

        var threat = ThreatScore.new()
        threat.room_id = room_id
        threat.room_type = room_type
        threat.threat_value = 0.0

        # Calculate threat based on room type
        match room_type:
            RoomData.RoomType.WEAPON:
                threat.threat_value += _calculate_weapon_threat(enemy_ship, room_id)
                threat.reasoning = "Dealing direct damage each turn"

            RoomData.RoomType.REACTOR:
                threat.threat_value += _calculate_reactor_threat(enemy_ship, room_id)
                threat.reasoning = "Powers multiple critical systems"

            RoomData.RoomType.SHIELD:
                threat.threat_value += _calculate_shield_threat(enemy_ship, room_id, our_ship)
                threat.reasoning = "Blocking our damage output"

            RoomData.RoomType.ENGINE:
                threat.threat_value += _calculate_engine_threat(enemy_ship, our_ship)
                threat.reasoning = "Granting initiative advantage"

            RoomData.RoomType.BRIDGE:
                threat.threat_value = 100.0  # Always highest (instant win)
                threat.reasoning = "Instant win condition"

        # Categorize threat level
        if threat.threat_value >= 80:
            threat.threat_category = "IMMEDIATE"
        elif threat.threat_value >= 60:
            threat.threat_category = "HIGH"
        elif threat.threat_value >= 40:
            threat.threat_category = "MEDIUM"
        else:
            threat.threat_category = "LOW"

        threats.append(threat)

    # Sort by threat value (descending)
    threats.sort_custom(func(a, b): return a.threat_value > b.threat_value)

    return threats

# Weapon Threat Calculation
func _calculate_weapon_threat(enemy_ship: ShipData, weapon_room_id: int) -> float:
    var threat = 30.0  # Base threat

    # Is it powered?
    var room_tiles = enemy_ship.room_instances[weapon_room_id]["tiles"]
    var is_powered = enemy_ship.is_room_powered(room_tiles[0].x, room_tiles[0].y)

    if not is_powered:
        return 10.0  # Low threat if unpowered

    # Check weapon damage output
    var weapon_stats = RoomData.get_stats(RoomData.RoomType.WEAPON)
    threat += weapon_stats.get("damage", 10) * 2  # Higher damage = higher threat

    # Check for synergies (Fire Rate = more dangerous)
    var synergies = enemy_ship.calculate_synergy_bonuses()
    var room_pos = Vector2i(room_tiles[0].x, room_tiles[0].y)
    if room_pos in synergies["room_synergies"]:
        if RoomData.SynergyType.FIRE_RATE in synergies["room_synergies"][room_pos]:
            threat += 20.0  # Synergized weapons are higher priority

    return threat

# Reactor Threat Calculation
func _calculate_reactor_threat(enemy_ship: ShipData, reactor_room_id: int) -> float:
    var threat = 40.0  # Base threat (reactors are valuable)

    # Count how many rooms this reactor powers
    var powered_rooms = enemy_ship.get_rooms_powered_by_reactor(reactor_room_id)

    # More powered rooms = higher threat
    threat += powered_rooms.size() * 8.0

    # Check what types of rooms are powered
    var powers_weapons = false
    var powers_shields = false
    for room_id in powered_rooms:
        var room_type = enemy_ship.room_instances[room_id]["type"]
        if room_type == RoomData.RoomType.WEAPON:
            powers_weapons = true
            threat += 10.0
        elif room_type == RoomData.RoomType.SHIELD:
            powers_shields = true
            threat += 8.0

    # Reactor powering weapons is highest priority
    if powers_weapons:
        threat += 15.0

    # Single reactor = critical (destroying it cripples ship)
    if enemy_ship.count_room_type(RoomData.RoomType.REACTOR) == 1:
        threat += 20.0

    return threat

# Shield Threat Calculation
func _calculate_shield_threat(enemy_ship: ShipData, shield_room_id: int, our_ship: ShipData) -> float:
    var threat = 25.0  # Base threat

    # Is shield powered?
    var room_tiles = enemy_ship.room_instances[shield_room_id]["tiles"]
    var is_powered = enemy_ship.is_room_powered(room_tiles[0].x, room_tiles[0].y)

    if not is_powered:
        return 5.0  # Low threat if unpowered

    # Calculate our damage vs their shields
    var our_damage = _calculate_dps(our_ship)
    var their_shields = _calculate_shield_absorption(enemy_ship, our_damage)

    # If shields are blocking significant damage, higher threat
    var block_percentage = float(their_shields) / float(our_damage)
    threat += block_percentage * 40.0

    # Check for shield synergies (capacity boost)
    var synergies = enemy_ship.calculate_synergy_bonuses()
    var room_pos = Vector2i(room_tiles[0].x, room_tiles[0].y)
    if room_pos in synergies["room_synergies"]:
        if RoomData.SynergyType.SHIELD_CAPACITY in synergies["room_synergies"][room_pos]:
            threat += 15.0

    return threat

# Engine Threat Calculation
func _calculate_engine_threat(enemy_ship: ShipData, our_ship: ShipData) -> float:
    var threat = 20.0  # Base threat

    # Do they have initiative advantage?
    var our_initiative = _calculate_initiative(our_ship)
    var their_initiative = _calculate_initiative(enemy_ship)

    if their_initiative > our_initiative:
        threat += 25.0  # They shoot first = higher threat

    # Check for initiative synergies
    var synergies = enemy_ship.calculate_synergy_bonuses()
    var initiative_synergy_count = synergies["counts"][RoomData.SynergyType.INITIATIVE]
    threat += initiative_synergy_count * 10.0

    return threat
```

#### **Threat-Based Targeting**

```
Target Selection Logic:

1. Get all enemy rooms
2. Calculate threat score for each
3. Filter by doctrine:

   AGGRESSIVE DOCTRINE:
   ├─ Prioritize WEAPONS (reduce enemy offense)
   ├─ Secondary: REACTORS (cascade damage)
   └─ Ignore: Shields (focus raw damage)

   DEFENSIVE DOCTRINE:
   ├─ Prioritize WEAPONS (reduce incoming damage)
   ├─ Secondary: SHIELDS (maximize our damage penetration)
   └─ Ignore: Engines (doesn't affect immediate survival)

   EFFICIENT DOCTRINE:
   ├─ Prioritize REACTORS (maximize cascade effect)
   ├─ Secondary: SYNERGIZED ROOMS (break combos)
   └─ Calculate: Damage-per-turn efficiency

   DESPERATE DOCTRINE:
   ├─ Prioritize BRIDGE (instant win)
   ├─ Secondary: REACTORS (cripple ship in one hit)
   └─ Ignore: Everything else (all-in gamble)

4. Select top-scoring valid target
5. Log reasoning to combat log
```

---

### **4. Targeting Intelligence System**

**Purpose:** Make smart targeting decisions based on doctrine + situation

#### **Multi-Factor Target Scoring**

```gdscript
func score_target(
    target_room_id: int,
    enemy_ship: ShipData,
    our_profile: ShipProfile,
    combat_state: CombatState,
    doctrine: CombatDoctrine
) -> float:
    var score = 0.0

    # Base threat value
    var threat_score = get_threat_score(target_room_id, enemy_ship)
    score += threat_score

    # Doctrine modifier
    score *= doctrine.get_priority_multiplier(target_room_id)

    # Situational modifiers
    if combat_state.desperation > 0.7:
        # Desperate: prioritize critical targets
        if is_critical_target(target_room_id, enemy_ship):
            score *= 1.5

    if combat_state.momentum > 0.5:
        # Winning: maintain pressure
        if is_offensive_target(target_room_id):
            score *= 1.2

    if combat_state.momentum < -0.5:
        # Losing: reduce incoming damage
        if target_type == RoomData.RoomType.WEAPON:
            score *= 1.4

    # Predictive bonus: "What happens if we destroy this?"
    var cascade_value = predict_cascade_effect(target_room_id, enemy_ship)
    score += cascade_value

    # Synergy disruption bonus
    if breaks_synergy(target_room_id, enemy_ship):
        score += 20.0

    return score

# Predictive Analysis
func predict_cascade_effect(target_room_id: int, enemy_ship: ShipData) -> float:
    var cascade_value = 0.0
    var room_type = enemy_ship.room_instances[target_room_id]["type"]

    if room_type == RoomData.RoomType.REACTOR:
        # Simul destroying reactor and count unpowered rooms
        var would_unpower = count_rooms_that_would_lose_power(target_room_id, enemy_ship)
        cascade_value = would_unpower * 10.0  # Each unpowered room adds value

        # Bonus if unpowering weapons
        var weapons_unpowered = count_weapons_that_would_unpower(target_room_id, enemy_ship)
        cascade_value += weapons_unpowered * 15.0

    return cascade_value

# Synergy Disruption
func breaks_synergy(target_room_id: int, enemy_ship: ShipData) -> bool:
    var synergies = enemy_ship.calculate_synergy_bonuses()
    var room_data = enemy_ship.room_instances[target_room_id]

    # Check if this room is part of any synergy
    for tile_pos in room_data["tiles"]:
        if tile_pos in synergies["room_synergies"]:
            return true  # Destroying this breaks a synergy

    return false
```

#### **Multi-Target Distribution** _(For 4+ Weapons)_

```gdscript
func select_multiple_targets(
    weapon_count: int,
    enemy_ship: ShipData,
    our_profile: ShipProfile,
    combat_state: CombatState,
    doctrine: CombatDoctrine
) -> Array[int]:

    if weapon_count <= 2:
        # Focus fire on single target
        return [select_single_target(...)]

    elif weapon_count <= 4:
        # Split fire between 2 targets
        var primary = select_single_target(...)
        var secondary = select_secondary_target(primary, ...)
        return [primary, primary, secondary, secondary]  # 2 weapons each

    else:
        # Distribute across 3+ targets
        var targets = []
        var available_targets = get_valid_targets(enemy_ship)

        # Prioritize by score
        available_targets.sort_custom(func(a, b):
            return score_target(a, ...) > score_target(b, ...)
        )

        # Distribute weapons proportionally
        for i in range(weapon_count):
            var target_index = i % min(3, available_targets.size())
            targets.append(available_targets[target_index])

        return targets
```

---

## Ship Personality & Doctrine

### **Doctrine System**

**Purpose:** Ship's design determines its combat philosophy

```gdscript
enum CombatDoctrine {
    ALPHA_STRIKE,      # Burst damage, end fights quickly
    WAR_OF_ATTRITION,  # Outlast enemy, win slowly
    SURGICAL_STRIKE,   # Target high-value rooms, maximize efficiency
    DEFENSIVE_TURTLE,  # Minimize damage taken, preserve HP
    ADAPTIVE_RESPONSE, # Change tactics based on opponent
    BERSERKER_RUSH     # All-out offense, ignore defense
}

class ShipPersonality:
    var doctrine: CombatDoctrine
    var aggression: float        # 0.0-1.0 (passive to aggressive)
    var risk_tolerance: float    # 0.0-1.0 (cautious to reckless)
    var adaptability: float      # 0.0-1.0 (rigid to flexible)
    var efficiency_focus: float  # 0.0-1.0 (wasteful to optimal)

func determine_personality(profile: ShipProfile) -> ShipPersonality:
    var personality = ShipPersonality.new()

    # Base doctrine on archetype
    match profile.archetype:
        Archetype.GLASS_CANNON:
            personality.doctrine = CombatDoctrine.ALPHA_STRIKE
            personality.aggression = 0.9
            personality.risk_tolerance = 0.8
            personality.adaptability = 0.3  # Rigid: MUST kill fast
            personality.efficiency_focus = 0.6

        Archetype.TURTLE:
            personality.doctrine = CombatDoctrine.DEFENSIVE_TURTLE
            personality.aggression = 0.2
            personality.risk_tolerance = 0.2
            personality.adaptability = 0.4
            personality.efficiency_focus = 0.9  # Very efficient, conserve resources

        Archetype.SPEEDSTER:
            personality.doctrine = CombatDoctrine.SURGICAL_STRIKE
            personality.aggression = 0.7
            personality.risk_tolerance = 0.6
            personality.adaptability = 0.7  # Very adaptive
            personality.efficiency_focus = 0.8  # Highly efficient strikes

        Archetype.BALANCED:
            personality.doctrine = CombatDoctrine.ADAPTIVE_RESPONSE
            personality.aggression = 0.5
            personality.risk_tolerance = 0.5
            personality.adaptability = 0.9  # Extremely adaptive
            personality.efficiency_focus = 0.7

        Archetype.ALPHA_STRIKER:
            personality.doctrine = CombatDoctrine.BERSERKER_RUSH
            personality.aggression = 1.0
            personality.risk_tolerance = 0.9
            personality.adaptability = 0.2  # Single-minded
            personality.efficiency_focus = 0.4  # Doesn't care about efficiency

        Archetype.JUGGERNAUT:
            personality.doctrine = CombatDoctrine.WAR_OF_ATTRITION
            personality.aggression = 0.4
            personality.risk_tolerance = 0.3
            personality.adaptability = 0.5
            personality.efficiency_focus = 0.8  # Long game focus

    # Adjust based on capabilities
    if profile.can_alpha_strike:
        personality.aggression += 0.2
        personality.risk_tolerance += 0.1

    if profile.has_power_redundancy:
        personality.risk_tolerance += 0.15  # Can afford to take risks

    if profile.efficiency_rating > 0.8:
        personality.efficiency_focus += 0.1

    # Clamp values
    personality.aggression = clamp(personality.aggression, 0.0, 1.0)
    personality.risk_tolerance = clamp(personality.risk_tolerance, 0.0, 1.0)
    personality.adaptability = clamp(personality.adaptability, 0.0, 1.0)
    personality.efficiency_focus = clamp(personality.efficiency_focus, 0.0, 1.0)

    return personality
```

### **Doctrine Behavior Profiles**

#### **ALPHA_STRIKE Doctrine**

```
Philosophy: "Kill them before they kill us"

Targeting Priority:
1. Enemy weapons (reduce counterattack)
2. Enemy reactors (maximize cascade damage)
3. Enemy bridge (if accessible)

Special Behaviors:
├─ Always use reactor overload when available
├─ Focus fire on single target
├─ Ignore shields (bypass, don't destroy)
└─ Will sacrifice defense for offense

Adaptability:
├─ If enemy HP > 50% at turn 5: PANIC MODE
│   └─ Switch to desperate all-in tactics
└─ If enemy HP < 25% by turn 3: Continue aggression

Weakness:
└─ Struggles against high-defense builds
```

#### **DEFENSIVE_TURTLE Doctrine**

```
Philosophy: "Outlast and outlive"

Targeting Priority:
1. Enemy weapons (reduce incoming damage)
2. Enemy damage-boosting synergies
3. Enemy engines (reduce initiative advantage)

Special Behaviors:
├─ Never use risky abilities (no reactor overload)
├─ Prioritize power preservation
├─ Always target weapons first
└─ Spread damage to delay enemy destruction effects

Adaptability:
├─ If losing at turn 10: Switch to surgical strikes
│   └─ Target reactors to create opening
└─ If winning: Maintain pressure, play safe

Weakness:
└─ Low damage output, fights drag on
```

#### **SURGICAL_STRIKE Doctrine**

```
Philosophy: "Maximum efficiency, minimum waste"

Targeting Priority:
1. Highest-value target by cascade effect
2. Synergy-breaking targets
3. Power infrastructure (reactors, relays)

Special Behaviors:
├─ Calculate optimal target each turn (no fixed priority)
├─ Uses predictive analysis heavily
├─ Exploit power dependencies
└─ Balance offense and defense

Adaptability:
├─ Constantly re-evaluates based on new information
├─ Switches focus as enemy composition changes
└─ Most flexible doctrine

Weakness:
└─ Can be "too clever" - overthinks simple situations
```

#### **ADAPTIVE_RESPONSE Doctrine**

```
Philosophy: "Match the opponent's strategy"

Targeting Priority:
├─ Mirror counter-play:
│   ├─ vs ALPHA_STRIKE → Target their weapons
│   ├─ vs TURTLE → Target their shields/armor
│   └─ vs SURGICAL → Play defensively, force trades

Special Behaviors:
├─ Analyzes enemy doctrine after turn 2
├─ Adjusts aggression based on opponent
├─ Uses abilities situationally
└─ No fixed playbook

Adaptability:
├─ Extreme (constantly shifting)
└─ Can counter any strategy given enough turns

Weakness:
└─ Takes 2-3 turns to "figure out" opponent
```

#### **BERSERKER_RUSH Doctrine**

```
Philosophy: "ATTACK ATTACK ATTACK"

Targeting Priority:
1. Anything that dies this turn
2. Enemy bridge (always)
3. Random targets (chaos)

Special Behaviors:
├─ Always overcharge reactors
├─ Redirect all power to weapons
├─ Multi-target if possible (spread chaos)
└─ Ignore incoming damage

Adaptability:
├─ NONE - single strategy
└─ If HP < 10%: Continue attacking (no survival instinct)

Weakness:
└─ Extremely vulnerable, dies quickly vs organized opponents
```

#### **WAR_OF_ATTRITION Doctrine**

```
Philosophy: "Slow and steady wins the race"

Targeting Priority:
1. Enemy weapons (long-term damage reduction)
2. Enemy efficiency (sabotage their power grid)
3. Gradual dismantling

Special Behaviors:
├─ Never takes risky plays
├─ Spreads damage evenly (delays cascades)
├─ Preserves own power grid at all costs
└─ Accepts longer battles

Adaptability:
├─ Very rigid (trusts in plan)
└─ If HP < 30%: Mild panic, increase aggression

Weakness:
└─ Loses damage races, vulnerable to alpha strikes
```

---

## Decision-Making Framework

### **Turn Decision Tree**

```
TURN START
│
├─ ANALYZE PHASE
│  ├─ Update ShipProfile (our ship)
│  ├─ Update EnemyProfile
│  ├─ Evaluate CombatState
│  └─ Calculate Threat Scores
│
├─ DOCTRINE CHECK
│  ├─ Should doctrine change? (Adaptive only)
│  ├─ Check special conditions (desperation, momentum)
│  └─ Adjust personality traits based on state
│
├─ SPECIAL ACTION CHECK
│  ├─ Should we use Reactor Overload?
│  │  └─ If doctrine.aggression > 0.7 AND combat_state.desperation > 0.5
│  │
│  ├─ Should we use Emergency Power Routing?
│  │  └─ If combat_state.win_probability < 0.3
│  │
│  └─ Should we use Emergency Thrust?
│     └─ If enemy about to destroy critical room
│
├─ TARGETING DECISION
│  ├─ Generate candidate targets
│  ├─ Score each target by:
│  │  ├─ Base threat value
│  │  ├─ Doctrine priority
│  │  ├─ Situational modifiers
│  │  ├─ Cascade prediction
│  │  └─ Synergy disruption
│  │
│  ├─ Select optimal target(s)
│  └─ Log decision reasoning
│
├─ EXECUTION PHASE
│  ├─ Show thought bubble (visual AI feedback)
│  ├─ Execute special actions
│  ├─ Fire weapons at target
│  └─ Apply damage
│
└─ REFLECTION PHASE
   ├─ Did our plan work?
   ├─ Update strategy confidence
   └─ Prepare for next turn
```

### **Decision Logging** _(Combat Log Integration)_

```
Every AI decision is logged for player understanding:

Example Log Entries:

"PLAYER AI (GLASS_CANNON): Targeting enemy REACTOR #2"
├─ Reasoning: High cascade value (would unpower 3 weapons)
├─ Threat Score: 85/100
└─ Doctrine Priority: ALPHA_STRIKE demands aggressive plays

"ENEMY AI (TURTLE): Targeting player WEAPON #1"
├─ Reasoning: Reduce incoming damage (defensive play)
├─ Threat Score: 65/100 (player weapon dealing 15 DPS)
└─ Doctrine Priority: DEFENSIVE_TURTLE prioritizes survival

"PLAYER AI: DESPERATE - All power to weapons!"
├─ Reasoning: Win probability < 20%, going all-in
├─ Action: Power routing (Shields → Weapons)
└─ Calculated Risk: High (sacrificing defense for offense)
```

---

## Advanced AI Behaviors

### **1. Predictive Play**

**AI looks 1-2 turns ahead and plans accordingly**

```gdscript
func plan_multi_turn_strategy(
    our_ship: ShipData,
    enemy_ship: ShipData,
    turns_ahead: int = 2
) -> StrategyPlan:

    var plan = StrategyPlan.new()

    # Simulate next N turns
    for turn in range(turns_ahead):
        # Clone ships for simulation
        var sim_our_ship = our_ship.duplicate_deep()
        var sim_enemy_ship = enemy_ship.duplicate_deep()

        # Simulate our turn
        var our_target = select_best_target(sim_our_ship, sim_enemy_ship)
        var our_damage = calculate_damage(sim_our_ship)
        apply_simulated_damage(sim_enemy_ship, our_damage, our_target)

        # Simulate enemy turn
        var enemy_target = select_best_target(sim_enemy_ship, sim_our_ship)
        var enemy_damage = calculate_damage(sim_enemy_ship)
        apply_simulated_damage(sim_our_ship, enemy_damage, enemy_target)

        # Evaluate outcome
        plan.projected_our_hp[turn] = sim_our_ship.current_hp
        plan.projected_enemy_hp[turn] = sim_enemy_ship.current_hp

    # Determine if current strategy wins
    if plan.projected_enemy_hp[turns_ahead - 1] <= 0:
        plan.outcome = "VICTORY"
    elif plan.projected_our_hp[turns_ahead - 1] <= 0:
        plan.outcome = "DEFEAT"
        plan.needs_strategy_shift = true  # Change approach!
    else:
        plan.outcome = "ONGOING"

    return plan

# Use predictive plan to adjust current turn
func make_predictive_decision(plan: StrategyPlan) -> int:
    if plan.needs_strategy_shift:
        # Current strategy leads to loss, try alternative
        return find_alternative_target()  # Switch to different priority
    else:
        # Current strategy is working, continue
        return select_best_target_normal()
```

**Example Scenarios:**

```
Scenario 1: "Two-Turn Knockout"
├─ Turn 3: Destroy enemy Reactor
├─ Turn 4 Prediction: 3 enemy weapons unpower → enemy DPS drops 30 → 15
├─ Turn 5 Prediction: We win damage race (our 40 DPS vs their 15 DPS)
└─ Decision: Target reactor aggressively, secure long-term advantage

Scenario 2: "Defensive Pivot"
├─ Turn 5: Currently targeting enemy reactor
├─ Turn 6 Prediction: Enemy destroys our last shield
├─ Turn 7 Prediction: We take 50 damage/turn (lethal in 2 turns)
└─ Decision: ABORT reactor plan, target enemy weapons instead

Scenario 3: "Calculated Sacrifice"
├─ Turn 4: We can destroy enemy weapon OR enemy shield
├─ Weapon Path: Reduces enemy DPS by 10 → we survive 1 extra turn
├─ Shield Path: Increases our damage by 15 → we kill enemy 1 turn faster
├─ Prediction: Shield path wins in 5 turns, Weapon path wins in 6 turns
└─ Decision: Target shield (optimal outcome)
```

---

### **2. Synergy Exploitation**

**AI recognizes and leverages its own synergies**

```gdscript
func exploit_synergies(our_ship: ShipData, personality: ShipPersonality) -> ActionPlan:
    var synergies = our_ship.calculate_synergy_bonuses()
    var action_plan = ActionPlan.new()

    # Fire Rate Synergy (Weapon+Weapon)
    if synergies["counts"][RoomData.SynergyType.FIRE_RATE] > 0:
        # We have weapon synergies - focus on burst damage
        action_plan.tactic = "ALPHA_STRIKE"
        action_plan.note = "Weapon synergies detected - maximizing burst"

        # If we can overcharge reactor, DO IT (amplify synergy)
        if personality.risk_tolerance > 0.6:
            action_plan.special_actions.append("OVERCHARGE_REACTOR")

    # Shield Capacity Synergy (Shield+Reactor)
    if synergies["counts"][RoomData.SynergyType.SHIELD_CAPACITY] > 0:
        # We have shield synergies - can afford to tank
        action_plan.tactic = "DEFENSIVE_POSTURE"
        action_plan.note = "Shield synergies detected - playing defensively"

        # Don't need to rush, we can outlast
        action_plan.aggression_modifier = -0.2

    # Initiative Synergy (Engine+Engine)
    if synergies["counts"][RoomData.SynergyType.INITIATIVE] > 0:
        # We shoot first - leverage initiative advantage
        action_plan.tactic = "FIRST_STRIKE_ADVANTAGE"
        action_plan.note = "Initiative synergies - striking first"

        # Target high-value targets (we'll hit before they respond)
        action_plan.targeting_priority = ["REACTOR", "WEAPON", "BRIDGE"]

    # Durability Synergy (Weapon+Armor)
    if synergies["counts"][RoomData.SynergyType.DURABILITY] > 0:
        # Our weapons are hard to kill - can play aggressively
        action_plan.tactic = "AGGRESSIVE_BRAWL"
        action_plan.note = "Durability synergies - weapons protected"

        # Don't need to protect weapons, focus on maximizing damage
        action_plan.aggression_modifier = +0.3

    return action_plan
```

---

### **3. Power Management AI**

**AI makes smart power-related decisions**

```gdscript
func manage_power_systems(
    our_ship: ShipData,
    combat_state: CombatState,
    personality: ShipPersonality
) -> PowerDecision:

    var decision = PowerDecision.new()
    decision.use_overcharge = false
    decision.route_power = PowerRoute.NONE

    # Check reactor overload opportunity
    if can_use_reactor_overload(our_ship):
        # Should we overcharge?
        var should_overcharge = false

        # Aggressive personalities overcharge often
        if personality.aggression > 0.7:
            should_overcharge = true

        # Desperate situations call for overcharge
        if combat_state.desperation > 0.6:
            should_overcharge = true

        # Winning by small margin - overcharge to secure victory
        if combat_state.win_probability > 0.55 and combat_state.win_probability < 0.75:
            should_overcharge = true

        # Cautious personalities only overcharge when desperate
        if personality.risk_tolerance < 0.4 and combat_state.desperation < 0.8:
            should_overcharge = false

        decision.use_overcharge = should_overcharge

        if should_overcharge:
            decision.reasoning = "Overcharging reactor to maximize power output"

    # Check emergency power routing opportunity
    if can_use_power_routing(our_ship):
        # Should we route power?

        # Losing badly - route shields to weapons (all-in offense)
        if combat_state.win_probability < 0.25:
            decision.route_power = PowerRoute.SHIELDS_TO_WEAPONS
            decision.reasoning = "Desperate: sacrificing defense for offense"

        # Winning but taking heavy damage - route weapons to shields
        elif combat_state.win_probability > 0.65 and combat_state.hp_ratio < 0.8:
            decision.route_power = PowerRoute.WEAPONS_TO_SHIELDS
            decision.reasoning = "Securing victory: protecting HP lead"

        # About to be destroyed - emergency thrust
        elif combat_state.time_to_die <= 2 and enemy_targeting_critical_room():
            decision.route_power = PowerRoute.ALL_TO_ENGINES
            decision.reasoning = "Emergency thrust: must shoot first next turn"

    return decision
```

---

### **4. Risk/Reward Calculations**

**AI evaluates high-risk plays and decides if worth it**

```gdscript
func evaluate_risky_play(
    action: RiskyAction,
    combat_state: CombatState,
    personality: ShipPersonality
) -> bool:

    var expected_value = 0.0

    # Calculate potential gain
    var potential_gain = action.success_value * action.success_probability

    # Calculate potential loss
    var potential_loss = action.failure_cost * action.failure_probability

    # Expected value = Gain - Loss
    expected_value = potential_gain - potential_loss

    # Adjust by personality
    if personality.risk_tolerance > 0.7:
        # Risk-tolerant: overvalue gains
        expected_value *= 1.3
    elif personality.risk_tolerance < 0.3:
        # Risk-averse: overvalue losses
        expected_value *= 0.7

    # Desperation makes risky plays more appealing
    if combat_state.desperation > 0.7:
        expected_value *= (1.0 + combat_state.desperation)

    # Momentum affects risk assessment
    if combat_state.momentum > 0.5:
        # Winning - can afford risks
        expected_value *= 1.2
    elif combat_state.momentum < -0.5:
        # Losing - risky plays are only hope
        expected_value *= 1.5

    # Decision threshold
    return expected_value > 10.0  # Positive expected value required

# Example: Should we overcharge reactor?
func should_overcharge_reactor(our_ship: ShipData, combat_state: CombatState) -> bool:
    var action = RiskyAction.new()

    # Success: +25% power output for 2 turns
    action.success_value = 30.0  # Equivalent to ~30 extra damage
    action.success_probability = 0.9  # 90% success rate

    # Failure: Reactor takes 20 damage (possibly destroyed)
    action.failure_cost = 40.0  # Losing reactor is catastrophic
    action.failure_probability = 0.1  # 10% failure rate

    return evaluate_risky_play(action, combat_state, personality)
```

---

### **5. Emergent Tactical Behaviors**

**AI discovers and executes advanced tactics**

#### **Reactor Sniping**

```
Tactic: Target enemy reactor to cascade-disable weapons

Conditions:
├─ Enemy has single reactor
├─ Reactor powers 3+ weapons
└─ We can destroy reactor this turn

Execution:
├─ Focus fire all weapons on reactor
├─ Predict cascade: reactor destroyed → 4 weapons unpower
├─ Next turn: enemy DPS drops 40 → 10
└─ We gain massive advantage

AI Reasoning:
"Reactor destruction will unpower 4 weapons. Trading 1 turn of focused fire for
permanent -30 DPS is optimal. Execute reactor snipe."
```

#### **Synergy Breaking**

```
Tactic: Destroy one room in synergy pair to break bonus

Conditions:
├─ Enemy has fire rate synergy (2 adjacent weapons)
└─ Breaking synergy reduces their DPS by 15%

Execution:
├─ Target one weapon in synergy pair
├─ Destroys synergy bonus for BOTH weapons
└─ More efficient than targeting non-synergized weapons

AI Reasoning:
"Enemy weapons have fire rate synergy. Destroying Weapon #2 breaks synergy for
Weapon #1 and #2, reducing total DPS by 22. Higher value than destroying
isolated Weapon #3."
```

#### **Shield Overwhelming**

```
Tactic: Ignore shields and kill enemy faster via raw damage

Conditions:
├─ Enemy shields absorb < 30% of our damage
├─ We can kill enemy in 4 turns
└─ Destroying shields would take 2 turns

Execution:
├─ Ignore shields entirely
├─ Focus weapons and reactor
├─ Accept reduced damage to win faster
└─ Math: Kill in 4 turns vs 6 turns (if we destroyed shields first)

AI Reasoning:
"Enemy shields only block 20 damage per turn. Destroying shields would take 2 turns
but only speeds up kill by 1 turn total. Not worth it. Bypass shields, target
weapons/reactors directly."
```

#### **Sacrifice Play**

```
Tactic: Accept loss of our room to secure critical enemy destruction

Conditions:
├─ Enemy about to destroy our shield
├─ We can destroy enemy reactor this turn
└─ Trade: Lose 1 shield for destroying 1 reactor + unpowering 4 weapons

Execution:
├─ Accept shield loss
├─ Focus fire on reactor
├─ Net gain: -15 absorption, +40 enemy DPS reduction
└─ Massive advantage

AI Reasoning:
"Enemy will destroy our Shield #1 this turn (-15 absorption). If we target their
Reactor, we unpower 4 weapons (-40 enemy DPS). This trade massively favors us.
Accept shield loss, execute reactor kill."
```

#### **Power Grid Exploitation**

```
Tactic: Destroy relay to cascade-unpower multiple rooms

Conditions:
├─ Enemy using relay to power multiple rooms
├─ Relay powers 5+ rooms within radius
└─ Relay is vulnerable (low armor, no durability synergy)

Execution:
├─ Target relay with all weapons
├─ Relay destroyed → 6 rooms lose power
├─ Enemy ship crippled in one turn
└─ Equivalent to destroying 6 rooms individually (would take 3 turns)

AI Reasoning:
"Enemy Relay #1 powers 6 rooms: 2 weapons, 2 shields, 1 engine, 1 weapon.
Destroying relay unpowers all 6 rooms simultaneously. This is 3x more efficient
than targeting rooms individually. Execute relay snipe."
```

---

## Visual Feedback & Player Understanding

### **Critical Requirement: Player Must Understand AI Decisions**

In an auto-battler, players MUST understand why AI made each choice, or they can't improve their designs.

#### **1. AI Thought Bubbles**

**Visual indicator showing AI's current intention**

```
Displayed above ship before action:

┌──────────────────────────────┐
│  🎯 Targeting REACTOR #2     │
│  "Cascade Effect"            │
└──────────────────────────────┘

┌──────────────────────────────┐
│  ⚡ OVERCHARGING REACTOR     │
│  "Going All-In!"             │
└──────────────────────────────┘

┌──────────────────────────────┐
│  🛡️ Targeting WEAPON #3      │
│  "Defensive Play"            │
└──────────────────────────────┘

┌──────────────────────────────┐
│  💀 DESPERATE GAMBLE         │
│  "Nothing to Lose"           │
└──────────────────────────────┘
```

**Implementation:**
```gdscript
func show_ai_thought_bubble(ship_display: ShipDisplay, decision: AIDecision):
    var bubble = ThoughtBubble.new()
    bubble.position = ship_display.position + Vector2(0, -100)

    # Icon based on action type
    var icon = _get_decision_icon(decision.action_type)
    bubble.set_icon(icon)

    # Primary text
    bubble.set_primary_text(decision.target_description)

    # Reasoning subtitle
    bubble.set_subtitle(decision.reasoning_short)

    # Color based on doctrine
    bubble.set_color(_get_doctrine_color(decision.doctrine))

    add_child(bubble)

    # Fade out after 1.5 seconds
    await get_tree().create_timer(1.5 * speed_multiplier).timeout
    bubble.queue_free()
```

---

#### **2. Enhanced Combat Log**

**Detailed AI reasoning in text log**

```
Turn 3 - PLAYER TURN (GLASS CANNON)
├─ Analyzed threat: Enemy REACTOR #2 (Threat: 85/100)
├─ Reasoning: "Reactor powers 4 weapons. Destroying it will reduce enemy DPS by 40."
├─ Decision: Target REACTOR #2
├─ Doctrine: ALPHA_STRIKE (Aggressive offense)
└─ Confidence: HIGH (92%)

Turn 4 - ENEMY TURN (TURTLE)
├─ Analyzed threat: Player WEAPON #1 (Threat: 70/100)
├─ Reasoning: "Weapon deals 15 DPS and has fire rate synergy. High priority."
├─ Decision: Target WEAPON #1
├─ Doctrine: DEFENSIVE_TURTLE (Minimize incoming damage)
├─ Special Action: None (risk tolerance too low)
└─ Confidence: MEDIUM (68%)

Turn 5 - PLAYER TURN (GLASS CANNON)
├─ Combat State: DESPERATE (Win prob: 18%, HP: 25%)
├─ Analyzed threat: Enemy BRIDGE (Threat: 100/100)
├─ Reasoning: "Must go all-in. Bridge is instant win."
├─ Decision: Target BRIDGE
├─ Special Action: OVERCHARGE REACTOR (+25% damage)
├─ Doctrine: ALPHA_STRIKE → BERSERKER_RUSH (desperation shift)
└─ Confidence: LOW (35%, high risk)
```

---

#### **3. Target Highlighting**

**Visual indicators on target before attack**

```
Before weapons fire:
├─ Target room flashes yellow (2 quick flashes)
├─ Targeting reticle appears over target
├─ Threat indicator shows above target:
│   ├─ 💀 (CRITICAL THREAT)
│   ├─ ⚠️ (HIGH THREAT)
│   └─ ℹ️ (MEDIUM THREAT)
└─ Optional: Show threat score number (85/100)
```

**Implementation:**
```gdscript
func highlight_target(target_room_id: int, threat_score: float):
    var room_pos = defender_display.get_room_center(target_room_id)

    # Flash target yellow
    var target_room = defender_display.room_instance_nodes[target_room_id]
    for i in range(2):
        target_room.modulate = Color(2.0, 2.0, 0.5)  # Yellow flash
        await get_tree().create_timer(0.1 * speed_multiplier).timeout
        target_room.modulate = Color(1.0, 1.0, 1.0)
        await get_tree().create_timer(0.1 * speed_multiplier).timeout

    # Show threat reticle
    var reticle = TargetReticle.new()
    reticle.position = room_pos
    reticle.set_threat_level(threat_score)
    add_child(reticle)

    await get_tree().create_timer(1.0 * speed_multiplier).timeout
    reticle.queue_free()
```

---

#### **4. Doctrine Indicator**

**Persistent UI element showing current AI doctrine**

```
Player Ship:
┌────────────────────────┐
│ DOCTRINE: GLASS CANNON │
│ Strategy: Alpha Strike │
│ Aggression: ████████░░ │
│ Risk: ███████░░░       │
└────────────────────────┘

Enemy Ship:
┌────────────────────────┐
│ DOCTRINE: TURTLE       │
│ Strategy: Defensive    │
│ Aggression: ██░░░░░░░░ │
│ Risk: ██░░░░░░░░       │
└────────────────────────┘
```

**Implementation:**
```gdscript
func update_doctrine_display(ship_personality: ShipPersonality):
    doctrine_label.text = "DOCTRINE: %s" % get_archetype_name(ship_personality.archetype)
    strategy_label.text = "Strategy: %s" % get_doctrine_name(ship_personality.doctrine)

    aggression_bar.max_value = 1.0
    aggression_bar.value = ship_personality.aggression

    risk_bar.max_value = 1.0
    risk_bar.value = ship_personality.risk_tolerance
```

---

#### **5. Post-Battle Analysis**

**AI decisions summary screen after battle**

```
POST-BATTLE ANALYSIS
═══════════════════════════════

PLAYER AI (GLASS CANNON):
├─ Primary Targets: Reactors (60%), Weapons (30%), Bridge (10%)
├─ Doctrine Shifts: ALPHA_STRIKE → BERSERKER_RUSH (Turn 5, desperate)
├─ Special Actions: 2x Reactor Overcharge, 1x Power Routing
├─ Efficiency: 85% (optimal targets 17/20 turns)
└─ Key Moments:
    ├─ Turn 3: Reactor snipe disabled 4 enemy weapons
    └─ Turn 7: Desperate overcharge secured victory

ENEMY AI (TURTLE):
├─ Primary Targets: Weapons (80%), Shields (15%), Reactors (5%)
├─ Doctrine Shifts: None (consistent defensive play)
├─ Special Actions: None (low risk tolerance)
├─ Efficiency: 72% (conservative targeting)
└─ Key Moments:
    ├─ Turn 4: Destroyed player weapon, reduced incoming DPS
    └─ Turn 6: Failed to adapt to player's aggressive pivot

PLAYER VICTORY (8 turns)
Winning Factor: Aggressive reactor targeting disrupted enemy power grid
```

---

## Implementation Roadmap

### **Phase 1: Foundation** _(1-2 weeks)_

**Build core AI architecture**

1. **Ship Profile Analyzer** (2 days)
   - Implement archetype detection
   - Calculate stat ratings
   - Identify strengths/weaknesses
   - Determine capabilities

2. **Combat State Evaluator** (2 days)
   - Implement win probability calculation
   - HP ratio and DPS tracking
   - Momentum and desperation metrics
   - State-based strategy adjustment

3. **Basic Doctrine System** (2 days)
   - Implement 3 core doctrines (ALPHA_STRIKE, DEFENSIVE, ADAPTIVE)
   - Personality trait calculation
   - Doctrine-based targeting priorities
   - Testing and balancing

4. **Enhanced Combat Log** (1 day)
   - Add AI reasoning to log entries
   - Show targeting priorities
   - Display doctrine shifts
   - Format for readability

**Total Phase 1:** 7-8 days

---

### **Phase 2: Threat Intelligence** _(1-2 weeks)_

**Implement smart targeting**

1. **Threat Assessment System** (3 days)
   - Calculate threat scores for all room types
   - Weapon threat (DPS + synergies)
   - Reactor threat (cascade effects)
   - Shield threat (damage blocking)
   - Engine threat (initiative advantage)
   - Threat-based targeting

2. **Multi-Factor Target Scoring** (2 days)
   - Implement scoring algorithm
   - Doctrine modifiers
   - Situational modifiers
   - Predictive bonuses
   - Synergy disruption bonuses

3. **Multi-Target Distribution** (1 day)
   - 4+ weapons split fire logic
   - Target diversity algorithm
   - Visual multi-target lines

**Total Phase 2:** 6-7 days

---

### **Phase 3: Advanced Behaviors** _(2-3 weeks)_

**Add depth and variety**

1. **Predictive Planning** (3 days)
   - Implement turn-ahead simulation
   - Strategy path evaluation
   - Alternative target selection
   - Plan visualization (optional)

2. **Synergy Exploitation** (2 days)
   - Detect own synergies
   - Adjust tactics based on synergies
   - Leverage synergy advantages
   - Testing with various builds

3. **Power Management AI** (3 days)
   - Reactor overload decision logic
   - Emergency power routing decisions
   - Risk/reward evaluation
   - Special ability usage timing

4. **Emergent Tactics** (3 days)
   - Reactor sniping logic
   - Synergy breaking logic
   - Shield overwhelming logic
   - Power grid exploitation
   - Testing and refinement

5. **Remaining Doctrine** (2 days)
   - Implement SURGICAL_STRIKE
   - Implement BERSERKER_RUSH
   - Implement WAR_OF_ATTRITION
   - Balance all 6 doctrines

**Total Phase 3:** 13-15 days

---

### **Phase 4: Visual Feedback** _(1-2 weeks)_

**Make AI understandable**

1. **AI Thought Bubbles** (2 days)
   - Design bubble UI
   - Icon system
   - Text formatting
   - Fade animations
   - Testing clarity

2. **Target Highlighting** (1 day)
   - Flash effect
   - Threat reticle
   - Threat score display
   - Timing/pacing

3. **Doctrine UI** (1 day)
   - Persistent doctrine display
   - Aggression/risk bars
   - Strategy label
   - Real-time updates

4. **Post-Battle Analysis** (2 days)
   - Summary screen design
   - AI statistics tracking
   - Key moment identification
   - Efficiency scoring

**Total Phase 4:** 6-7 days

---

### **Phase 5: Polish & Balancing** _(1-2 weeks)_

**Refinement and testing**

1. **Doctrine Balancing** (3 days)
   - Test all 6 doctrines against each other
   - Win rate matrix (should be ~50% for each matchup)
   - Adjust aggression/risk values
   - Ensure no dominant strategy

2. **AI vs AI Variety** (2 days)
   - Watch 100+ AI vs AI battles
   - Ensure interesting variety in combat
   - No repetitive patterns
   - Different builds produce different behaviors

3. **Player Build Testing** (2 days)
   - Test 20+ different player ship designs
   - Ensure AI adapts appropriately
   - Glass cannon should see aggressive AI
   - Turtle should see patient AI
   - Verify learning curve (player can predict AI)

4. **Performance Optimization** (1 day)
   - Optimize threat calculation
   - Cache profile analysis
   - Reduce per-frame calculations
   - Maintain 60fps combat

**Total Phase 5:** 8-10 days

---

### **Total Implementation Timeline**

- **Phase 1:** 1-2 weeks (Foundation)
- **Phase 2:** 1-2 weeks (Threat Intelligence)
- **Phase 3:** 2-3 weeks (Advanced Behaviors)
- **Phase 4:** 1-2 weeks (Visual Feedback)
- **Phase 5:** 1-2 weeks (Polish & Balance)

**Grand Total:** ~8-12 weeks (2-3 months of focused development)

---

## Design Validation

### **Success Criteria**

The AI system succeeds if:

1. **Clarity** ✓
   - Player can predict AI behavior after 2-3 battles
   - Combat log explains all AI decisions
   - Visual feedback shows AI reasoning
   - No "What just happened?" moments

2. **Variety** ✓
   - Different ship builds produce noticeably different AI behavior
   - No two battles look identical
   - Players see meaningful differences between archetypes
   - AI adapts to player's design choices

3. **Drama** ✓
   - Close battles feel tense (win probability 40-60%)
   - AI makes exciting plays (overcharges, desperate gambits)
   - Dominant victories feel earned (player outsmarted AI)
   - Losses are educational (player sees what went wrong)

4. **Strategic Depth** ✓
   - AI exploits synergies intelligently
   - AI recognizes and counters player strategies
   - AI makes "smart" plays that feel intentional
   - Advanced tactics emerge from core rules

5. **Player Agency** ✓
   - Ship design choices directly affect combat outcome
   - Room placement matters (power grid, synergies)
   - Build philosophy determines AI behavior
   - Players feel "My design made this happen"

### **Testing Metrics**

**Quantitative:**
- Win rate matrix (6 doctrines vs 6 doctrines = 36 matchups)
- Target: Each doctrine wins 40-60% against others
- Combat duration: 5-12 turns average
- AI efficiency: 70%+ optimal target selection

**Qualitative:**
- Playtest feedback: "I understand why I lost"
- Playtest feedback: "The AI felt smart"
- Playtest feedback: "My design mattered"
- Playtest feedback: "Combat was fun to watch"

---

## Conclusion

### **Key Takeaways**

1. **Auto-battler AI must be performative, not just challenging**
   - Players watch, don't fight
   - Clarity matters more than difficulty
   - Visual feedback is critical

2. **Ship design should determine AI behavior**
   - Glass cannon → aggressive AI
   - Turtle → patient AI
   - Player sees their philosophy reflected

3. **AI must create narrative moments**
   - Desperate gambits
   - Clutch victories
   - Smart plays that feel intentional

4. **Depth emerges from core systems**
   - Threat assessment + Doctrine + State evaluation = complex behavior
   - No need for scripted moments
   - AI discovers tactics naturally

5. **Player learning is core gameplay loop**
   - Watch AI fight
   - Understand decisions
   - Redesign ship to counter
   - Repeat

### **Recommended Priority**

**MVP (6-8 weeks):**
- Phase 1: Foundation (core architecture)
- Phase 2: Threat Intelligence (smart targeting)
- Phase 4: Visual Feedback (thought bubbles, log, highlighting)

**Full System (10-12 weeks):**
- Add Phase 3: Advanced Behaviors (predictive play, synergies)
- Add Phase 5: Polish & Balance (extensive testing)

**Post-Launch:**
- Add machine learning layer (AI learns from player designs)
- Add custom doctrine editor (player creates AI personalities)
- Add AI difficulty levels (beginner → expert)

---

**This AI system transforms combat from "watch two ships trade blows" into "watch two intelligent commanders outsmart each other."**
