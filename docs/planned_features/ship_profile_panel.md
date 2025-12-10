# Ship Profile Panel (Live Design Feedback)

**Status:** 🔴 Planned
**Priority:** ⬆️ High
**Estimated Time:** 6-8 hours
**Dependencies:** Existing ShipDesigner, Room placement system
**Assigned To:** AI Assistant

---

## Purpose

**Why does this feature exist?**
Players currently design ships without immediate feedback on their overall strategy. They don't know if they've created a "glass cannon" or a "turtle" until combat starts. This feature provides real-time visual feedback showing ship strengths, weaknesses, and predicted performance as the player designs.

**What does it enable?**
Players can instantly see the consequences of their design choices. They'll understand tradeoffs (adding weapons increases offense but reduces other stats), identify critical weaknesses before combat, and experiment with different archetypes knowing what each build excels at. The feature transforms ship design from trial-and-error into strategic planning.

**Success criteria:**
- Stats update in real-time (< 0.1s delay) as rooms are placed/removed
- Players can identify their ship archetype at a glance
- Archetype detection accurately reflects ship capabilities
- Predicted win chances correlate with actual combat outcomes within ±15%
- Panel visible and readable throughout design phase
- Players report "feeling confident" about their design before launching

---

## How It Works

### Overview
The Ship Profile Panel sits on the right side of the ShipDesigner screen, displaying a radar chart and statistical analysis that updates every time a room is placed or removed. The system calculates five core stats (Offense, Defense, Speed, Durability, Efficiency) based on the ship's current loadout, then uses these to determine the ship's archetype (Glass Cannon, Turtle, Balanced, etc.).

The panel also analyzes the design for critical weaknesses (e.g., "no shield regeneration"), provides strategic advice ("good for fast battles"), and predicts win chances against known enemy types. All calculations happen instantly, giving players constant feedback as they experiment with different room placements.

### User Flow
```
1. Player opens ShipDesigner → Panel appears on right side showing empty stats
2. Player places first room (e.g., Weapon) → Offense bar fills to 20%, Archetype shows "INCOMPLETE"
3. Player adds more rooms → Stats update instantly, bars fill/drain dynamically
4. Player places 5th Weapon → Offense hits 100%, Defense at 10%, Archetype changes to "GLASS CANNON"
5. Panel displays warning: "⚠️ CRITICAL WEAKNESS: Low armor"
6. Player adds Shield → Defense increases to 30%, warning updates
7. Player hovers over stat bar → Tooltip shows calculation: "Offense: 5 weapons × 10 dmg = 50 / 60 max = 83%"
8. Player clicks "Predict Performance" → Panel shows "vs Scout: 85% win chance"
9. Player continues iterating until satisfied with profile
```

### Rules & Constraints
- Stats recalculate immediately on every room placement/removal
- All five stats must be between 0-100%
- Archetype detection requires minimum 5 rooms placed
- Win chance predictions only available if at least 1 weapon and 1 reactor placed
- Panel always visible (cannot be closed/hidden)
- Stats based on current grid state, ignoring power routing (shows potential, not actual)
- Efficiency stat considers total rooms vs powered rooms

### Edge Cases
- What happens if no rooms placed?
  → Display "Empty Ship - Place rooms to begin analysis"
- What happens if invalid ship (no Bridge)?
  → Show "⚠️ INVALID: Bridge required" in red
- What happens if budget exceeded?
  → Stats still calculate, but show "⚠️ Over budget - remove rooms"
- What happens if exact tie between archetypes (e.g., 60% offense, 60% defense)?
  → Priority order: Glass Cannon > Turtle > Speedster > Balanced
- What happens if all stats exactly 0?
  → Show "NO FUNCTIONAL SYSTEMS" archetype

---

## User Interaction

### Controls
- **No direct controls**: Panel is passive display, updates automatically
- **Hover on stat bars**: Shows tooltip with calculation breakdown
- **Hover on radar chart**: Highlights corresponding stat bar
- **Optional: Click archetype name**: Shows definition and strategy tips

### Visual Feedback
- **Stat bars**: Animated fill/drain with smooth lerp (0.2s transition)
- **Radar chart**: Polygon shape morphs as stats change
- **Archetype label**: Color changes (green/yellow/red) and pulses briefly on archetype shift
- **Warning icons**: Flash briefly (0.3s) when new weakness detected
- **Win chance numbers**: Count up/down animation when recalculated

### Audio Feedback
- **Stat increase**: Subtle positive chime (pitch increases with stat value)
- **Stat decrease**: Subtle negative tone (pitch decreases)
- **Archetype change**: Distinctive "achievement" sound
- **Critical weakness detected**: Warning beep
- **No sound spam**: Audio only plays if stat changes by ≥10%

---

## Visual Design

### Layout
```
┌─ SHIP PROFILE ──────────────────┐  ← Panel width: 350px
│                                  │     Panel height: Fill remaining
│        Offense                   │  ← Radar chart: 200x200px
│          /|\                     │     Centered at top
│         / | \                    │
│    Speed  |  Defense             │  ← Pentagon axes labeled
│         \ | /                    │
│          \|/                     │
│      Durability                  │
│                                  │
│  Archetype: GLASS CANNON         │  ← 24pt bold, color-coded
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│  Offense:    ████████░░  80%    │  ← Progress bars: 10 blocks
│  Defense:    ██░░░░░░░░  20%    │     Percentage label right-aligned
│  Speed:      ████░░░░░░  40%    │
│  Durability: ███░░░░░░░  30%    │
│  Efficiency: ██████░░░░  60%    │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│  ⚠️ CRITICAL WEAKNESSES:        │  ← Warning section (if any)
│  • Low armor (only 1 room)      │     Icon + bullet list
│  • No shield regeneration       │     Max 3 warnings shown
│  • Vulnerable to long battles   │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│  PREDICTED PERFORMANCE:          │  ← Strategy analysis
│  ✓ Fast decisive battles         │     Checkmarks/X marks
│  ✗ Attrition warfare             │
│  ✗ Multi-phase encounters        │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│  vs Scout:     85% win chance    │  ← Win predictions
│  vs Raider:    45% win chance    │     (if enough data)
│  vs Dreadnought: 15% win chance  │
└──────────────────────────────────┘
```

### Components
- **Radar Chart (Polygon2D)**: Pentagon with 5 vertices, filled with semi-transparent color
- **Stat Bars (ProgressBar)**: Custom theme, 10-segment blocks
- **Archetype Label (Label)**: Large, bold, color-modulated
- **Warning List (VBoxContainer)**: Icon + Rich Text Label for each warning
- **Performance Checklist (VBoxContainer)**: Checkmark/X + text labels
- **Win Chance List (VBoxContainer)**: Enemy name + percentage

### Visual Style
- **Colors:**
  - Background: Dark blue-gray (#0F1F28)
  - Panel border: Cyan (#4AE2E2)
  - Radar chart fill: Semi-transparent archetype color (50% opacity)
  - Radar chart outline: White (#FFFFFF)
  - Stat bar filled: Gradient (green → yellow → red based on value)
  - Stat bar empty: Dark gray (#2C2C2C)
  - Archetype colors:
    - Balanced: Green (#4AE24A)
    - Specialized: Yellow (#E2D44A)
    - Extreme: Red (#E24A4A)
- **Fonts:**
  - Archetype: 24pt bold, blueprint mono
  - Section headers: 16pt bold
  - Stat labels: 14pt regular
  - Body text: 12pt regular
- **Animations:**
  - Stat bars: Tween lerp over 0.2s
  - Radar chart: Tween vertices over 0.2s
  - Archetype color: Tween modulate over 0.3s
  - Warning flash: Tween modulate alpha 1.0 → 0.5 → 1.0 over 0.3s

### States
- **Default:** All elements visible, stats at current values
- **Empty Ship:** Radar chart collapsed to center, bars at 0%, "INCOMPLETE" archetype in gray
- **Archetype Change:** Archetype label pulses (scale 1.0 → 1.1 → 1.0) and color shifts
- **Warning Added:** New warning flashes briefly
- **Calculating:** Optional loading spinner if calculation takes > 0.1s (shouldn't happen)
- **Invalid Ship:** Red border around panel, large warning icon

---

## Technical Implementation

### Scene Structure
```
ShipProfilePanel.tscn
├── Panel (background with StyleBox)
├── MarginContainer (padding 15px all sides)
│   └── VBoxContainer (main layout)
│       ├── RadarChartContainer (Control, fixed 200×200)
│       │   ├── RadarChartPolygon (Polygon2D)
│       │   ├── RadarChartOutline (Line2D, 5 axes)
│       │   └── AxisLabels (5 Label nodes)
│       ├── ArchetypeLabel (Label, 24pt bold)
│       ├── Separator1 (HSeparator)
│       ├── StatsContainer (VBoxContainer)
│       │   ├── OffenseRow (HBoxContainer)
│       │   │   ├── OffenseLabel ("Offense:")
│       │   │   ├── OffenseBar (ProgressBar)
│       │   │   └── OffensePercent ("80%")
│       │   ├── DefenseRow (HBoxContainer)
│       │   ├── SpeedRow (HBoxContainer)
│       │   ├── DurabilityRow (HBoxContainer)
│       │   └── EfficiencyRow (HBoxContainer)
│       ├── Separator2 (HSeparator)
│       ├── WarningsContainer (VBoxContainer)
│       │   ├── WarningsHeader (Label "CRITICAL WEAKNESSES:")
│       │   └── WarningsList (VBoxContainer, dynamic)
│       ├── Separator3 (HSeparator)
│       ├── PerformanceContainer (VBoxContainer)
│       │   ├── PerformanceHeader (Label "PREDICTED PERFORMANCE:")
│       │   └── PerformanceList (VBoxContainer, dynamic)
│       ├── Separator4 (HSeparator)
│       └── WinChancesContainer (VBoxContainer)
│           └── WinChancesList (VBoxContainer, dynamic)
```

### Script Responsibilities
- **ShipProfilePanel.gd:** Main controller
  - Listens for `room_placed` and `room_removed` signals from ShipGrid
  - Calculates all stats via `calculate_stats()`
  - Determines archetype via `detect_archetype()`
  - Updates UI elements (bars, chart, labels)
  - Generates warnings via `analyze_weaknesses()`
  - Predicts performance via `predict_performance()`
  - Emits `profile_updated` signal when recalculation completes

- **RadarChart.gd:** Handles pentagon drawing
  - Takes 5 stat values (0-1 floats)
  - Calculates vertex positions in pentagon layout
  - Updates Polygon2D and Line2D nodes
  - Animates transitions with Tweens

- **ShipStatsCalculator.gd (optional utility):** Stat calculation logic
  - Static methods for each stat calculation
  - Keeps calculations separate from UI logic
  - Easier to test and reuse

### Data Structures
```gdscript
# ShipProfilePanel.gd
extends Panel

# Stats (0.0 to 1.0)
var offense: float = 0.0
var defense: float = 0.0
var speed: float = 0.0
var durability: float = 0.0
var efficiency: float = 0.0

# Archetype
enum Archetype {
    INCOMPLETE,
    GLASS_CANNON,
    TURTLE,
    SPEEDSTER,
    BALANCED,
    JUGGERNAUT,
    ALPHA_STRIKER,
    LAST_STAND,
    GUERRILLA
}
var current_archetype: Archetype = Archetype.INCOMPLETE

# Room counts (cached for calculations)
var weapon_count: int = 0
var shield_count: int = 0
var engine_count: int = 0
var armor_count: int = 0
var reactor_count: int = 0
var bridge_count: int = 0
var total_rooms: int = 0
var powered_rooms: int = 0

# Signals
signal profile_updated(offense, defense, speed, durability, efficiency, archetype)

func calculate_stats():
    # Count rooms
    weapon_count = count_rooms_of_type(RoomType.WEAPON)
    shield_count = count_rooms_of_type(RoomType.SHIELD)
    engine_count = count_rooms_of_type(RoomType.ENGINE)
    armor_count = count_rooms_of_type(RoomType.ARMOR)
    reactor_count = count_rooms_of_type(RoomType.REACTOR)
    bridge_count = count_rooms_of_type(RoomType.BRIDGE)
    total_rooms = weapon_count + shield_count + engine_count + armor_count + reactor_count + bridge_count
    powered_rooms = count_powered_rooms()

    # Calculate stats (0-100 scale)
    offense = calculate_offense()
    defense = calculate_defense()
    speed = calculate_speed()
    durability = calculate_durability()
    efficiency = calculate_efficiency()

    # Detect archetype
    current_archetype = detect_archetype()

    # Update UI
    update_radar_chart()
    update_stat_bars()
    update_archetype_label()
    update_warnings()
    update_performance()
    update_win_chances()

    profile_updated.emit(offense, defense, speed, durability, efficiency, current_archetype)

func calculate_offense() -> float:
    if weapon_count == 0:
        return 0.0
    # Max possible damage ~60 (6 weapons × 10 dmg)
    var damage_output = weapon_count * 10.0
    return min(100.0, (damage_output / 60.0) * 100.0)

func calculate_defense() -> float:
    # Max possible defense ~150 (shields + armor)
    var shield_value = shield_count * 15.0  # Shield absorption
    var armor_value = armor_count * 20.0   # HP bonus
    var total_defense = shield_value + armor_value
    return min(100.0, (total_defense / 150.0) * 100.0)

func calculate_speed() -> float:
    # Max speed ~6 engines
    var speed_value = engine_count * 16.67
    return min(100.0, speed_value)

func calculate_durability() -> float:
    # Base hull 60, max ~200 with armor
    var hull_hp = 60 + (armor_count * 20)
    return min(100.0, (hull_hp / 200.0) * 100.0)

func calculate_efficiency() -> float:
    if total_rooms == 0:
        return 100.0
    return (float(powered_rooms) / float(total_rooms)) * 100.0

func detect_archetype() -> Archetype:
    if total_rooms < 5:
        return Archetype.INCOMPLETE

    # Check extreme archetypes first
    if offense >= 80 and speed >= 60:
        return Archetype.ALPHA_STRIKER
    if durability >= 80 and defense >= 70:
        return Archetype.LAST_STAND
    if speed >= 70 and efficiency >= 60:
        return Archetype.GUERRILLA

    # Check primary archetypes
    if offense >= 70 and defense <= 30:
        return Archetype.GLASS_CANNON
    if defense >= 70 and offense <= 40:
        return Archetype.TURTLE
    if speed >= 70 and durability <= 40:
        return Archetype.SPEEDSTER
    if durability >= 70 and speed <= 30:
        return Archetype.JUGGERNAUT

    # Check balanced
    if offense >= 40 and offense <= 60 and defense >= 40 and defense <= 60:
        return Archetype.BALANCED

    return Archetype.BALANCED  # Default fallback

func analyze_weaknesses() -> Array[String]:
    var warnings = []

    if armor_count <= 1:
        warnings.append("Low armor (only %d room)" % armor_count)
    if shield_count == 0:
        warnings.append("No shields - vulnerable to burst damage")
    if engine_count == 0:
        warnings.append("No engines - will always shoot last")
    if reactor_count == 1 and total_rooms > 8:
        warnings.append("Single reactor - critical failure point")
    if powered_rooms < total_rooms:
        warnings.append("%d unpowered rooms (wasted budget)" % (total_rooms - powered_rooms))
    if weapon_count <= 1:
        warnings.append("Low firepower - battles will drag")
    if offense >= 70 and defense <= 20:
        warnings.append("Extreme glass cannon - one mistake = death")
    if defense >= 80 and offense <= 20:
        warnings.append("Too defensive - can't win by timeout")

    return warnings.slice(0, 3)  # Max 3 warnings

func predict_performance() -> Dictionary:
    var predictions = {
        "strengths": [],
        "weaknesses": []
    }

    # Analyze based on archetype
    match current_archetype:
        Archetype.GLASS_CANNON:
            predictions["strengths"].append("Fast decisive battles")
            predictions["weaknesses"].append("Attrition warfare")
            predictions["weaknesses"].append("Multi-phase encounters")
        Archetype.TURTLE:
            predictions["strengths"].append("Long battles")
            predictions["strengths"].append("Surviving alpha strikes")
            predictions["weaknesses"].append("Low damage output")
        Archetype.SPEEDSTER:
            predictions["strengths"].append("First strike advantage")
            predictions["strengths"].append("Avoiding slow enemies")
            predictions["weaknesses"].append("Prolonged combat")
        Archetype.BALANCED:
            predictions["strengths"].append("Versatile performance")
            predictions["strengths"].append("No critical weaknesses")
            predictions["weaknesses"].append("No dominant strength")

    return predictions

func calculate_win_chance(enemy_type: String) -> int:
    # Simplified win chance calculation
    # In real implementation, this would use combat simulation
    var player_power = (offense + defense + speed + durability) / 4.0

    var enemy_power = 0.0
    match enemy_type:
        "Scout":
            enemy_power = 30.0  # Weak
        "Raider":
            enemy_power = 50.0  # Medium
        "Dreadnought":
            enemy_power = 80.0  # Strong

    var power_diff = player_power - enemy_power
    var win_chance = 50 + (power_diff * 1.5)  # ±1.5% per power point

    return int(clamp(win_chance, 5, 95))  # Never 0% or 100%
```

### Integration Points
- **Connects to:** ShipDesigner (main scene), ShipGrid (room placement)
- **Emits signals:**
  - `profile_updated(stats, archetype)` - When recalculation completes
  - `archetype_changed(old, new)` - When archetype shifts
- **Listens for:**
  - `ShipGrid.room_placed(x, y, room_type)` - Triggers recalculation
  - `ShipGrid.room_removed(x, y)` - Triggers recalculation
  - `ShipGrid.grid_cleared()` - Resets to empty state
- **Modifies:** Only UI elements (does not affect game state/combat)

### Configuration
- **Constants in ShipProfilePanel.gd:**
  ```gdscript
  const MAX_DAMAGE = 60.0  # 6 weapons × 10 dmg
  const MAX_DEFENSE = 150.0  # Max shields + armor
  const MAX_DURABILITY = 200.0  # Max hull HP
  const BASE_HULL_HP = 60
  const WEAPON_DAMAGE = 10
  const SHIELD_ABSORPTION = 15
  const ARMOR_HP_BONUS = 20
  ```
- **Archetype thresholds:** Defined in `detect_archetype()` method
- **Tunable via inspector:** Update delay (default 0.0s, instant)

---

## Acceptance Criteria

Feature is complete when:

- [ ] Panel visible on right side of ShipDesigner screen
- [ ] Stats recalculate and update within 0.1s of room placement/removal
- [ ] Radar chart displays pentagon with 5 labeled axes (Offense, Defense, Speed, Durability, Efficiency)
- [ ] Stat bars show percentage values and fill proportionally
- [ ] Archetype label displays correct archetype based on stat thresholds
- [ ] Archetype color changes (green for balanced, yellow for specialized, red for extreme)
- [ ] Warning section appears when critical weaknesses detected (max 3 shown)
- [ ] Performance section shows strategic strengths/weaknesses
- [ ] Win chance predictions display for Scout, Raider, Dreadnought
- [ ] Empty ship shows "INCOMPLETE" archetype with 0% stats
- [ ] All animations smooth (stat bars lerp, radar chart morphs)
- [ ] Tooltips show calculation breakdown when hovering stat bars
- [ ] Panel responsive to window resizing (no overflow/clipping)

---

## Testing Checklist

### Functional Tests
- [ ] **Empty ship test**: Start with no rooms → Panel shows "INCOMPLETE", 0% stats
- [ ] **Single room test**: Place 1 Weapon → Offense increases, other stats remain 0%
- [ ] **Glass Cannon build**: Place 6 Weapons, 1 Bridge, 1 Reactor → Archetype = "GLASS CANNON", Offense ~100%, Defense ~0%
- [ ] **Turtle build**: Place 5 Shields, 5 Armor, 1 Bridge, 1 Reactor → Archetype = "TURTLE", Defense ~90%, Offense ~0%
- [ ] **Balanced build**: Place 3 Weapons, 3 Shields, 2 Engines, 2 Armor, 1 Bridge, 2 Reactors → Archetype = "BALANCED", all stats 40-60%
- [ ] **Room removal test**: Remove Weapon → Offense decreases immediately
- [ ] **Efficiency test**: Place rooms without powering them → Efficiency < 100%
- [ ] **Warning test**: Place only 1 armor → Warning "Low armor" appears

### Edge Case Tests
- [ ] **No Bridge test**: Place only Weapons → Warning "INVALID: Bridge required"
- [ ] **No Reactor test**: Place rooms but no Reactor → Efficiency = 0%, warning appears
- [ ] **Max rooms test**: Fill entire 8×6 grid → Stats calculate correctly, no overflow
- [ ] **Archetype tie test**: Build with exactly 60% offense, 60% defense → Archetype resolves deterministically
- [ ] **Rapid placement test**: Spam-click to place/remove rooms quickly → No lag, no visual glitches

### Integration Tests
- [ ] Works with existing ShipDesigner grid placement system
- [ ] Doesn't block room placement interactions
- [ ] Win chance predictions match actual combat outcomes (within ±15% variance)
- [ ] Panel visible during budget constraints (over-budget state)
- [ ] Stats update when power routing changes (if implemented)

### Polish Tests
- [ ] Stat bars lerp smoothly over 0.2s (no instant snapping)
- [ ] Radar chart morphs smoothly (vertices tween)
- [ ] Archetype label color transitions smoothly
- [ ] Warning flash animation plays when new warning added
- [ ] Audio feedback plays at appropriate volume (not spammy)
- [ ] Panel layout doesn't break at different resolutions (1280×720, 1920×1080, 2560×1440)
- [ ] Performance: Recalculation completes in < 0.1s (60 FPS maintained)

---

## Known Limitations

- **Simplified win chance calculation:** Current implementation uses basic power comparison, not full combat simulation. Future: Add Monte Carlo simulation for accurate predictions.
- **Static enemy data:** Win chances assume fixed enemy stats. Future: Dynamically load enemy data from mission files.
- **No power routing consideration:** Stats calculate based on room count, ignoring whether rooms are actually powered. Future: Integrate with power system to show "actual" vs "potential" stats.
- **Limited to 8 archetypes:** More granular classification possible. Future: Add "hybrid" archetypes (e.g., "Armored Striker").
- **No historical tracking:** Doesn't remember previous designs. Future: Add "compare to last build" feature.

---

## Future Enhancements

*(Not for MVP, but worth noting)*

- **Design history:** Save last 5 ship profiles for comparison
- **Target enemy selector:** Choose which enemy to optimize against
- **Real-time combat simulation:** Run 100 simulated battles, show win rate distribution
- **Recommended changes:** AI suggests "Add 1 Shield to reach 30% defense"
- **Archetype library:** Show example builds for each archetype
- **Export/share builds:** Generate shareable ship codes
- **Animated radar chart:** Show how stats change during combat (predictive animation)
- **Multi-ship comparison:** Compare current design to saved templates

---

## Implementation Notes

*(For AI assistant or future you)*

- **Polygon2D for radar chart:** Use 5 vertices in circular layout, calculate positions with `Vector2(cos(angle), sin(angle)) * radius`. Order: Offense (top), Defense (top-right), Durability (bottom-right), Speed (bottom-left), Efficiency (top-left).
- **Tween for animations:** Use `create_tween()` for smooth transitions. Set `trans_type = Tween.TRANS_CUBIC` and `ease_type = Tween.EASE_OUT` for natural motion.
- **ProgressBar custom theme:** Create StyleBoxFlat with 10 segments using `bg_color` for filled and `border_color` for separators. Use `theme_override_styles/fill` and `theme_override_styles/background`.
- **Performance optimization:** Cache room counts and only recalculate when rooms change. Use `call_deferred()` to avoid recalculating mid-frame.
- **Win chance formula:** Current simplified formula is `50 + (player_power - enemy_power) × 1.5`. Tune multiplier based on playtesting. Real implementation should use combat simulator from Combat.gd.
- **Archetype priority:** If multiple archetypes match, prioritize extreme builds over balanced. Order: ALPHA_STRIKER > LAST_STAND > GUERRILLA > GLASS_CANNON > TURTLE > SPEEDSTER > JUGGERNAUT > BALANCED.
- **Warning limit:** Display max 3 warnings to avoid clutter. Prioritize by severity: Invalid ship > Critical weaknesses > Inefficiencies > Strategic advice.
- **Alternative approach considered:** Circular radar chart instead of pentagon. Rejected because pentagon maps better to 5 discrete stats (clearer visual separation).

---

## Change Log

| Date | Change | Reason |
|------|--------|--------|
| 2025-12-09 | Initial spec | Feature planned for enhanced ship design feedback |

