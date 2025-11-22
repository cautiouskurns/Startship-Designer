# STARSHIP DESIGNER - Development Roadmap

**Generated from:** STARSHIP DESIGNER - Prototype Design Document v0.1
**Target:** Weekend Prototype (12-16 hours)

---

## OVERVIEW

**Total Time Estimate:** 22-23 hours (with buffer for iteration)

**5-Phase Structure:**
1. **Visual Layout** (3.5h) - Static UI on screen, no interaction
2. **Interactive** (4h) - Respond to player input, basic placement
3. **Systems** (8h) - Combat logic, power routing, missions
4. **Polish** (3h) - Visual feedback, animations, balance
5. **Designer UI/UX** (4.5h) - Modern toolkit interface, improved usability

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

# PHASE 5: DESIGNER UI/UX POLISH

**Goal:** Designer has modern toolkit UI - select room from palette, see stats/costs, get instant visual feedback

**Time:** 4-5 hours

---

## Feature 5.1: Room Type Palette Panel

**Tests:** Q1 (Design → iterate loop)
**Time:** 1.5 hours

### What Player Sees:
- **Position:** Right side of screen, 300px wide panel, anchored to right edge
- **Title:** "ROOM TYPES" in white header text (24pt)
- **Layout:** 6 rows stacked vertically, one per room type
- **Each row shows:**
  - Room icon (64×64px sprite, same as grid rooms)
  - Room name in white text (18pt): "Bridge", "Weapon", etc.
  - Cost in gray text (14pt): "2 pts", "3 pts"
  - Count placed on far right: "×0", "×1", "×2" (updates live)
- **Selection state:**
  - Selected room: cyan border glow (2px), background slightly lighter
  - Unselected: default dark background
- **Disabled state:**
  - Can't afford: row grayed out (50% opacity)
  - Bridge limit reached: Bridge row grayed out
  - Hover disabled row: shows red flash briefly

### What Player Does:
- Click a room type row → row highlights (cyan border)
- Selected room type stays active
- Click grid tile → places selected room (no more cycling through 7 types!)
- Right-click grid → still removes rooms (unchanged)
- Click different room type row → selection changes
- See counts update: place Weapon → count shows "×1", place another → "×2"

### How It Works:
- New scene: `RoomPalettePanel.tscn` (Panel container with VBoxContainer)
- Each row is custom `RoomTypeButton.tscn` (Button with HBoxContainer layout)
  - Contains: TextureRect (icon), Label (name), Label (cost), Label (count)
- ShipDesigner tracks: `selected_room_type: RoomData.RoomType = RoomData.RoomType.EMPTY`
- On palette button clicked:
  - Set `selected_room_type` to clicked room
  - Update visual highlights (previous button loses glow, clicked button gains glow)
- On grid tile left-click:
  - If `selected_room_type != EMPTY`: attempt to place that room type
  - Run validation: check budget, row constraints, Bridge limit
  - If valid: place room, update count labels, update budget
  - If invalid: flash palette button red (can't place)
- Update all count labels after every placement/removal:
  - Iterate through grid tiles, count each room type
  - Set count label text: "×N" for each room type

### Acceptance Criteria:
- [ ] Visual check: Room palette panel visible on right side with 6 room types
- [ ] Visual check: Each row shows icon, name, cost, and count
- [ ] Interaction check: Click Weapon row → Weapon highlighted with cyan border
- [ ] Interaction check: Click grid tile → Weapon placed (no cycling)
- [ ] Interaction check: Click room type you can't afford → red flash, doesn't select
- [ ] Manual test: Place 2 Weapons → count shows "×2"
- [ ] Manual test: Remove 1 Weapon → count shows "×1"

### Shortcuts for This Phase:
- Reuse existing room scene sprites as icons (no separate icon assets)
- No drag-and-drop (just click-to-select, then click-to-place)
- No tooltips yet (defer to Feature 5.3)
- Simple instant selection (no smooth transitions)

---

## Feature 5.2: Hover Preview & Placement Feedback

**Tests:** Q1 (Design → iterate loop)
**Time:** 1 hour

### What Player Sees:
- **Valid tile hover (with room selected):**
  - Tile border glows cyan (2px border)
  - Small cost indicator floats near cursor: "+3" in white
- **Invalid tile hover:**
  - Tile border glows red (2px border)
  - Tile shows red overlay (50% opacity ColorRect)
  - Cost indicator near cursor shows "+3" in red
- **Invalid reasons:**
  - Wrong row (row constraint failed)
  - Over budget (can't afford)
  - Already have Bridge (limit 1)
- **No selection:** Hovering grid with no room selected shows no preview

### What Player Does:
- Select room type from palette
- Move mouse over grid tiles
- See cyan glow on valid placement tiles
- See red glow + overlay on invalid tiles
- See floating cost "+3" following cursor
- Click valid tile → room places
- Click invalid tile → nothing happens (tile flashes red briefly)

### How It Works:
- ShipDesigner has variable: `hovered_tile: GridTile = null`
- On GridTile mouse_entered:
  - Set `hovered_tile = self`
  - If `selected_room_type != EMPTY`:
    - Run validation: check budget, row constraint, Bridge limit
    - If valid: show cyan border (modulate or border ColorRect)
    - If invalid: show red border + red overlay
- On GridTile mouse_exited:
  - Clear `hovered_tile = null`
  - Remove border glow and overlay
- Cursor cost indicator:
  - Label node that follows mouse position (update in `_process()`)
  - Text: "+%d" % RoomData.get_cost(selected_room_type)
  - Color: white if valid, red if invalid
  - Only visible when selected_room_type != EMPTY and hovering grid

### Acceptance Criteria:
- [ ] Visual check: Select Weapon, hover valid tile → cyan border appears
- [ ] Visual check: Select Reactor, hover row 0 → red border + overlay (wrong row)
- [ ] Visual check: Fill budget to 29, select 3-cost room, hover → red (over budget)
- [ ] Visual check: Cost indicator "+3" follows cursor while hovering
- [ ] Interaction check: Click red (invalid) tile → nothing happens

### Shortcuts for This Phase:
- Don't show *why* invalid (just red = can't place)
- No animation on hover (instant show/hide)
- Cost indicator is simple Label, doesn't smoothly follow (just position updates)
- No preview of the actual room sprite (just border feedback)

---

## Feature 5.3: Room Info Tooltips

**Tests:** Q1 (Design → iterate loop)
**Time:** 45 minutes

### What Player Sees:
- **Hover over room type button:** Tooltip appears after 0.3s delay
- **Tooltip panel:**
  - 250px wide, floats to the left of button
  - Dark background (#1A1A1A), light border (#4A4A4A)
  - Room name in cyan header (20pt)
  - Description text (14pt white): explains room function
  - Stats text (14pt gray): shows combat numbers
- **Tooltip content examples:**
  - **Bridge:** "Command center. Required. Self-powered. | Losing Bridge = instant defeat."
  - **Weapon:** "Offensive system. | Deals 10 damage per powered weapon."
  - **Shield:** "Defensive system. | Absorbs up to 15 damage per powered shield."
  - **Engine:** "Propulsion system. | Higher engine count shoots first (initiative)."
  - **Reactor:** "Power generation. | Powers adjacent rooms (up/down/left/right only)."
  - **Armor:** "Hull plating. | Adds 20 HP per armor room (doesn't need power)."

### What Player Does:
- Hover mouse over room type button in palette
- Wait 0.3s → see tooltip appear
- Read what the room does and how it affects combat
- Move mouse away → tooltip disappears immediately

### How It Works:
- Each `RoomTypeButton` has:
  - `tooltip_panel: Panel` child node (hidden by default)
  - `tooltip_timer: Timer` (one-shot, wait_time = 0.3s)
- On `mouse_entered`:
  - Start `tooltip_timer`
- On `timeout`:
  - Show `tooltip_panel`
  - Position panel to left of button: `position.x = -260` (250px width + 10px margin)
- On `mouse_exited`:
  - Stop `tooltip_timer`
  - Hide `tooltip_panel`
- Tooltip text is hard-coded per room type in RoomTypeButton script

### Acceptance Criteria:
- [ ] Visual check: Hover Weapon button 0.3s → see tooltip with description
- [ ] Visual check: Tooltip shows "Deals 10 damage per powered weapon"
- [ ] Visual check: Hover Reactor → see "Powers adjacent rooms (up/down/left/right only)"
- [ ] Interaction check: Move mouse away before 0.3s → tooltip doesn't appear
- [ ] Interaction check: Move mouse away after tooltip shown → tooltip disappears

### Shortcuts for This Phase:
- Hard-code all tooltip text in RoomTypeButton (no data file)
- Instant show/hide (no fade animation)
- Tooltip doesn't follow cursor (fixed position left of button)
- Simple Panel styling (no fancy graphics)

---

## Feature 5.4: Ship Status Panel

**Tests:** Q1 (Design → iterate loop)
**Time:** 1 hour

### What Player Sees:
- **Position:** Bottom-right corner, 300px wide, 200px tall
- **Title:** "SHIP STATUS" in white header (24pt)
- **3 status rows:**
  - **Bridge:** Icon + text
    - ✓ "Ready" in green (#4AE24A) when 1 Bridge placed
    - ✗ "Missing" in red (#E24A4A) when 0 Bridges
  - **Budget:** Icon + text
    - ✓ "Within Limits" in green when current ≤ max
    - ✗ "Over Budget" in red when current > max
    - Shows amount: "28 / 30" in gray
  - **Power:** Icon + text
    - ✓ "All Rooms Powered" in green when all rooms powered
    - ⚠ "N Unpowered" in yellow (#E2D44A) when some rooms unpowered
    - Shows count: "2 rooms need power" in gray
- **Launch button state:** Only enabled when all 3 checks are green (✓)

### What Player Does:
- Glance at status panel to see if ship is ready to launch
- See what's blocking launch:
  - No Bridge? → red ✗ Missing
  - Over budget? → red ✗ Over Budget
  - Unpowered rooms? → yellow ⚠ N Unpowered (warning, but still launchable)
- Fix issues → watch status update in real-time
- All green → Launch button enables

### How It Works:
- New scene: `ShipStatusPanel.tscn` (Panel with VBoxContainer)
- 3 child nodes: `StatusRow.tscn` (HBoxContainer with icon label + status label)
- ShipDesigner calls `_update_ship_status()` after every room placement/removal:
  - **Bridge check:**
    - Count Bridges: `bridge_count = count_bridges()`
    - If `bridge_count == 1`: status = "✓ Ready" (green)
    - Else: status = "✗ Missing" (red)
  - **Budget check:**
    - If `current_budget <= max_budget`: status = "✓ Within Limits" (green)
    - Else: status = "✗ Over Budget" (red)
  - **Power check:**
    - Create temp ShipData: `temp_ship = ShipData.from_designer_grid(grid_tiles)`
    - Count unpowered non-armor rooms:
      ```
      unpowered_count = 0
      for each room in grid:
        if room != EMPTY and room != ARMOR and !temp_ship.is_room_powered(x, y):
          unpowered_count++
      ```
    - If `unpowered_count == 0`: status = "✓ All Rooms Powered" (green)
    - Else: status = "⚠ %d Unpowered" % unpowered_count (yellow)
- Launch button enabled only if:
  - Bridge check green AND Budget check green
  - Power check doesn't block launch (yellow warning is OK)

### Acceptance Criteria:
- [ ] Visual check: Status panel visible bottom-right with 3 status rows
- [ ] Visual check: Start with no Bridge → see "✗ Missing" in red
- [ ] Interaction check: Place Bridge → see "✓ Ready" in green
- [ ] Interaction check: Go over budget → see "✗ Over Budget" in red, Launch disabled
- [ ] Interaction check: Place weapon without reactor nearby → see "⚠ 1 Unpowered" in yellow
- [ ] Manual test: Fix all issues (Bridge placed, within budget) → all green → Launch enables

### Shortcuts for This Phase:
- Use text symbols for icons (✓, ✗, ⚠) instead of image icons
- Power check only shows count, doesn't list which rooms
- Simple color change (no animation)
- Don't show detailed power grid visualization here

---

## Feature 5.5: Clear Grid Button

**Tests:** Q1 (Design → iterate loop)
**Time:** 30 minutes

### What Player Sees:
- **Position:** Top-right of grid area, 150×50px button
- **Appearance:**
  - Red background (#E24A4A)
  - White text "CLEAR GRID" (18pt)
  - Hover: background lightens to #FF6A6A
  - Hover: button scales to 1.05
- **Click effect:** All rooms removed instantly from grid

### What Player Does:
- Click "CLEAR GRID" button
- See all rooms disappear from grid
- Budget resets to 0/[max]
- Room counts reset to ×0
- Power lines disappear
- Status panel updates (shows Bridge missing)
- Start designing from scratch

### How It Works:
- Add Button to ShipDesigner.tscn
  - Position above grid, top-right corner
  - Red StyleBoxFlat background
- On `pressed` signal:
  - Call existing `_clear_all_rooms()` function (already exists from auto-fill feature)
  - Call `_update_budget_display()`
  - Call `update_all_power_states()`
  - Call `_update_ship_status()`
- Button has same hover scale effect as other buttons (existing `_on_button_hover_start/end`)

### Acceptance Criteria:
- [ ] Visual check: Clear Grid button visible top-right with red background
- [ ] Interaction check: Click button → all rooms removed instantly
- [ ] Visual check: Budget shows "0 / 20", all counts show "×0"
- [ ] Visual check: Status panel shows "✗ Missing" for Bridge
- [ ] Interaction check: Hover button → scales to 1.05, background lightens

### Shortcuts for This Phase:
- No confirmation dialog ("Are you sure?")
- No undo functionality
- Instant clear (no fade-out animation)
- Reuses existing _clear_all_rooms() function

---

# PHASE 6: ADJACENCY SYNERGIES

**Goal:** Rooms gain stat bonuses when placed next to compatible types, adding strategic depth without changing core mechanics

**Time:** 3-4 hours

---

## Feature 6.1: Synergy Detection & Visual Indicators

**Tests:** Q2 (Placement strategic), Q5 (Engineering fantasy)
**Time:** 1.5 hours

### What Player Sees:
- **Position:** Between adjacent grid tiles where synergies exist
- **Appearance:** Small glowing icon (32×32px) appears at the border between compatible rooms
  - Weapon + Weapon: Orange crosshair (#E2904A)
  - Shield + Reactor: Cyan energy bolt (#4AE2E2)
  - Engine + Engine: Blue flame (#4A90E2)
  - Weapon + Armor: Red shield (#E24A4A)
- **Animation:** Icons pulse gently (scale 1.0 → 1.15 → 1.0, 1.5s cycle)
- **Visual states:**
  - Active: Full opacity, pulsing
  - Appearing: Fades in over 0.2s when rooms placed adjacent
  - Disappearing: Fades out over 0.2s when rooms separated

### What Player Does:
- Place two Weapons adjacent (up/down/left/right) → see orange crosshair appear between them
- Place Shield next to Reactor → see cyan energy bolt
- Move rooms apart or remove one → see icon fade out
- Experiment with clustering vs spreading rooms
- Hover over synergy icon → (optional) see tooltip explaining bonus

### How It Works:
- After every room placement/removal, run synergy check:
  - For each occupied tile, check 4 directions (no diagonals)
  - If adjacent room type creates synergy: spawn SynergyIndicator node
  - Position indicator at midpoint between two tiles
- Synergy pairs defined in RoomData:
  ```
  SYNERGY_PAIRS = {
    [WEAPON, WEAPON]: "fire_rate",
    [SHIELD, REACTOR]: "shield_capacity",
    [ENGINE, ENGINE]: "initiative",
    [WEAPON, ARMOR]: "durability"
  }
  ```
- Each synergy indicator tracks both connected rooms
- If either room removed/changed: indicator fades out and removes self
- Indicators stored in separate Node2D container (like PowerLinesContainer)

### Acceptance Criteria:
- [ ] Visual check: Place 2 Weapons side-by-side → orange crosshair appears between them
- [ ] Visual check: Synergy icon pulses smoothly
- [ ] Interaction check: Remove one weapon → crosshair fades out and disappears
- [ ] Visual check: Place Shield next to Reactor → cyan bolt appears
- [ ] Manual test: Create cluster of 4 weapons (2×2) → see 4 crosshair icons (one per adjacency)
- [ ] Interaction check: Replace weapon with shield → crosshair disappears

### Shortcuts for This Phase:
- Use simple colored circle sprites (no detailed icons initially)
- Only 4-directional adjacency (no diagonals)
- Don't show synergy preview before placement
- Bonuses are visual only (combat integration in 6.2)
- No limit on stacking (3 adjacent weapons = 3 synergies)

---

## Feature 6.2: Synergy Bonus Combat System

**Tests:** Q2 (Placement strategic), Q4 (Budget trade-offs)
**Time:** 1.5 hours

### What Player Sees:

**In Designer:**
- Ship Status Panel shows new row: "⚡ Synergies: 3 active" in purple (#A04AE2)
- Hovering synergized room shows enhanced tooltip: "Weapon (+15% damage from adjacency)"

**In Combat:**
- Damage numbers reflect synergy bonuses:
  - 3 weapons non-synergized: "30" damage
  - 3 weapons (middle one has 2 adjacencies): "36" damage (30 + 20% from middle weapon)
- Shield absorption higher: "54" instead of "45" when synergized
- Initiative tie-breaks won by synergized engines

### What Player Does:
- Design ship prioritizing synergies (cluster weapons together)
- See immediate feedback in Ship Status Panel ("⚡ Synergies: 2 active")
- Launch combat → observe higher damage/shield numbers
- Compare synergized vs non-synergized builds in combat results
- Make trade-offs: tight clusters (synergies) vs spread layout (easier power routing)

### How It Works:

**Synergy Bonuses (applied in combat calculation):**
1. **Weapon + Weapon:** +15% damage per adjacency
   - Formula: `damage_per_weapon = 10 × (1 + 0.15 × adjacency_count)`
   - Example: Weapon with 2 adjacent weapons = 10 × 1.3 = 13 damage

2. **Shield + Reactor:** +20% absorption capacity per adjacency
   - Formula: `absorption_per_shield = 15 × (1 + 0.20 × reactor_adjacencies)`
   - Example: Shield next to 1 reactor = 15 × 1.2 = 18 absorption

3. **Engine + Engine:** +1 initiative bonus per adjacency
   - Formula: `initiative = base_engine_count + engine_adjacency_bonuses`
   - Example: 2 engines adjacent = 2 base + 2 bonus = 4 initiative

4. **Weapon + Armor:** Reduces destruction probability by 25% per adjacency
   - Formula: When selecting room to destroy, armored weapons have 0.75× weight
   - Example: Weapon next to armor = 25% less likely to be targeted

**Combat Integration:**
- At combat start, calculate synergy bonuses for both ships:
  ```
  for each room:
    count adjacent synergy partners
    apply bonus multiplier to room's stats
  ```
- Recalculate after any room destroyed (synergies may break)
- Display updated damage numbers reflecting bonuses

### Acceptance Criteria:
- [ ] Manual test: Place 3 weapons in a row → middle weapon deals 13 damage (10 × 1.3)
- [ ] Manual test: Place 2 shields adjacent to reactor → each absorbs 18 (15 × 1.2)
- [ ] Manual test: Place 4 engines in 2×2 cluster → total initiative +8 (each has +2)
- [ ] Visual check: Ship Status Panel shows "⚡ Synergies: N active" count
- [ ] Interaction check: Hover synergized weapon → tooltip shows "+15% damage"
- [ ] Manual test: Win combat with synergies at 25 budget vs non-synergized at 30 budget
- [ ] Manual test: Reactor destroyed mid-combat → shield loses bonus, absorption drops to 15

### Shortcuts for This Phase:
- Bonuses stack additively (not multiplicatively)
- No detailed combat log text (just visual damage numbers)
- Durability bonus is probabilistic (not true HP system for rooms)
- Don't rebalance enemy ships yet (keep existing stats)

---

## Feature 6.3: Synergy Guide Panel

**Tests:** Q1 (Design → iterate loop)
**Time:** 1 hour

### What Player Sees:
- **Position:** Bottom-left corner, 280px wide × 200px tall
- **Title:** "SYNERGIES" in white header (20pt)
- **Layout:** 4 rows showing synergy types
- **Each row:**
  - Two room icons (32×32px each) with + symbol between
  - Synergy icon (same as grid indicators)
  - Bonus text: "+15% Damage" in white (14pt)
  - Active count: "×2" in cyan (#4AE2E2) or "×0" in gray
- **Visual states:**
  - Inactive (×0): 50% opacity, gray
  - Active (×1+): Full opacity, count in cyan

### What Player Does:
- Glance at panel to see all available synergy types
- Read bonus descriptions to understand effects
- See live count updates: place adjacent weapons → "×0" becomes "×1"
- Use as reference guide while designing ship layout
- Plan clusters based on desired bonuses

### How It Works:
- New scene: SynergyGuidePanel.tscn (Panel with VBoxContainer)
- Contains 4 SynergyRow.tscn instances (one per synergy type)
- ShipDesigner calls `update_synergy_display()` after every placement/removal:
  ```
  Count each synergy type from active indicators
  Update row labels with counts
  Set row opacity based on count (dim if 0, bright if 1+)
  ```
- Count calculation: iterate through all SynergyIndicator nodes, group by type

### Acceptance Criteria:
- [ ] Visual check: Synergy Guide visible bottom-left with 4 rows
- [ ] Visual check: Each row shows two room icons + bonus description
- [ ] Visual check: All counts start at "×0" with 50% opacity
- [ ] Interaction check: Place 2 adjacent weapons → Weapon+Weapon shows "×1" in cyan
- [ ] Interaction check: Add 3rd weapon → count becomes "×2"
- [ ] Manual test: Remove all weapons → count returns to "×0", row dims
- [ ] Visual check: Multiple synergy types active simultaneously show correct counts

### Shortcuts for This Phase:
- Static panel (no collapse/expand)
- Hard-coded synergy descriptions (no data file)
- Counts show total synergies, not per-room bonuses
- Reuse existing room icon sprites

---

# PHASE 7: MULTI-TILE ROOM SHAPES

**Goal:** Rooms occupy 2-4 tiles in Tetris-style shapes, adding spatial puzzle element to ship design

**Time:** 6-7 hours

---

## Feature 7.1: Shaped Room Data & Placement Validation

**Tests:** Q2 (Placement strategic), Q4 (Budget trade-offs)
**Time:** 2 hours

### What Player Sees:

**In Room Palette:**
- Room icons now show multi-tile shapes:
  - Bridge: 2×2 square (4 tiles)
  - Weapon: 1×2 horizontal bar (2 tiles)
  - Shield: 1×2 horizontal bar (2 tiles)
  - Engine: 1×2 horizontal bar (2 tiles)
  - Reactor: T-shape (4 tiles: center + 3 below)
  - Armor: 1×1 single tile (unchanged)
- Costs adjusted: Bridge (5 BP), Weapon (2 BP), Shield (3 BP), Engine (2 BP), Reactor (3 BP), Armor (1 BP)
- Tooltip shows: "Occupies 2×2 tiles (4 spaces)"

**Grid Interaction:**
- Selected shaped room shows multi-tile cursor outline
- Invalid placements (overlap, out of bounds) show red flash on all affected tiles

### What Player Does:
- Click Bridge in palette → cursor changes to show 2×2 outline
- Move over grid → see which 4 tiles would be occupied
- Click valid position → Bridge fills all 4 tiles
- Try to place at edge where it doesn't fit → red flash, rejected
- Right-click any tile of shaped room → entire room removed (all tiles clear)
- Design ship considering Tetris-like spatial constraints

### How It Works:

**Room Shape Definitions (in RoomData):**
```
BRIDGE: [[0,0], [1,0], [0,1], [1,1]] # 2×2 square
WEAPON: [[0,0], [1,0]] # 1×2 horizontal
SHIELD: [[0,0], [1,0]] # 1×2 horizontal
ENGINE: [[0,0], [1,0]] # 1×2 horizontal
REACTOR: [[0,1], [1,0], [1,1], [1,2]] # T-shape (top center + 3 below)
ARMOR: [[0,0]] # 1×1 single
```

**Placement Validation:**
- Click grid tile at [x, y] with shaped room selected
- For each tile offset in shape:
  - Calculate absolute position: [x + offset_x, y + offset_y]
  - Check bounds: must be 0-7 for x, 0-5 for y
  - Check occupancy: tile must be empty (no other room)
  - Check row constraints: all tiles must pass row validation
- If any tile fails: reject entire placement, flash all attempted tiles red
- If all pass: place room, mark all tiles as occupied by this room instance

**GridTile Occupancy Tracking:**
- Each GridTile now stores: `occupying_room: MultiTileRoom` (reference to parent room)
- MultiTileRoom stores: array of all occupied GridTiles
- Removal: clicking any tile of shaped room removes entire room from all tiles

### Acceptance Criteria:
- [ ] Visual check: Bridge icon in palette shows 2×2 shape preview
- [ ] Visual check: Reactor icon shows T-shape
- [ ] Interaction check: Select Bridge → cursor shows 2×2 outline
- [ ] Manual test: Click valid 2×2 area → Bridge occupies all 4 tiles
- [ ] Manual test: Try to place Bridge at x=7, y=5 → red flash (doesn't fit bounds)
- [ ] Manual test: Place Weapon, then try to place Bridge overlapping → red flash
- [ ] Interaction check: Right-click any tile of shaped room → entire room clears

### Shortcuts for This Phase:
- Fixed orientations (no rotation yet - defer to 7.3)
- Simple rectangular/T shapes only
- Hard-coded shape data (no data files)
- All tiles in shaped room share single sprite (stretched texture)

---

## Feature 7.2: Multi-Tile Hover Preview

**Tests:** Q1 (Design → iterate loop)
**Time:** 1.5 hours

### What Player Sees:
- **Valid hover:** All tiles in shape show cyan border (2px), unified preview
- **Invalid hover:** Blocked tiles show red border, valid tiles show cyan (mixed preview)
- **Cursor indicator:** Shows room shape outline following mouse (semi-transparent overlay)
- **Cost indicator:** Shows total cost "+5" for shaped room near cursor (same as Feature 5.2)

### What Player Does:
- Select shaped room from palette
- Move cursor over grid → see all tiles that would be occupied
- Hover valid placement → all tiles cyan
- Hover edge/overlap → some tiles red (shows exactly what's blocking)
- Click when all cyan → room places successfully
- Click when any red → nothing happens, brief red flash

### How It Works:
- On GridTile mouse_entered with shaped room selected:
  ```
  Get anchor tile [x, y]
  For each offset in room shape:
    Calculate preview_tile = get_tile_at(x + offset_x, y + offset_y)
    If preview_tile exists and is empty:
      preview_tile.show_valid_preview() # Cyan border
    Else:
      preview_tile.show_invalid_preview() # Red border (if exists)

  Store all preview_tiles in array for cleanup
  ```
- On mouse_exited: clear all previewed tiles' borders
- Cost indicator updates color: white if all tiles valid, red if any invalid

### Acceptance Criteria:
- [ ] Visual check: Select Bridge, hover valid 2×2 space → all 4 tiles show cyan
- [ ] Visual check: Hover near edge (x=7) → tiles out of bounds don't preview, others show red
- [ ] Interaction check: Hover over occupied tiles → those tiles red, empty tiles cyan
- [ ] Visual check: Cost indicator "+5" shows white for valid, red for invalid
- [ ] Manual test: Move cursor across grid → preview updates smoothly for all tiles
- [ ] Interaction check: Deselect room → preview clears immediately

### Shortcuts for This Phase:
- Preview shows borders only (no room sprite ghost)
- All tiles update simultaneously (no animation)
- Don't show power routing preview yet
- No rotation preview (comes in 7.3)

---

## Feature 7.3: Room Rotation System

**Tests:** Q2 (Placement strategic)
**Time:** 1.5 hours

### What Player Sees:
- **Rotation control:** Press R key to rotate selected room 90° clockwise
- **Visual feedback:**
  - Palette icon rotates to show current orientation
  - Grid preview rotates to match
  - Rotation cycles: 0° → 90° → 180° → 270° → 0°
- **UI button:** Circular arrow button "↻" next to room name in palette
- **Rotation states:**
  - Weapon/Shield/Engine: 2 states (horizontal ↔ vertical)
  - Reactor T-shape: 4 states (all rotations)
  - Bridge 2×2: doesn't rotate (looks same all directions)

### What Player Does:
- Select Weapon (1×2 horizontal bar)
- Press R → weapon rotates to vertical (2×1)
- Press R again → back to horizontal
- Select Reactor (T-shape)
- Press R four times → see T rotate through 4 orientations
- Use rotation to fit rooms in tight spaces (vertical weapon in narrow column)

### How It Works:

**Rotation Transform (applied to tile offsets):**
```
For 90° CW rotation:
  [x, y] becomes [-y, x]
For 180°:
  [x, y] becomes [-x, -y]
For 270° CW:
  [x, y] becomes [y, -x]

Normalize to positive coordinates after rotation
```

**Input Handling:**
```
On R key pressed:
  current_rotation = (current_rotation + 90) % 360
  Update preview with rotated offsets
  Re-validate placement
```

**UI Updates:**
- Palette room icon rotates visually (Sprite2D rotation property)
- Rotation button shows current angle: "↻ 90°"
- Preview updates immediately with new orientation

### Acceptance Criteria:
- [ ] Interaction check: Select Weapon, press R → preview rotates vertical
- [ ] Interaction check: Press R four times → returns to original horizontal
- [ ] Visual check: Reactor rotates through 4 distinct T-shape orientations
- [ ] Visual check: Palette icon rotates to match current orientation
- [ ] Manual test: Place vertical weapon → occupies [x,y] and [x,y+1] instead of [x,y] and [x+1,y]
- [ ] Interaction check: Click rotation button → same effect as R key
- [ ] Visual check: Bridge doesn't show rotation (stays 2×2 square)

### Shortcuts for This Phase:
- Only 90° increments (no free rotation)
- Instant rotation (no smooth animation)
- Rotation resets to 0° when changing room selection
- Square shapes skip rotation (Bridge always 0°)

---

## Feature 7.4: Shaped Rooms in Combat

**Tests:** Q1 (Design → iterate loop), Q3 (Combat readable)
**Time:** 1.5 hours

### What Player Sees:

**In Combat Scene:**
- Shaped rooms render with correct multi-tile size:
  - Bridge appears as large 2×2 block (128×128px at 64px/tile)
  - T-reactor shows distinctive T-shape
- When shaped room damaged: entire shape flashes red simultaneously
- When destroyed: all tiles explode at once (multiple explosion effects)
- Power lines connect to shaped reactors at all edge points (T-reactor can power 5+ rooms)

### What Player Does:
- Design ship with shaped rooms
- Launch combat → see shaped rooms displayed correctly
- Watch larger rooms (Bridge) flash red when hit
- See shaped reactor destroyed → observe multiple adjacent rooms lose power
- Understand that bigger rooms are more visible but same durability as 1×1 rooms

### How It Works:

**Combat Ship Rendering:**
```
For each MultiTileRoom:
  Calculate bounding box (min_x, min_y, max_x, max_y from tile positions)
  Create sprite sized to fit: (max_x - min_x + 1) × (max_y - min_y + 1) tiles
  Position sprite at center of occupied tiles
  Render room texture stretched to fit
```

**Stat Calculation:**
- Shaped rooms count as 1 room (not multiple):
  - 2×2 Bridge = 1 Bridge (not 4 Bridges)
  - 1×2 Weapon = 1 Weapon (size doesn't multiply stats)
- Power routing checks adjacency from all tiles:
  - T-reactor has 5-7 potential adjacency points (more than 1×1 reactor's 4)

**Destruction Handling:**
```
When room selected for destruction:
  Flash all tiles in room red (0.3s)
  Spawn explosion at center of each tile (simultaneous)
  Replace all tiles with destroyed sprite
  Mark entire MultiTileRoom as destroyed
  Recalculate power grid (may unpower many rooms if reactor destroyed)
```

### Acceptance Criteria:
- [ ] Visual check: Launch with 2×2 Bridge → renders as large 2×2 block in combat
- [ ] Visual check: T-reactor shows correct T-shape
- [ ] Manual test: Shaped room destroyed → all tiles explode simultaneously
- [ ] Visual check: All tiles in destroyed shaped room show destroyed sprite
- [ ] Manual test: T-reactor destroyed → 5+ adjacent rooms lose power
- [ ] Manual test: Win combat with shaped rooms → ship visualization accurate
- [ ] Performance check: 10+ shaped rooms in combat runs at 60fps

### Shortcuts for This Phase:
- Use stretched single sprite (not individual tile sprites)
- All tiles in shape destroyed together (no partial damage)
- Enemy ships still use 1×1 rooms (don't complicate enemy AI yet)
- Don't rebalance costs based on shape sizes yet

---

# PHASE 8: DIRECTIONAL FACING & ARC OF FIRE

**Goal:** Rooms can be rotated to face different directions, affecting which targets they can hit in combat

**Time:** 4-5 hours

---

## Feature 8.1: Room Facing Direction System

**Tests:** Q2 (Placement strategic)
**Time:** 1.5 hours

### What Player Sees:
- **In Designer Grid:**
  - Weapons show directional arrow overlay indicating facing (forward/left/right/back)
  - Shield rooms show protective arc indicator (90° wedge in facing direction)
  - Default facing: forward (right side, toward enemy)
- **Rotation control:** R key rotates facing 90° CW (separate from shape rotation in Phase 7)
- **Visual indicators:**
  - Weapon: Targeting reticle points in facing direction
  - Shield: Blue arc shows protected angle
  - Other rooms: no facing (omnidirectional)

### What Player Does:
- Place Weapon → defaults to facing forward (right)
- Press R → weapon rotates to face up → R → right → R → down → R → left
- Place Shield → see blue arc showing 90° protection cone
- Rotate Shield to protect different side of ship
- Design ship with strategic facings (broadside weapons, forward shields)

### How It Works:
- Each room stores: `facing_direction: int` (0=right, 90=up, 180=left, 270=down)
- Visual overlay: arrow sprite rotated to match facing_direction
- Keyboard input: R key increments facing by 90° (separate from shape rotation)
- Rooms with facing: WEAPON, SHIELD
- Rooms without: BRIDGE, ENGINE, REACTOR, ARMOR (omnidirectional)

### Acceptance Criteria:
- [ ] Visual check: Place Weapon → see forward-facing arrow
- [ ] Interaction check: Press R → arrow rotates 90° clockwise
- [ ] Visual check: Shield shows 90° arc indicator in facing direction
- [ ] Interaction check: Press R four times → facing returns to forward
- [ ] Visual check: Engine/Reactor don't show facing indicators
- [ ] Manual test: Save ship design with rotated weapons → facings persist on reload

### Shortcuts for This Phase:
- 90° increments only (no free rotation)
- Instant rotation (no animation)
- Default all weapons/shields to forward facing
- Shape rotation (Phase 7) and facing rotation are same key (combined behavior)

---

## Feature 8.2: Combat Arc of Fire System

**Tests:** Q2 (Placement strategic), Q3 (Combat readable)
**Time:** 2 hours

### What Player Sees:

**In Combat:**
- Ships positioned with orientation: player faces right, enemy faces left
- Before weapon fires: targeting lines show from weapon to target (if in arc)
- Weapons outside arc show "NO ANGLE" indicator (gray, crossed out)
- Only forward-facing weapons fire at frontal enemies
- Damage numbers show per-weapon contribution (not total)

**Arc of Fire Rules:**
- Forward (0°): Hits enemies in front (standard combat)
- Up/Down (90°/270°): No valid targets in frontal combat (wasted)
- Backward (180°): No valid targets in frontal combat (wasted)

### What Player Does:
- Design ship with all weapons facing forward → all fire in combat
- Accidentally rotate weapon to face up → see it grayed out in combat (doesn't fire)
- Redesign with correct facings → higher damage output
- Understand facing matters: forward weapons essential for frontal combat

### How It Works:

**Combat Facing Check:**
```
For each weapon:
  enemy_angle = calculate_angle(weapon_position, enemy_position)
  weapon_facing_angle = weapon.facing_direction
  angle_diff = abs(enemy_angle - weapon_facing_angle)

  if angle_diff < 45: # Within arc
    weapon fires normally
  else:
    weapon doesn't fire (counts as 0 damage)
```

**Simplified for Frontal Combat:**
- Enemy always directly to the right (angle = 0°)
- Forward weapons (0°): fire normally
- Up/Down/Back weapons: don't fire

**Visual Feedback:**
- Active weapons flash white when firing
- Inactive weapons (wrong facing) stay dim
- Damage number shows only from active weapons

### Acceptance Criteria:
- [ ] Manual test: 3 weapons facing forward → deal 30 damage
- [ ] Manual test: 1 forward, 2 facing up → deal only 10 damage (2 wasted)
- [ ] Visual check: Weapons facing wrong direction grayed out in combat
- [ ] Visual check: Targeting lines draw from forward weapons to enemy
- [ ] Manual test: Rotate all weapons forward → damage increases
- [ ] Interaction check: Shield facing forward absorbs damage, facing backward doesn't

### Shortcuts for This Phase:
- Enemies always directly right (no angled approaches yet)
- Simple binary check (in arc or not, no partial damage)
- No side/rear armor differences
- Shields use same arc system as weapons

---

## Feature 8.3: Tactical Facing UI Enhancements

**Tests:** Q1 (Design → iterate loop)
**Time:** 1 hour

### What Player Sees:
- **Facing Info Panel:** New panel bottom-center, 300px wide
  - Shows expected combat scenario: "Enemy Approach: FRONTAL"
  - Lists active weapons: "3 forward" in green, "1 up" in red (wasted)
  - Warnings: "⚠ 2 weapons can't hit target"
- **Grid overlay (toggle with F key):** Shows firing lanes
  - Green arrows from forward weapons → right edge
  - Red X on weapons facing wrong direction

### What Player Does:
- Design ship and see real-time facing analysis
- Toggle overlay (F key) to visualize firing lanes
- Fix misaligned weapons based on warnings
- Understand at a glance which weapons will fire

### How It Works:
- After every weapon placement/rotation, scan all weapons:
  ```
  Count weapons by facing direction
  For frontal combat scenario:
    forward_count = weapons facing 0° (green, active)
    wasted_count = weapons facing other directions (red, inactive)
  Update panel display
  ```
- Overlay toggle: draws Line2D from each weapon to grid edge in facing direction
  - Green lines: will hit enemy
  - Red lines: won't hit enemy

### Acceptance Criteria:
- [ ] Visual check: Panel shows "3 forward" in green, "1 up" in red
- [ ] Interaction check: Press F → firing lane overlay appears
- [ ] Visual check: Green arrows from forward weapons point right
- [ ] Interaction check: Rotate weapon → panel updates immediately
- [ ] Manual test: Fix all weapons to forward → warnings disappear

### Shortcuts for This Phase:
- Only frontal combat scenario (no side/rear approaches)
- Simple line overlays (no fancy graphics)
- Don't predict enemy movement or formations
- Panel doesn't auto-suggest fixes (just shows problems)

---

# PHASE 9: MODULAR UPGRADES

**Goal:** Rooms can be enhanced with small upgrade chips, adding customization without new room types

**Time:** 5-6 hours

---

## Feature 9.1: Upgrade Chip System & UI

**Tests:** Q4 (Budget trade-offs), Q5 (Engineering fantasy)
**Time:** 2 hours

### What Player Sees:
- **Upgrade Palette Panel:** New panel below Room Palette, 300px wide
  - Title: "UPGRADES" (18pt white)
  - 6 chip types shown as small icons (24×24px colored squares):
    - Auto-Loader (orange): +25% weapon fire rate, 1 BP
    - Targeting (red): +10% weapon damage, 1 BP
    - Capacitor (cyan): +30% shield capacity, 1 BP
    - Afterburner (blue): +1 initiative per engine, 1 BP
    - Overcharge (yellow): Reactor powers +1 extra tile, 2 BP
    - Reinforced (gray): +50% room HP, 1 BP
- **On Grid Tiles:** Small colored dots appear in corners when upgrade installed
- **Upgrade Slots:** Each room type has 1-2 slots (Bridge: 2, others: 1)

### What Player Does:
- Click upgrade chip in palette → cursor shows chip icon
- Click room on grid → chip installs in room's slot (colored dot appears)
- Right-click chip dot → removes upgrade, refunds BP
- Hover over upgraded room → tooltip shows "+25% fire rate (Auto-Loader)"
- Budget accounts for chips: base room + installed upgrades

### How It Works:

**Upgrade Definitions (in RoomData):**
```
UPGRADES = {
  AUTO_LOADER: {cost: 1, compatible: [WEAPON], effect: "fire_rate", value: 0.25},
  TARGETING: {cost: 1, compatible: [WEAPON], effect: "damage", value: 0.10},
  CAPACITOR: {cost: 1, compatible: [SHIELD], effect: "capacity", value: 0.30},
  AFTERBURNER: {cost: 1, compatible: [ENGINE], effect: "initiative", value: 1},
  OVERCHARGE: {cost: 2, compatible: [REACTOR], effect: "power_range", value: 1},
  REINFORCED: {cost: 1, compatible: [all], effect: "durability", value: 0.50}
}
```

**Installation:**
```
On chip clicked on room:
  if room.upgrade_slots_remaining > 0:
    if chip compatible with room type:
      if can afford chip cost:
        room.add_upgrade(chip)
        current_budget += chip.cost
        show chip indicator dot on tile
      else:
        flash red (over budget)
    else:
      flash red (incompatible)
  else:
    flash red (no slots)
```

**Visual Indicators:**
- Each upgrade type has unique color dot
- Dots positioned in tile corners (top-left, top-right for 2 slots)
- Hover over dot shows upgrade name in tooltip

### Acceptance Criteria:
- [ ] Visual check: Upgrade palette visible with 6 chip types
- [ ] Interaction check: Click Auto-Loader → click Weapon → orange dot appears
- [ ] Visual check: Budget increases by 1 BP when chip installed
- [ ] Interaction check: Try to install weapon chip on shield → red flash
- [ ] Interaction check: Right-click chip dot → dot disappears, budget decreases
- [ ] Manual test: Install 2 upgrades on Bridge → see 2 colored dots
- [ ] Interaction check: Try to add 3rd chip to 2-slot room → red flash

### Shortcuts for This Phase:
- Simple dot indicators (no detailed chip sprites on tiles)
- Fixed slot counts (Bridge: 2, all others: 1)
- No rarity tiers (all chips equally available)
- Chips apply effects in combat only (visual in 9.2)

---

## Feature 9.2: Upgrade Effects in Combat

**Tests:** Q4 (Budget trade-offs)
**Time:** 2 hours

### What Player Sees:

**In Combat:**
- Upgraded rooms have subtle visual cues (colored glow matching chip)
- Damage numbers reflect upgrades:
  - Base weapon: "10" damage
  - Auto-Loader weapon: "12.5" damage (10 × 1.25)
  - Auto-Loader + Targeting: "13.75" damage (10 × 1.25 × 1.10)
- Overcharged reactors show extended power lines (reaches diagonal tiles)

### What Player Does:
- Design ship with strategic upgrades (Auto-Loaders on weapons)
- Launch combat → see higher damage output
- Compare base ship (30 BP, no upgrades) vs upgraded ship (25 BP rooms + 5 BP upgrades)
- Optimize builds: fewer rooms with upgrades vs more rooms without

### How It Works:

**Effect Application:**
```
Before combat stats calculation:
  for each room:
    base_value = room.base_stat
    for each installed upgrade:
      if upgrade.effect == "damage":
        base_value *= (1 + upgrade.value)
      elif upgrade.effect == "fire_rate":
        base_value *= (1 + upgrade.value)
      elif upgrade.effect == "capacity":
        base_value *= (1 + upgrade.value)
      # etc.
    room.effective_stat = base_value
```

**Specific Effects:**
1. **Auto-Loader:** Weapon damage × 1.25
2. **Targeting:** Weapon damage × 1.10
3. **Capacitor:** Shield absorption × 1.30
4. **Afterburner:** Engine initiative + 1 per engine
5. **Overcharge:** Reactor powers diagonal tiles too (8 directions instead of 4)
6. **Reinforced:** Room has 50% lower destruction probability

**Stacking:**
- Multiple upgrades on same room multiply: Auto-Loader + Targeting = 1.25 × 1.10 = 1.375× damage
- Upgrades lost if room destroyed

### Acceptance Criteria:
- [ ] Manual test: Weapon with Auto-Loader deals 12.5 damage (10 × 1.25)
- [ ] Manual test: Weapon with both Auto-Loader + Targeting deals 13.75 damage
- [ ] Manual test: Shield with Capacitor absorbs 19.5 (15 × 1.30)
- [ ] Visual check: Overcharged reactor power lines reach diagonal tiles
- [ ] Manual test: Reinforced room survives longer (fewer destructions)
- [ ] Manual test: Destroy upgraded room → lose upgrade effects

### Shortcuts for This Phase:
- Effects stack multiplicatively (simple multiplication)
- No diminishing returns
- Overcharge uses simple 8-direction check (not extended range)
- Reinforced durability is probabilistic (not true HP)

---

## Feature 9.3: Upgrade Quick-Install UI

**Tests:** Q1 (Design → iterate loop)
**Time:** 1.5 hours

### What Player Sees:
- **Right-click room:** Popup menu appears showing compatible upgrades
  - "Install Auto-Loader (+1 BP)" in orange
  - "Install Targeting (+1 BP)" in red
  - Grayed out if over budget
  - Grayed out if no slots remaining
- **Hover menu item:** Shows effect description: "+25% fire rate"
- **Click menu item:** Chip installs immediately, menu closes

### What Player Does:
- Right-click weapon → see 2 compatible upgrade options
- Click "Auto-Loader" → chip installs, orange dot appears
- Right-click again → see only "Targeting" (1 slot used)
- Use menu for quick installation without palette interaction

### How It Works:
- Right-click on occupied tile opens context menu (PopupMenu node)
- Menu populated with compatible upgrades for room type:
  ```
  on right_click(room):
    menu.clear()
    for upgrade in UPGRADES:
      if room_type in upgrade.compatible:
        if room.has_slot_available():
          menu.add_item(upgrade.name, upgrade.cost)
        else:
          menu.add_item_disabled(upgrade.name + " (No slots)")
    menu.popup_at_mouse()
  ```
- Menu item clicked triggers same installation logic as chip palette

### Acceptance Criteria:
- [ ] Interaction check: Right-click weapon → menu shows Auto-Loader, Targeting
- [ ] Interaction check: Click menu item → upgrade installs
- [ ] Visual check: Menu shows costs and grays out unaffordable items
- [ ] Interaction check: Right-click room with no slots → menu shows "No slots"
- [ ] Manual test: Install chip via menu → same result as palette method

### Shortcuts for This Phase:
- Simple PopupMenu (no fancy styling)
- Menu doesn't show current upgrades (just installation options)
- No uninstall via menu (still need to right-click dot)
- Menu closes on any click outside

---

# PHASE 10: SHIP HULL VARIANTS

**Goal:** Choose from different hull templates with unique shapes/bonuses before designing

**Time:** 4-5 hours

---

## Feature 10.1: Hull Selection Screen

**Tests:** Q4 (Budget trade-offs), Q5 (Engineering fantasy)
**Time:** 1.5 hours

### What Player Sees:
- **Position:** New screen before ship designer, 1280×720 full screen
- **Title:** "SELECT HULL TYPE" at top (36pt white)
- **Layout:** 3 hull options shown as cards, 350px wide each, horizontally centered
- **Each card shows:**
  - Hull silhouette preview (200×150px grid outline)
  - Hull name: "FRIGATE", "CRUISER", "BATTLESHIP" (24pt)
  - Grid size: "10×4", "8×6", "7×7" (gray, 16pt)
  - Bonus description: "+2 Initiative", "Balanced", "+20 HP" (cyan, 18pt)
  - "SELECT" button at bottom
- **Visual states:**
  - Hover: card scales to 1.05, border glows cyan
  - Selected (locked in mission): green checkmark overlay

### What Player Does:
- Start mission → see hull selection screen
- Read 3 hull types and their bonuses
- Click "SELECT" on preferred hull → loads ship designer with that grid template
- Design ship within chosen hull's grid constraints
- Return after combat → remember hull selection for mission

### How It Works:

**Hull Definitions (in GameState):**
```
HULL_TYPES = {
  FRIGATE: {
    grid_size: Vector2i(10, 4),  # Narrow and long
    bonus_type: "initiative",
    bonus_value: 2,
    description: "Fast interceptor"
  },
  CRUISER: {
    grid_size: Vector2i(8, 6),   # Standard (current default)
    bonus_type: "none",
    bonus_value: 0,
    description: "Balanced warship"
  },
  BATTLESHIP: {
    grid_size: Vector2i(7, 7),   # Wide and bulky
    bonus_type: "hull_hp",
    bonus_value: 20,
    description: "Heavy gunship"
  }
}
```

**Screen Flow:**
- MissionSelect → HullSelect → ShipDesigner
- HullSelect passes chosen hull type to ShipDesigner
- ShipDesigner creates grid with chosen dimensions
- Combat applies hull bonuses to stats

### Acceptance Criteria:
- [ ] Visual check: Hull selection screen shows 3 cards with previews
- [ ] Visual check: Each card shows grid size and bonus description
- [ ] Interaction check: Hover card → scales up, border glows
- [ ] Interaction check: Click SELECT on Frigate → loads designer with 10×4 grid
- [ ] Manual test: Select Battleship → see 7×7 grid in designer
- [ ] Visual check: Grid dimensions match selected hull type

### Shortcuts for This Phase:
- Fixed 3 hull types (no progression/unlocks)
- Simple grid outlines for previews (no detailed hull art)
- Hull selection doesn't persist across missions (choose each time)
- No "recommended hull" guidance for missions

---

## Feature 10.2: Hull-Specific Grid Constraints

**Tests:** Q2 (Placement strategic)
**Time:** 1.5 hours

### What Player Sees:

**In Designer:**
- Grid resized to match hull type:
  - Frigate: 10 columns × 4 rows (wider, shorter)
  - Cruiser: 8 columns × 6 rows (standard)
  - Battleship: 7 columns × 7 rows (squarer, bulkier)
- Row constraints adapt to grid height:
  - Frigate (4 rows): Weapons in rows 0-1, Engines in rows 2-3
  - Cruiser (6 rows): Weapons in rows 0-1, Engines in rows 4-5
  - Battleship (7 rows): Weapons in rows 0-2, Engines in rows 4-6

### What Player Does:
- Select Frigate hull → see wider, shorter grid
- Place weapons → notice only top 2 rows allowed (rows 0-1)
- Place engines → only bottom 2 rows allowed (rows 2-3)
- Experiment with how hull shape affects room placement strategies

### How It Works:
- ShipDesigner._create_grid() uses hull_type.grid_size instead of constants:
  ```
  var grid_width = selected_hull.grid_size.x
  var grid_height = selected_hull.grid_size.y

  for y in range(grid_height):
    for x in range(grid_width):
      # Create tiles...
  ```
- Row constraints recalculated based on grid_height:
  ```
  WEAPON_ROWS = [0, 1] if grid_height <= 4 else [0, 1] if grid_height == 6 else [0, 1, 2]
  ENGINE_ROWS = [grid_height-2, grid_height-1]
  ```

### Acceptance Criteria:
- [ ] Visual check: Frigate hull shows 10×4 grid (40 tiles)
- [ ] Visual check: Battleship hull shows 7×7 grid (49 tiles)
- [ ] Interaction check: Try to place weapon in row 2 of Frigate → red flash (invalid)
- [ ] Manual test: Place engines in Frigate rows 2-3 → succeeds
- [ ] Manual test: Fill entire Battleship grid → can place 49 rooms (within budget)

### Shortcuts for This Phase:
- Row constraints use simple top/bottom logic (not hull-specific rules)
- All hulls use same budget (don't adjust budget per hull)
- Grid tiles remain 64×64px (grid scales overall size)
- Center grid on screen regardless of hull size

---

## Feature 10.3: Hull Bonus Combat Effects

**Tests:** Q4 (Budget trade-offs)
**Time:** 1.5 hours

### What Player Sees:

**In Combat:**
- Frigate ships move first (initiative bonus applied)
  - "Player shoots first (+2 initiative)" appears briefly
- Battleship ships have higher starting HP
  - Health bar shows "120 / 120 HP" instead of "100 / 100 HP"
- Combat log (if added) shows hull bonuses: "Frigate Hull: +2 initiative"

### What Player Does:
- Design Frigate with 3 engines → total initiative = 5 (3 base + 2 hull bonus)
- Fight enemy with 4 engines → player shoots first (5 vs 4)
- Design Battleship with 2 armor → total HP = 100 (60 base + 40 from 2 armor + 20 hull bonus)
- Notice hull choice impacts combat viability

### How It Works:

**Bonus Application:**
```
At combat start:
  base_initiative = count_engines()
  base_hp = 60 + (armor_count × 20)

  if hull_type == FRIGATE:
    initiative += 2
  elif hull_type == BATTLESHIP:
    hull_hp += 20

  Use modified stats for combat
```

**Initiative Check:**
```
player_initiative = player_engines + player_hull_bonus
enemy_initiative = enemy_engines + enemy_hull_bonus

if player_initiative > enemy_initiative:
  player shoots first
else:
  enemy shoots first
```

### Acceptance Criteria:
- [ ] Manual test: Frigate with 2 engines vs enemy with 3 engines → player shoots first (4 vs 3)
- [ ] Manual test: Battleship with 0 armor → starts at 80 HP (60 + 20 hull)
- [ ] Visual check: Ship Status Panel shows hull bonus: "Hull: +2 Initiative (Frigate)"
- [ ] Manual test: Win with Frigate using initiative advantage
- [ ] Manual test: Win with Battleship using HP advantage

### Shortcuts for This Phase:
- Only 2 bonus types (initiative, HP - no damage/shield bonuses yet)
- Bonuses are flat additions (not multipliers)
- Enemy ships don't have hull types (always standard)
- Don't show hull type visually in combat (just stats)

---

# PHASE 11: SYSTEM INTEGRITY & DAMAGE PROPAGATION

**Goal:** Rooms have internal HP, damaged rooms lose efficiency, adjacent rooms take splash damage

**Time:** 5-6 hours

---

## Feature 11.1: Room HP System & Visual Damage States

**Tests:** Q3 (Combat readable), Q5 (Engineering fantasy)
**Time:** 2 hours

### What Player Sees:

**In Designer:**
- Rooms show HP indicator when hovered: "20 / 20 HP" (gray text overlay)
- Room tooltips include: "HP: 20 (Fully operational)"

**In Combat:**
- Each room has mini HP bar above it (48px wide, 4px tall)
  - Green fill when HP > 66%
  - Yellow fill when HP 33-66%
  - Red fill when HP < 33%
- Damaged rooms show visual degradation:
  - 66-100% HP: Normal appearance
  - 33-66% HP: Sparks particle effect, slight dim
  - 1-33% HP: Smoke particle effect, heavy dim, cracks overlay
  - 0% HP: Destroyed (gray sprite, no function)

### What Player Does:
- Watch combat → see rooms take partial damage (not instant destruction)
- Notice weapon at 50% HP still functions (reduced effectiveness)
- See room go from green → yellow → red → destroyed across multiple hits
- Understand gradual damage vs instant loss

### How It Works:

**Room HP Values (in RoomData):**
```
ROOM_HP = {
  BRIDGE: 30,
  WEAPON: 20,
  SHIELD: 25,
  ENGINE: 15,
  REACTOR: 20,
  ARMOR: 40
}
```

**Damage Application:**
```
On combat damage dealt:
  remaining_damage = total_damage - shield_absorption

  while remaining_damage > 0:
    target_room = pick_random_active_room()
    damage_to_room = min(remaining_damage, target_room.current_hp)

    target_room.current_hp -= damage_to_room
    remaining_damage -= damage_to_room

    update_room_visual(target_room)

    if target_room.current_hp <= 0:
      destroy_room(target_room)
```

**Visual Updates:**
- HP bar tween animates damage
- Particle effects spawn at HP thresholds
- Room sprite modulate darkens proportionally to damage

### Acceptance Criteria:
- [ ] Visual check: Each room in combat shows mini HP bar above it
- [ ] Manual test: Deal 10 damage to weapon (20 HP) → bar shows 10/20 (yellow)
- [ ] Visual check: Damaged weapon shows sparks particle effect
- [ ] Manual test: Deal another 10 damage → weapon reaches 0 HP, destroys
- [ ] Visual check: Room transitions green → yellow → red as HP decreases
- [ ] Manual test: Bridge with 30 HP takes 3 hits of 10 damage before destroying

### Shortcuts for This Phase:
- Fixed HP values per room type (no upgrades yet)
- Simple particle effects (built-in CPUParticles2D)
- Damage allocated randomly (not targeted)
- HP doesn't regenerate between turns

---

## Feature 11.2: Damage Efficiency Scaling

**Tests:** Q2 (Placement strategic), Q3 (Combat readable)
**Time:** 1.5 hours

### What Player Sees:

**In Combat:**
- Damaged weapons show reduced damage numbers:
  - 100% HP: "10" damage
  - 50% HP: "5" damage (dimmed, orange color)
  - 25% HP: "2.5" damage (dimmed, red color)
- Damaged shields absorb less:
  - 100% HP: "15" absorption
  - 50% HP: "7.5" absorption
- Damaged engines contribute less initiative

### What Player Does:
- Watch weapon get damaged to 50% HP → notice damage output drops by half
- See damaged systems still contribute (not binary on/off)
- Prioritize protecting critical rooms from damage
- Understand partial damage has strategic impact

### How It Works:

**Efficiency Calculation:**
```
room_efficiency = current_hp / max_hp

For weapons:
  effective_damage = base_damage × room_efficiency
  Example: 20/20 HP = 100% = 10 damage
           10/20 HP = 50% = 5 damage
           5/20 HP = 25% = 2.5 damage

For shields:
  effective_absorption = base_absorption × room_efficiency

For engines:
  effective_initiative = base_initiative × room_efficiency (rounded)
```

**Stat Recalculation:**
```
On each combat turn start:
  total_damage = 0
  for each weapon:
    if powered:
      efficiency = weapon.current_hp / weapon.max_hp
      total_damage += 10 × efficiency

  Apply total_damage to enemy
```

### Acceptance Criteria:
- [ ] Manual test: Weapon at 20/20 HP deals 10 damage
- [ ] Manual test: Same weapon at 10/20 HP deals 5 damage
- [ ] Visual check: Damaged weapon's damage number shows in orange/red
- [ ] Manual test: Shield at 12.5/25 HP absorbs 7.5 damage (50% efficiency)
- [ ] Manual test: Combat with all damaged systems → significantly reduced performance

### Shortcuts for This Phase:
- Linear scaling (no step functions or thresholds)
- All room types scale same way (no special rules)
- Efficiency doesn't affect power consumption
- Don't show efficiency percentage visually (just HP bar color)

---

## Feature 11.3: Splash Damage Propagation

**Tests:** Q2 (Placement strategic), Q3 (Combat readable)
**Time:** 2 hours

### What Player Sees:

**In Combat:**
- When room destroyed, adjacent rooms flash briefly (orange flash)
- Adjacent rooms' HP bars decrease (show splash damage)
- Damage numbers appear on adjacent rooms: "-5" in gray
- Armor rooms reduce splash to neighbors (visual shield icon appears briefly)

**Splash Pattern:**
- Destroyed weapon explodes → 4 adjacent rooms take 5 damage each
- Armor adjacent to destroyed room → blocks splash to rooms behind it

### What Player Does:
- Watch weapon destroyed → see adjacent reactor take 5 splash damage
- Notice cluster of rooms creates chain vulnerability
- Place armor strategically to absorb splash
- Spread critical rooms apart to reduce splash impact

### How It Works:

**Splash Damage Application:**
```
When room destroyed:
  splash_damage = 5 (base)

  for each adjacent tile (4 directions):
    if tile has room:
      # Check if armor blocks splash
      if no armor between destroyed room and target:
        target.current_hp -= splash_damage
        spawn_damage_number(target, "-5", Color.GRAY)
        flash_orange(target)

      update_room_visual(target)

      if target.current_hp <= 0:
        destroy_room(target) # Can cause chain reaction
```

**Armor Blocking:**
- If armor room is between destroyed room and splash target: no splash
- Armor itself takes splash damage normally (but has 40 HP)
- Creates strategic placement: armor as "blast shields"

### Acceptance Criteria:
- [ ] Manual test: Destroy weapon → adjacent reactor takes 5 splash damage
- [ ] Visual check: Adjacent rooms flash orange when splash hits
- [ ] Visual check: Gray "-5" damage numbers appear on splashed rooms
- [ ] Manual test: Destroy weapon with armor adjacent → armor takes splash, shields room behind it
- [ ] Manual test: Cluster of 4 rooms → destroy center room → all 4 neighbors take splash
- [ ] Manual test: Chain reaction: splash destroys second room → third room splashed

### Shortcuts for This Phase:
- Fixed 5 splash damage (not percentage of room max HP)
- Only 4-directional splash (no diagonals)
- Armor blocks splash in straight line only (simple blocking)
- No splash damage to player's own rooms (only in enemy ship, or both if implemented)

---

# PHASE 12: CREW ASSIGNMENT SYSTEM

**Goal:** Limited crew members must be assigned to rooms for full efficiency

**Time:** 4-5 hours

---

## Feature 12.1: Crew Roster & Assignment UI

**Tests:** Q4 (Budget trade-offs), Q5 (Engineering fantasy)
**Time:** 2 hours

### What Player Sees:
- **Crew Panel:** New panel left side, 250px wide
  - Title: "CREW ROSTER" (20pt white)
  - Shows 6 crew portraits (64×64px each) in vertical list
  - Each portrait shows:
    - Name: "Lt. Chen", "Eng. Park" (14pt)
    - Specialty icon: Pilot (blue), Gunner (red), Engineer (yellow)
    - Assignment status: "UNASSIGNED" gray, or "Bridge" cyan
- **Drag-and-Drop:** Drag portrait from roster → drop on grid room
- **On Grid Tiles:** Small crew portrait appears in top-right corner when assigned
- **Unassigned rooms:** Show 50% opacity overlay, tooltip says "Unmanned (-50% efficiency)"

### What Player Does:
- See 6 crew available for 12+ rooms (must choose wisely)
- Drag "Lt. Chen" portrait → drop on Bridge room
- See portrait appear on Bridge tile
- Notice unassigned weapon has 50% opacity (unmanned)
- Drag "Gunner Rodriguez" → drop on weapon → weapon brightens to full opacity
- Prioritize which 6 rooms get crew assignments

### How It Works:

**Crew Definitions (in GameState):**
```
CREW_ROSTER = [
  {name: "Cdr. Hart", specialty: "COMMAND", bonus: "bridge_hp", value: 1.5},
  {name: "Lt. Chen", specialty: "PILOT", bonus: "engine_power", value: 1.25},
  {name: "Gunnery Rodriguez", specialty: "GUNNER", bonus: "weapon_damage", value: 1.15},
  {name: "Eng. Park", specialty: "ENGINEER", bonus: "reactor_range", value: 1},
  {name: "Shields Okoro", specialty: "DEFENDER", bonus: "shield_capacity", value: 1.20},
  {name: "Med. Tanaka", specialty: "MEDIC", bonus: "crew_survival", value: 0}
]
```

**Assignment Logic:**
```
On crew portrait dropped on tile:
  if tile has room:
    if room already has crew:
      unassign previous crew
    assign new crew to room
    room.assigned_crew = crew
    show crew portrait on tile
    update room efficiency
  else:
    return crew to roster
```

**Efficiency Calculation:**
```
room_efficiency = 1.0 if room.assigned_crew else 0.5
Apply to room stats in combat
```

### Acceptance Criteria:
- [ ] Visual check: Crew panel shows 6 crew portraits with names
- [ ] Interaction check: Drag crew portrait → see dragging cursor with portrait
- [ ] Interaction check: Drop on room → portrait appears on tile
- [ ] Visual check: Unassigned rooms show 50% opacity overlay
- [ ] Interaction check: Assign crew to room → room brightens to full opacity
- [ ] Manual test: Try to assign 7th crew (only 6 available) → roster empty

### Shortcuts for This Phase:
- Fixed 6 crew (not scalable)
- One crew per room max (no multi-crew rooms)
- Simple portrait placeholders (colored squares with initials)
- Crew can be reassigned freely (no lock-in)

---

## Feature 12.2: Crew Specialties & Bonuses

**Tests:** Q4 (Budget trade-offs)
**Time:** 1.5 hours

### What Player Sees:

**In Designer:**
- Hovering assigned crew shows bonus tooltip:
  - "Gunnery Rodriguez: +15% weapon damage"
  - "Eng. Park: Reactor powers +1 extra tile"
- Ship Status Panel shows: "👥 Crew: 6/6 assigned"

**In Combat:**
- Crew-boosted rooms show enhanced stats:
  - Weapon with Gunner: "11.5" damage instead of "10"
  - Shield with Defender: "18" absorption instead of "15"
- Specialty bonuses stack with upgrades and synergies

### What Player Does:
- Assign Gunner to weapon → see damage increase
- Assign Engineer to reactor → see power range increase
- Optimize crew assignments for maximum benefit
- Trade off: man all weapons or spread across weapon/shield/engine?

### How It Works:

**Bonus Application:**
```
In combat stat calculation:
  base_stat = room.base_value

  if room.assigned_crew:
    base_stat *= 1.0 # Full efficiency
    if crew.specialty matches room type:
      apply crew bonus:
        GUNNER on WEAPON: damage × 1.15
        DEFENDER on SHIELD: absorption × 1.20
        PILOT on ENGINE: initiative + 2
        ENGINEER on REACTOR: power range +1 tile
        COMMAND on BRIDGE: bridge HP × 1.5
  else:
    base_stat *= 0.5 # Unmanned penalty

  Apply synergies, upgrades on top of crew bonuses
```

**Stacking Order:**
```
final_stat = base × crew_efficiency × crew_specialty × synergy × upgrade
Example: Weapon with Gunner + Auto-Loader + Weapon adjacency
  = 10 × 1.0 × 1.15 × 1.15 × 1.25 = 16.56 damage
```

### Acceptance Criteria:
- [ ] Manual test: Weapon with Gunner deals 11.5 damage (10 × 1.15)
- [ ] Manual test: Weapon without any crew deals 5 damage (10 × 0.5)
- [ ] Manual test: Engineer on reactor → reactor powers diagonal tiles too
- [ ] Visual check: Tooltip shows "+15% damage (Gunnery Rodriguez)"
- [ ] Manual test: Stack all bonuses → see combined effect (16+ damage possible)

### Shortcuts for This Phase:
- Fixed crew specialties (no leveling/progression)
- Specialty bonuses are simple multipliers
- One specialty per crew (no multi-talented crew)
- Crew bonuses don't affect budget costs

---

## Feature 12.3: Crew Casualties System

**Tests:** Q3 (Combat readable)
**Time:** 1 hour

### What Player Sees:

**In Combat:**
- When manned room destroyed: crew portrait flashes red, then fades out
- Death notification: "Gunnery Rodriguez KIA" appears briefly (red text)
- Room becomes unmanned (loses crew bonus instantly)

**Next Battle:**
- Return to designer → Crew Roster shows 5 crew (one lost)
- Empty slot shows "LOST IN ACTION" (gray)
- Must design ship with only 5 crew available

### What Player Does:
- Watch manned weapon destroyed → lose Gunner crew permanently (for this mission)
- Next retry attempt → only 5 crew available
- Understand crew loss increases difficulty
- Protect critical manned rooms to preserve crew

### How It Works:

**On Room Destruction:**
```
When room destroyed:
  if room.assigned_crew:
    crew = room.assigned_crew
    flash_red(crew.portrait)
    show_death_notification(crew.name + " KIA")
    GameState.remove_crew(crew)
    room.assigned_crew = null

GameState tracks living crew per mission
```

**Mission Flow:**
```
Mission start: 6 crew
Combat 1: Lose 1 crew
Retry: 5 crew available
Combat 2: Lose 2 more crew
Retry: 3 crew available
Win mission: Reset to 6 crew for next mission
```

### Acceptance Criteria:
- [ ] Manual test: Destroy manned weapon → see "Gunnery Rodriguez KIA"
- [ ] Visual check: Crew portrait fades out when killed
- [ ] Manual test: Return to designer → roster shows 5 crew (one missing)
- [ ] Manual test: Complete mission → next mission resets crew to 6
- [ ] Manual test: Lose all 6 crew → can still design ship (all rooms unmanned)

### Shortcuts for This Phase:
- Crew casualties don't persist across missions (reset each mission)
- No crew replacement or hiring
- Medic doesn't prevent casualties (just placeholder for future)
- All crew equally likely to die (no survival bonuses yet)

---

# PHASE 13: POWER CONDUIT ROUTING

**Goal:** Draw power lines from reactors through grid instead of simple adjacency

**Time:** 4-5 hours

---

## Feature 13.1: Manual Conduit Drawing UI

**Tests:** Q2 (Placement strategic), Q5 (Engineering fantasy)
**Time:** 2 hours

### What Player Sees:
- **Mode Toggle:** Button "POWER MODE" top-left (toggles grid into routing mode)
- **In Power Mode:**
  - Grid tiles show power capacity: empty tiles show "0/2" (can hold 2 conduit paths)
  - Click and drag from reactor → draw glowing line to adjacent tile
  - Continue dragging → line follows cursor through grid
  - Release on room tile → conduit path saved, room powered
- **Conduits Visual:**
  - Cyan glowing lines (4px wide) running through tile centers
  - Animated energy flow (dashed line scrolling effect)
  - Tiles with conduits show small "⚡" icon in corner

### What Player Does:
- Click "POWER MODE" button → grid changes to conduit view
- Click reactor tile, drag to adjacent tile → see cyan line appear
- Continue dragging through 3 tiles → reach weapon tile
- Release → conduit path complete, weapon powered
- Draw second path from same reactor to shield
- Exit power mode → return to normal placement mode

### How It Works:

**Conduit Path Data:**
```
Conduit = {
  source: GridTile (reactor),
  path: Array[GridTile] (tiles the conduit passes through),
  target: GridTile (powered room)
}

Each GridTile tracks:
  conduits_passing_through: Array[Conduit] (max 2)
```

**Drawing Logic:**
```
On mouse drag in Power Mode:
  if drag started on reactor:
    path = [reactor_tile]

    on mouse move to adjacent tile:
      if tile.conduits_passing_through.size() < 2:
        if tile not in path (prevent loops):
          path.append(tile)
          draw line segment

    on mouse release on room tile:
      create Conduit(reactor, path, room)
      mark room as powered
      save conduit to grid data
```

**Visual Rendering:**
```
For each conduit:
  for i in path.size() - 1:
    draw Line2D from path[i].center to path[i+1].center
    animate texture offset for flow effect
```

### Acceptance Criteria:
- [ ] Visual check: Click POWER MODE → grid shows "0/2" capacity labels
- [ ] Interaction check: Drag from reactor → see cyan line follow cursor
- [ ] Interaction check: Release on weapon 3 tiles away → path saved, weapon powered
- [ ] Visual check: Conduit shows animated energy flow
- [ ] Interaction check: Try to route 3 paths through same tile → 3rd rejected (max 2)
- [ ] Manual test: Draw conduit, exit power mode → conduit persists

### Shortcuts for This Phase:
- Conduits are straight paths (no branching from middle of path)
- Max 2 conduits per tile (hard limit)
- Can't delete individual conduits yet (must clear all and redraw)
- Conduits don't cost budget

---

## Feature 13.2: Conduit Damage & Power Loss

**Tests:** Q2 (Placement strategic), Q3 (Combat readable)
**Time:** 1.5 hours

### What Player Sees:

**In Combat:**
- When tile with conduit destroyed: conduit line breaks (gap appears)
- Downstream rooms fed by that conduit lose power (gray out)
- Power loss notification: "Weapon offline - conduit severed" (orange text)
- Multiple rooms can lose power from single tile destruction

### What Player Does:
- Watch tile containing conduit destroyed → see power line break
- Notice weapon that was powered goes gray (unpowered)
- Understand conduit vulnerability: one tile breaks entire path
- Design redundant power paths (2 conduits to critical rooms)

### How It Works:

**On Tile Destroyed in Combat:**
```
destroyed_tile = combat_hit_tile

for conduit in destroyed_tile.conduits_passing_through:
  conduit.is_broken = true
  conduit.target_room.powered = false

  # Visual: gray out conduit path after break point
  break_index = conduit.path.index(destroyed_tile)
  for i in range(break_index, conduit.path.size()):
    conduit.path[i].conduit_visual.modulate = Color.GRAY

  # Gray out unpowered room
  conduit.target_room.set_powered_state(false)

Recalculate combat stats (unpowered rooms don't contribute)
```

**Redundancy Check:**
```
room.powered = false
for each conduit leading to room:
  if not conduit.is_broken:
    room.powered = true
    break

Only gray out room if ALL conduits to it are broken
```

### Acceptance Criteria:
- [ ] Manual test: Destroy tile with conduit → see conduit line break
- [ ] Visual check: Downstream rooms gray out when conduit severed
- [ ] Visual check: Broken conduit shows gray beyond break point
- [ ] Manual test: Room with 2 conduits → destroy 1 path → room stays powered (redundancy)
- [ ] Manual test: Destroy 2nd path → room loses power

### Shortcuts for This Phase:
- Conduits don't regenerate or repair mid-combat
- Empty tiles can be destroyed (not just rooms) if they have conduits
- No conduit armor or shielding
- Reactors can't reroute power automatically

---

## Feature 13.3: Conduit Management Tools

**Tests:** Q1 (Design → iterate loop)
**Time:** 1 hour

### What Player Sees:
- **In Power Mode:**
  - Right-click conduit line → context menu: "Delete Conduit"
  - Button: "CLEAR ALL CONDUITS" (red, clears entire power grid)
  - Highlight toggle: "Show Unpowered" (highlights rooms with no power in red)
- **Visual aids:**
  - Unpowered rooms pulse red border when "Show Unpowered" enabled
  - Conduit paths highlight on hover (brighter cyan)

### What Player Does:
- Right-click conduit path → select "Delete" → path removed
- Click "Show Unpowered" → see all unpowered rooms highlighted
- Draw new conduits to power highlighted rooms
- Click "CLEAR ALL" → wipe power grid, start over

### How It Works:
- Right-click on conduit line:
  - Detect which conduit was clicked (raycast to Line2D nodes)
  - Show PopupMenu with "Delete Conduit"
  - On confirm: remove conduit from grid, unpower target room, delete Line2D nodes
- Clear All button:
  ```
  for each conduit in all_conduits:
    delete conduit
    unpower target room
  all_conduits.clear()
  ```
- Show Unpowered toggle:
  ```
  for each room in grid:
    if not room.powered:
      room.show_red_pulse_border()
  ```

### Acceptance Criteria:
- [ ] Interaction check: Right-click conduit → see "Delete Conduit" menu
- [ ] Interaction check: Click Delete → conduit removed, room unpowered
- [ ] Interaction check: Click "Show Unpowered" → unpowered rooms pulse red
- [ ] Interaction check: Click "CLEAR ALL" → all conduits deleted
- [ ] Manual test: Delete and redraw conduits to optimize routing

### Shortcuts for This Phase:
- No undo/redo for conduit changes
- Can't edit existing conduit (must delete and redraw)
- No auto-routing or suggested paths
- Simple straight-line rendering (no curved conduits)

---

# PHASE 14: ROOM TIERS & SPECIALIZATIONS

**Goal:** Each room type has 3 variants unlocked through progression

**Time:** 4-5 hours

---

## Feature 14.1: Tiered Room Variants UI

**Tests:** Q4 (Budget trade-offs), Q5 (Engineering fantasy)
**Time:** 2 hours

### What Player Sees:
- **Room Palette Enhanced:**
  - Each room type now expandable (click arrow to expand)
  - Expanded shows 3 tiers:
    - Tier 1: "Laser Weapon" (unlocked, 2 BP)
    - Tier 2: "Cannon Weapon" (locked, 3 BP, shows "Complete Mission 2")
    - Tier 3: "Missile Weapon" (locked, 4 BP, shows "Complete Mission 5")
  - Each tier has unique icon and color variant
- **Visual differences:**
  - Laser: Bright red, thin beam icon
  - Cannon: Dark red, chunky barrel icon
  - Missile: Orange, rocket icon

### What Player Does:
- Start game → only Tier 1 rooms available
- Complete Mission 2 → Tier 2 rooms unlock
- Expand Weapon category → see 3 weapon types available
- Select "Cannon Weapon" → place heavier weapon variant
- Compare tier trade-offs: cost vs effectiveness

### How It Works:

**Room Tier Definitions:**
```
WEAPON_VARIANTS = {
  LASER: {tier: 1, cost: 2, damage: 8, speed: "fast", unlock: 0},
  CANNON: {tier: 2, cost: 3, damage: 15, speed: "slow", unlock: 2},
  MISSILE: {tier: 3, cost: 4, damage: 12, ignores_shields: true, unlock: 5}
}

SHIELD_VARIANTS = {
  KINETIC: {tier: 1, cost: 3, absorption: 15, strong_vs: "physical"},
  ENERGY: {tier: 2, cost: 3, absorption: 12, strong_vs: "laser"},
  ADAPTIVE: {tier: 3, cost: 4, absorption: 13, strong_vs: "all"}
}

REACTOR_VARIANTS = {
  FUSION: {tier: 1, cost: 2, power_range: 4, stable: true},
  ANTIMATTER: {tier: 2, cost: 3, power_range: 6, explodes_when_hit: true},
  QUANTUM: {tier: 3, cost: 4, power_range: 8, bonus: "phase_shift"}
}
```

**Unlock Tracking (GameState):**
```
unlocked_tiers = {
  WEAPON: 1, # Tier 1 unlocked
  SHIELD: 1,
  REACTOR: 1,
  # etc.
}

On mission complete:
  if mission_index == 2:
    unlock_tier(2) # Tier 2 for all room types

Update palette to show newly unlocked variants
```

### Acceptance Criteria:
- [ ] Visual check: Room palette shows expandable arrows
- [ ] Interaction check: Click arrow → see 3 room tiers
- [ ] Visual check: Tier 2 and 3 show lock icons and unlock requirements
- [ ] Manual test: Complete Mission 2 → Tier 2 unlocks for all rooms
- [ ] Visual check: Each tier has distinct icon and description
- [ ] Interaction check: Select Cannon Weapon → cursor shows cannon icon

### Shortcuts for This Phase:
- Fixed 3 tiers per room type (no 4th tier)
- All room types unlock tiers at same missions (not individual unlock paths)
- Simple tier icons (recolored base room sprites)
- Unlocks persist across missions (not per-playthrough)

---

## Feature 14.2: Variant Combat Mechanics

**Tests:** Q2 (Placement strategic), Q4 (Budget trade-offs)
**Time:** 1.5 hours

### What Player Sees:

**In Combat:**
- Laser weapons fire first (high initiative bonus)
  - Fast attack animation, thin red beam
  - Damage: "8" (lower than base 10)
- Cannon weapons fire last (low initiative penalty)
  - Slow attack animation, heavy projectile
  - Damage: "15" (higher than base 10)
  - Screen shake effect on hit
- Missile weapons show "SHIELDS BYPASSED" notification
  - Damage: "12" directly to hull (shields don't absorb)

**Variant Bonuses:**
- Kinetic shields glow blue, absorb +50% vs physical weapons
- Energy shields glow cyan, absorb +50% vs laser weapons
- Adaptive shields glow purple, absorb +25% vs all weapon types

### What Player Does:
- Build ship with 3 Lasers → fire first, deal 24 damage (8 × 3)
- Build ship with 2 Cannons → fire last, deal 30 damage (15 × 2)
- Use Missiles against heavily shielded enemy → bypass shields
- Choose shield type based on enemy weapon types (counter-builds)

### How It Works:

**Combat Stat Calculation:**
```
For weapon variants:
  LASER: damage = 8, initiative_bonus = +2
  CANNON: damage = 15, initiative_bonus = -1
  MISSILE: damage = 12, shield_penetration = true

total_damage = sum of all weapon damages
total_initiative = engines + weapon_initiative_bonuses

If missile count > 0:
  missile_damage = missile_count × 12
  missile_damage bypasses shields
  remaining_weapons deal damage to shields first
```

**Shield Variant Mechanics:**
```
For shield variants:
  KINETIC: absorption = 15 vs non-laser, 7.5 vs laser
  ENERGY: absorption = 15 vs laser, 7.5 vs non-laser
  ADAPTIVE: absorption = 13 vs all weapon types

total_absorption = sum based on incoming weapon types
```

### Acceptance Criteria:
- [ ] Manual test: 3 Lasers vs enemy → deal 24 damage, shoot first
- [ ] Manual test: 2 Cannons vs enemy → deal 30 damage, shoot last
- [ ] Manual test: 2 Missiles vs 3 Kinetic Shields → 24 damage bypasses shields
- [ ] Visual check: Different weapon types have distinct attack animations
- [ ] Manual test: Kinetic Shield vs Cannons → absorbs 22.5 (15 × 1.5)
- [ ] Manual test: Kinetic Shield vs Lasers → absorbs 7.5 (15 × 0.5)

### Shortcuts for This Phase:
- Simple rock-paper-scissors balance (not complex damage types)
- Initiative bonuses are flat additions (not multiplicative)
- Missile shield penetration is binary (100% bypass, not partial)
- No hybrid weapons (each weapon is one type only)

---

## Feature 14.3: Tier Rebalancing & Enemy Variants

**Tests:** Q4 (Budget trade-offs)
**Time:** 1 hour

### What Player Sees:

**Enemy Ships:**
- Mission 3+ enemies use Tier 2 rooms (balanced difficulty)
- Mission 5+ enemies use Tier 3 rooms (high difficulty)
- Enemy ships have mixed builds (2 Lasers + 1 Cannon)

**Budget Impact:**
- Can afford 3 Tier 1 weapons (6 BP) or 2 Tier 2 weapons (6 BP)
- Trade-off: quantity vs quality
- Ship Status Panel shows tier mix: "3 T1, 2 T2, 1 T3 rooms"

### What Player Does:
- Choose between 4 Tier 1 Lasers (24 damage) vs 2 Tier 2 Cannons (30 damage)
- Face enemy with Tier 2 shields → realize Tier 1 weapons struggle
- Unlock Tier 3 → experiment with advanced builds
- Optimize budget between tier costs and room counts

### How It Works:
- Enemy ship generation uses tier-appropriate rooms:
  ```
  if mission_index <= 2:
    enemy_tiers = [1] # Tier 1 only
  elif mission_index <= 4:
    enemy_tiers = [1, 2] # Mix of Tier 1 and 2
  else:
    enemy_tiers = [1, 2, 3] # All tiers

  for each room slot:
    tier = random choice from enemy_tiers
    room = random variant from tier
  ```
- Balance testing ensures tier costs match power level

### Acceptance Criteria:
- [ ] Manual test: Build all Tier 1 → affordable but weak vs Tier 2 enemies
- [ ] Manual test: Build all Tier 3 → powerful but expensive (few rooms)
- [ ] Manual test: Mix Tier 1 + Tier 2 → balanced cost/power
- [ ] Visual check: Enemy ships in Mission 3 use Tier 2 rooms
- [ ] Manual test: Win Mission 2 with Tier 1, struggle → unlock Tier 2, win easily

### Shortcuts for This Phase:
- Simple tier cost scaling (T1: 2-3 BP, T2: 3-4 BP, T3: 4-5 BP)
- Enemies use random tier distributions (not optimized builds)
- Don't rebalance all missions (focus on Mission 3+)
- Tier unlocks don't gate progression (can win with Tier 1 only)

---

# PHASE 15: HEAT MANAGEMENT SYSTEM

**Goal:** Weapons and reactors generate heat, requiring cooling management

**Time:** 4-5 hours

---

## Feature 15.1: Heat Generation & Display

**Tests:** Q2 (Placement strategic), Q5 (Engineering fantasy)
**Time:** 1.5 hours

### What Player Sees:

**In Designer:**
- Rooms show heat output in tooltip:
  - Weapon: "+5 heat/turn"
  - Reactor: "+3 heat/turn"
  - Shield/Engine/Armor: "+0 heat/turn"
- Heat indicator panel top-left, 200px wide:
  - "HEAT: 0 / 30" (current / overheat threshold)
  - Bar shows heat level (green < 15, yellow 15-25, red > 25)
  - Shows heat sources: "3 Weapons (+15), 2 Reactors (+6)"

**Grid visual:**
- Hot rooms show red glow particle effect
- Heat intensity visualized by glow brightness

### What Player Does:
- Place 3 weapons → see "HEAT: +15/turn" in panel
- Add 2 reactors → heat increases to "+21/turn"
- Understand heat limit: too many weapons/reactors = overheating
- Balance offensive power vs heat generation

### How It Works:

**Heat Calculation:**
```
Heat sources (per turn in combat):
  WEAPON: +5 heat
  REACTOR: +3 heat
  BRIDGE/SHIELD/ENGINE/ARMOR: +0 heat

Total heat generation = (weapon_count × 5) + (reactor_count × 3)

Heat cap = 30 (base) + cooling_rooms
If heat > cap: overheat penalty applies
```

**Visual Updates:**
```
After each room placement:
  recalculate total_heat
  update heat panel display
  if heat > 15:
    change bar to yellow
  if heat > 25:
    change bar to red, show warning icon
  if heat > 30:
    show "OVERHEATING" warning (red, pulsing)
```

### Acceptance Criteria:
- [ ] Visual check: Heat panel visible top-left showing "0 / 30"
- [ ] Interaction check: Place weapon → heat increases by +5
- [ ] Visual check: Heat bar turns yellow at 15, red at 25
- [ ] Interaction check: Place 6 weapons → heat = 30, "OVERHEATING" warning
- [ ] Visual check: Hot rooms show red glow particles

### Shortcuts for This Phase:
- Fixed heat values per room (no variance)
- Heat calculated at design time (not dynamic in combat yet)
- Simple threshold system (not gradual scaling)
- No heat decay or cooling over time yet

---

## Feature 15.2: Radiator Rooms & Cooling

**Tests:** Q2 (Placement strategic)
**Time:** 1.5 hours

### What Player Sees:

**New Room Type:**
- Radiator added to Room Palette:
  - Cost: 2 BP
  - Icon: Blue heatsink symbol
  - Tooltip: "Dissipates heat from adjacent rooms. -5 heat/room."

**In Designer:**
- Place Radiator adjacent to Weapon → weapon glow dims (cooled)
- Heat panel updates: "3 Weapons (+15), 1 Radiator (-5) = +10 total"
- Edge tiles (grid edges) show bonus: "EDGE: -2 heat" when hovered

### What Player Does:
- Place 6 weapons → heat = 30 (overheating)
- Add 2 Radiators adjacent to weapons → heat = 20 (safe)
- Position radiators at grid edges for bonus cooling
- Trade-off: spend BP on radiators vs more weapons

### How It Works:

**Radiator Cooling:**
```
For each Radiator:
  cooling = -5 heat (base)

  if radiator on edge tile (x=0, x=7, y=0, y=5):
    cooling = -7 heat (edge bonus)

  for each adjacent room:
    if room generates heat (weapon/reactor):
      apply cooling visual (dim glow)

Total cooling = radiator_count × cooling_value
Net heat = heat_generation - cooling
```

**Edge Bonus:**
- Radiators on grid edge tiles (exposed to space) get +2 cooling
- Encourages strategic placement at edges vs center

### Acceptance Criteria:
- [ ] Visual check: Radiator appears in Room Palette with blue icon
- [ ] Interaction check: Place Radiator → heat decreases by -5
- [ ] Visual check: Adjacent weapon's red glow dims when cooled
- [ ] Manual test: Place Radiator at edge → heat decreases by -7 (edge bonus)
- [ ] Manual test: 6 Weapons (30 heat) + 2 Radiators (−10) = 20 net heat (safe)

### Shortcuts for This Phase:
- Fixed -5 cooling per radiator
- Edge bonus is simple +2 (not distance-based)
- Radiators cool all adjacent rooms equally (no prioritization)
- Radiators don't need power to function

---

## Feature 15.3: Overheat Combat Penalties

**Tests:** Q3 (Combat readable)
**Time:** 1.5 hours

### What Player Sees:

**In Combat:**
- If ship overheating (heat > 30): warning icon flashes
- Overheat effects applied each turn:
  - Weapons deal -25% damage (orange damage numbers)
  - Reactors power 1 fewer tile (power lines dim)
  - Small chance (10% per turn) random hot room takes 5 damage
- Heat damage notification: "Weapon overheated - 5 damage" (orange text)

### What Player Does:
- Launch overheating ship (35 heat) → see reduced damage output
- Watch weapon take random heat damage over time
- Redesign with Radiators → launch at 25 heat → full performance
- Balance risk: overheat for more firepower vs safe lower heat

### How It Works:

**Overheat Penalty Application:**
```
At each combat turn start:
  if net_heat > 30:
    overheat_amount = net_heat - 30 # Amount over threshold

    # Damage penalty
    for each weapon:
      weapon_damage *= (1 - 0.25) # 25% reduction

    # Power penalty
    for each reactor:
      reactor_range -= 1 # Powers 1 fewer tile

    # Random damage
    if random(0, 100) < (overheat_amount × 2): # 2% per point over
      random_hot_room = pick random weapon or reactor
      random_hot_room.take_damage(5)
      show_notification("Overheated - 5 damage")
```

**Visual Feedback:**
- Overheating weapons show orange damage numbers (not white)
- Dimmed power lines indicate reduced reactor range
- Heat damage uses orange "-5" numbers distinct from combat damage

### Acceptance Criteria:
- [ ] Manual test: Launch with 35 heat → weapons deal 7.5 damage (10 × 0.75)
- [ ] Visual check: Damage numbers appear in orange when overheating
- [ ] Manual test: Watch combat → see random weapon take 5 heat damage
- [ ] Manual test: Reactor range reduced → see previously powered room lose power
- [ ] Manual test: Launch with 28 heat → no penalties (under threshold)

### Shortcuts for This Phase:
- Linear penalty (not scaling with overheat amount)
- Random damage is uniform probability (not weighted by heat output)
- Heat doesn't increase mid-combat (fixed at design time)
- No emergency cooling or heat venting mechanics

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
- **RoomPalettePanel.tscn** (Phase 5) - Room selection UI
  - Contains 6 RoomTypeButton instances
  - Properties: selected_room_type
  - Signals: room_type_selected(room_type)
- **RoomTypeButton.tscn** (Phase 5) - Single room type in palette
  - Properties: room_type, cost, count, is_selected
  - Contains: icon, name label, cost label, count label, tooltip panel
- **ShipStatusPanel.tscn** (Phase 5) - Ship readiness display
  - Contains 3 StatusRow instances (Bridge, Budget, Power)
  - Updates in real-time as ship design changes

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

**Total Features:** 22 features across 5 phases

**Critical Path (Minimum Viable):**
- Phase 1: All features (need visual foundation)
- Phase 2: All features (need interactivity)
- Phase 3: Features 3.1, 3.2, 3.3, 3.5 (skip 3.4 if time-constrained)
- Phase 4: Features 4.2, 4.3 (skip 4.1 if time-constrained)
- Phase 5: Optional (game is playable without it, but UX is much better)

**Time Estimates:**
- **Must-Have:** 14.5 hours (Phases 1-3, skip 3.4, minimal Phase 4)
- **With Phase 4 Polish:** 18.5 hours (Phases 1-4 complete)
- **Full Roadmap:** 23 hours (all phases including Phase 5 UX polish)

**Testing the 5 Critical Questions:**
- Q1 (Design → iterate loop): Features 2.4, 3.1, 3.2, 3.5, 4.2, 5.1, 5.2, 5.3, 5.4, 5.5
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
