# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Starship Designer** is a Godot 4.5 puzzle-combat game prototype testing the "design ship → auto-battle → iterate" gameplay loop. Players act as starship designers (not pilots), placing rooms on a grid to create ships that fight in auto-resolved battles.

**Core Design Pillars:**
- Engineering fantasy over piloting (design decisions, not twitch skills)
- Meaningful spatial puzzles (room placement matters, power routing, damage location)
- Clear feedback through simplicity (transparent combat math, immediate iteration)

**Prototype Scope:** Weekend project (12-16 hours) testing 5 critical questions about the core gameplay loop. See `docs/STARSHIP DESIGNER - Prototype Design D.md` for complete design document.

## Project Structure

```
scenes/
├── main/          # Main entry point (Main.tscn)
├── ui/            # Mission select, win/lose screens
├── designer/      # Ship designer grid interface
├── combat/        # Auto-battle visualization
└── components/    # Reusable UI/game components

scripts/
├── autoloads/     # Global systems (game state, combat engine)
├── data/          # Data structures (room types, ship stats, missions)
└── utils/         # Helper functions

assets/
├── sprites/
│   ├── rooms/     # 6 room type sprites (Bridge, Weapon, Shield, Engine, Reactor, Armor)
│   ├── ships/     # Player/enemy ship hulls
│   ├── ui/        # Buttons, panels, indicators
│   └── effects/   # Explosions, damage numbers, power lines
├── fonts/
└── sounds/        # (Optional, not in prototype scope)
```

## Running the Project

**Open in Godot:**
```bash
# Open project in Godot 4.5+
godot --path "/Users/diarmuidcurran/Godot Projects/Prototypes/starship-designer"
```

**Main Scene:** `res://scenes/main/Main.tscn` (set in project settings)

**No build step required** - Godot projects run directly in the editor or export to binary.

## Core Game Systems

### 1. Grid-Based Ship Design
- 8×6 tile grid (64×64px tiles = 512×384px total)
- 6 room types with costs: Bridge (2), Weapon (3), Shield (3), Engine (2), Reactor (2), Armor (1)
- 30-point budget constraint per mission (Mission 1: 20, Mission 2: 25, Mission 3: 30)
- Click tile → cycle rooms, right-click → remove
- Placement constraints: Weapons in top 2 rows, Engines in bottom 2 rows

### 2. Power Routing System
- Reactors power 4 adjacent tiles (cardinal directions only)
- Unpowered rooms = inactive (grayed out, don't contribute to combat stats)
- Visual feedback: green lines/glow from reactor to powered rooms

### 3. Auto-Resolved Combat
Turn-based calculation (player watches, no control):
1. Initiative check (more engines = shoot first)
2. Active ship shoots (damage = active weapons × 10)
3. Shields absorb (reduction = active shields × 15, capped at incoming damage)
4. Remaining damage hits hull
5. Damage destroys random rooms (20 damage = 1 room destroyed)
6. Switch active ship
7. Check win condition (hull ≤ 0 OR bridge destroyed = loss)

**Stats Calculation:**
- Hull HP: 60 base + (armor count × 20)
- Damage per turn: active weapons × 10
- Shield absorption: active shields × 15
- Initiative: engine count (tie = player wins)

### 4. Mission Structure
3 sequential missions with preset enemies:
- **Mission 1 "Patrol Duty":** Scout (4×4, 2 weapons, 1 shield, 2 engines, 40 HP)
- **Mission 2 "Convoy Defense":** Raider (6×5, 3 weapons, 2 shields, 1 engine, 60 HP)
- **Mission 3 "Fleet Battle":** Dreadnought (8×6, 5 weapons, 3 shields, 2 engines, 100 HP)

Win = unlock next mission, Lose = redesign and retry

## Godot-Specific Conventions

**Scene Organization:**
- Each major screen (designer, combat, mission select) is a separate scene
- Components are reusable scenes (e.g., GridTile, HealthBar, RoomSprite)
- Main.tscn orchestrates scene transitions

**Script Naming:**
- Match script filename to node name (e.g., `GridTile.gd` for GridTile scene)
- Use PascalCase for class names, snake_case for functions/variables

**Signals for Communication:**
- UI → logic: signals (e.g., `tile_clicked`, `room_placed`)
- Logic → UI: direct calls or signals for updates
- Combat engine emits signals for visualization (e.g., `damage_dealt`, `room_destroyed`)

**Autoloads (Singletons):**
- GameState: mission progress, current ship design
- CombatEngine: battle calculation, turn resolution

## Implementation Phases (from Design Doc)

**Phase 1 (4h):** Grid system with room placement and budget tracking
**Phase 2 (4h):** Combat math and auto-battle visualization
**Phase 3 (4h):** Power routing system with visual feedback
**Phase 4 (3h):** Mission structure with 3 preset enemies
**Phase 5 (3h):** Polish (damage numbers, animations, balance tuning)

## Success Criteria

Prototype tests 5 critical questions (score 1-5 each):
1. Is design → watch → iterate loop satisfying?
2. Does room placement feel strategic?
3. Is auto-combat readable?
4. Does budget create interesting trade-offs?
5. Is engineering fantasy compelling?

**Decision thresholds:**
- 20-25 points: Build full game
- 15-19 points: Iterate and retest
- <15 points: Pivot or kill

## Key Design Constraints

**What's IN the prototype:**
- 6 room types, 3 missions, auto-battle, power routing, budget system

**What's OUT (explicitly scoped out):**
- ❌ Crew management
- ❌ Resource gathering / meta-progression
- ❌ Real-time combat control
- ❌ Procedural enemies (handcrafted only)
- ❌ Sound/music (optional polish)
- ❌ Save system (complete in one sitting)
- ❌ Tooltips/tutorials (assume player understands)

## Combat Balance Reference

**Example Builds (30-point budget):**
- Glass Cannon: 1 Bridge, 6 Weapons, 2 Reactors, 3 Armor = 27 pts (high damage, fragile)
- Balanced: 1 Bridge, 3 Weapons, 3 Shields, 2 Engines, 2 Reactors, 2 Armor = 30 pts

**Quantitative Targets:**
- Mission 1: Beatable in 3 attempts
- Mission 2: Beatable in 5 attempts
- Mission 3: Beatable in 7 attempts
- Redesign time: 60 seconds (fast iteration is critical)
- Total session: 15-20 minutes

## Important Notes for Claude

- This is a rapid prototype (weekend scope), prioritize speed over perfection
- Combat must be transparent (player needs to understand why they lost)
- Power routing is a core puzzle mechanic (not just cosmetic)
- Budget constraint drives strategic depth (must force trade-offs)
- Grid constraints (weapons forward, engines back) create spatial puzzles
- No hidden mechanics - all math should be visible/debuggable


# STARSHIP DESIGNER - Development Roadmap

**Generated from:** STARSHIP DESIGNER - Prototype Design Document v0.1
**Target:** Weekend Prototype (12-16 hours)

---

## OVERVIEW

**Total Time Estimate:** 17-18 hours (with buffer for iteration)

**4-Phase Structure:**
1. **Visual Layout** (3.5h) - Static UI on screen, no interaction
2. **Interactive** (4h) - Respond to player input, basic placement
3. **Systems** (8h) - Combat logic, power routing, missions
4. **Polish** (3h) - Visual feedback, animations, balance

**Critical Questions Being Tested:**
- **Q1:** Is the design → watch → iterate loop satisfying?
- **Q2:** Does room placement feel strategic (not arbitrary)?
- **Q3:** Is auto-combat readable enough to understand failures?
- **Q4:** Does the 30-point budget create interesting trade-offs?
- **Q5:** Is the engineering fantasy compelling?

**Success Threshold:** 15+ points out of 25 (avg 3+/5 per question)

---

# PHASE 1: VISUAL LAYOUT

**Goal:** Player can see the ship designer grid, room sprites, and budget counter on screen (no interaction yet)

**Time:** 3.5 hours

---

## Feature 1.1: Grid Rendering

**Tests:** Q2 (Room placement feels strategic)
**Time:** 1 hour

### What Player Sees:
- **Position:** Center of screen, 8×6 grid of tiles
- **Size:** Each tile is 64×64 pixels, total grid is 512×384 pixels
- **Colors:** Empty tiles have dark gray background (#2C2C2C), 1px white border (#FFFFFF) between tiles
- **Visual states:** All tiles start empty (uniform appearance)

### What Player Does:
- Nothing yet (visual only)

### How It Works:
- Grid is 8 tiles wide × 6 tiles tall = 48 total tile positions
- Each tile has coordinates [x,y] from [0,0] (top-left) to [7,5] (bottom-right)
- Grid positioned at screen center (assuming 1280×720 resolution = grid at x:384, y:168)
- Each tile is a separate scene instance (GridTile.tscn) for modularity

### Acceptance Criteria:
- [ ] Visual check: 8×6 grid visible at screen center
- [ ] Visual check: Each tile is exactly 64×64 pixels
- [ ] Visual check: White borders visible between all tiles
- [ ] Manual test: Open designer scene, see complete grid with no missing tiles

### Shortcuts for This Phase:
- Hard-code grid to 8×6 (don't make it configurable)
- Use solid color fills (no textures/sprites yet)
- No hover states or visual feedback

---

## Feature 1.2: Room Type Sprites

**Tests:** Q2 (Room placement strategic), Q5 (Engineering fantasy)
**Time:** 1.5 hours

### What Player Sees:
- **Position:** Inside grid tiles (when placed)
- **Size:** 60×60 pixels (4px margin inside 64×64 tile)
- **Colors/Appearance:** 6 distinct room types, each with unique color and icon:
  - Bridge: Blue (#4A90E2) with command chair icon
  - Weapon: Red (#E24A4A) with crosshair icon
  - Shield: Cyan (#4AE2E2) with energy field icon
  - Engine: Orange (#E2A04A) with thruster icon
  - Reactor: Yellow (#E2D44A) with power core icon
  - Armor: Gray (#6C6C6C) with plate icon
- **Visual states:** Normal (full opacity), Unpowered (50% opacity gray overlay - for later)

### What Player Does:
- Nothing yet (visual only)

### How It Works:
- Each room type is a separate sprite/scene (Bridge.tscn, Weapon.tscn, etc.)
- Room costs: Bridge (2), Weapon (3), Shield (3), Engine (2), Reactor (2), Armor (1)
- Rooms have metadata: cost, type enum, placement constraints (weapons top 2 rows, engines bottom 2 rows)
- GridTile can hold reference to one Room instance or null (empty)

### Acceptance Criteria:
- [ ] Visual check: Can manually place each of 6 room types in a tile (via inspector)
- [ ] Visual check: Each room type visually distinct (different color + icon)
- [ ] Visual check: Room sprites centered in tiles with 4px margin
- [ ] Manual test: Place all 6 room types in grid (manually in editor), each looks correct

### Shortcuts for This Phase:
- Use simple colored rectangles + text labels instead of custom icons
- No animations or state changes
- Don't implement placement constraints yet (any room anywhere)

---

## Feature 1.3: Budget Display

**Tests:** Q4 (Budget creates trade-offs)
**Time:** 0.5 hours

### What Player Sees:
- **Position:** Top-right of screen, above grid
- **Size:** 200×60 pixel panel
- **Colors:** Dark background (#1A1A1A), white text (#FFFFFF)
- **Appearance:** Two lines of text:
  - "BUDGET: 20/30" (current/max in large font, 24pt)
  - "Remaining: 10" (smaller font, 16pt, color changes based on value)
- **Visual states:**
  - Green text (#4AE24A) when remaining > 5
  - Yellow (#E2D44A) when remaining 1-5
  - Red (#E24A4A) when remaining = 0
  - Red + bold when over budget (negative)

### What Player Does:
- Nothing yet (visual only, updates happen later)

### How It Works:
- Budget starts at mission-specific value: Mission 1 (20), Mission 2 (25), Mission 3 (30)
- Current budget = total cost of all placed rooms
- Remaining = max budget - current budget
- Display updates whenever room placed/removed (in Phase 2)

### Acceptance Criteria:
- [ ] Visual check: Budget panel visible at top-right
- [ ] Visual check: Shows "BUDGET: 0/30" and "Remaining: 30" at start
- [ ] Manual test: Manually set current to different values in inspector, see color changes (green→yellow→red)

### Shortcuts for This Phase:
- Hard-code max budget to 30 (don't vary by mission yet)
- Use Label nodes with simple color changes (no fancy animations)
- Static display (no updates yet)

---

## Feature 1.4: UI Chrome & Layout

**Tests:** Q5 (Engineering fantasy)
**Time:** 0.5 hours

### What Player Sees:
- **Screen title:** "SHIP DESIGNER" centered at top (36pt white text)
- **Launch button:** Bottom-right, 150×50 pixel button, "LAUNCH" text
  - Normal state: Dark blue (#2C4A8C), white text
  - Disabled state: Gray (#4C4C4C), dark gray text (default at start)
- **Background:** Dark space texture or solid dark blue-black (#0A0A1A)

### What Player Does:
- Nothing yet (button disabled)

### How It Works:
- Launch button stays disabled until valid ship design (has Bridge, within budget)
- Screen is a separate scene: ShipDesigner.tscn
- Main.tscn loads ShipDesigner as child scene

### Acceptance Criteria:
- [ ] Visual check: Title "SHIP DESIGNER" visible at top center
- [ ] Visual check: Launch button visible bottom-right, appears disabled (gray)
- [ ] Visual check: Background fills entire screen
- [ ] Manual test: Open ShipDesigner scene, see complete UI layout

### Shortcuts for This Phase:
- Use solid color background (no texture/parallax)
- Button is just a Button node (no custom sprites)
- No scene transition logic yet (button does nothing when enabled)

---

# PHASE 2: INTERACTIVE

**Goal:** Player can click tiles to place/remove rooms, see budget update in real-time, and launch button enables when valid

**Time:** 4 hours

---

## Feature 2.1: Tile Click Handling

**Tests:** Q2 (Placement feels strategic)
**Time:** 1 hour

### What Player Sees:
- **Hover state:** Tile border highlights white → cyan (#4AE2E2) when mouse over
- **Click feedback:** Brief flash (white overlay, 0.1s) when clicked
- **Cursor change:** Default → pointer when over tiles

### What Player Does:
- Move mouse over tiles → see highlight
- Left-click tile → (triggers room cycling in Feature 2.2)
- Right-click tile → (triggers room removal in Feature 2.2)

### How It Works:
- Each GridTile has mouse_entered/mouse_exited signals
- On mouse_entered: change border color to cyan, change cursor
- On mouse_exited: restore border to white, restore cursor
- On gui_input (left-click): emit signal "tile_clicked(x, y)"
- On gui_input (right-click): emit signal "tile_right_clicked(x, y)"
- ShipDesigner scene listens for these signals

### Acceptance Criteria:
- [ ] Interaction check: Hover over any tile → border turns cyan
- [ ] Interaction check: Move mouse away → border returns to white
- [ ] Interaction check: Left-click tile → see white flash
- [ ] Manual test: Hover and click all 48 tiles, each responds correctly

### Shortcuts for This Phase:
- Simple border color change (no glow effects)
- Flash is just a ColorRect overlay with tween
- Don't add sound effects

---

## Feature 2.2: Room Placement & Cycling

**Tests:** Q2 (Placement strategic), Q4 (Budget trade-offs)
**Time:** 1.5 hours

### What Player Sees:
- **Left-click empty tile:** Room appears (cycles: Bridge → Weapon → Shield → Engine → Reactor → Armor → Empty → repeat)
- **Left-click occupied tile:** Room changes to next type in cycle
- **Right-click occupied tile:** Room disappears (tile becomes empty)
- **Budget display:** Updates immediately showing new cost

### What Player Does:
- Left-click empty tile → see Bridge appear, budget shows "2/30"
- Left-click Bridge tile → Bridge changes to Weapon, budget shows "3/30"
- Continue clicking → cycles through all 6 types → returns to empty
- Right-click Weapon tile → Weapon removed, tile empty, budget shows "0/30"

### How It Works:
- GridTile stores current room type enum (Empty, Bridge, Weapon, Shield, Engine, Reactor, Armor)
- On tile_clicked signal:
  - Get current room type
  - Advance to next in cycle (Bridge → Weapon → Shield → Engine → Reactor → Armor → Empty → Bridge)
  - Update tile's visual (load new room sprite)
  - Emit "room_placed(x, y, room_type)" signal to ShipDesigner
- On tile_right_clicked signal:
  - Set room type to Empty
  - Clear tile's visual
  - Emit "room_removed(x, y)" signal to ShipDesigner
- ShipDesigner tracks all placed rooms, recalculates total cost, updates budget display

### Acceptance Criteria:
- [ ] Interaction check: Left-click empty tile → Bridge appears
- [ ] Interaction check: Left-click 7 times → cycles through all types and returns to empty
- [ ] Interaction check: Right-click occupied tile → becomes empty
- [ ] Manual test: Place Bridge (see "2/30"), place Weapon (see "5/30"), remove Bridge (see "3/30")

### Shortcuts for This Phase:
- Ignore placement constraints (weapons/engines can go anywhere)
- Allow multiple Bridges (validation comes in 2.3)
- Simple sprite swap (no placement animation)

---

## Feature 2.3: Budget Validation & Constraints

**Tests:** Q4 (Budget trade-offs), Q2 (Placement strategic)
**Time:** 1 hour

### What Player Sees:
- **Over-budget prevention:** Click to place room → if cost exceeds budget, room doesn't place and tile briefly flashes red
- **Invalid placement:** Try to place Weapon in bottom row → tile flashes red, doesn't place
- **No-Bridge warning:** Budget display shows "NEED BRIDGE" in red if no Bridge placed
- **Budget color coding:** (from 1.3) Updates as you place rooms

### What Player Does:
- Place rooms until budget = 30/30 → try to place another → see red flash, can't place
- Place Weapon in row 5 (bottom) → see red flash, can't place
- Place Weapon in row 0 (top) → succeeds
- Remove all rooms → budget display shows "NEED BRIDGE" warning

### How It Works:
- Before placing room in GridTile:
  1. Check placement constraints:
     - Weapon: must be in rows 0-1 (top 2 rows)
     - Engine: must be in rows 4-5 (bottom 2 rows)
     - Other rooms: anywhere
  2. Calculate new total cost = current budget + room cost
  3. If new total > max budget OR constraint violated → reject placement, flash red, return
  4. Otherwise: place room normally
- ShipDesigner tracks Bridge count:
  - If Bridge count = 0: show "NEED BRIDGE" warning
  - If trying to place 2nd Bridge: reject (only 1 allowed)
- Budget validation happens in real-time before placement

### Acceptance Criteria:
- [ ] Interaction check: Fill budget to 30 → try to place 3-cost room → see red flash, doesn't place
- [ ] Interaction check: Try to place Weapon in row 4 → red flash, rejected
- [ ] Interaction check: Try to place Engine in row 0 → red flash, rejected
- [ ] Manual test: Place only Weapons and Engines, confirm rows 0-1 for weapons, rows 4-5 for engines work
- [ ] Interaction check: Place 2 Bridges → second one rejected

### Shortcuts for This Phase:
- Simple red flash (no detailed error message popup)
- Hard-code row constraints (don't make them data-driven)
- No tutorial/tooltips explaining constraints

---

## Feature 2.4: Launch Button Enablement

**Tests:** Q1 (Design → iterate loop)
**Time:** 0.5 hours

### What Player Sees:
- **Button state changes:**
  - Disabled (gray): when no Bridge OR over budget
  - Enabled (blue): when has Bridge AND within budget
- **Hover effect (when enabled):** Button lightens to bright blue on mouse-over
- **Click (when enabled):** Button text changes to "LAUNCHING..." briefly

### What Player Does:
- Start with no rooms → button disabled (gray)
- Place Bridge → button still disabled (needs to be within budget, but 2/30 is valid... actually should enable)
- Place rooms until over budget → button disables
- Adjust design to valid state → button enables
- Click enabled button → (triggers combat scene transition in Phase 3)

### How It Works:
- ShipDesigner checks after every room placement/removal:
  - valid = (bridge_count == 1) AND (current_budget <= max_budget)
  - Update button: disabled = !valid
- Button's disabled property controls visual state and click blocking
- When clicked (if enabled): emit "launch_pressed" signal (combat scene loads in Phase 3)

### Acceptance Criteria:
- [ ] Visual check: Button starts disabled (gray)
- [ ] Interaction check: Place Bridge only (2 pts) → button enables (blue)
- [ ] Interaction check: Place rooms until budget = 31 → button disables
- [ ] Interaction check: Remove room to budget = 30 → button enables
- [ ] Interaction check: Remove Bridge → button disables
- [ ] Manual test: Design valid ship (Bridge + rooms, ≤30 budget) → button blue, clickable

### Shortcuts for This Phase:
- Simple disabled property toggle (no smooth transitions)
- Don't validate power routing yet (unpowered rooms still count)
- Button click doesn't do anything yet (combat scene in Phase 3)

---

# PHASE 3: SYSTEMS

**Goal:** Player can launch into auto-combat, watch ships fight with turn-based logic, see power routing, and play through 3 missions

**Time:** 8 hours

---

## Feature 3.1: Combat Scene Layout

**Tests:** Q1 (Design → iterate loop), Q3 (Combat readable), Q5 (Engineering fantasy)
**Time:** 1 hour

### What Player Sees:
- **Background:** Dark space with stars (same as designer)
- **Player ship:** Left side (x: 200), large sprite showing grid with placed rooms
- **Enemy ship:** Right side (x: 1080), similar sprite with enemy's rooms
- **Health bars:** Above each ship, 300×40 pixel bars
  - Green fill (#4AE24A) when HP > 50%
  - Yellow (#E2D44A) when HP 25-50%
  - Red (#E24A4A) when HP < 25%
  - Text overlay: "80 / 100 HP"
- **Turn indicator:** Center top (640, 50), "PLAYER TURN" or "ENEMY TURN" in large text
- **Return button:** Bottom-left, "REDESIGN" (appears only when combat ends)

### What Player Does:
- Click Launch button in designer → screen transitions to combat scene
- Watch ships appear facing each other
- See health bars at full
- Wait for combat to start (automatic)

### How It Works:
- Combat scene (Combat.tscn) loads when "launch_pressed" signal emitted
- ShipDesigner passes player ship data (grid of room types) to Combat scene
- Combat scene receives enemy ship data from current mission (hard-coded for now)
- Ships rendered by drawing grid with room sprites (reuse room sprites from Phase 1)
- Health bars are ProgressBar nodes with custom colors
- Turn indicator is Label node (updates during combat in 3.2)

### Acceptance Criteria:
- [ ] Visual check: Click Launch → see combat scene with 2 ships facing each other
- [ ] Visual check: Player ship on left shows rooms placed in designer
- [ ] Visual check: Enemy ship on right shows different room layout
- [ ] Visual check: Both health bars visible, showing full HP (green)
- [ ] Visual check: Turn indicator shows "PLAYER TURN" or "ENEMY TURN"

### Shortcuts for This Phase:
- Static ship sprites (no animations yet)
- Hard-code enemy ship to Mission 1 Scout layout (2 weapons, 1 shield, 2 engines, 40 HP)
- Ships don't move or animate (static positions)
- Return button appears immediately (doesn't wait for combat end)

---

## Feature 3.2: Combat Calculation Engine

**Tests:** Q1 (Design → iterate loop), Q3 (Combat readable)
**Time:** 2.5 hours

### What Player Sees:
- **Turn sequence (1 second per turn):**
  1. Turn indicator shows active ship
  2. Active ship flashes briefly (white overlay)
  3. Damage number appears above target ship (floating text, e.g., "-30")
  4. Target health bar decreases smoothly
  5. If room destroyed: target ship room sprite explodes (gray sprite replaces it)
  6. Pause 1 second
  7. Repeat for other ship
- **Combat end:**
  - Winning ship flashes green
  - Losing ship flashes red, all rooms gray out
  - Big text overlay: "VICTORY" or "DEFEAT"
  - Return button enables

### What Player Does:
- Watch combat play out automatically (no input)
- Read damage numbers and health changes
- See which rooms get destroyed
- Understand why they won/lost
- Click "REDESIGN" to return to designer with same budget

### How It Works:

**Combat Loop (executes automatically on scene load):**

1. **Initialize:**
   - Count active rooms for each ship (powered rooms only - but power check added in 3.3, count all for now)
   - Player stats: weapons_count, shields_count, engines_count, armor_count
   - Enemy stats: same
   - Hull HP: 60 base + (armor_count × 20)

2. **Initiative Check (once):**
   - Compare engines_count: higher shoots first
   - Tie: player shoots first
   - Store turn order

3. **Turn Loop:**

   **Active Ship's Turn:**
   - Calculate damage: weapons_count × 10
   - Target's shields absorb: min(damage, shields_count × 15)
   - Remaining damage: max(0, damage - shield_absorption)
   - Apply to target hull: hull_hp -= remaining_damage
   - Destroy rooms: for each 20 damage, destroy 1 random active room

   **Visual Updates:**
   - Show turn indicator
   - Flash active ship
   - Spawn damage number as Label with tween (float up, fade out)
   - Update health bar with tween
   - If room destroyed: replace sprite with gray version

   **Check Win Condition:**
   - If target hull_hp ≤ 0: target loses
   - If target Bridge destroyed: target loses instantly
   - If winner determined: break loop, show end screen

   **Switch Turn:**
   - Toggle active ship
   - Wait 1 second (await get_tree().create_timer(1.0).timeout)
   - Repeat

4. **Combat End:**
   - Display "VICTORY" or "DEFEAT"
   - Flash winner green, loser red
   - Enable "REDESIGN" button

**Room Destruction Logic:**
- Get list of active rooms (exclude Bridge initially)
- For each 20 damage: pick random room from list, mark destroyed
- If all non-Bridge rooms destroyed and damage remains: destroy Bridge → instant loss

### Acceptance Criteria:
- [ ] Manual test: Design ship with 3 weapons (30 damage), enemy has 0 shields → see "-30" damage number, enemy HP drops 30
- [ ] Manual test: Design ship with 3 weapons, enemy has 3 shields (45 absorption) → see "-0" damage (shields absorb all)
- [ ] Manual test: Design ship with 2 engines, enemy with 1 → player shoots first every turn
- [ ] Manual test: Watch combat until one ship reaches 0 HP → see VICTORY/DEFEAT screen
- [ ] Interaction check: Click REDESIGN → return to ship designer with empty grid (budget reset)
- [ ] Manual test: Design ship, let enemy destroy Bridge → instant defeat even if HP > 0

### Shortcuts for This Phase:
- Simple random room destruction (don't weight by importance)
- Basic damage number (plain text, simple float-up tween)
- 1 second per turn (don't make speed adjustable)
- Don't show detailed combat log (just visual feedback)
- REDESIGN button returns to empty grid (doesn't save previous design)

---

## Feature 3.3: Power Routing System

**Tests:** Q2 (Placement strategic), Q4 (Budget trade-offs)
**Time:** 2 hours

### What Player Sees:

**In Designer:**
- **Powered tiles:** When reactor placed, 4 adjacent tiles (up/down/left/right) show green corner indicators
- **Unpowered rooms:** Rooms not adjacent to any reactor have 50% opacity + gray overlay
- **Power lines:** Green lines (2px wide) connect reactor to adjacent powered rooms (visual guide)
- **Reactor removed:** Green indicators disappear, affected rooms become gray

**In Combat:**
- Only powered rooms count for stats
- Unpowered rooms visible but grayed out (don't participate)
- When reactor destroyed: connected rooms gray out mid-combat

### What Player Does:

**In Designer:**
- Place Reactor in grid → see 4 adjacent tiles gain green indicators
- Place rooms adjacent to Reactor → they appear normal (powered)
- Place rooms NOT adjacent to Reactor → they appear gray (unpowered)
- Hover over unpowered room → (optional) tooltip "UNPOWERED - No reactor adjacent"
- Remove Reactor → see previously powered rooms turn gray

**In Combat:**
- Watch combat → unpowered rooms don't contribute to weapon/shield/engine counts
- See reactor destroyed → connected rooms gray out immediately

### How It Works:

**Power Checking Algorithm:**
- For each room at position [x,y]:
  - Check 4 adjacent tiles: [x-1,y], [x+1,y], [x,y-1], [x,y+1]
  - If any adjacent tile contains Reactor → room is powered
  - Reactors power themselves (always active)
  - Bridge doesn't need power (special case, always active)
- Run power check whenever:
  - Room placed/removed
  - Combat starts (recalculate stats)
  - Reactor destroyed in combat

**Visual Feedback in Designer:**
- When room placed: check power status
  - If powered: full opacity, no overlay
  - If unpowered: 50% opacity, gray ColorRect overlay
- Draw green lines: for each reactor, draw Line2D from reactor center to each adjacent powered room center

**Combat Integration:**
- When calculating stats (weapons_count, shields_count, engines_count):
  - Only count rooms where powered == true
  - Example: 5 weapons placed, only 3 powered → weapons_count = 3 → damage = 30 (not 50)
- When reactor destroyed:
  - Recalculate power for all rooms
  - Update visual (gray out newly unpowered rooms)
  - Recalculate stats for next turn

### Acceptance Criteria:
- [ ] Visual check: Place Reactor → see green corner indicators on 4 adjacent tiles
- [ ] Visual check: Place Weapon adjacent to Reactor → appears normal (full opacity)
- [ ] Visual check: Place Weapon NOT adjacent to Reactor → appears gray (50% opacity)
- [ ] Interaction check: Remove Reactor → previously powered rooms turn gray
- [ ] Manual test: Place 2 Reactors, create power grid covering 8 rooms → all appear powered
- [ ] Manual test: Design ship with 3 weapons (only 2 powered) → in combat, damage = 20 (not 30)
- [ ] Manual test: In combat, reactor destroyed → connected rooms gray out, stats recalculate

### Shortcuts for This Phase:
- Simple corner indicators (don't draw full grid glow)
- Basic line drawing (no animated energy flow)
- Don't show power grid preview before placement
- Reactors can't power through other rooms (only direct adjacency, no chaining)

---

## Feature 3.4: Room Destruction Visual Feedback

**Tests:** Q3 (Combat readable)
**Time:** 1 hour

### What Player Sees:
- **Room about to be destroyed:** Flashes red 3 times (0.1s on/off)
- **Destruction moment:**
  - Explosion sprite appears (orange/yellow circle, 80×80 px, centered on room)
  - Explosion expands from 60px → 80px → fades out (0.3s total)
  - Room sprite replaced with "destroyed" version (same shape, dark gray, cracks/damage)
- **Post-destruction:** Destroyed room remains visible but clearly non-functional (dark, broken sprite)

### What Player Does:
- Watch combat
- See specific rooms flash red before destruction
- Understand which rooms were lost and why
- Connect room loss to decreased ship performance

### How It Works:
- When room selected for destruction:
  1. Start red flash tween (modulate color: white → red, repeat 3x, 0.3s total)
  2. After flash: instantiate Explosion scene at room position
  3. Explosion plays animation (scale + fade tween, 0.3s)
  4. Replace room sprite with destroyed version (load "destroyed_[roomtype].png")
  5. Mark room as inactive (powered = false, doesn't count in stats)
- Destroyed rooms tracked in array, excluded from future destruction targets
- If all non-Bridge rooms destroyed: next destruction targets Bridge → instant loss

### Acceptance Criteria:
- [ ] Visual check: Watch combat, see rooms flash red before destruction
- [ ] Visual check: Explosion appears when room destroyed (orange burst)
- [ ] Visual check: After explosion, room sprite changes to dark/broken version
- [ ] Manual test: Let enemy deal 60 damage → see 3 rooms destroyed (60/20 = 3)
- [ ] Manual test: Count active weapons before/after destruction → verify stats recalculate

### Shortcuts for This Phase:
- Simple circular explosion sprite (no particle effects)
- Destroyed sprite = same sprite with dark gray modulate (don't create custom damaged sprites)
- All rooms use same explosion (don't customize per room type)

---

## Feature 3.5: Mission Structure & Progression

**Tests:** Q1 (Design → iterate loop)
**Time:** 1.5 hours

### What Player Sees:

**Mission Select Screen (new scene):**
- **Title:** "MISSION SELECT" at top
- **3 mission buttons:** Vertically centered, 400×100 px each
  - Mission 1: "PATROL DUTY" - Unlocked (blue, clickable)
  - Mission 2: "CONVOY DEFENSE" - Locked (gray, shows padlock icon)
  - Mission 3: "FLEET BATTLE" - Locked (gray, shows padlock icon)
- **Mission brief (when hovering unlocked mission):**
  - Small panel below button, 400×60 px
  - Shows 2-3 sentence description
- **Back button:** Bottom-left, returns to main menu (out of scope, just exits for now)

**Mission Flow:**
1. Select Mission 1 → loads ShipDesigner with budget = 20
2. Design ship → Launch → Combat vs Scout
3. **Win:** Return to Mission Select, Mission 2 now unlocked
4. **Lose:** Return to ShipDesigner with same budget, redesign
5. Repeat for Missions 2 and 3

**Victory Screen (after Mission 3 win):**
- Big text: "ALL MISSIONS COMPLETE"
- "You've proven your designs can win the war!"
- Button: "RETURN TO MENU" (exits to Mission Select)

### What Player Does:
- Start game → see Mission Select screen
- Click "PATROL DUTY" button → loads designer
- Design ship with 20-point budget
- Launch, watch combat
- **If win:** Return to Mission Select, see Mission 2 unlocked, click it
- **If lose:** Return to designer, redesign, retry
- Complete all 3 missions → see victory screen

### How It Works:

**Mission Data Structure:**
```
Mission 1: "Patrol Duty"
- Brief: "Pirates raiding supply lines. Need fast interceptor."
- Player Budget: 20 points
- Enemy: Scout
  - Grid: 4×4 (smaller than player's 8×6)
  - Rooms: 1 Bridge, 2 Weapons, 1 Shield, 2 Engines, 1 Reactor, 1 Armor
  - Hull: 40 HP (60 base - 20, or 60 base + 0 armor, adjusted)
  - Actually: 60 base + 1 armor × 20 = 80 HP (use 60 base, no armor for Scout = 60 HP, but GDD says 40 HP)
  - Use GDD exactly: 40 HP total (so base = 40, no armor bonus)

Mission 2: "Convoy Defense"
- Brief: "Enemy cruiser attacking convoy. Engage and destroy."
- Player Budget: 25 points
- Enemy: Raider
  - Grid: 6×5
  - Rooms: 1 Bridge, 3 Weapons, 2 Shields, 1 Engine, 2 Reactors
  - Hull: 60 HP (from GDD)

Mission 3: "Fleet Battle"
- Brief: "Capital ship inbound. This is our final stand."
- Player Budget: 30 points
- Enemy: Dreadnought
  - Grid: 8×6 (same as player)
  - Rooms: 1 Bridge, 5 Weapons, 3 Shields, 2 Engines, 3 Reactors
  - Hull: 100 HP (from GDD)
```

**Progression System:**
- GameState autoload (singleton) tracks:
  - missions_unlocked: array [true, false, false]
  - current_mission: int (0, 1, or 2)
- When mission won:
  - Set missions_unlocked[current_mission + 1] = true
  - Return to MissionSelect
- When mission lost:
  - Return to ShipDesigner for same mission (retry)
- MissionSelect loads from GameState to show unlocked missions

**Scene Flow:**
- Main → MissionSelect
- MissionSelect → ShipDesigner (pass mission data)
- ShipDesigner → Combat (pass player + enemy ship data)
- Combat → ShipDesigner (if loss) OR MissionSelect (if win)

### Acceptance Criteria:
- [ ] Visual check: Launch game → see Mission Select with Mission 1 unlocked, Missions 2-3 locked
- [ ] Interaction check: Click Mission 1 → loads designer with budget "20/20"
- [ ] Manual test: Design ship, launch, win combat → return to Mission Select, see Mission 2 unlocked
- [ ] Manual test: Click Mission 2 → loads designer with budget "25/25"
- [ ] Manual test: Design ship, launch, lose combat → return to designer (not Mission Select)
- [ ] Manual test: Win all 3 missions → see "ALL MISSIONS COMPLETE" victory screen
- [ ] Visual check: Enemy ships in combat show correct layouts (Scout 4×4, Raider 6×5, Dreadnought 8×6)

### Shortcuts for This Phase:
- Hard-code enemy ship layouts (don't use data files)
- Simple unlock system (boolean array, no save persistence)
- No mission stats tracking (attempts, time, etc.)
- Victory screen is just text overlay (no fancy animation)
- GameState autoload only tracks mission unlocks (no other global state)

---

# PHASE 4: POLISH

**Goal:** Visual feedback polished, combat feels juicy, game is balanced and ready for playtesting

**Time:** 3 hours

---

## Feature 4.1: Visual Feedback & Juice

**Tests:** Q3 (Combat readable), Q5 (Engineering fantasy)
**Time:** 1.5 hours

### What Player Sees:

**Enhanced Damage Numbers:**
- Larger font (32pt)
- Bold, outlined text (white text, black outline)
- Floats up 50px, fades out over 0.8s
- Different colors based on effectiveness:
  - Red: damage dealt to hull (shields overwhelmed)
  - Cyan: damage absorbed by shields (0 hull damage)
  - Orange: partial absorption (some shield, some hull)

**Ship Flash Feedback:**
- When taking damage: ship flashes red (0.1s)
- When dealing damage: attacker flashes white (0.1s)
- When healed/repaired (n/a for prototype): would flash green

**Turn Indicator Enhancement:**
- "PLAYER TURN" pulses larger (scale 1.0 → 1.1 → 1.0, 0.5s)
- "ENEMY TURN" also pulses
- Background glow behind text (matching ship color)

**Grid Power Lines (enhanced from 3.3):**
- Animated flow: dashed line pattern scrolls along line (creates "energy flowing" effect)
- Pulses brighter when reactor powering multiple rooms (0.8s pulse cycle)

**Button Hover Polish:**
- Launch button: scales 1.0 → 1.05 on hover, smooth tween
- Mission buttons: same scale effect
- Redesign button: gentle glow pulse (0.5s cycle)

### What Player Does:
- Same interactions as before, but with enhanced visual feedback
- Feels more responsive and satisfying
- Easier to read combat events at a glance

### How It Works:
- Damage numbers use Tween for movement (position.y -= 50) and modulate.a (255 → 0)
- Color determined by damage calculation:
  ```
  if remaining_damage > 0: color = red
  elif shield_absorption == damage: color = cyan
  else: color = orange
  ```
- Flash effects use Tween on modulate property
- Turn indicator uses Tween on scale
- Power lines use Line2D with animated texture offset (offset += delta * speed)
- Button hover uses Tween on scale (triggered by mouse_entered/exited signals)

### Acceptance Criteria:
- [ ] Visual check: Watch combat, damage numbers large and clearly visible
- [ ] Visual check: Damage to hull shows red numbers, fully absorbed shows cyan
- [ ] Visual check: Ships flash red when hit, white when attacking
- [ ] Visual check: Turn indicator pulses larger when active
- [ ] Visual check: Power lines appear to flow/animate (energy effect)
- [ ] Interaction check: Hover over Launch button → scales up slightly

### Shortcuts for This Phase:
- Simple color changes (don't add gradients or particle effects)
- Basic tweens (no complex animation curves)
- No sound effects (still out of scope)

---

## Feature 4.2: Combat Animation Timing

**Tests:** Q1 (Design → iterate loop), Q3 (Combat readable)
**Time:** 1 hour

### What Player Sees:
- Combat plays at better pace (not too slow, not too fast)
- Clear sequence: turn indicator → attacker flash → damage number → health bar update → room destruction → pause → next turn
- Each action has distinct moment (not overlapping/confusing)
- Optional: "Fast Forward" button (2x speed) for repeat playthroughs

### What Player Does:
- Watch combat at comfortable pace on first attempt
- (Optional) Click "FF" button on retry to speed through known combat

### How It Works:
- Adjust timing of combat loop:
  - Turn indicator appears: wait 0.5s
  - Attacker flashes: wait 0.2s
  - Damage calculated: wait 0.1s
  - Damage number spawns, health bar tweens: wait 0.8s (for tween to complete)
  - If room destroyed: explosion plays: wait 0.5s
  - Turn ends: wait 0.5s
  - Next turn starts
- Total per turn: ~2.5-3s (adjust based on feel during testing)
- Fast Forward: multiply all wait times by 0.5 (or just reduce to 0.2s each)

### Acceptance Criteria:
- [ ] Manual test: Watch full combat (player vs Scout) → takes 15-30 seconds total (feels right pacing)
- [ ] Visual check: Can clearly see each action (turn change, attack, damage, destruction)
- [ ] Manual test: Watch combat 3 times → doesn't feel too slow or boring
- [ ] (Optional) Interaction check: Click FF button → combat plays at 2x speed

### Shortcuts for This Phase:
- Hard-code timing values (don't make them configurable)
- FF button just halves all waits (no smooth speed transition)
- Don't add pause/step-through controls

---

## Feature 4.3: Balance Tuning & Playtesting

**Tests:** All 5 critical questions
**Time:** 0.5 hours (coding) + extended playtesting

### What Player Sees:
- Mission 1 beatable with basic strategy (tutorial difficulty)
- Mission 2 requires thoughtful design (learning curve)
- Mission 3 challenging but achievable with optimization (peak difficulty)
- Budget feels tight but fair (must make trade-offs, but not impossible)

### What Player Does:
- Play through all 3 missions
- Try different ship designs
- Win Mission 1 in 1-3 attempts
- Win Mission 2 in 3-5 attempts
- Win Mission 3 in 5-7 attempts
- Feel satisfied with victories (earned through design, not luck)

### How It Works:
- **Balance Levers to Adjust:**
  - Room costs (currently: Bridge 2, Weapon 3, Shield 3, Engine 2, Reactor 2, Armor 1)
  - Mission budgets (currently: 20, 25, 30)
  - Enemy ship stats (weapons, shields, engines, armor counts)
  - Damage/shield formulas (currently: weapon × 10, shield × 15)
  - Room destruction threshold (currently: 20 damage per room)

- **Playtesting Process:**
  1. Play Mission 1 with "balanced" build (from GDD: 3 weapons, 3 shields, 2 engines, 2 reactors, 2 armor for 30pt budget)
     - Adjust to 20pt budget: try 2 weapons, 2 shields, 2 engines, 1 reactor, 3 armor = 19 pts
  2. If too easy: buff enemy Scout (add 1 weapon or shield)
  3. If too hard: nerf Scout (reduce 1 weapon or reduce HP to 30)
  4. Repeat for Missions 2 and 3
  5. Test extreme builds:
     - Glass Cannon (all weapons, no defense) - should be risky but viable
     - Turtle (max shields, min weapons) - should be slow but safe
  6. Adjust room costs if builds feel obviously optimal (e.g., if everyone stacks shields, increase cost to 4)

- **Target Metrics (from GDD):**
  - Mission 1: Beatable in 3 attempts
  - Mission 2: Beatable in 5 attempts
  - Mission 3: Beatable in 7 attempts
  - Redesign time: ~60 seconds
  - Combat time: ~30 seconds

### Acceptance Criteria:
- [ ] Manual test: Play Mission 1 (fresh, no prior knowledge) → win within 3 attempts
- [ ] Manual test: Play Mission 2 → win within 5 attempts
- [ ] Manual test: Play Mission 3 → win within 7 attempts
- [ ] Manual test: Try Glass Cannon build (6 weapons, 1 reactor, 1 bridge, 1 armor vs Mission 1) → can win but risky
- [ ] Manual test: Try Turtle build (2 weapons, 5 shields, reactors) → can win but slow
- [ ] Observation: Redesigning ship takes ~60 seconds (comfortable, not rushed)
- [ ] Observation: Combat lasts 15-45 seconds (engaging, not boring)

### Shortcuts for This Phase:
- Balance by feel and rapid iteration (no spreadsheet math)
- Test with 2-3 builds per mission (not exhaustive)
- Accept rough balance (doesn't need to be tournament-ready)
- Document final values in GDD or comments for post-prototype reference

---

## APPENDIX: Scene Architecture Recommendations

Based on the roadmap, here's suggested scene structure:

### Core Scenes:
- **Main.tscn** - Entry point, loads MissionSelect
- **MissionSelect.tscn** - Mission selection UI
- **ShipDesigner.tscn** - Grid-based ship designer
- **Combat.tscn** - Auto-battle visualization
- **VictoryScreen.tscn** - Final win screen (after Mission 3)

### Reusable Components:
- **GridTile.tscn** - Single tile (used 48 times in ShipDesigner grid)
  - Signals: tile_clicked(x, y), tile_right_clicked(x, y)
  - Properties: x, y, current_room_type, is_powered
- **Room.tscn** - Base room (inherited by 6 room types)
  - Properties: room_type enum, cost, is_powered, is_destroyed
  - 6 variants: Bridge.tscn, Weapon.tscn, Shield.tscn, Engine.tscn, Reactor.tscn, Armor.tscn
- **HealthBar.tscn** - Health display with color gradient
  - Properties: current_hp, max_hp
  - Methods: update_hp(new_value), set_color_by_percentage()
- **DamageNumber.tscn** - Floating damage text
  - Properties: damage_value, damage_type (hull/shield/mixed)
  - Auto-plays tween on _ready() and queue_free() when done
- **Explosion.tscn** - Room destruction effect
  - Auto-plays animation and queue_free() when done

### Autoload Singletons:
- **GameState.gd** - Global state
  - Properties: missions_unlocked[], current_mission, current_budget
  - Methods: unlock_mission(index), get_mission_data(index)
- **CombatEngine.gd** - Combat calculation (optional, could be in Combat.tscn instead)
  - Methods: calculate_stats(ship_data), resolve_turn(attacker, defender), check_win_condition()

### Data (scripts/data/):
- **RoomData.gd** - Room type enum, costs, placement rules
- **MissionData.gd** - Mission definitions (budget, enemy layout, brief text)

---

## SUMMARY

**Total Features:** 17 features across 4 phases

**Critical Path (Minimum Viable):**
- Phase 1: All features (need visual foundation)
- Phase 2: All features (need interactivity)
- Phase 3: Features 3.1, 3.2, 3.3, 3.5 (skip 3.4 if time-constrained)
- Phase 4: Features 4.2, 4.3 (skip 4.1 if time-constrained)

**Time Estimates:**
- **Must-Have:** 14.5 hours (Phases 1-3, skip 3.4, minimal Phase 4)
- **Full Roadmap:** 18.5 hours (all features)
- **GDD Original:** 18 hours (5 phases)

**Testing the 5 Critical Questions:**
- Q1 (Design → iterate loop): Features 2.4, 3.1, 3.2, 3.5, 4.2
- Q2 (Placement strategic): Features 1.1, 1.2, 2.1, 2.2, 2.3, 3.3
- Q3 (Combat readable): Features 3.1, 3.2, 3.4, 4.1, 4.2
- Q4 (Budget trade-offs): Features 1.3, 2.2, 2.3, 3.3
- Q5 (Engineering fantasy): Features 1.2, 1.4, 3.1, 4.1

**Next Steps:**
1. Set up project structure (scenes/ folders, autoloads)
2. Start Phase 1, Feature 1.1 (Grid Rendering)
3. Work sequentially through features
4. Playtest after Phase 3 complete (before polish)
5. Adjust balance in Phase 4 based on playtesting
6. Sunday evening: Final playtest, score 5 critical questions, decide next steps

# STARSHIP DESIGNER - Prototype Design Document

**Version:** 0.1 - Weekend Prototype

**Goal:** Test if "design ship → auto-battle → iterate" loop is satisfying for puzzle-combat genre

**Timeline:** One weekend (12-16 hours)

**Date:** November 22, 2024

---

## 1. CONCEPT

### Elevator Pitch

You're the chief starship designer for Starfleet Command during wartime - design ships on a grid, launch them into auto-battle, and iterate on failures until your designs win the war.

### Design Pillars

**Engineering Fantasy Over Piloting**

- Player is designer/engineer, not pilot or captain
- Success comes from smart layout decisions, not twitch skills
- Watch your creations fight (validation of design choices)
- Iterate quickly: redesign takes 60 seconds, test takes 30 seconds

**Meaningful Spatial Puzzles**

- Room placement physically matters (weapons forward, engines back)
- Power routing creates optimization puzzle (reactor powers adjacent)
- Damage location affects functionality (lose weapons = less damage)
- Trade-offs forced by budget constraint (can't have everything)

**Clear Feedback Through Simplicity**

- Auto-combat shows exactly why you won/lost
- No hidden mechanics (all stats visible, math is transparent)
- Immediate iteration (fail → redesign → retest in 90 seconds)
- Visual damage shows which rooms failed you

### Primary Influences

**FTL: Faster Than Light**

- Grid-based ship design with rooms affecting performance
- Applies: Room placement and damage disabling systems, but simplified (no crew, no real-time control)

**Into The Breach**

- Puzzle-combat where you preview outcomes
- Applies: Auto-resolved combat with clear cause-effect, iterate on losses

**Zachtronics Games (SpaceChem, Opus Magnum)**

- Engineering optimization puzzles with visual validation
- Applies: Design → test → optimize loop, satisfaction from watching your solution work

**Advance Wars**

- Unit design affects auto-resolved battles
- Applies: Pre-combat design phase determines outcome, not player execution during battle

---

## 2. WHAT WE'RE TESTING

### Critical Questions

**Q1: Is the design → watch → iterate loop satisfying?**

- Success = Player excited to redesign after loss, "one more try" feeling
- Failure = Player frustrated by opaque failures or bored by repetition

**Q2: Does room placement feel strategic (not arbitrary)?**

- Success = Player discusses placement choices, tries different layouts
- Failure = Player randomly places rooms, doesn't see pattern impact

**Q3: Is auto-combat readable enough to understand failures?**

- Success = After battle, player says "I lost because X, I'll fix Y"
- Failure = Player says "I don't know why I lost" or "combat is random"

**Q4: Does the 30-point budget create interesting trade-offs?**

- Success = Player agonizes over choices, removes rooms to fit others
- Failure = Player maxes out budget without thinking, or can't fill budget

**Q5: Is the engineering fantasy compelling?**

- Success = Player feels like designer/engineer, wants to optimize
- Failure = Player wishes they could pilot/control ship during battle

### Success Criteria

After Sunday night playtest, score each question 1-5:

- 1 = Doesn't work at all
- 3 = Works but needs improvement
- 5 = Works great, build full game

**Decision Threshold:**

- 20-25 points (4-5 avg): Build full game
- 15-19 points (3-4 avg): Iterate and retest
- <15 points (<3 avg): Pivot or kill

---

## 3. CORE MECHANICS

### Grid-Based Ship Design

Players place rooms on an 8×6 tile grid to create their starship. Each room costs points from a 30-point budget. Placement is constrained: weapons face forward (top 2 rows), engines face back (bottom 2 rows), reactors power adjacent tiles.

**Specifics:**

- Grid: 8 tiles wide × 6 tiles tall = 48 total positions
- Tile size: 64×64 pixels each, total grid = 512×384 pixels
- Budget: 30 points per mission
- Click empty tile → cycle through room types (Bridge → Weapon → Shield → Engine → Reactor → Armor → Empty)
- Right-click tile → remove room, refund points

**Interactions:**

- Must place Bridge (can't launch without it)
- Reactors "activate" adjacent rooms (visually shown with glow/connection lines)
- Unpowered rooms show as "inactive" (grayed out)

### Six Room Types

**Bridge (2 points)**

- Must have exactly 1, controls ship
- Can be placed anywhere
- If destroyed → instant loss

**Weapons (3 points)**

- Must be placed in top 2 rows (faces forward)
- Each weapon deals 10 damage per shot
- Destroyed weapons reduce damage output

**Shield (3 points)**

- Can be placed anywhere
- Each shield absorbs 15 HP of damage
- Destroyed shields reduce protection

**Engine (2 points)**

- Must be placed in bottom 2 rows (faces backward)
- Each engine adds +1 to initiative
- More engines = shoot first
- Destroyed engines lose initiative

**Reactor (2 points)**

- Can be placed anywhere
- Powers 4 adjacent tiles (up/down/left/right)
- Rooms not adjacent to reactor = inactive (shown grayed)
- Destroyed reactor deactivates connected rooms

**Armor (1 point)**

- Can be placed anywhere
- Adds +20 HP to hull
- No special function, just buffer health
- Cheap filler for unused budget

### Auto-Resolved Combat

Turn-based combat calculation that plays out automatically. Player watches but doesn't control. Initiative determines who shoots first, then ships trade volleys until one is destroyed.

**Combat Sequence:**

1. Initiative Check: Count engines (more = shoot first, tie = player wins)
2. Active Ship Shoots: Damage = (Active Weapons Count × 10)
3. Target Shields Absorb: Reduction = (Active Shields Count × 15), max damage absorbed
4. Remaining Damage Hits Hull: Hull HP decreases
5. Damage Destroys Random Room: Each 20 damage = 1 room destroyed (random selection from active rooms)
6. Switch Active Ship: Repeat steps 2-5 for other ship
7. Check Win Condition: If hull ≤ 0 → destroyed, if Bridge destroyed → instant loss
8. Next Turn: Return to step 2

**Example:**

- Player: 3 weapons, 2 shields, 2 engines, 80 hull HP
- Enemy: 2 weapons, 3 shields, 1 engine, 60 hull HP
- Turn 1: Player shoots first (2 engines > 1 engine)
    - Player deals 30 damage (3 weapons × 10)
    - Enemy shields absorb 45 (3 shields × 15, but only 30 needed)
    - 0 damage to hull, no rooms destroyed
- Turn 2: Enemy shoots
    - Enemy deals 20 damage (2 weapons × 10)
    - Player shields absorb 20 (2 shields × 15, enough)
    - 0 damage to hull
- Turn 3: Player shoots
    - Player deals 30 damage
    - Enemy shields absorb 45 (still full)
    - 0 damage to hull
- *Combat continues until shields are overwhelmed...*

### Power Routing System

Reactors create a "power grid" by activating adjacent rooms. Rooms not connected to power are inactive (don't contribute to ship stats). Destroyed reactors break the chain.

**Specifics:**

- Reactor powers tiles: [x-1,y], [x+1,y], [x,y-1], [x,y+1]
- Visual: Green lines connect reactor to powered rooms
- Unpowered rooms: Gray overlay, don't count in combat
- Example: 5 weapons placed, only 3 powered → only 3 count (3×10 = 30 damage)

**Strategic Depth:**

- Cheap build: Few reactors, tightly clustered rooms
- Spread build: Multiple reactors, rooms distributed
- Risk: Reactor destroyed = multiple rooms deactivate

### Budget Constraint System

30 points to spend per mission. Creates forced trade-offs: offense vs defense, raw power vs efficiency.

**Costs:**

- Bridge: 2 (required)
- Weapons: 3 each
- Shields: 3 each
- Engines: 2 each
- Reactors: 2 each
- Armor: 1 each

**Example Builds:**

- "Glass Cannon": 1 Bridge (2), 6 Weapons (18), 2 Reactors (4), 3 Armor (3) = 27 points
- "Turtle": 1 Bridge (2), 2 Weapons (6), 5 Shields (15), 2 Reactors (4), 2 Engines (4) = 31 ❌ over budget!
- "Balanced": 1 Bridge (2), 3 Weapons (9), 3 Shields (9), 2 Engines (4), 2 Reactors (4), 2 Armor (2) = 30 ✓

### Mission Structure

Three sequential missions with increasing difficulty. Each mission has a brief, an enemy ship design, and a win condition. Lose = redesign and retry, win = unlock next mission.

**Mission 1: "Patrol Duty"**

- Brief: "Pirates raiding supply lines. Need fast interceptor."
- Enemy: Scout (4×4 grid, 2 weapons, 1 shield, 2 engines, 40 HP)
- Player Budget: 20 points (reduced for tutorial)
- Win: Destroy enemy, advance to Mission 2

**Mission 2: "Convoy Defense"**

- Brief: "Enemy cruiser attacking convoy. Engage and destroy."
- Enemy: Raider (6×5 grid, 3 weapons, 2 shields, 1 engine, 60 HP)
- Player Budget: 25 points
- Win: Destroy enemy, advance to Mission 3

**Mission 3: "Fleet Battle"**

- Brief: "Capital ship inbound. This is our final stand."
- Enemy: Dreadnought (8×6 grid, 5 weapons, 3 shields, 2 engines, 100 HP)
- Player Budget: 30 points (full budget)
- Win: Destroy enemy, victory screen

### Hull HP System

Each ship has base hull HP. Armor rooms add +20 HP each. When damage exceeds shields, hull HP decreases. Hull ≤ 0 = ship destroyed.

**Specifics:**

- Base Hull: 60 HP (player and all enemies)
- Armor Bonus: +20 HP per armor room
- Example: 60 base + 3 armor rooms = 120 HP total
- Damage Calculation: (Incoming Damage - Shield Absorption) → subtract from Hull HP
- Death: Hull ≤ 0 OR Bridge destroyed = combat loss

**Visual:**

- Health bar above ship (green → yellow → red)
- Current HP / Max HP displayed numerically

---

## 4. PROTOTYPE SCOPE

### What's IN (Minimum Viable)

**Ship Designer:**

- 8×6 clickable grid (512×384 pixels)
- 6 room types (Bridge, Weapon, Shield, Engine, Reactor, Armor)
- Room placement/removal (left-click cycle, right-click remove)
- Budget display (30 points, updates in real-time)
- Power connection visual (green lines from reactor to adjacent)
- Launch button (disabled if no Bridge or over budget)

**Combat System:**

- Auto-resolved turn-based calculation
- 2 ships face each other (player left, enemy right)
- Health bars (green/yellow/red gradient)
- Turn indicator ("Player Turn" / "Enemy Turn" text)
- Damage numbers pop up on hit
- Room destruction visual (sprite explodes/grays out)
- Win/Lose screen (text + Redesign button)

**Content:**

- 3 missions with escalating difficulty
- Mission briefs (2-3 sentences text)
- 3 preset enemy ship designs (Scout, Raider, Dreadnought)
- Victory condition (beat all 3 missions)

**UI/Menus:**

- Mission select screen (shows 3 missions, locked/unlocked)
- Ship designer screen (grid + budget + launch)
- Combat screen (ships + health + turn info)
- Win/Lose screen (message + retry/continue button)

### What's OUT (Not for Prototype)

**❌ Multiple Player Ship Designs**

- Reason: Testing one design iteration loop, not ship variety
- Prototype: Design 1 ship per mission attempt

**❌ Crew Management**

- Reason: Not testing crew mechanics, too complex for weekend
- Prototype: Rooms just exist, no people to manage

**❌ Resource Gathering / Meta-Progression**

- Reason: Testing core combat loop, not economy
- Prototype: Fixed budget per mission, no carry-over

**❌ Ship Customization (Names/Colors)**

- Reason: Not testing expression, testing mechanics
- Prototype: Generic blue player ship, red enemy ships

**❌ Real-Time Combat Control**

- Reason: Testing auto-battle iteration, not piloting skill
- Prototype: Watch-only combat, no pause/target/maneuver

**❌ Procedural Enemies**

- Reason: Testing if handcrafted difficulty curve works
- Prototype: 3 preset enemy designs, not generated

**❌ Sound Effects / Music**

- Reason: Not testing audio, focus on mechanics
- Prototype: Silent (add if time permits Sunday afternoon)

**❌ Save System**

- Reason: 3 missions playable in one 15-minute session
- Prototype: Complete in single sitting or restart

**❌ Advanced UI (Tooltips, Tutorials, Settings)**

- Reason: Not testing onboarding, testing core loop
- Prototype: Assume player understands grid placement

---

## 5. IMPLEMENTATION PHASES

### Phase 1: Grid System (Saturday Morning - 4 hours)

**Goal:** Clickable grid where player can place/remove rooms and see budget update

**Deliverables:**

- 8×6 grid of tiles (64×64px each)
- Click tile → cycle through 7 states (6 room types + empty)
- Right-click tile → clear to empty
- Budget counter display (updates on placement)
- Room cost validation (can't place if over budget)

**Test:** Can place rooms, see budget, can't exceed 30 points

### Phase 2: Combat Math (Saturday Afternoon - 4 hours)

**Goal:** Auto-battle calculation that shows ships fighting with health bars

**Deliverables:**

- Combat screen with 2 ship sprites (player left, enemy right)
- Count rooms from grid → calculate stats (weapons, shields, engines, hull)
- Turn-based loop: initiative → damage → shields → hull → room destruction
- Health bars above ships (visual feedback)
- Win/Lose detection + screen

**Test:** Launch battle, watch ships trade hits, one ship wins

### Phase 3: Power System (Saturday Evening - 4 hours)

**Goal:** Reactors power adjacent rooms, unpowered rooms don't count

**Deliverables:**

- Reactor placement highlights adjacent tiles (green glow/lines)
- Combat counts only powered rooms
- Visual feedback (unpowered rooms grayed out)

**Test:** Place reactor, see powered tiles, remove reactor, see rooms deactivate

### Phase 4: Mission Structure (Sunday Morning - 3 hours)

**Goal:** 3 missions with enemy designs and progression

**Deliverables:**

- Mission select screen (3 buttons: Mission 1/2/3)
- Mission briefs (text overlay before designer)
- 3 enemy ship presets (Scout 4×4, Raider 6×5, Dreadnought 8×6)
- Mission unlock (beat 1 → unlock 2 → unlock 3)
- Victory screen (beat mission 3)

**Test:** Play through 3 missions, progression feels escalating

### Phase 5: Polish & Playtesting (Sunday Afternoon - 3 hours)

**Goal:** Visual feedback, balance tuning, playtest

**Deliverables:**

- Damage numbers pop on hit
- Room destruction animation (explosion sprite)
- Turn indicator text ("Player Turn")
- Balance pass (test all 3 missions beatable but challenging)
- Playtest with friend, gather feedback

**Test:** Friend can understand game, beat missions with iteration

---

## 6. SUCCESS METRICS

### Playtester Observations (Sunday Evening)

**During Design Phase:**

- Do they think about placement? (Good: "I'll put engines here because..." Bad: Random clicking)
- Do they mention trade-offs? (Good: "I wish I could fit more shields" Bad: Silent placement)
- Do they understand power? (Good: Cluster near reactor. Bad: Spread rooms, don't notice gray)

**During Combat:**

- Do they watch attentively? (Good: Lean in, watch health. Bad: Look away, bored)
- Do they understand outcome? (Good: "I lost because no shields" Bad: "Why did I lose?")
- Do they want to retry? (Good: "Let me try again" Bad: "Whatever, next mission")

**After Session:**

- Ask: "Did you feel like a designer or pilot?" (Want: Designer)
- Ask: "Could you tell why you won/lost?" (Want: Yes, very clear)
- Ask: "Would you play 10 missions like this?" (Want: Yes)

### Quantitative Targets

- Mission 1: Win within 3 attempts (tutorial difficulty)
- Mission 2: Win within 5 attempts (learning curve)
- Mission 3: Win within 7 attempts (peak challenge)
- Total session: 15-20 minutes (short enough to retest)
- Redesign speed: 60 seconds (fast iteration)

---

## 7. RISK MITIGATION

**Risk: Combat is opaque, player doesn't understand losses**

- Mitigation: Show damage numbers, health bars, turn-by-turn breakdown
- Fallback: Add post-battle "Combat Log" text summary

**Risk: Placement feels arbitrary, no strategy**

- Mitigation: Force weapon/engine constraints, require power routing
- Fallback: Add tooltips explaining optimal placement

**Risk: Budget too restrictive or too loose**

- Mitigation: Playtest Saturday night, tune costs before Sunday
- Fallback: Allow budget adjustment per mission (20/25/30)

**Risk: Auto-combat too slow or too fast**

- Mitigation: Prototype with 1 second per turn, adjust based on feel
- Fallback: Add "Fast Forward" button for repeat playthroughs

**Risk: 3 missions not enough to test loop**

- Mitigation: 3 missions = 30-60 min content with retries, sufficient for prototype
- Fallback: If time permits, add Mission 4 as stretch goal

---

## 8. POST-PROTOTYPE DECISION TREE

### If Score 20-25 (Build Full Game)

**Immediate Next Steps:**

- Design 10 total missions (full campaign)
- Add 4 more room types (Repair Bay, Scanner, Hangar, ECM)
- Implement special mission conditions (asteroids, ambush, multi-battle)
- Create mission briefings with light narrative
- Build meta-progression (unlock advanced rooms)

**Timeline:** 12 weeks to v1.0

### If Score 15-19 (Iterate)

**Identified Issues → Solutions:**

- Combat unclear → Add detailed combat log
- Placement too simple → Add more room interactions
- Budget wrong → Rebalance costs after more testing
- Not enough content → Prototype 3 more missions before committing

**Timeline:** 1 week iteration, retest, reassess

### If Score <15 (Pivot/Kill)

**Exit Criteria:**

- Core loop not fun after fixes
- Fantasy doesn't resonate (player wants to pilot)
- Optimization puzzle not engaging (placement feels random)

**Pivot Options:**

- Keep grid system, add real-time control (make it FTL-like)
- Keep auto-battle, make it deck-builder (card-based ship design)
- Keep engineering fantasy, make it puzzle-only (no combat, pure optimization challenges)

---

**END OF DESIGN DOCUMENT**

This prototype tests the absolute core: Can "design ship → watch it fight → iterate on failure" sustain a full game? By Sunday night, you'll know.