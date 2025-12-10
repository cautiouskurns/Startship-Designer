# Combat System Enhancement Proposals

**Generated:** December 10, 2025
**Current Build:** Starship Designer Prototype

---

## Table of Contents

1. [Current Combat System Overview](#current-combat-system-overview)
2. [Enhancement Proposals](#enhancement-proposals)
   - [1. Enemy AI & Decision Making](#1-enemy-ai--decision-making)
   - [2. VFX/SFX Enhancements](#2-vfxsfx-enhancements)
   - [3. Turn Flow Refinements](#3-turn-flow-refinements)
   - [4. Ship Systems Integration](#4-ship-systems-integration)
   - [5. Campaign/Meta Integration](#5-campaignmeta-integration)
3. [Prioritized Roadmap](#prioritized-roadmap)
4. [Specific Recommendations](#specific-recommendations)

---

## Current Combat System Overview

### ✅ What's Already Implemented

#### **Enemy AI & Targeting**
- **Targeting Priority System**: RANDOM, WEAPONS_FIRST, POWER_FIRST
- Different enemies use different strategies:
  - Scout → RANDOM targeting
  - Raider → WEAPONS_FIRST
  - Dreadnought → POWER_FIRST
- Visual targeting lines with arrows showing attack destination
- Primary target flashes white before being hit
- Consistent targeting (same target selected for visual feedback and actual destruction)

#### **VFX (Visual Effects)**
- Muzzle flashes at weapon firing points
- Laser beams (player ships) vs Torpedoes (enemy ships)
- Shield impact ripples (expanding cyan rings)
- Hull impact particles (red debris with gravity)
- Screen shake for significant hits (>20 damage)
- Room destruction animations with explosions
- Ship color flashing (red when hit, green/red at victory/defeat)
- Turn indicator pulse animations

#### **SFX (Sound Effects)**
Already integrated via `AudioManager`:
- Laser fire sounds
- Explosion sounds
- Reactor powerdown sound
- Victory/defeat fanfares
- Button click feedback
- Event start sound

#### **Turn Flow**
- Pause/Resume functionality
- 4-speed fast-forward system (0.25x, 0.5x, 1x, 2x)
- Turn indicators with pulse animations and color coding
- Initiative system based on powered engines
- Synergy bonuses affect initiative
- Hull bonuses affect initiative (Frigate +2)
- Comprehensive combat log tracking all actions
- Full replay system capturing every turn state

#### **Ship Systems Integration**
- Power grid affects all systems (powered/unpowered states)
- Synergy bonuses:
  - **Fire Rate**: Weapon+Weapon (+15% damage per weapon)
  - **Shield Capacity**: Shield+Reactor (+20% absorption per shield)
  - **Initiative**: Engine+Engine (+1 initiative per synergy)
  - **Durability**: Weapon+Armor (33% chance to resist destruction)
- Hull bonuses (HP, Initiative from ship type):
  - Battleship: +20 HP
  - Frigate: +2 Initiative
- Sector bonuses (Campaign mode):
  - Damage modifier
  - Shield modifier
  - HP modifier
  - All stats modifier
- Reactor destruction triggers power recalculation
- Real-time stats panels showing weapon/shield/engine counts
- Zoom & Pan controls (WASD + mouse wheel)
- Combat replay system with timeline scrubbing
- Post-battle analysis panel

---

## Enhancement Proposals

### 1. Enemy AI & Decision Making

#### A. Adaptive AI Behaviors

**Current State:**
- Fixed targeting priorities per enemy type (set once, never changes)

**Enhancement:**
Dynamic decision-making based on combat state

```
Suggested AI Personalities:
├── AGGRESSOR: High HP → focus damage, Low HP → target shields/engines to survive
├── OPPORTUNIST: Targets weakest/unpowered rooms first
├── DEFENSIVE: Prioritizes player weapons when at risk
├── BERSERKER: Ignores self-preservation, all-out offense when low HP
└── TACTICAL: Switches strategy mid-combat based on player build
```

**Implementation Approach:**
1. Add `ai_personality` enum to ShipData
2. Create `_evaluate_combat_state()` function that analyzes:
   - HP ratios (who's winning)
   - Remaining firepower (active weapons count)
   - Threat assessment (player DPS vs enemy shields)
   - Turn count (desperation increases over time)
3. AI switches priority mid-battle based on evaluation
   - Example: Raider starts WEAPONS_FIRST, switches to POWER_FIRST if losing badly

**User Experience Benefits:**
- Combat feels less predictable and more challenging
- Rewards players who notice and exploit AI patterns
- Creates memorable "oh shit" moments when AI adapts
- Makes replaying missions more interesting

**Estimated Effort:** Medium (1-2 days)

---

#### B. Multi-Target Selection

**Current State:**
- All weapons fire at single target per turn
- Multiple weapons feel redundant (just increase damage number)

**Enhancement:**
Weapons distribute fire across multiple targets based on weapon count

```
Distribution Rules:
├── 1-2 weapons: Single target (current behavior)
├── 3-4 weapons: Split fire between 2 targets
└── 5+ weapons: Distribute across 3+ vulnerable targets
```

**Implementation Approach:**
1. Modify `_select_target_room()` to return `Array[int]` of target room IDs
2. Distribute weapon fire visually:
   - Some lasers aim at target A, others at target B
   - Each weapon still shows targeting line to its specific target
3. Damage calculations:
   - Total damage remains same
   - Distribute room destructions across multiple targets
   - More chaotic/realistic destruction pattern

**Visual Changes:**
- Multiple targeting lines/arrows (color-coded or faded)
- Staggered laser firing (weapons fire in sequence, not all at once)
- Multiple explosion locations on defender ship

**User Experience Benefits:**
- High weapon count feels more impactful visually
- Room placement matters more (concentrated vs spread weapons)
- Combat feels more dynamic and less "watch same explosion 5 times"

**Estimated Effort:** Low-Medium (1 day)

---

### 2. VFX/SFX Enhancements

#### A. Advanced Visual Feedback

##### **Critical Hit Effects**

**When Bridge/Reactor Destroyed:**
- Golden flash instead of regular red flash
- Larger explosion radius (2x normal size)
- Brief slow-motion zoom-in (0.5s at 0.25x speed)
- Screen border flash:
  - Red pulse for player critical hit received
  - Cyan pulse for enemy critical hit received
- Dramatic sound effect (deeper boom + reverb)

**Implementation:**
```gdscript
func _destroy_critical_room(room_type: RoomType, defender_display: ShipDisplay):
    if room_type == RoomData.RoomType.BRIDGE or room_type == RoomData.RoomType.REACTOR:
        # Trigger critical hit sequence
        _show_critical_hit_effect(defender_display)
        await _zoom_in_dramatic(defender_display.get_room_center(room_id))
        await _spawn_critical_explosion(position)
        _flash_screen_border(Color.RED if defender == player_data else Color.CYAN)
```

**Estimated Effort:** Low (4-6 hours)

---

##### **Overkill Effects**

**When Damage >> Shields:**
- Shield sparking/crackling effect before breaking
- Extra particle explosions for massive hits (50+ damage)
- Lightning arcs across ship display
- Damage number shows "SHIELDS OVERLOADED" instead of just number

**Visual Specs:**
- Threshold: Damage > Shield Absorption × 1.5
- Effect: Blue lightning particles from impact point spreading across ship
- Duration: 0.5s
- Sound: Electric zap + shield break sound

**Estimated Effort:** Low (3-4 hours)

---

##### **Power System Visualization**

**When Reactor Destroyed:**
- Power "drain wave" animates from reactor to powered rooms
- Wave uses blue glowing line (similar to power lines in designer)
- Unpowered rooms flicker 3 times, then dim to gray
- Duration: 1 second total

**Visual Specs:**
```
Animation Sequence:
1. Reactor explodes (current behavior)
2. Blue wave emanates from reactor center (Line2D with expanding circle)
3. Wave reaches each powered room (0.3s travel time)
4. Room receives "power loss" flash (blue → dark)
5. Room sprite modulates to 50% brightness
```

**Relay Pulse Animation:**
- Relay shows pulsing glow when actively distributing power
- Pulse frequency: 1 pulse per 2 seconds
- Color: Cyan (#4AE2E2) at 50% opacity
- Helps player understand relay coverage radius

**Estimated Effort:** Medium (1 day)

---

##### **Ship Status Indicators**

**Progressive Damage States:**

| HP Range | Visual Effect | Implementation |
|----------|---------------|----------------|
| 75-100% | Clean | Default sprites |
| 50-74% | Light Smoke | Add CPUParticles2D (gray smoke, slow rise) |
| 25-49% | Heavy Smoke + Sparks | Add fire particles + electrical sparks |
| 0-24% | Critical State | Add hull cracks (Line2D overlays), red glow |

**Implementation:**
```gdscript
func _update_ship_damage_state(ship: ShipData, display: ShipDisplay):
    var hp_percent = float(ship.current_hp) / float(ship.max_hp)

    if hp_percent < 0.25:
        display.show_critical_damage_effects()
    elif hp_percent < 0.5:
        display.show_heavy_damage_effects()
    elif hp_percent < 0.75:
        display.show_light_damage_effects()
    else:
        display.clear_damage_effects()
```

**Benefits:**
- Glanceable ship status without checking HP bars
- Increases tension as damage accumulates
- Provides clear visual feedback on combat progress

**Estimated Effort:** Medium (1-1.5 days)

---

##### **Environmental Effects**

**Optional Polish:**
- Background star parallax during camera movement
- Space debris floating across screen (random intervals)
- Distant nebula/planet scenery (static background layer)
- Occasional asteroid passing through combat zone

**Priority:** Low (cosmetic polish for post-MVP)

**Estimated Effort:** Medium (1-2 days)

---

#### B. Enhanced Audio

##### **Dynamic Music System**

**Intensity Layers:**
```
Music Tracks:
├── Base Layer: Ambient space ambience (always playing)
├── +Combat Layer: Drums + bass (starts at combat begin)
├── +Tension Layer: Strings (activates when either ship < 50% HP)
└── +Danger Layer: Intense synth (activates when player < 30% HP)
```

**Implementation:**
- Use AudioStreamPlayer with multiple tracks
- Crossfade layers based on combat state
- Each layer volume controlled independently

**Special Moments:**
- Victory Fanfare: Triumphant brass (Mission 1-2)
- Final Victory: Full orchestral swell (Mission 3)
- Defeat Sting: Dark, ominous chord

**Estimated Effort:** Medium-High (requires music composition/licensing)

---

##### **Spatial Audio**

**Pan Audio Based on Position:**
- Player weapons fire from left speaker
- Enemy weapons fire from right speaker
- Explosions pan based on which ship (left = player, right = enemy)
- Shield impacts have "whoosh" reverb effect

**Implementation:**
```gdscript
func play_positional_sound(sound: AudioStream, is_player_ship: bool):
    var player = AudioStreamPlayer.new()
    player.stream = sound
    player.bus = "SFX"
    # Pan: -1 = left (player), +1 = right (enemy)
    player.pan = -0.7 if is_player_ship else 0.7
    add_child(player)
    player.play()
```

**Estimated Effort:** Low (2-3 hours)

---

##### **Room-Specific Destruction Sounds**

**Current:** Generic explosion sound for all rooms

**Enhanced:** Different sounds per room type:

| Room Type | Sound Description | Audio Layers |
|-----------|-------------------|--------------|
| Reactor | Deep BOOM + power-down whine | Explosion + electrical hum fade |
| Weapon | Sharp crack + ammo cook-off | Crack + secondary pops |
| Shield | Electric discharge fizz | Capacitor discharge + sparking |
| Engine | Rumble + fire whoosh | Explosion + roaring fire |
| Bridge | Metallic crunch + alarm | Structural collapse + klaxon |
| Armor | Dull thud + debris scatter | Impact + metal fragments |

**Staggered Destruction:**
- When multiple rooms destroyed in one turn, play sounds 0.2s apart
- Creates auditory cascade effect
- Makes multi-room destruction feel more impactful

**Estimated Effort:** Low-Medium (4-6 hours + audio sourcing)

---

##### **Feedback Sounds**

**Low HP Alarm:**
- Activates when player < 25% HP
- Slow beep (1 beep per 2 seconds)
- Increases tension and awareness
- Can be muted in settings

**Weapon Charging:**
- 0.5s "charging hum" before weapons fire
- Builds anticipation for attack
- Pitch increases as charge builds

**Victory/Defeat Voiceover:**
- "Mission Complete" (robotic AI voice)
- "Ship Destroyed" (static-laden voice)
- Adds professionalism and immersion

**Estimated Effort:** Low (2-3 hours + voice recording)

---

### 3. Turn Flow Refinements

#### A. Turn Pacing Options

##### **Auto-Skip Turns**

**Scenario:**
Player is dominating (HP > 75%, enemy HP < 40%)

**Feature:**
- "Skip to Critical Event" button appears
- Fast-forwards through boring turns until:
  - Player HP drops below 60%
  - Enemy about to destroy critical room
  - Combat ends
- Shows summary: "Skipped 3 turns, dealt 45 damage"

**Implementation:**
```gdscript
func _auto_skip_boring_turns():
    while _is_combat_boring() and combat_active:
        _execute_turn_silently()  # No animations, instant calculations
        turn_count += 1

    # Resume normal combat
    combat_log.add_message("--- Fast-forwarded through %d turns ---" % skipped_turns)
```

**User Experience:**
- Reduces tedium in one-sided fights
- Player retains control (opt-in button)
- Useful for testing/replaying

**Estimated Effort:** Low (3-4 hours)

---

##### **Critical Moment Slowdown**

**Auto-Adjust Speed Based on Drama:**

```
Speed Adjustments:
├── Player HP > 75%: 1x speed (normal)
├── Player HP 50-75%: 0.75x speed (slight slowdown)
├── Player HP 25-50%: 0.5x speed (dramatic)
├── Player HP < 25%: 0.25x speed (extreme tension)
└── Bridge/Reactor about to be destroyed: 0.25x + zoom
```

**Implementation:**
- Check at start of each turn
- Smoothly transition speed_multiplier
- Add visual indicator: "CRITICAL SITUATION" banner

**Toggle Option:**
- Settings: "Dynamic Combat Pacing" (ON/OFF)
- Respects player preference for control vs automation

**Estimated Effort:** Low (2-3 hours)

---

##### **Turn Prediction Preview**

**Show Before Turn Executes:**
- Estimated damage to be dealt
- Probability of which rooms will be destroyed
- Visual highlight on likely target rooms (pulsing red outline)

**Display Format:**
```
┌─────────────────────────────┐
│ NEXT TURN PREDICTION        │
├─────────────────────────────┤
│ Attacker: ENEMY             │
│ Estimated Damage: 35-40     │
│ Shield Absorption: 25       │
│ Net Damage: 10-15           │
│                             │
│ Likely Targets:             │
│ • Weapon #2 (60%)           │
│ • Shield #1 (40%)           │
└─────────────────────────────┘
```

**Benefits:**
- Reduces "wait and see" tedium
- Helps player learn combat mechanics
- Creates suspense ("Please don't hit my reactor!")

**Implementation Complexity:**
- Requires duplicating damage calculation logic
- Must handle RNG prediction (show ranges/probabilities)

**Estimated Effort:** Medium (1 day)

---

##### **Skip To End Option**

**"Simulate Remaining Combat" Button:**
- Instantly calculates remaining turns without animation
- Shows final result screen
- Useful for:
  - Testing ship designs quickly
  - Replaying missions
  - When outcome is obvious

**Safeguard:**
- Confirmation dialog: "Are you sure? This will skip all animations."
- Only appears after Turn 3 (prevent accidental clicks)

**Estimated Effort:** Low (2-3 hours)

---

#### B. Turn Interruptions

##### **Chain Explosions**

**Mechanic:**
When reactor destroyed, adjacent rooms take spillover damage

**Rules:**
- Reactor explosion deals 20 damage to all adjacent rooms
- Adjacent rooms check if destroyed (20 damage = 1 room threshold)
- If adjacent room is also a reactor → another chain explosion
- Maximum chain depth: 3 explosions

**Visual:**
- Primary reactor explodes (red particles)
- 0.3s delay
- Adjacent rooms flash red simultaneously
- Secondary explosions for any adjacent rooms destroyed
- Dramatic screen shake (intensity increases with chain length)

**Implementation:**
```gdscript
func _handle_reactor_chain_explosion(reactor_pos: Vector2i, defender: ShipData):
    var adjacent_rooms = _get_adjacent_rooms(reactor_pos)

    for room_id in adjacent_rooms:
        var room_data = defender.room_instances[room_id]

        # Apply chain damage (not tracked as regular damage)
        if _should_destroy_from_chain(room_data):
            await _destroy_room_with_explosion(room_id)

            # Check if this was also a reactor
            if room_data["type"] == RoomData.RoomType.REACTOR:
                await _handle_reactor_chain_explosion(room_pos, defender)  # Recursive
```

**Balance Consideration:**
- Makes reactor placement risk vs reward
- Clustering reactors = more power, but chain explosion risk
- Adds strategic depth to ship design

**Estimated Effort:** Medium (1 day)

---

##### **Shield Overload**

**Mechanic:**
When shields absorb massive hit (>80 damage), chance to overload

**Rules:**
- Threshold: Shield absorption > 80 damage in single turn
- Chance: 30% per hit over threshold
- Effect: Shields disabled for 1 turn (0 absorption next turn)
- Visual: Shield room flickers blue → red, shows "OVERLOADED" text

**Implementation:**
```gdscript
func _check_shield_overload(defender: ShipData, absorption: int) -> bool:
    if absorption > 80:
        if randf() < 0.3:
            defender.shield_overloaded = true  # Flag checked during next turn
            combat_log.add_message("SHIELDS OVERLOADED! Disabled for 1 turn.")
            return true
    return false
```

**Balance:**
- Punishes over-reliance on shields
- Encourages armor investment as backup
- Makes alpha-strike builds more viable (burst through shields)

**Estimated Effort:** Low-Medium (4-6 hours)

---

##### **Emergency Engine Boost**

**Player Ability:**
One-time use per battle, guarantees next turn initiative

**Usage:**
- Button appears on turn 2+
- Click to activate: "EMERGENCY THRUST ENGAGED"
- Next turn, player shoots first regardless of engine count
- Button grays out after use

**Visual Feedback:**
- Engine rooms glow bright cyan
- Ship Display shakes slightly (thrust effect)
- Turn indicator shows: "PLAYER TURN (BOOSTED)"

**Strategic Value:**
- Allows player to interrupt dangerous enemy turn
- Must choose optimal moment (only once!)
- Adds player agency during combat

**Implementation:**
```gdscript
func _activate_emergency_boost():
    emergency_boost_used = true
    boost_button.disabled = true
    boost_active_next_turn = true

    # Visual feedback
    player_ship_display.flash_engines(Color.CYAN)
    combat_log.add_message("EMERGENCY THRUST! Player will shoot first next turn.")
```

**Estimated Effort:** Low (3-4 hours)

---

##### **Weapon Malfunction**

**Mechanic:**
Damaged weapons (via durability system) have chance to jam

**Rules:**
- Only if room degradation system implemented (see Section 4B)
- CRITICAL state weapons: 15% chance to fail
- DAMAGED state weapons: 5% chance to fail
- Failed weapon: Shows "JAMMED" indicator, deals 0 damage that turn
- Repair chance: 50% each turn (auto-repairs)

**Visual:**
- Weapon room flashes yellow during fire sequence
- Muzzle flash fails (no laser fired)
- Damage number shows: "WEAPON JAMMED (-10 damage)"

**Balance:**
- Incentivizes protecting weapons (armor placement)
- Adds unpredictability (players must adapt)
- Enemies can also jam (fairness)

**Estimated Effort:** Medium (requires room degradation system)

---

### 4. Ship Systems Integration

#### A. Advanced Synergy Effects

##### **Weapon Synergy Visual**

**Current:**
Passive +15% damage bonus (invisible except in numbers)

**Enhanced:**
- Glowing connection lines between adjacent weapons
- Color: Orange (#E2A04A) at 50% opacity
- Line2D drawn from weapon center to adjacent weapon center
- Pulse animation (brightness oscillates)

**Synchronized Firing:**
- All synergized weapons fire simultaneously (same frame)
- Instead of staggered 0.05s delay
- Creates visual "volley" effect
- Sound: Layered laser sounds = louder/more impactful

**Implementation:**
```gdscript
func _fire_synergized_weapons(weapon_positions: Array, synergized_groups: Array):
    for group in synergized_groups:
        # Fire all weapons in synergy group at once
        for weapon_pos in group:
            combat_fx.spawn_muzzle_flash(weapon_pos, 0.1)
            combat_fx.spawn_laser_beam(weapon_pos, target_position, 0.3)

        # Wait before firing next group
        await get_tree().create_timer(0.1 * speed_multiplier).timeout
```

**Estimated Effort:** Low-Medium (4-6 hours)

---

##### **Shield Synergy Mechanic**

**Current:**
Shield+Reactor = +20% absorption (passive)

**Enhanced: Shield Recharge**
- After absorbing damage, shields regenerate 20% of absorption
- Regeneration happens at END of turn (after damage applied)
- Visual: Blue particles flow from reactor to shield
- Log message: "Shields regenerating... +15 absorption restored"

**Rules:**
- Only if synergy active (shield adjacent to reactor)
- Only if shields not destroyed
- Caps at original max absorption (no over-charging)

**Implementation:**
```gdscript
func _apply_shield_regeneration(defender: ShipData):
    var shield_synergies = defender.get_shield_reactor_synergies()

    for shield_id in shield_synergies:
        var regen_amount = int(shield_base_absorption * 0.2)
        defender.restore_shield_charge(shield_id, regen_amount)
        combat_log.add_message("Shield regenerated +%d absorption" % regen_amount)

        # Visual effect
        _show_shield_recharge_particles(shield_id)
```

**Balance:**
- Makes shields more viable in long battles
- Rewards shield+reactor placement
- Doesn't affect burst damage scenarios

**Estimated Effort:** Medium (1 day, requires tracking shield state)

---

##### **Engine Synergy Buff: Evasion**

**Current:**
Engine+Engine = +1 initiative (passive)

**Enhanced: Evasion Chance**
- 10% chance to completely dodge incoming fire
- Works once per turn (can't dodge multiple attacks)
- Visual: Ship flickers/blinks, projectiles pass through
- Sound: "Whoosh" sound effect
- Log: "ENEMY ATTACK EVADED!"

**Implementation:**
```gdscript
func _check_evasion(defender: ShipData) -> bool:
    var engine_synergies = defender.calculate_synergy_bonuses()["counts"][RoomData.SynergyType.INITIATIVE]

    if engine_synergies > 0:
        var evasion_chance = 0.10 * engine_synergies  # 10% per synergy
        if randf() < evasion_chance:
            # Trigger evasion
            combat_log.add_message("EVADED! No damage taken.")
            return true

    return false
```

**Balance Consideration:**
- 10% is low enough to not be reliable
- Adds excitement ("Did we dodge?!")
- Doesn't trivialize combat (still take damage on average)

**Estimated Effort:** Low-Medium (4-6 hours)

---

##### **Durability Synergy Feedback**

**Current:**
Weapon+Armor = 33% chance to resist destruction (happens silently)

**Enhanced Feedback:**
- When resistance triggers:
  - Large "ARMOR PLATING HELD" text above room
  - Visual shield bubble around weapon (0.5s duration)
  - Metallic "clang" sound effect
  - Particle sparks deflect off room
- Makes synergy feel powerful and visible

**Implementation:**
```gdscript
func _show_durability_resist_feedback(room_id: int, room_type: RoomType):
    var room_pos = defender_display.get_room_center(room_id)

    # Text popup
    var resist_label = Label.new()
    resist_label.text = "ARMOR HELD!"
    resist_label.position = room_pos - Vector2(50, 30)
    resist_label.add_theme_font_size_override("font_size", 24)
    resist_label.add_theme_color_override("font_color", Color.GOLD)
    add_child(resist_label)

    # Shield bubble visual
    var shield = _create_shield_bubble(room_pos, 30.0)

    # Sound
    AudioManager.play_armor_clang()

    # Fade out after 0.5s
    await get_tree().create_timer(0.5 * speed_multiplier).timeout
    resist_label.queue_free()
    shield.queue_free()
```

**Estimated Effort:** Low (3-4 hours)

---

#### B. Room State Complexity

**Current State:**
Binary room states (active/destroyed, powered/unpowered)

**Enhanced: Multi-State Rooms with Degradation**

##### **Room HP System**

**Each room has internal HP:**

| Room State | HP Range | Effectiveness | Visual Effect |
|------------|----------|---------------|---------------|
| PRISTINE | 100% | 100% | Normal sprite, no effects |
| DAMAGED | 50-99% | 75% | Sparks, light smoke |
| CRITICAL | 1-49% | 50% | Heavy smoke, cracks |
| DESTROYED | 0% | 0% | Gray, explosion marks |

##### **Damage Mechanics**

**Overkill Damage Spillover:**
- When room destroyed with excess damage, spillover to adjacent rooms
- Example: Room has 10 HP, takes 30 damage → 20 damage spills to adjacent rooms
- Distributed evenly across adjacent rooms

**Critical State Malfunction:**
- CRITICAL rooms have 15% chance to malfunction each turn
- Malfunction = temporarily disabled (0% effectiveness for 1 turn)
- Auto-repairs to CRITICAL state next turn (doesn't get worse)

**Implementation:**
```gdscript
class RoomState:
    var room_id: int
    var current_hp: int = 100
    var max_hp: int = 100
    var state: RoomStateEnum = RoomStateEnum.PRISTINE

    func take_damage(amount: int) -> int:
        current_hp -= amount
        current_hp = max(0, current_hp)

        # Update state
        var hp_percent = float(current_hp) / float(max_hp)
        if hp_percent <= 0:
            state = RoomStateEnum.DESTROYED
        elif hp_percent < 0.5:
            state = RoomStateEnum.CRITICAL
        elif hp_percent < 1.0:
            state = RoomStateEnum.DAMAGED

        # Return excess damage for spillover
        return max(0, amount - max_hp)
```

##### **Visual Indicators**

**Room HP Bars (Combat View):**
- Small HP bar above each room (optional, toggle in settings)
- Color-coded:
  - Green: PRISTINE
  - Yellow: DAMAGED
  - Red: CRITICAL
- Only show for rooms below 100% HP

**Persistent Damage Effects:**
- Sparks particle effect (random bursts)
- Smoke trails (continuous, intensity based on damage)
- Crack overlays (Line2D drawn over sprite)

##### **Campaign Integration**

**Between Missions:**
- Damaged rooms persist to next mission
- Player must choose:
  - **Repair All**: Costs resources, all rooms → PRISTINE
  - **Partial Repair**: Repair critical rooms only
  - **No Repair**: Save resources, accept reduced effectiveness

**Strategic Implications:**
- Players must balance resource spending
- Risk-reward: Go into mission damaged to save resources?
- Damaged ships feel "battle-worn" (immersion)

**Estimated Effort:** High (2-3 days, significant system rework)

---

#### C. Power System Depth

##### **Reactor Overload**

**Mechanic:**
Reactors can temporarily boost power output at a cost

**Rules:**
- Activation: Right-click reactor during combat (if UI added)
- Effect: Reactor powers 125% of normal rooms for 2 turns
- Cooldown: 50% power output for next 2 turns (overheated)
- Risk: 10% chance reactor takes 20 damage when activated

**Use Case:**
- Player needs extra power to activate unpowered weapon
- Desperate situation (low HP, need damage NOW)
- Strategic timing: Overload before critical turn

**Visual:**
- Reactor glows bright yellow during overload
- Power lines pulse rapidly
- Cooldown: Reactor dims, smoke effect

**Implementation:**
```gdscript
func _activate_reactor_overload(reactor_id: int):
    if reactor_cooldowns[reactor_id] > 0:
        return  # Still on cooldown

    # Apply overload
    reactor_overload_active[reactor_id] = 2  # 2 turns of boost
    reactor_cooldowns[reactor_id] = 4  # 2 boost + 2 penalty

    # Recalculate power with 125% range
    player_data.calculate_power_grid_with_boost(reactor_id, 1.25)

    # Visual feedback
    player_ship_display.flash_reactor(reactor_id, Color.YELLOW)

    # Risk check
    if randf() < 0.10:
        _apply_overload_damage(reactor_id, 20)
        combat_log.add_message("Reactor overload caused damage!")
```

**Estimated Effort:** Medium-High (requires UI + power system changes)

---

##### **Emergency Power Routing**

**Player Ability:**
Manually redirect power mid-battle (once per battle)

**Options:**
- **Weapons → Shields**: Unpowers weapons, boosts shield absorption by 50%
- **Shields → Weapons**: Disables shields, boosts weapon damage by 50%
- **All → Engines**: Emergency thrust, gain initiative next turn

**UI:**
- "EMERGENCY POWER" button appears on turn 2+
- Opens popup with 3 routing options
- Click option → immediate effect
- Button grays out after use

**Implementation:**
```gdscript
func _emergency_power_routing(route: PowerRoute):
    match route:
        PowerRoute.WEAPONS_TO_SHIELDS:
            player_data.disable_weapons()
            player_data.boost_shields(0.5)
            combat_log.add_message("Power redirected: Weapons → Shields (+50% absorption)")

        PowerRoute.SHIELDS_TO_WEAPONS:
            player_data.disable_shields()
            player_data.boost_weapons(0.5)
            combat_log.add_message("Power redirected: Shields → Weapons (+50% damage)")

        PowerRoute.ALL_TO_ENGINES:
            player_data.disable_weapons()
            player_data.disable_shields()
            player_data.boost_initiative(100)  # Guarantee first strike
            combat_log.add_message("EMERGENCY THRUST! All power to engines!")

    emergency_power_used = true
    emergency_power_button.disabled = true
```

**Strategic Depth:**
- All-in gambles (disable defense to maximize offense)
- Reactive tool (enemy about to hit, need shields NOW)
- Adds player agency during combat (current combat is passive)

**Estimated Effort:** Medium (1 day, requires UI + state management)

---

##### **Relay Network Vulnerability**

**Current:**
Relays provide wireless power within radius (invisible)

**Enhanced:**
Show power distribution lines during combat

**Visual:**
- Dashed cyan lines from relay to all powered rooms in range
- Lines fade in/out with 2s pulse cycle
- When relay destroyed:
  - Lines spark red
  - Fade out over 0.5s
  - Powered rooms flicker and dim

**Tactical Value:**
- Player can see exactly which rooms rely on relay
- Destroying relay is visually satisfying (power grid collapse)
- Helps player understand relay placement consequences

**Implementation:**
```gdscript
func _draw_relay_power_lines(relay_id: int, ship_display: ShipDisplay):
    var relay_pos = ship_display.get_room_center(relay_id)
    var powered_rooms = ship_data.get_rooms_powered_by_relay(relay_id)

    for room_id in powered_rooms:
        var room_pos = ship_display.get_room_center(room_id)

        # Draw dashed line
        var line = Line2D.new()
        line.add_point(relay_pos)
        line.add_point(room_pos)
        line.default_color = Color(0.29, 0.89, 0.89, 0.3)  # Cyan, transparent
        line.width = 2.0
        line.texture_mode = Line2D.LINE_TEXTURE_TILE
        # Add dashed texture or use modulation for pulse
        ship_display.add_child(line)

        relay_power_lines[relay_id].append(line)
```

**Estimated Effort:** Low-Medium (4-6 hours)

---

##### **Power Surge Mechanic**

**When Reactor Destroyed:**
Explosion sends power surge to adjacent powered rooms

**Rules:**
- All rooms adjacent to destroyed reactor take 10 damage
- Damage applies BEFORE power recalculation
- Can trigger chain destruction of fragile rooms
- Incentivizes spacing reactors away from critical rooms

**Visual:**
- Blue lightning bolts emanate from reactor
- Hit adjacent rooms simultaneously
- Rooms flash blue-white briefly
- Log: "Power surge damaged adjacent rooms!"

**Implementation:**
```gdscript
func _apply_power_surge(reactor_id: int, defender: ShipData):
    var adjacent_rooms = defender.get_adjacent_room_ids(reactor_id)

    for room_id in adjacent_rooms:
        if defender.is_room_powered(room_id):
            # Apply surge damage
            var surge_damage = 10
            defender.apply_damage_to_room(room_id, surge_damage)

            # Visual effect
            _spawn_lightning_bolt(reactor_pos, room_pos)

            # Check if surge destroyed room
            if defender.room_instances[room_id]["hp"] <= 0:
                await _destroy_room_visual(room_id, defender_display)
```

**Balance:**
- Adds risk to dense reactor placement
- Makes reactor destruction more catastrophic
- Encourages thoughtful reactor positioning

**Estimated Effort:** Low-Medium (4-6 hours)

---

### 5. Campaign/Meta Integration

#### A. Enemy Scaling & Variety

##### **Elite Variants**

**Concept:**
Modified versions of base enemies with better AI and stats

**Examples:**

| Base Enemy | Elite Variant | Changes |
|------------|---------------|---------|
| Scout | Veteran Scout | +50% HP, WEAPONS_FIRST targeting, +1 weapon |
| Raider | Elite Raider | +30% HP, TACTICAL AI (adaptive), +1 shield |
| Dreadnought | Flagship Dreadnought | +100% HP, POWER_FIRST, +2 weapons, +1 reactor |

**Appearance:**
- Later campaign sectors (Sector 3+)
- Special indicator: "ELITE" badge on enemy ship display
- Different color scheme (red tint vs normal gray)

**Implementation:**
```gdscript
func _create_elite_enemy(base_enemy_id: String) -> ShipData:
    var enemy = ShipData.create_enemy_from_id(base_enemy_id)

    # Apply elite modifiers
    enemy.max_hp = int(enemy.max_hp * 1.5)
    enemy.current_hp = enemy.max_hp
    enemy.targeting_priority = ShipData.TargetingPriority.TACTICAL

    # Visual indicator
    enemy.is_elite = true

    return enemy
```

**Estimated Effort:** Low (2-3 hours per variant)

---

##### **Boss Mechanics**

**Multi-Phase Battles:**
Certain enemies trigger special events at HP thresholds

**Example: Dreadnought Repair Protocol**

```
Phase 1 (100-50% HP): Normal combat
Phase 2 Trigger (50% HP): "EMERGENCY REPAIRS ACTIVATED"
├── Dreadnought repairs 1 destroyed room (random)
├── Power grid recalculates
├── Shields boost +50% absorption for 3 turns
└── Visual: Green nano-bot particles swarm ship

Phase 3 (50-0% HP): Aggressive mode
├── AI switches to WEAPONS_FIRST
├── Damage increased by 25%
└── Turn indicator: "DREADNOUGHT ENRAGED"
```

**Implementation:**
```gdscript
func _check_boss_phase_transition(boss: ShipData):
    var hp_percent = float(boss.current_hp) / float(boss.max_hp)

    if hp_percent <= 0.5 and not boss.phase_2_triggered:
        boss.phase_2_triggered = true
        await _trigger_boss_repair_sequence(boss)

    # Additional phases...
```

**Boss Abilities:**

| Ability | Description | Trigger |
|---------|-------------|---------|
| Shield Pulse | Absorbs next attack completely | Every 4 turns |
| Weapon Barrage | Fires 2x weapons this turn | When HP < 30% |
| Emergency Warp | Heals 20% HP, teleports (visual only) | Once per battle at HP < 20% |

**Estimated Effort:** High (1-2 days per boss, requires unique logic)

---

##### **Enemy Fleet Battles**

**2v1 Scenarios:**
Player faces two smaller ships simultaneously

**Mechanics:**
- Player must choose target each turn (button prompt)
- Both enemies take turns attacking player
- Player can switch targets between turns
- Different strategies:
  - **Focus Fire**: Eliminate one ship quickly
  - **Balanced**: Damage both evenly
  - **Adaptive**: Target based on threats

**Turn Flow:**
```
Turn Order (by initiative):
1. Player selects target A or target B
2. Player attacks selected target
3. Enemy A attacks player
4. Enemy B attacks player
5. Repeat until player or both enemies destroyed
```

**UI Changes:**
- Two enemy ship displays (stacked vertically on right)
- Target selection buttons above each enemy
- Damage/HP bars for both enemies
- Combat log tracks which enemy is active

**Balance:**
- Two Scouts (combined HP = 120) vs player Mission 2 ship
- Adds variety to mission structure
- Tests different strategies than 1v1

**Implementation Complexity:**
- Requires significant combat scene restructuring
- Two ShipData instances, two ShipDisplay instances
- Modified targeting system

**Estimated Effort:** Very High (3-4 days, major feature)

---

#### B. Persistent Combat State

##### **Carried Damage (Campaign Mode)**

**Mechanic:**
Damaged rooms persist between missions

**Flow:**
```
Mission 1 Complete:
├── Player exits combat with 2 destroyed weapons, 1 destroyed shield
├── Return to campaign map
├── "DAMAGE REPORT" screen shows:
│   ├── Weapons: 3/5 active
│   ├── Shields: 1/2 active
│   └── Estimated Repair Cost: 150 credits
├── Player chooses:
│   ├── "Repair All" (150 credits)
│   ├── "Partial Repair" (select rooms to fix)
│   └── "Continue Damaged" (save credits, accept weakness)
└── Enter Mission 2 with chosen ship state
```

**Implementation:**
```gdscript
# After combat ends
func _finalize_battle_state():
    GameState.player_damaged_rooms = player_data.get_destroyed_room_ids()
    GameState.player_current_hp = player_data.current_hp

    # Show damage report
    var report = DamageReportScreen.new()
    report.show_damage(GameState.player_damaged_rooms)
    report.repair_selected.connect(_on_repair_selected)

# Before next combat
func start_combat(mission_index: int):
    # Apply persisted damage
    for room_id in GameState.player_damaged_rooms:
        player_data.destroy_room_instance(room_id)

    player_data.current_hp = GameState.player_current_hp
    # ... continue normal combat setup
```

**Strategic Implications:**
- Resource management between missions
- Risk-reward: Save credits vs go in damaged
- Creates emotional investment (THIS ship has history)

**Estimated Effort:** Medium-High (2 days, requires repair UI + persistence)

---

##### **Battle Fatigue**

**Mechanic:**
Consecutive battles without repair reduce effectiveness

**Rules:**
```
Battle Count Without Repair:
├── 1 battle: No penalty
├── 2 battles: -5% all stats
├── 3 battles: -10% all stats
├── 4+ battles: -15% all stats (max penalty)
```

**Visual Indicators:**
- Crew Morale bar (green → yellow → red)
- Fatigue icon next to ship stats
- Warning message: "Crew fatigued! Stats reduced by 10%"

**Implementation:**
```gdscript
func _apply_battle_fatigue():
    var battles_without_repair = GameState.consecutive_battles_without_repair

    if battles_without_repair >= 2:
        var penalty = min(0.15, battles_without_repair * 0.05)
        player_data.apply_stat_modifier(1.0 - penalty)

        combat_log.add_message("Crew Fatigued: -%d%% effectiveness" % int(penalty * 100))
```

**Balance:**
- Encourages repairing between missions
- Punishes pure rush strategies (ignore damage, push forward)
- Adds campaign-level decision making

**Estimated Effort:** Low-Medium (4-6 hours)

---

##### **Crew Experience**

**Mechanic:**
Winning battles improves crew performance over time

**Progression System:**
```
Crew XP Gains:
├── Win Mission: +100 XP
├── Win Without Taking Damage: +50 XP bonus
├── Win With <25% HP: +25 XP bonus (clutch victory)
└── Total XP → Crew Level

Crew Levels:
├── Level 1 (0-200 XP): No bonuses
├── Level 2 (200-500 XP): +5% initiative
├── Level 3 (500-1000 XP): +5% initiative, +5% damage
├── Level 4 (1000-2000 XP): +10% initiative, +10% damage
└── Level 5 (2000+ XP): +15% all stats
```

**Visual:**
- XP bar on campaign map
- "CREW LEVEL UP!" notification after mission
- Level badge on ship display during combat

**Integration with Barks:**
- Higher level crew = more confident barks
- Low level crew = nervous/uncertain barks
- Adds character progression arc

**Implementation:**
```gdscript
# After battle victory
func _award_crew_xp(victory_bonus: int):
    var xp_gained = 100 + victory_bonus
    GameState.crew_xp += xp_gained

    # Check for level up
    var old_level = GameState.crew_level
    GameState.crew_level = _calculate_crew_level(GameState.crew_xp)

    if GameState.crew_level > old_level:
        _show_level_up_notification(GameState.crew_level)
```

**Estimated Effort:** Medium (1 day, requires XP system + UI)

---

## Prioritized Roadmap

### **Phase 1: Quick Wins** _(1-2 weeks)_
**High Impact, Low-Medium Effort**

1. **Critical Hit Effects** (6 hours)
   - Golden flash for Bridge/Reactor destruction
   - Slow-motion zoom
   - Screen border flash
   - Dramatic sound effects

2. **Room-Specific Explosion Sounds** (6 hours)
   - Different sounds per room type
   - Staggered multi-room destruction audio

3. **Power Drain Wave Animation** (1 day)
   - Visual wave from reactor to powered rooms
   - Flickering unpowered rooms
   - Relay pulse animations

4. **Ship Damage States** (1.5 days)
   - Smoke/sparks at low HP
   - Progressive damage visuals
   - Hull crack overlays

5. **Synergy Visual Feedback** (6 hours)
   - Glowing connection lines between synergized rooms
   - Durability resist feedback ("ARMOR HELD!")
   - Synchronized weapon firing

**Total Phase 1 Time:** 5-6 days

---

### **Phase 2: AI Improvements** _(2-3 weeks)_
**Medium Impact, Medium Effort**

1. **Adaptive AI Behaviors** (2 days)
   - AI personality enum
   - Combat state evaluation
   - Dynamic priority switching
   - Testing/balancing

2. **Multi-Target Selection** (1 day)
   - Distribute weapons across multiple targets
   - Multiple targeting lines visual
   - Staggered destruction

3. **Turn Interruptions** (2 days)
   - Chain explosions (reactor → adjacent rooms)
   - Shield overload mechanic
   - Emergency engine boost ability

4. **Enhanced Audio** (2 days)
   - Spatial audio (left/right panning)
   - Low HP alarm
   - Weapon charging sound
   - Victory/defeat voiceover

**Total Phase 2 Time:** 7-8 days

---

### **Phase 3: Polish & Depth** _(3-4 weeks)_
**Medium-High Impact, High Effort**

1. **Advanced Synergy Effects** (2 days)
   - Shield regeneration mechanic
   - Evasion chance for engines
   - Visual effect polish

2. **Turn Pacing Options** (2 days)
   - Auto-skip boring turns
   - Critical moment slowdown
   - Turn prediction preview
   - Skip to end button

3. **Room Degradation System** (3 days)
   - Room HP tracking
   - Multi-state rooms (PRISTINE → DAMAGED → CRITICAL → DESTROYED)
   - Overkill damage spillover
   - Room HP bars (UI)
   - Malfunction chance

4. **Power System Depth** (2 days)
   - Reactor overload ability
   - Emergency power routing
   - Relay network visualization
   - Power surge damage

**Total Phase 3 Time:** 9-10 days

---

### **Phase 4: Campaign Integration** _(4-5 weeks)_
**High Impact, Very High Effort**

1. **Elite Enemy Variants** (1 week)
   - Create 3-4 elite variants
   - Modified AI and stats
   - Visual indicators
   - Balance testing

2. **Boss Mechanics** (1.5 weeks)
   - Multi-phase battle system
   - Boss abilities (shield pulse, weapon barrage)
   - Repair sequence animations
   - Special boss combat flow

3. **Persistent Combat State** (1 week)
   - Carried damage between missions
   - Damage report screen
   - Repair shop UI
   - Battle fatigue system

4. **Crew Experience** (1 week)
   - XP progression system
   - Level-up bonuses
   - Integration with crew barks
   - XP UI on campaign map

5. **Fleet Battles** (1.5 weeks)
   - 2v1 combat system
   - Target selection UI
   - Modified combat loop
   - Two enemy displays
   - Balance testing

**Total Phase 4 Time:** 20-25 days

---

### **Total Estimated Timeline**
- **Phase 1:** 1-2 weeks
- **Phase 2:** 2-3 weeks
- **Phase 3:** 3-4 weeks
- **Phase 4:** 4-5 weeks

**Grand Total:** ~10-14 weeks of development

---

## Specific Recommendations

Based on your design pillars (**Engineering Fantasy**, **Meaningful Spatial Puzzles**, **Clear Feedback**):

### **Must-Have (Align with Core Pillars)**

1. **Power Drain Wave Animation**
   - **Why:** Visually demonstrates spatial consequences of reactor placement
   - **Pillar:** Meaningful Spatial Puzzles
   - **Effort:** Low (1 day)
   - **Impact:** High (makes power system feel real)

2. **Synergy Visual Connections**
   - **Why:** Makes adjacency feel impactful, shows player smart design choices
   - **Pillar:** Engineering Fantasy
   - **Effort:** Low (6 hours)
   - **Impact:** High (validates player's spatial decisions)

3. **Adaptive AI**
   - **Why:** Makes player designs feel tested/validated, creates memorable battles
   - **Pillar:** Engineering Fantasy (player sees their design tested by intelligent opponent)
   - **Effort:** Medium (2 days)
   - **Impact:** Very High (transforms combat from predictable to engaging)

4. **Critical Hit Effects**
   - **Why:** Provides clear feedback on impactful moments
   - **Pillar:** Clear Feedback
   - **Effort:** Low (6 hours)
   - **Impact:** High (increases drama and clarity)

---

### **Should-Have (Strong Additions)**

1. **Multi-Target Selection**
   - **Why:** Makes weapon count and placement feel more meaningful
   - **Pillar:** Meaningful Spatial Puzzles
   - **Effort:** Low (1 day)
   - **Impact:** Medium (high weapon builds feel better)

2. **Room Degradation System**
   - **Why:** Adds tactical depth, makes armor placement critical
   - **Pillar:** Meaningful Spatial Puzzles
   - **Effort:** High (3 days)
   - **Impact:** High (adds new layer of strategy)

3. **Ship Damage States**
   - **Why:** Glanceable feedback on combat progress
   - **Pillar:** Clear Feedback
   - **Effort:** Medium (1.5 days)
   - **Impact:** Medium-High (improves readability)

4. **Turn Pacing Options**
   - **Why:** Reduces tedium, makes combat more watchable
   - **Pillar:** Clear Feedback
   - **Effort:** Medium (2 days)
   - **Impact:** Medium (quality of life improvement)

---

### **Nice-to-Have (Replayability & Polish)**

1. **Elite Enemy Variants**
   - **Why:** Increases campaign replayability
   - **Pillar:** Engineering Fantasy (more interesting enemies to design against)
   - **Effort:** Medium (1 week)
   - **Impact:** Medium (long-term engagement)

2. **Boss Mechanics**
   - **Why:** Creates memorable climactic moments
   - **Pillar:** Engineering Fantasy
   - **Effort:** High (1.5 weeks)
   - **Impact:** High (adds spectacle)

3. **Persistent Combat State**
   - **Why:** Adds campaign-level strategy, emotional investment
   - **Pillar:** Engineering Fantasy (THIS ship has history)
   - **Effort:** High (1 week)
   - **Impact:** Medium-High (campaign depth)

4. **Fleet Battles**
   - **Why:** Tests multi-target strategies
   - **Pillar:** Meaningful Spatial Puzzles
   - **Effort:** Very High (1.5 weeks)
   - **Impact:** Medium (content variety)

---

### **Recommended Implementation Order**

**If you have limited time, prioritize:**

1. **Power Drain Wave** (1 day) - Reinforces core mechanic
2. **Synergy Visual Connections** (0.5 day) - Makes design choices visible
3. **Critical Hit Effects** (0.5 day) - Increases drama
4. **Adaptive AI** (2 days) - Makes combat less predictable
5. **Room-Specific Sounds** (0.5 day) - Easy polish, big impact

**Total: 4.5 days for maximum impact per effort**

---

### **Post-MVP Polish** _(After Core Gameplay Validated)_

- Dynamic music system
- Environmental effects (parallax stars, nebula)
- Boss mechanics
- Fleet battles
- Full crew progression system

---

## Conclusion

Your combat system is already quite robust! The main opportunities are:

1. **Making existing systems more visible** (synergies, power distribution)
2. **Adding player agency during combat** (emergency abilities)
3. **Increasing enemy unpredictability** (adaptive AI, turn interruptions)
4. **Polishing feedback loops** (visual effects, audio cues)

Focus on Phase 1 and Phase 2 for the best return on investment. Phase 3 and Phase 4 are excellent for post-launch updates or if transitioning to a full game.
