# Core Systems

**Living document. Update when systems change significantly.**

**Last Updated:** December 2024
**Version:** 0.1 MVP

---

## System 1: Ship Design & Room Placement

### Overview

The ship design system is a spatial puzzle where players place multi-tile rooms on shaped hull grids within a budget constraint. Rooms occupy 1-6 tiles in rectangular shapes (1×1 to 3×2), creating Tetris-like placement challenges. Each hull has a unique shape defined by valid/invalid tiles, and rooms can be rotated in 90° increments to fit efficiently.

The system emphasizes strategic trade-offs: offensive rooms (weapons) vs defensive rooms (shields, armor) vs utility rooms (reactors, engines). Budget constraints force players to specialize rather than build "perfect" ships. Room placement also affects synergy bonuses (see System 3) and power routing (see System 2).

### Room Types

| Room Type | Size | Cost | Primary Function | Placement Constraint |
|-----------|------|------|------------------|---------------------|
| **Bridge** | 2×2 | 5 | Command center (required) | Any location |
| **Weapon** | 2×1 | 2 | Deals 10 damage per weapon | Rightmost 2 columns (bow) |
| **Shield** | 2×1 | 3 | Absorbs 15 damage per shield | Any location |
| **Engine** | 2×2 | 3 | Adds +1 initiative per engine | Leftmost 2 columns (stern) |
| **Reactor** | 3×2 | 4 | Powers 8 adjacent tiles | Any location |
| **Armor** | 1×1 | 1 | Adds +20 HP per armor | Any location |
| **Conduit** | 1×1 | 1 | Extends power range | Any location |
| **Relay** | 2×2 | 3 | Power hub (8 tile range) | Any location |

**Total:** 9 room types (8 functional + 1 required Bridge)

### Placement Rules

**Budget Constraint:**
- Each mission has a budget (20-50 points)
- Each room costs points when placed
- Cannot exceed budget (placement blocked if over)
- Must have exactly 1 Bridge to launch

**Spatial Constraints:**
- Rooms occupy multiple tiles (no overlap)
- Must fit within hull shape (only 'X' tiles valid, not '.' empty space)
- Can rotate rooms 0°, 90°, 180°, 270° to fit
- Placement preview shows green (valid) or red (invalid)

**Strategic Constraints (Soft):**
- Weapons in rightmost columns (face forward in combat)
- Engines in leftmost columns (thrusters face backward)
- Other rooms: any valid location

**Design Flow:**
1. Select room type from palette
2. Hover over grid to see placement preview
3. Click/drag to place (validates budget + space)
4. Room placed → budget updates → power recalculates → synergies update
5. Right-click to remove room (refund cost)

### UI Components

**Room Palette Panel:**
- 9 buttons (one per room type)
- Shows room icon, label, cost, size
- Click to select, click again to rotate
- Selected room highlights in cyan

**Ship Grid:**
- Sized to current hull (8×6, 10×4, 7×7, etc.)
- Tiles show room sprites or empty
- Green overlay = powered, gray = unpowered
- Synergy indicators between adjacent rooms

**Budget Display:**
- "BUDGET: X / Y" (current / max)
- Color-coded: green (plenty), yellow (tight), red (over/full)
- Real-time updates on placement/removal

**Stats Panel:**
- Offense: Weapon count × 10 damage
- Defense: Shield count × 15 absorption + HP
- Thrust: Engine count (initiative)
- HP: 60 base + (armor × 20) + hull bonus

**Specifications Panel:**
- Detailed stat breakdown with synergy bonuses
- Power grid efficiency percentage
- Room counts by type
- Active synergy counter

### Implementation Details

**Data Structure:**
- Grid stored as 2D array of `RoomType` enum
- Multi-tile rooms tracked in `room_instances` dictionary (ID → {type, tiles[]})
- Each tile stores which room instance it belongs to
- Rooms defined in `data/rooms.json` (cost, shape, color, label)

**Key Scripts:**
- `ShipGrid.gd`: Grid rendering and state management
- `PlacementManager.gd`: Placement validation and logic
- `RoomData.gd`: Static room definitions and utilities
- `ShipData.gd`: Ship state (grid, stats, HP, power)

**Validation:**
```gdscript
func can_place_room(room_type, x, y, rotation) -> bool:
    # Check budget
    if current_budget + room_cost > max_budget:
        return false

    # Check all tiles in rotated shape fit within hull
    for offset in rotated_shape:
        var tile_x = x + offset[0]
        var tile_y = y + offset[1]

        # Out of bounds
        if tile_x < 0 or tile_y < 0 or tile_x >= width or tile_y >= height:
            return false

        # Invalid hull tile (empty space)
        if hull_shape[tile_y][tile_x] == '.':
            return false

        # Tile already occupied
        if grid[tile_y][tile_x] != RoomType.EMPTY:
            return false

    return true
```

---

## System 2: Power Routing

### Overview

Power routing creates an optimization puzzle: reactors generate power, conduits/relays extend range, and rooms must be adjacent to powered tiles to function. Unpowered rooms are inactive (grayed out visually, don't contribute to combat stats). Efficient power grids maximize active rooms while minimizing reactor/conduit costs.

Power flows from reactors in 8 directions (cardinal + diagonal). Conduits extend power by 1 tile in all 8 directions. Relays act as power hubs, distributing to 8 surrounding tiles. Destroyed reactors/relays during combat can cascade-disable entire sections of the ship.

### Power Sources

**Reactor (3×2, 4 cost):**
- Powers 8 adjacent tiles (cardinal + diagonal)
- Large footprint, expensive, high capacity
- Can power 8-10 rooms if densely packed

**Relay (2×2, 3 cost):**
- Powers 8 adjacent tiles (acts as power hub)
- Mid-size footprint, moderate cost
- Extends power grid range efficiently
- Useful for connecting distant room clusters

**Conduit (1×1, 1 cost):**
- Powers 8 adjacent tiles (passes power through)
- Small footprint, cheap, limited capacity
- Ideal for extending power 1-2 tiles
- Can chain conduits for long-distance power

**Bridge (2×2, 5 cost):**
- Always powered (doesn't require external power)
- Special case: command center functions independently

### Power Flow Rules

**Adjacency Check:**
```gdscript
func is_room_powered(room_position: Vector2i) -> bool:
    # Bridge always powered
    if room_type == RoomType.BRIDGE:
        return true

    # Check 8 adjacent tiles for power sources
    for dx in [-1, 0, 1]:
        for dy in [-1, 0, 1]:
            if dx == 0 and dy == 0:
                continue  # Skip self

            var neighbor_x = room_position.x + dx
            var neighbor_y = room_position.y + dy

            # Out of bounds
            if not in_bounds(neighbor_x, neighbor_y):
                continue

            var neighbor_type = grid[neighbor_y][neighbor_x]

            # Adjacent to reactor/relay/conduit = powered
            if neighbor_type in [RoomType.REACTOR, RoomType.RELAY, RoomType.CONDUIT]:
                return true

    return false  # No power source found
```

**Cascade Effects:**
- Reactor destroyed → all rooms it powered become unpowered
- Relay destroyed → breaks power hub, disconnects room clusters
- Conduit destroyed → may break power chain
- Unpowered weapons/shields/engines don't contribute to stats

### Visual Indicators

**Power Lines:**
- Green lines connect reactors/relays to powered rooms
- Lines drawn from power source center to room center
- Thicker lines for reactors, thinner for conduits

**Room States:**
- **Powered:** Full color, no overlay
- **Unpowered:** 50% opacity + gray overlay
- **Destroyed:** Dark gray, cracked sprite

**Power Grid Efficiency:**
- Percentage displayed in Performance Panel
- Formula: `(powered_rooms / total_rooms) × 100%`
- Target: 80%+ efficiency (most rooms powered)

### Strategic Depth

**Trade-offs:**
- **Centralized Power:** Few reactors, tightly packed rooms
  - Pro: Cheap (fewer reactors)
  - Con: Single point of failure (reactor destroyed = many rooms disabled)

- **Distributed Power:** Multiple reactors, spread-out rooms
  - Pro: Redundancy (one reactor lost ≠ catastrophic)
  - Con: Expensive (more reactors = higher cost)

- **Conduit Chains:** Long conduit lines connecting distant rooms
  - Pro: Cheap power extension
  - Con: Fragile (any conduit destroyed breaks chain)

- **Relay Hubs:** Relays at strategic junctions
  - Pro: Efficient multi-room powering
  - Con: Relay destroyed = hub collapses

**Example Designs:**
- **Glass Cannon:** 1 reactor powering 3 weapons + bridge (high damage, fragile power grid)
- **Fortress:** 3 reactors in triangle formation, all rooms redundantly powered (expensive but resilient)
- **Balanced:** 2 reactors in opposite corners, conduits linking middle sections (moderate cost, decent redundancy)

---

## System 3: Room Synergy System

### Overview

Room synergies reward strategic adjacency: placing specific room pairs next to each other grants combat bonuses. Synergies are detected automatically based on 8-directional adjacency (cardinal + diagonal). Multiple instances of the same synergy stack linearly (e.g., 3 Weapon+Weapon pairs = 3× Fire Rate bonus).

Synergies encourage thoughtful layout optimization beyond just fitting rooms efficiently. Players must balance synergy placement with power routing and budget constraints, creating a multi-layered spatial puzzle.

### Synergy Types

| Synergy Type | Room Pair | Bonus Effect | Combat Impact |
|--------------|-----------|--------------|---------------|
| **Fire Rate** | Weapon + Weapon | +20% damage per pair | 2 weapons adjacent = 10 → 12 dmg each |
| **Shield Capacity** | Shield + Reactor | +30% absorption per pair | 1 shield adjacent to reactor = 15 → 19.5 absorb |
| **Initiative** | Engine + Engine | +2 initiative per pair | 2 engines adjacent = shoot first more often |
| **Durability** | Weapon + Armor | Weapon takes 2 hits to destroy | Protects offense from early destruction |

**Total:** 4 synergy types, each with distinct strategic purpose

### Detection Logic

**Adjacency Check:**
```gdscript
func detect_synergies(grid: Array) -> Array:
    var active_synergies = []

    for y in range(height):
        for x in range(width):
            var room_type = grid[y][x]
            if room_type == RoomType.EMPTY:
                continue

            # Check 8 adjacent tiles
            for dx in [-1, 0, 1]:
                for dy in [-1, 0, 1]:
                    if dx == 0 and dy == 0:
                        continue  # Skip self

                    var neighbor_x = x + dx
                    var neighbor_y = y + dy

                    if not in_bounds(neighbor_x, neighbor_y):
                        continue

                    var neighbor_type = grid[neighbor_y][neighbor_x]

                    # Check synergy pairs (order-independent)
                    var synergy = RoomData.get_synergy_type(room_type, neighbor_type)
                    if synergy != SynergyType.NONE:
                        active_synergies.append({
                            "type": synergy,
                            "room_a": Vector2i(x, y),
                            "room_b": Vector2i(neighbor_x, neighbor_y)
                        })

    return active_synergies
```

**Stacking:**
- Each synergy instance counted separately
- Multiple Fire Rate pairs = cumulative damage bonus
- Example: 3 weapons in a row = 2 Fire Rate synergies = +40% damage

### Combat Integration

**Damage Calculation (with synergies):**
```gdscript
# Base damage
var base_damage = active_weapons * 10

# Apply Fire Rate synergies
var fire_rate_count = count_synergies(SynergyType.FIRE_RATE)
var damage_multiplier = 1.0 + (fire_rate_count * 0.2)
var final_damage = base_damage * damage_multiplier
```

**Shield Calculation (with synergies):**
```gdscript
# Base absorption
var base_absorption = active_shields * 15

# Apply Shield Capacity synergies
var shield_synergy_count = count_synergies(SynergyType.SHIELD_CAPACITY)
var absorption_multiplier = 1.0 + (shield_synergy_count * 0.3)
var final_absorption = base_absorption * absorption_multiplier
```

**Initiative Calculation (with synergies):**
```gdscript
# Base initiative
var base_initiative = active_engines

# Apply Initiative synergies
var initiative_bonus = count_synergies(SynergyType.INITIATIVE) * 2
var final_initiative = base_initiative + initiative_bonus
```

**Durability (special case):**
- Weapons with Durability synergy marked in `durable_weapons` array
- When targeted for destruction, check if durable:
  - First hit: Mark as "damaged" (not destroyed)
  - Second hit: Actually destroy
- Effectively doubles weapon HP

### Visual Indicators

**Synergy Lines:**
- Color-coded lines between synergized rooms:
  - Fire Rate: Orange (#E2904A)
  - Shield Capacity: Cyan (#4AE2E2)
  - Initiative: Blue (#4A90E2)
  - Durability: Red (#E24A4A)
- Drawn during design phase (persistent)
- Thicker lines for multiple stacks

**Synergy Counter:**
- Panel shows active synergies by type
- "Fire Rate: 2" (2 instances active)
- Updated in real-time as rooms placed/removed

**Synergy Guide Panel:**
- Lists all 4 synergy types with descriptions
- Shows which room pairs trigger each
- Educational tool for new players

---

## System 4: Auto-Resolved Combat

### Overview

Combat is turn-based and fully automated. Players watch their design fight the enemy ship, with no manual control. Initiative determines turn order, ships exchange fire, damage destroys rooms, and battle continues until one ship is destroyed (hull HP ≤ 0 or Bridge destroyed).

Combat is transparent: all math is visible, damage numbers display, turn log records events, and replay system allows detailed analysis. Failures point to design flaws (not RNG or execution mistakes), supporting the fast iteration loop.

### Turn Resolution Sequence

**1. Initialize Combat:**
```
- Load player ShipData (from designer)
- Load enemy ShipData (from mission definition)
- Calculate stats for both ships (weapons, shields, engines, HP)
- Determine initiative (engine count + synergy bonuses)
- Set turn order (higher initiative shoots first, tie = player wins)
```

**2. Turn Loop (repeat until win condition):**
```
Turn N:
  a. Show turn indicator ("PLAYER TURN" or "ENEMY TURN")
  b. Active ship attacks:
     - Calculate damage = active_weapons × 10 × synergy_multiplier
     - Target's shields absorb = min(damage, active_shields × 15 × synergy_multiplier)
     - Remaining hull damage = max(0, damage - shield_absorption)
     - Apply hull damage to target's HP
  c. Destroy rooms:
     - For each 20 damage dealt, destroy 1 random active room
     - Use enemy targeting strategy (RANDOM, WEAPONS_FIRST, POWER_FIRST)
     - Mark room as destroyed (sprite grayed, no longer contributes to stats)
  d. Visual feedback:
     - Flash active ship white (attacking)
     - Spawn damage number above target (color-coded)
     - Flash target ship red (taking damage)
     - Play explosion sprite if room destroyed
     - Update health bars (smooth tween)
  e. Recalculate stats (destroyed rooms reduce weapon/shield/engine counts)
  f. Check win condition:
     - If target hull HP ≤ 0 → Target loses
     - If target Bridge destroyed → Target loses instantly
     - Otherwise, continue
  g. Switch active ship
  h. Wait 1 second (visual pacing)
  i. Go to step a (next turn)
```

**3. Combat End:**
```
- Determine winner/loser
- Display result overlay ("VICTORY" or "DEFEAT")
- Store BattleResult (full turn history for replay)
- Enable Redesign button (returns to designer)
- If victory: unlock next mission
```

### Damage Calculation

**Base Damage:**
```gdscript
var active_weapons = count_active_rooms(RoomType.WEAPON)  # Must be powered
var base_damage = active_weapons * 10

# Apply synergies
var fire_rate_synergies = count_synergies(SynergyType.FIRE_RATE)
var damage_multiplier = 1.0 + (fire_rate_synergies * 0.2)  # +20% per synergy
var final_damage = base_damage * damage_multiplier
```

**Shield Absorption:**
```gdscript
var active_shields = count_active_rooms(RoomType.SHIELD)  # Must be powered
var base_absorption = active_shields * 15

# Apply synergies
var shield_synergies = count_synergies(SynergyType.SHIELD_CAPACITY)
var absorption_multiplier = 1.0 + (shield_synergies * 0.3)  # +30% per synergy
var max_absorption = base_absorption * absorption_multiplier

# Shields can't absorb more than incoming damage
var actual_absorption = min(final_damage, max_absorption)
```

**Hull Damage:**
```gdscript
var hull_damage = max(0, final_damage - actual_absorption)
target.current_hp -= hull_damage
```

**Room Destruction:**
```gdscript
var rooms_to_destroy = int(hull_damage / 20)  # Integer division
for i in range(rooms_to_destroy):
    var target_room = select_room_to_destroy(targeting_strategy)
    destroy_room(target_room)
```

### Targeting Strategies (Enemy AI)

**RANDOM:**
- Select any active room randomly
- Fair distribution across all room types
- Used by Scout (Mission 1) - beginner-friendly

**WEAPONS_FIRST:**
- Prioritize destroying weapons (reduce player damage output)
- If no weapons, target shields next (reduce defense)
- If no weapons/shields, target any active room
- Used by Raider (Mission 2) - intermediate challenge

**POWER_FIRST:**
- Prioritize destroying reactors/relays (cascade power failures)
- If no power sources, target weapons (reduce offense)
- If neither, target any active room
- Used by Dreadnought (Mission 3) - advanced challenge

**Implementation:**
```gdscript
func select_room_to_destroy(strategy: TargetingStrategy) -> Vector2i:
    var active_rooms = get_active_rooms()  # Excludes destroyed/unpowered

    match strategy:
        TargetingStrategy.RANDOM:
            return active_rooms[randi() % active_rooms.size()]

        TargetingStrategy.WEAPONS_FIRST:
            var weapons = filter_by_type(active_rooms, RoomType.WEAPON)
            if weapons.size() > 0:
                return weapons[randi() % weapons.size()]

            var shields = filter_by_type(active_rooms, RoomType.SHIELD)
            if shields.size() > 0:
                return shields[randi() % shields.size()]

            return active_rooms[randi() % active_rooms.size()]

        TargetingStrategy.POWER_FIRST:
            var power_sources = filter_by_types(active_rooms, [RoomType.REACTOR, RoomType.RELAY])
            if power_sources.size() > 0:
                return power_sources[randi() % power_sources.size()]

            var weapons = filter_by_type(active_rooms, RoomType.WEAPON)
            if weapons.size() > 0:
                return weapons[randi() % weapons.size()]

            return active_rooms[randi() % active_rooms.size()]
```

### Win Conditions

**Loss Conditions (either triggers defeat):**
1. Hull HP ≤ 0
2. Bridge destroyed (instant loss, even if HP > 0)

**Victory Condition:**
- Enemy triggers loss condition first

**Special Case:**
- If both ships would lose on same turn (mutual destruction), player wins (tie-breaker)

### Visual Feedback

**Damage Numbers:**
- Float upward above target ship
- Color-coded:
  - **Red:** Hull damage dealt
  - **Cyan:** Fully absorbed by shields
  - **Orange:** Partial absorption
- Font size: 32pt bold, black outline
- Duration: 0.8s fade-out

**Flash Effects:**
- **White flash (0.1s):** Attacking ship
- **Red flash (0.1s):** Damaged ship
- **Green flash (0.2s):** Winning ship (end of combat)
- **Red flash (0.2s):** Losing ship (end of combat)

**Explosion Sprite:**
- Orange/yellow circle (80×80px)
- Scale from 60px → 80px
- Fade out over 0.3s
- Centered on destroyed room

**Health Bars:**
- Width: 300px, Height: 40px
- Color gradient:
  - Green: HP > 50%
  - Yellow: HP 25-50%
  - Red: HP < 25%
- Smooth tween on damage (0.3s)
- Label: "XX / YY HP" (current / max)

---

## System 5: Hull Type System

### Overview

Hull types provide shaped grids with unique bonuses, creating variety across missions. Each hull has a distinct visual profile (tapered, angular, or blocky) and a strategic bonus (initiative, HP, or balanced). Players select hull type before designing, adding a meta-layer of strategy (which hull best counters this enemy?).

Hulls are defined in `data/hulls.json` with grid sizes, shapes (X = valid tile, . = empty), and bonuses. Ships visually taper from wide engine side (left) to narrow weapon side (right), reinforcing the "weapons forward, engines back" spatial constraint.

### Hull Types

**Frigate (10×4):**
```
Row 0: XXXXXX....  (6 valid tiles)
Row 1: XXXXXXXX..  (8 valid tiles)
Row 2: XXXXXXXX..  (8 valid tiles)
Row 3: XXXXXX....  (6 valid tiles)
Total: 28 tiles
```
- **Bonus:** +2 Initiative (shoots first more often)
- **Shape:** Sleek, angular, tapered front
- **Strategy:** Fast interceptor, good for offensive builds
- **Unlocked:** Mission 1

**Cruiser (8×6):**
```
Row 0: XXXXX...  (5 valid tiles)
Row 1: XXXXXX..  (6 valid tiles)
Row 2: XXXXXXX.  (7 valid tiles)
Row 3: XXXXXXX.  (7 valid tiles)
Row 4: XXXXXX..  (6 valid tiles)
Row 5: XXXXX...  (5 valid tiles)
Total: 36 tiles
```
- **Bonus:** None (balanced)
- **Shape:** Classic hull, symmetric taper
- **Strategy:** Versatile, no specialization
- **Unlocked:** Mission 2

**Battleship (7×7):**
```
Row 0: XXXXX..  (5 valid tiles)
Row 1: XXXXXX.  (6 valid tiles)
Row 2: XXXXXXX  (7 valid tiles)
Row 3: XXXXXXX  (7 valid tiles)
Row 4: XXXXXXX  (7 valid tiles)
Row 5: XXXXXX.  (6 valid tiles)
Row 6: XXXXX..  (5 valid tiles)
Total: 43 tiles
```
- **Bonus:** +20 HP (extra survivability)
- **Shape:** Imposing, thick, boxy
- **Strategy:** Tank/fortress builds, high armor
- **Unlocked:** Mission 3

**Free Design (30×30):**
```
All tiles valid (no shape restrictions)
Total: 900 tiles
```
- **Bonus:** None
- **Shape:** Unrestricted rectangle
- **Strategy:** Sandbox mode, testing, extreme builds
- **Unlocked:** Always (for custom scenarios)

### Hull Selection Flow

```
Mission Select → Hull Select Screen
    ↓
Player sees 3 hull cards:
  - Hull sprite preview
  - Grid size (e.g., "10×4 GRID")
  - Bonus description (e.g., "+2 INITIATIVE")
  - "SELECT" button
    ↓
Click hull card → Set GameState.current_hull
    ↓
Proceed to Ship Designer with selected hull
```

### Strategic Implications

**Hull Choice vs Enemy:**
- **Fast Enemy (high initiative):** Use Frigate (+2 initiative to shoot first)
- **High Damage Enemy:** Use Battleship (+20 HP to survive longer)
- **Balanced Enemy:** Use Cruiser (no bonus but most tiles)

**Hull Shape Constraints:**
- Frigate: Narrow front limits weapon placement (2-3 weapons max in row 0)
- Cruiser: Balanced taper allows even weapon spread
- Battleship: Wide throughout, can pack dense room clusters

**Tile Count vs Budget:**
- More tiles = more placement options (but budget still constrains)
- Frigate: 28 tiles (tightest, forces efficiency)
- Cruiser: 36 tiles (moderate)
- Battleship: 43 tiles (spacious, allows sprawl)

---

## System 6: Template Save/Load System

### Overview

Templates allow players to save successful ship designs for reuse, speeding up iteration. Saves entire grid + hull type to JSON file in user directory (`user://templates/`). Load templates to restore designs instantly (auto-fill) or manually place rooms one-by-one.

Templates are hull-specific: can only load a template if current hull matches saved hull. Prevents invalid designs (e.g., loading 10×4 Frigate design onto 7×7 Battleship).

### Save Flow

```
Player in Ship Designer
    ↓
Clicks "SAVE TEMPLATE" button
    ↓
TemplateNameDialog appears (text input)
    ↓
Player enters name (e.g., "Glass Cannon v2")
    ↓
TemplateManager saves to user://templates/glass_cannon_v2.json:
{
  "name": "Glass Cannon v2",
  "hull_type": "FRIGATE",
  "grid": [[...], [...], ...],  # 2D array of RoomType enums
  "room_instances": {...},      # Multi-tile room data
  "budget_used": 28,
  "created_at": "2024-12-03T14:30:00Z"
}
    ↓
Template saved, appears in Template List Panel
```

### Load Flow

```
Player in Ship Designer
    ↓
Clicks "LOAD TEMPLATE" button
    ↓
TemplateListPanel shows all saved templates:
  - Template name
  - Hull type
  - Budget used
  - Created date
  - "LOAD" and "DELETE" buttons
    ↓
Player clicks "LOAD" on template
    ↓
Validate: Does template.hull_type == current_hull?
  - Yes → Proceed
  - No → Show error "Template is for FRIGATE hull, you're using CRUISER"
    ↓
Clear current grid (remove all rooms, refund budget)
    ↓
Restore grid from template:
  - For each room instance in template:
    - Place room at saved position/rotation
    - Deduct cost from budget
    ↓
Recalculate power grid
    ↓
Recalculate synergies
    ↓
Update all UI panels (budget, stats, etc.)
```

### Auto-Fill Feature

**Quick Placement:**
- Load button auto-places all rooms from template
- No manual clicking required
- Instant restoration of entire design

**Use Case:**
- Player beats Mission 1 with "Balanced Build"
- Saves template
- Mission 2: Load template → tweak 2-3 rooms → launch
- Iteration time: 30 seconds (vs 90 seconds from scratch)

### Template Management

**List View:**
- Scrollable panel (max 10 templates visible)
- Each entry shows: name, hull, budget, date
- Load and Delete buttons per template

**Delete Flow:**
- Click "DELETE" → Confirmation dialog ("Delete 'Glass Cannon v2'?")
- Confirm → Remove JSON file → Refresh list

**File Storage:**
- Location: `user://templates/` (OS-specific user directory)
- Format: JSON (human-readable, easy to share)
- Filename: Sanitized template name (lowercase, underscores)

**Sharing (future):**
- Players can copy JSON files to share designs
- Import templates from other players
- Workshop integration (Steam) for browsing community templates

---

## System 7: Combat Replay & Timeline System

### Overview

After combat ends (win or lose), players can review the entire battle turn-by-turn using a timeline scrubber. Replay system stores full battle history (`BattleResult` object) and allows stepping forward/backward, pausing, and speed control. Critical for learning from defeats: "Why did I lose? → Scrub to turn 8 → See reactor destroyed → Power grid collapsed → Weapons disabled."

Replay is non-interactive (can't change outcomes), but provides complete visibility into what happened and why.

### BattleResult Data Structure

```gdscript
class BattleResult:
    var turns: Array = []           # Array of TurnSnapshot objects
    var winner: String              # "player" or "enemy"
    var total_turns: int            # Battle duration
    var player_final_hp: int
    var enemy_final_hp: int
    var created_at: String          # Timestamp

    class TurnSnapshot:
        var turn_number: int
        var active_ship: String     # "player" or "enemy"
        var damage_dealt: int
        var shield_absorbed: int
        var hull_damage: int
        var rooms_destroyed: Array  # [{type, position}, ...]
        var player_hp: int          # After this turn
        var enemy_hp: int           # After this turn
        var player_grid: Array      # Full grid state
        var enemy_grid: Array       # Full grid state
        var events: Array           # ["PLAYER attacks for 30 dmg", "ENEMY shield absorbs 20", ...]
```

**Storage:**
- After combat, `BattleResult` stored in `GameState.last_battle_result`
- Persists until next combat
- Available from Redesign screen (defeat) or Mission Select (victory)

### Timeline Scrubber UI

**Timeline Bar:**
- Horizontal bar at bottom of combat screen
- Width: 800px, segmented into turn markers
- Each turn = vertical tick mark
- Current turn highlighted (cyan)
- Scrubber handle (draggable circle)

**Controls:**
- **Play/Pause Button:** Resume/pause auto-playback
- **Step Forward Button:** Advance 1 turn
- **Step Backward Button:** Rewind 1 turn
- **Speed Selector:** 0.5x, 1x, 2x playback speed
- **Turn Label:** "Turn 5 / 12" (current / total)

**Interaction:**
- Drag scrubber handle → Jump to turn
- Click timeline bar → Jump to turn
- Click step buttons → Increment/decrement turn
- Scrubbing updates ship display, HP bars, stats panels

### Playback Flow

```
Combat Ends
    ↓
Store BattleResult in GameState
    ↓
Show result overlay ("VICTORY" or "DEFEAT")
    ↓
Player clicks "REDESIGN" (if defeat)
    ↓
Return to Ship Designer
    ↓
Player clicks "VIEW REPLAY" button (optional)
    ↓
Load ReplayViewer scene:
  - Initialize ships at turn 0 state
  - Show timeline bar (scrubber at turn 0)
  - Enable scrubbing controls
    ↓
Player scrubs to turn 8:
  - Load TurnSnapshot[8]
  - Restore player_grid and enemy_grid
  - Update HP bars (player_hp, enemy_hp)
  - Update stats panels
  - Show events in combat log
    ↓
Player sees: "Turn 8: ENEMY destroys PLAYER's REACTOR"
    ↓
Understanding: "My reactor was destroyed → power grid collapsed → weapons unpowered → lost offense"
    ↓
Close replay → Return to designer → Redesign with better reactor protection
```

### Event Log

**Text Display:**
- Scrollable panel (right side of replay viewer)
- Shows turn-by-turn events:
  - "Turn 1: PLAYER attacks for 30 damage"
  - "Turn 1: ENEMY shields absorb 20 damage"
  - "Turn 1: ENEMY takes 10 hull damage"
  - "Turn 2: ENEMY attacks for 40 damage"
  - "Turn 2: PLAYER shields absorb 40 damage"
  - "Turn 3: PLAYER destroys ENEMY's WEAPON"
  - ...

**Color Coding:**
- Player actions: Cyan text
- Enemy actions: Red text
- Damage: Bold
- Destruction: **BOLD + ALL CAPS**

---

## System Interactions

### Power + Combat
- **Unpowered rooms don't contribute to stats:**
  - Unpowered weapons → lower damage output
  - Unpowered shields → less absorption
  - Unpowered engines → lower initiative
- **Reactor/relay destruction cascades:**
  - Reactor destroyed → adjacent rooms lose power → stats drop mid-combat
  - Can turn winning battle into loss if power grid collapses
- **Power-first targeting exploits this:**
  - Enemy destroys reactors → player loses multiple rooms' effectiveness at once

### Synergies + Combat
- **Bonuses only apply to powered rooms:**
  - Fire Rate synergy inactive if weapons unpowered
  - Shield Capacity synergy inactive if shields/reactors unpowered
- **Synergies stack with base stats:**
  - 3 weapons × 10 base damage = 30
  - 2 Fire Rate synergies (+40%) = 30 × 1.4 = 42 damage
- **Durability synergy protects offense:**
  - Weapons with Durability take 2 hits to destroy
  - Counters WEAPONS_FIRST targeting (enemy wastes turns)

### Budget + Design
- **Tight budgets force specialization:**
  - Mission 2 (25 budget): Can't afford high offense + high defense
  - Must choose: Glass cannon (offense) or Turtle (defense)
- **Room efficiency matters:**
  - Conduits (1 cost) extend power cheaply
  - Relays (3 cost) power hubs efficiently
  - Armor (1 cost) cheap HP boost
- **Multi-tile rooms consume space:**
  - Reactor (3×2 = 6 tiles) takes significant footprint
  - Smaller hulls (Frigate: 28 tiles) → less room for large reactors

### Hull Type + Design
- **Hull shape constrains placement:**
  - Frigate row 0: 6 tiles → max 3 weapons (2×1 each)
  - Battleship row 3: 7 tiles → can pack 3 weapons + 1 armor
- **Hull bonus affects strategy:**
  - Frigate (+2 initiative) → favor offensive builds (shoot first, kill fast)
  - Battleship (+20 HP) → favor defensive builds (outlast enemy)
  - Cruiser (no bonus) → balanced builds

### Templates + Iteration
- **Fast iteration loop:**
  - Design → Save template → Test → Lose → Load template → Tweak → Test
  - Iteration time: 30s (load template + minor edits) vs 90s (full redesign)
- **A/B testing:**
  - Save "Offensive v1" → Test → Save "Defensive v1" → Test → Compare
  - Template names track experiments
- **Hull-specific templates:**
  - Can't load Frigate template on Cruiser → prevents invalid designs
  - Encourages specialized templates per hull type

---

## Design Philosophy

**Transparency First:**
- All systems have visible math (no hidden mechanics)
- Combat damage numbers show exact calculations
- Power grid visually shows which rooms active
- Synergies explicitly labeled and counted

**Failure = Learning:**
- Defeats point to specific design flaws (not RNG)
- Replay system enables detailed analysis
- Fast iteration encourages experimentation
- Templates allow incremental improvements

**Depth Through Layering:**
- Core: Tetris-like room placement (easy to grasp)
- Layer 1: Power routing (moderate complexity)
- Layer 2: Synergies (advanced optimization)
- Layer 3: Hull choice (meta-strategy)
- New players engage with core, experts optimize all layers

**Strategic Trade-offs:**
- Budget constraint forces specialization (can't have everything)
- Power routing vs room density (centralized vs distributed)
- Synergy placement vs power efficiency (adjacent weapons vs powered weapons)
- Hull type vs mission (initiative vs HP vs balance)

---

## Implementation Status

### Completed ✅
- Ship design & room placement
- Power routing (reactors, conduits, relays)
- Room synergies (4 types, visual indicators)
- Auto-resolved combat (turn-based, transparent)
- Hull type system (3 types + Free Design)
- Template save/load
- Combat replay & timeline scrubbing
- Intelligent enemy AI (3 targeting strategies)

### In Progress 🔲
- Tutorial system (guided first mission)
- Audio integration (SFX + music)
- Art pass (sprite art for rooms/ships)
- Save/load game state (progression persistence)

### Planned 📋
- More missions (10-15 total)
- More enemies (15-20 archetypes)
- More room types (12-15 total)
- More hulls (5-6 types)
- Achievements & statistics
- Mission editor
- Endless mode

---

**This document explains HOW systems work. For WHY, see 1-game-overview.md.**

**For implementation details, see `/scripts/` codebase and MVP_SUMMARY.md.**
