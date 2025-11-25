# Power System Development Roadmap
## Relay + Secondary Grid Architecture

---

## OVERVIEW

**Total Time Estimate:** 32-40 hours

**4 Development Phases:**
1. **Visual Layout** - See two-grid architecture (8-10 hours)
2. **Interactive** - Place relays and route power (10-12 hours)
3. **Systems** - Combat damage and failures (8-10 hours)
4. **Polish** - Validation and UX refinements (6-8 hours)

**Critical Questions We're Testing:**
- Can players understand the two-grid system (physical vs electrical)?
- Is relay placement strategic enough to matter?
- Can players diagnose power failures during combat?
- Does the overlay system clarify rather than confuse?
- Are power networks vulnerable enough to create tension?

---

## PHASE 1: Visual Foundation

**Goal:** Player can see the two-grid architecture and place relay modules

**Time:** 8-10 hours

---

### Feature 1.1: Two-Grid Data Structure

**Tests:** Can we separate physical placement from electrical routing?

**Time:** 2 hours

**What Player Sees:**
- Nothing changes visually yet
- All existing components still place normally

**What Player Does:**
- Places components exactly as before
- No new interactions yet

**How It Works:**
- Extract current grid into `MainGrid` class (physical components)
- Create `SecondaryGrid` class (virtual connections, no tile consumption)
- `MainGrid`: Stores reactors, relays, weapons, shields, armor, structure
- `SecondaryGrid`: Stores connections as arrays of tile positions
- Both grids reference same coordinate system
- Components check both grids for placement validity

**Acceptance Criteria:**
- [ ] Visual check: All existing components render at correct positions
- [ ] Interaction check: Click tile → can place component → appears on main grid
- [ ] Manual test: Place reactor, weapons, armor → all appear correctly, no errors

**Shortcuts for This Phase:**
- No secondary grid visualization yet
- No connection logic yet
- Just data structure separation

---

### Feature 1.2: Relay Module Component

**Tests:** Can relays exist as placeable modules on main grid?

**Time:** 1.5 hours

**What Player Sees:**
- New "RELAY" button in module palette (orange-yellow color)
- Relay count indicator shows "0" initially
- Relay displayed at right side of palette (after Conduit)

**What Player Does:**
- Click Relay button in palette
- Hover over grid → see 2×2 preview (orange-yellow)
- Click to place relay module
- Right-click to remove relay

**How It Works:**
- Relay defined in RoomData.gd: `RoomType.RELAY = 8`
- Size: 2×2 tiles (4 grid positions)
- Cost: 3 budget points
- Color: #FF8800 (orange) with #FFDD00 (yellow) center
- Relay.tscn: 2×2 ColorRect with gradient (orange border, yellow center)
- Label: "RELAY" in white text, 10pt font
- Same placement rules as other 2×2 modules

**Acceptance Criteria:**
- [ ] Visual check: Relay button visible in palette at correct position
- [ ] Visual check: Relay preview shows 2×2 orange-yellow module when hovering
- [ ] Interaction check: Click relay → click grid → relay appears orange-yellow
- [ ] Manual test: Place 5 relays, budget decreases by 15 points, count shows "5"

**Shortcuts for This Phase:**
- No coverage radius shown yet
- No power functionality yet
- No connections yet

---

### Feature 1.3: Coverage Radius Visualization

**Tests:** Can players understand relay coverage area?

**Time:** 2 hours

**What Player Sees:**
- When hovering over placed relay: Faint yellow circle appears (radius 3 tiles)
- Circle drawn on grid, centered on relay (2×2 module center)
- Coverage zone: #FFDD00 at 15% opacity
- Border: Thin yellow circle outline (2px)
- Circle appears only when hovering relay module

**What Player Does:**
- Hover over relay → see coverage zone
- Move mouse away → coverage zone fades
- Compare coverage zones of multiple relays
- Check if systems fall within coverage

**How It Works:**
- Relay tracks mouse hover state (mouse_entered signal)
- On hover: Calculate coverage zone (circle, radius = 3 tiles from center)
- Draw coverage as ColorRect or Polygon2D on overlay layer
- Coverage calculation: All tiles where `distance(tile, relay_center) <= 3.0`
- Relay center for 2×2 module: `(relay_x + 0.5, relay_y + 0.5)` in tile coordinates
- Fade in/out over 0.2 seconds using Tween

**Acceptance Criteria:**
- [ ] Visual check: Hover relay → see faint yellow circle (radius ~3 tiles)
- [ ] Visual check: Circle centered on relay's center (not top-left)
- [ ] Interaction check: Hover different relay → new circle appears
- [ ] Manual test: Place system 2 tiles from relay → check if inside circle (should be)

**Shortcuts for This Phase:**
- Coverage shown only on hover, not permanently
- No "powered" state visualization yet
- No power overlay toggle yet

---

### Feature 1.4: Power Overlay Toggle

**Tests:** Can players toggle between clean view and power network view?

**Time:** 2.5 hours

**What Player Sees:**
- New "POWER OVERLAY" toggle button in top-right UI (near zoom controls)
- Button states:
  - OFF: Gray background, "OVERLAY: OFF" text
  - ON: Yellow background, "OVERLAY: ON" text
- When overlay OFF: Clean main grid, no power indicators
- When overlay ON: All relay coverage zones visible permanently (not just on hover)

**What Player Does:**
- Click toggle button → overlay switches ON
- See all relay coverage zones appear
- Click toggle again → overlay switches OFF
- Coverage zones fade away

**How It Works:**
- Add `power_overlay_enabled: bool = false` to ShipDesigner
- Add Button node to ShipDesigner UI (positioned at top-right, below budget panel)
- Button connects to `_on_power_overlay_toggled()` function
- When enabled:
  - Iterate all placed relays
  - Show coverage zone for each relay (using Feature 1.3 logic)
  - Keep zones visible until overlay disabled
- When disabled:
  - Clear all coverage zone visuals
- Smooth transition: Fade coverage zones in/out over 0.3 seconds

**Acceptance Criteria:**
- [ ] Visual check: Toggle button visible at top-right corner
- [ ] Visual check: Button color changes gray ↔ yellow when clicked
- [ ] Interaction check: Click toggle → all relay coverage zones appear
- [ ] Manual test: Place 3 relays → toggle ON → see 3 yellow circles → toggle OFF → circles fade

**Shortcuts for This Phase:**
- No secondary grid connections shown yet
- No powered/unpowered states yet
- Just coverage zones

---

## PHASE 2: Interactive Power Network

**Goal:** Player can route power from reactors to relays and see which systems are powered

**Time:** 10-12 hours

---

### Feature 2.1: Secondary Grid Data Model

**Tests:** Can we store and query electrical connections?

**Time:** 2 hours

**What Player Sees:**
- Nothing changes visually
- Existing functionality still works

**What Player Does:**
- Same as before
- No new interactions

**How It Works:**
- Create `SecondaryGrid` class in `scripts/data/SecondaryGrid.gd`
- Data structure: `Dictionary<relay_id, Connection>`
- Connection: `{source_id: int, path: Array[Vector2i], is_powered: bool}`
- SecondaryGrid methods:
  - `add_connection(relay_id, source_id, path)`
  - `remove_connection(relay_id)`
  - `get_connection(relay_id) -> Connection`
  - `is_relay_powered(relay_id) -> bool`
  - `get_all_connections() -> Array[Connection]`
- ShipDesigner instantiates `SecondaryGrid` alongside `MainGrid`

**Acceptance Criteria:**
- [ ] Code check: SecondaryGrid class exists with required methods
- [ ] Code check: ShipDesigner creates SecondaryGrid instance in _ready()
- [ ] Manual test: Call add_connection() in test → connection stored → get_connection() returns it

**Shortcuts for This Phase:**
- No pathfinding yet (just store paths)
- No auto-routing yet
- Pure data structure

---

### Feature 2.2: Pathfinding Through Main Grid

**Tests:** Can we find safe routes from reactors to relays?

**Time:** 3 hours

**What Player Sees:**
- Nothing changes visually yet
- Console prints pathfinding results (debug only)

**What Player Does:**
- Same as before
- No new interactions

**How It Works:**
- Create `PowerPathfinder` class in `scripts/systems/PowerPathfinder.gd`
- Implements A* pathfinding on main grid tiles
- Traversable tiles: Empty, Structure, Armor, Relays, Reactors
- Blocked tiles: Weapons, Shields, Engines (too dense for wiring)
- Cost function:
  - Empty space: Cost 1.0
  - Structure: Cost 1.0 (preferred - protected route)
  - Armor: Cost 1.5 (safe but tight)
  - Reactor/Relay: Cost 1.0 (start/end points)
- Heuristic: Manhattan distance × 1.0
- `find_path(start: Vector2i, end: Vector2i, main_grid: MainGrid) -> Array[Vector2i]`
- Returns array of tile positions from start to end, or empty array if no path

**Acceptance Criteria:**
- [ ] Code check: PowerPathfinder class exists with find_path() method
- [ ] Manual test: Place reactor at (2,2), relay at (6,2) → find_path() returns [(2,2), (3,2), (4,2), (5,2), (6,2)]
- [ ] Manual test: Block path with weapon → find_path() routes around it

**Shortcuts for This Phase:**
- No visual rendering of paths yet
- No dynamic re-routing when grid changes
- Just static pathfinding algorithm

---

### Feature 2.3: Auto-Connect Relays to Reactors

**Tests:** Can relays automatically find and connect to power sources?

**Time:** 2.5 hours

**What Player Sees:**
- When overlay enabled: Yellow lines appear from reactors to relays
- Lines follow grid (not diagonal)
- Lines avoid weapons/shields/engines (route around them)

**What Player Does:**
- Place reactor on grid
- Place relay anywhere
- Relay automatically connects (yellow line appears in overlay)
- Move relay → connection updates

**How It Works:**
- On relay placement:
  - Find all reactors on main grid
  - Use PowerPathfinder to find path from nearest reactor to relay
  - If path found: Store in SecondaryGrid as connection
  - If no path: Relay remains unpowered (warning)
- On relay moved/removed:
  - Remove old connection from SecondaryGrid
  - Recalculate if relay still exists
- Connection visualization (when overlay enabled):
  - For each connection in SecondaryGrid:
    - Draw line segments between consecutive path tiles
    - Line color: #FFDD00 (yellow) if source is reactor, #444444 (gray) if no path
    - Line width: 2-3 pixels
    - Line opacity: 80%
    - Draw on overlay layer (above main grid, below coverage zones)

**Acceptance Criteria:**
- [ ] Visual check: Place reactor → place relay → yellow line connects them (overlay ON)
- [ ] Visual check: Line routes through empty space and structure tiles
- [ ] Interaction check: Block path with weapon → line re-routes around it
- [ ] Manual test: Place relay far from reactor (no path) → no yellow line, relay shows warning

**Shortcuts for This Phase:**
- Only connects to nearest reactor (no multi-source support yet)
- No manual routing override
- Auto-routes immediately on placement

---

### Feature 2.4: Powered State for Relays

**Tests:** Can relays know if they're receiving power?

**Time:** 1.5 hours

**What Player Sees:**
- Powered relays: Bright orange (#FF8800) with yellow center, subtle pulse glow
- Unpowered relays: Dim gray (#666666) with darker center, no pulse
- Overlay enabled: Powered relays have bright yellow connection lines, unpowered have gray lines

**What Player Does:**
- Place reactor → place relay → relay glows (powered)
- Remove reactor → relay dims (unpowered)
- Block connection path → relay dims (unpowered)

**How It Works:**
- SecondaryGrid tracks powered state per relay:
  - Relay is powered if: Has connection AND source is reactor AND path is valid
  - Valid path: All tiles in path still exist and are traversable
- Check powered state:
  - On placement/removal of any component
  - On any main grid change
  - Store result: `connection.is_powered = true/false`
- Visual update:
  - Powered: `relay.modulate = Color(1, 1, 1, 1)` + pulse animation (scale 1.0 ↔ 1.05 over 1 second loop)
  - Unpowered: `relay.modulate = Color(0.4, 0.4, 0.4, 1)` + no animation
  - Update whenever powered state changes

**Acceptance Criteria:**
- [ ] Visual check: Relay with valid connection glows orange-yellow
- [ ] Visual check: Relay without connection appears dim gray
- [ ] Interaction check: Remove reactor → all relays dim
- [ ] Manual test: Place relay → see glow → block its path with weapon → glow fades to gray

**Shortcuts for This Phase:**
- Only supports single reactor
- No power capacity tracking (100 units not enforced yet)
- Just binary powered/unpowered

---

### Feature 2.5: Powered State for Systems

**Tests:** Can systems know if they're within powered relay coverage?

**Time:** 2 hours

**What Player Sees:**
- Powered systems: Normal color + subtle green/yellow edge glow (1-2px border)
- Unpowered systems: Desaturated (-50%) + red "OFFLINE" label in top-left corner
- Glow/label only visible when overlay enabled (clean view when overlay OFF)

**What Player Does:**
- Enable overlay → see which systems are powered (green glow) vs unpowered (red OFFLINE)
- Place relay near unpowered system → system turns green
- Move relay away → system turns red + shows OFFLINE

**How It Works:**
- System powered check:
  - Iterate all placed relays
  - For each relay: Check if relay is powered (Feature 2.4)
  - If powered: Check if system center is within relay coverage radius (3 tiles)
  - System is powered if: Within coverage of ANY powered relay
- Coverage radius calculation:
  - Relay center: `(relay.x + relay.width/2, relay.y + relay.height/2)`
  - System center: `(system.x + system.width/2, system.y + system.height/2)`
  - Distance: `sqrt((system_center - relay_center).length_squared())`
  - Within coverage if: `distance <= 3.0`
- Visual update (when overlay enabled):
  - Powered: Add StyleBox border (1-2px, color #4AE24A - green-yellow)
  - Unpowered: Apply modulate (desaturate: Color(1, 1, 1, 1) → HSV saturation × 0.5), add Label "OFFLINE" in red (#E24A4A)
- Update whenever:
  - Relay placement/removal/movement
  - Powered state of any relay changes
  - System placement/removal/movement

**Acceptance Criteria:**
- [ ] Visual check: Overlay ON → systems near powered relays have green glow
- [ ] Visual check: Overlay ON → systems far from relays show red "OFFLINE" label
- [ ] Interaction check: Place relay near unpowered system → system glows green
- [ ] Manual test: Place 3 weapons → 1 relay → overlay ON → check only 2 weapons in radius glow green

**Shortcuts for This Phase:**
- Power capacity not enforced (relay can power unlimited systems)
- No combat functionality yet
- Just design-time visualization

---

## PHASE 3: Combat Integration

**Goal:** Power network responds to damage in combat

**Time:** 8-10 hours

---

### Feature 3.1: Relay Damage Model

**Tests:** Can relays be destroyed and lose power?

**Time:** 2 hours

**What Player Sees:**
- Relay has HP bar above module (like other systems)
- Relay HP: 50 points (50% of reactor's 100 HP)
- When hit: HP bar decreases, relay flashes red
- When destroyed: Explosion effect, relay disappears, coverage zone vanishes

**What Player Does:**
- Watch combat
- See enemy fire hit relay
- Relay HP decreases
- Relay explodes and disappears

**How It Works:**
- Relay component extends Room class (same as weapons, shields)
- Relay stats:
  - Max HP: 50
  - Armor: 0 (no damage reduction)
  - Size: 2×2 tiles
- Combat system treats relay as targetable module
- On relay destroyed:
  - Remove relay from MainGrid placed_rooms array
  - Remove all connections to/from relay in SecondaryGrid
  - Trigger relay explosion animation (particle effect, orange flash)
  - Update all system powered states (systems lose power if this was their only relay)
- Event log: "Relay at (X, Y) destroyed - N systems lost power"

**Acceptance Criteria:**
- [ ] Visual check: Relay shows HP bar in combat
- [ ] Visual check: Relay flashes red when hit
- [ ] Interaction check: Relay HP reaches 0 → explosion → relay disappears
- [ ] Manual test: Combat with 1 relay powering 2 weapons → relay destroyed → both weapons show OFFLINE

**Shortcuts for This Phase:**
- No partial damage effects (relay works at full capacity until destroyed)
- No repair mechanics
- Simple binary alive/destroyed

---

### Feature 3.2: Connection Path Damage

**Tests:** Can connections break when tiles are destroyed?

**Time:** 3 hours

**What Player Sees:**
- When tile on connection path is destroyed:
  - Connection line turns red briefly (0.5 seconds)
  - Line fades to gray (disconnected state)
  - Downstream relay loses glow (unpowered)
  - Systems covered by relay show OFFLINE

**What Player Does:**
- Watch combat
- Enemy destroys tile (armor, structure, empty space)
- If connection passes through that tile: Connection breaks
- Downstream relay and systems go offline

**How It Works:**
- Each connection stores: `{source_id, path: Array[Vector2i], is_powered}`
- On any tile destroyed in MainGrid:
  - Iterate all connections in SecondaryGrid
  - For each connection: Check if destroyed tile is in path array
  - If yes: Mark connection as broken (`is_powered = false`)
  - Update relay powered state (relay.is_powered = false)
  - Update all systems covered by this relay (powered = false)
  - Trigger visual effects: Connection line flash red → fade to gray, relay dim, systems show OFFLINE
- Path validation:
  - Check each tile in path: `main_grid.get_tile_at(pos).exists() AND is_traversable()`
  - If any tile invalid: Connection broken
- Event log: "Power connection severed at (X, Y) - Relay at (A, B) offline"

**Acceptance Criteria:**
- [ ] Visual check: Connection line turns red when tile in path destroyed
- [ ] Visual check: Relay loses glow when connection breaks
- [ ] Interaction check: Destroy tile on path → relay and systems go offline
- [ ] Manual test: Path through armor → armor destroyed → connection breaks → relay offline

**Shortcuts for This Phase:**
- No automatic re-routing (connection stays broken until redesign)
- No connection HP (path either exists or doesn't)
- Binary valid/broken

---

### Feature 3.3: Cascade Failure Visualization

**Tests:** Can players see power network failures propagate?

**Time:** 2 hours

**What Player Sees:**
- When relay destroyed or connection breaks:
  - Relay flashes yellow briefly (0.3 sec)
  - Coverage zone flickers and fades
  - All systems in coverage flash yellow (0.3 sec)
  - Systems turn gray with OFFLINE label
- Event log shows cascade:
  - "Relay at (5, 3) destroyed"
  - "Forward Weapons Array offline - no power"
  - "Shields offline - no power"

**What Player Does:**
- Watch combat unfold
- See visual feedback of power failures
- Read event log to understand what happened
- Assess damage severity

**How It Works:**
- On relay power lost (destroyed or connection broken):
  - Trigger relay flash animation (yellow glow, 0.3 sec)
  - Fade out coverage zone over 0.5 seconds
  - For each system in old coverage: Trigger system flash animation (yellow glow, 0.3 sec)
  - After flash: Apply unpowered visuals (desaturate, OFFLINE label)
  - Log events:
    - Relay event: "Relay at (%d, %d) destroyed/disconnected"
    - For each affected system: "%s offline - no relay coverage"
- Animation timing:
  - Relay flash: 0.0-0.3 sec
  - Coverage fade: 0.0-0.5 sec
  - System flash: 0.1-0.4 sec (slight delay for cascade feel)
  - System offline visuals: 0.4 sec (after flash)
- Queue animations so player can follow sequence

**Acceptance Criteria:**
- [ ] Visual check: Relay destroyed → yellow flash → coverage fades → systems flash yellow → gray
- [ ] Visual check: Event log shows relay destroyed, then systems offline
- [ ] Interaction check: Destroy connection tile → see cascade visuals
- [ ] Manual test: 1 relay powering 4 systems → relay destroyed → see 4 systems flash and go offline in sequence

**Shortcuts for This Phase:**
- Linear animation queue (no parallel cascades for now)
- Simple timing (not physics-based propagation)
- Event log limited to 10 most recent events

---

### Feature 3.4: Combat Power Overlay Auto-Enable

**Tests:** Is power state visible during combat by default?

**Time:** 1 hour

**What Player Sees:**
- Combat starts → power overlay automatically ON
- See all relay coverage, connections, powered states
- Can toggle overlay OFF if desired (button still works)
- Combat ends → overlay state preserved into next combat

**What Player Does:**
- Enter combat → see power overlay immediately
- Toggle OFF if want clean view
- Toggle back ON to check power state
- Leave combat → next combat starts with overlay ON again

**How It Works:**
- Combat scene initialization:
  - In `Combat._ready()` or `start_combat()`:
  - Set `ship_designer.power_overlay_enabled = true`
  - Call `ship_designer._on_power_overlay_toggled()` to show overlays
- Store preference:
  - GameState variable: `combat_power_overlay_default: bool = true`
  - Load in combat start, save on combat end
- Toggle button still functional:
  - Player can disable if desired
  - Preference saved for next combat

**Acceptance Criteria:**
- [ ] Visual check: Start combat → overlay already ON
- [ ] Visual check: Coverage zones and connections visible immediately
- [ ] Interaction check: Toggle OFF → overlay hides → toggle ON → overlay shows
- [ ] Manual test: Combat → toggle OFF → end combat → start new combat → overlay ON again

**Shortcuts for This Phase:**
- Overlay always ON by default (no per-battle persistence)
- Can't set default in options menu (hardcoded ON for combat)
- Designer scene starts with overlay OFF (only combat auto-enables)

---

## PHASE 4: Polish & Validation

**Goal:** System feels smooth, clear, and helps player make good design decisions

**Time:** 6-8 hours

---

### Feature 4.1: Design-Time Validation Checks

**Tests:** Can the system prevent invalid ship designs from launching?

**Time:** 2 hours

**What Player Sees:**
- Validation panel (existing panel, new checks added)
- Red X or checkmark icons next to each validation rule
- Critical errors (red):
  - "No reactor placed - ship has no power generation"
  - "Relay at (X, Y) has no power connection to reactor"
  - "System [Name] at (X, Y) outside all relay coverage zones"
- Launch button disabled if any critical errors exist

**What Player Does:**
- Attempt to launch ship
- See validation errors if ship invalid
- Fix errors (add reactor, add relay, move system)
- Launch button enables when valid

**How It Works:**
- Validation runs on:
  - Any component placement/removal
  - Relay connection changes
  - Launch button pressed
- Validation checks:
  - `has_reactor()`: Check if placed_rooms contains at least one REACTOR
  - `all_relays_connected()`: For each relay, check if SecondaryGrid has valid connection
  - `all_systems_covered()`: For each system (weapon, shield, engine), check if within coverage of any powered relay
- Store results: `Array<ValidationError>` with `{type: ErrorType, message: String, position: Vector2i}`
- Display in validation panel:
  - Red X icon + message for each error
  - Green checkmark if no errors
- Launch button:
  - `launch_button.disabled = !validation_results.is_empty()`

**Acceptance Criteria:**
- [ ] Visual check: No reactor → validation shows "No reactor placed" in red
- [ ] Visual check: Relay far from reactor → validation shows "Relay has no connection"
- [ ] Interaction check: System outside coverage → validation shows "System outside coverage"
- [ ] Manual test: Fix all errors → launch button enables → can launch ship

**Shortcuts for This Phase:**
- No warning level (only critical errors that prevent launch)
- No auto-fix suggestions
- Basic text messages only (no visual indicators on grid)

---

### Feature 4.2: Design-Time Warnings (Non-Blocking)

**Tests:** Can the system warn about risky designs without preventing launch?

**Time:** 1.5 hours

**What Player Sees:**
- Validation panel shows warnings (yellow triangle icon):
  - "Relay at (X, Y) has only one power connection (single point of failure)"
  - "Systems [A, B, C] share only one relay (vulnerable to relay loss)"
  - "Power generation (100) exceeds typical consumption - consider removing reactor"
- Launch button remains enabled (warnings don't block)
- Warnings can be ignored

**What Player Does:**
- See warnings about design risks
- Decide whether to fix or accept risk
- Can launch ship with warnings present
- Can ignore warnings if desired

**How It Works:**
- Warning checks (run after validation):
  - `check_single_point_failure()`: For each relay, check if only one connection path exists
  - `check_relay_redundancy()`: For each system, count how many relays cover it (warn if only 1)
  - `check_power_generation()`: Sum reactor power (100 per reactor), compare to typical load (warn if excess)
- Store results: `Array<ValidationWarning>` with `{message: String, severity: WarningSeverity}`
- Display in validation panel:
  - Yellow triangle icon + message
  - Separate section below errors
  - Expandable/collapsible warnings list
- Launch button:
  - Enabled even if warnings exist
  - Warnings just informational

**Acceptance Criteria:**
- [ ] Visual check: 1 relay with 1 connection → warning shows "single point of failure"
- [ ] Visual check: 3 systems near 1 relay → warning shows "systems share only one relay"
- [ ] Interaction check: Warnings present → can still click launch → ship launches
- [ ] Manual test: Add second relay to cover systems → warning disappears

**Shortcuts for This Phase:**
- No severity levels (all warnings same priority)
- No warning dismiss/ignore feature
- Simple text warnings only

---

### Feature 4.3: Relay Hover Details Panel

**Tests:** Can players get detailed info about relay state?

**Time:** 1.5 hours

**What Player Sees:**
- Hover over relay → small panel appears near cursor
- Panel shows:
  - "RELAY at (X, Y)"
  - "Status: POWERED" (green) or "OFFLINE" (red)
  - "Connection: Reactor at (A, B)" or "No connection"
  - "Systems Covered: 3"
  - List of covered system names
- Panel follows cursor with slight offset (10-20px)
- Panel fades in/out smoothly (0.2 sec)

**What Player Does:**
- Hover relay → read status and coverage info
- Move mouse → panel follows
- Move away from relay → panel fades out

**How It Works:**
- Relay MouseEnter signal:
  - Show details panel (Panel node, positioned near cursor)
  - Populate fields:
    - Position: relay.grid_position
    - Status: relay.is_powered ? "POWERED" (green) : "OFFLINE" (red)
    - Connection: Get from SecondaryGrid, show source reactor position
    - Coverage: Count systems within 3-tile radius
    - System list: Names of all systems in coverage
  - Panel z_index = 100 (draw on top)
- Relay MouseMove signal:
  - Update panel position to follow cursor (cursor_pos + Vector2(20, 20))
- Relay MouseExit signal:
  - Fade out panel over 0.2 seconds
  - Hide panel after fade

**Acceptance Criteria:**
- [ ] Visual check: Hover relay → panel appears showing status and coverage
- [ ] Visual check: Panel shows "POWERED" in green if connected to reactor
- [ ] Interaction check: Move mouse while hovering → panel follows cursor
- [ ] Manual test: Relay covering 2 weapons → panel lists both weapon names

**Shortcuts for This Phase:**
- No click-to-pin panel (only hover)
- No connection path highlight on hover
- Basic panel styling (no fancy graphics)

---

### Feature 4.4: Connection Line Visual Polish

**Tests:** Does the power network feel alive and clear?

**Time:** 2 hours

**What Player Sees:**
- Connection lines have smooth appearance:
  - Powered: Bright yellow (#FFDD00) with subtle pulse glow
  - Unpowered: Dark gray (#444444) solid
  - Broken: Red (#E24A4A) flash → fade to gray
- Lines have slight thickness variation (2-3px, thicker when powered)
- Pulse animation: Brightness oscillates 80% ↔ 100% over 2 seconds
- Lines drawn with antialiasing (smooth, not jagged)

**What Player Does:**
- Enable overlay → see smooth, glowing connection lines
- Watch powered lines pulse gently
- See immediate visual feedback when connections break

**How It Works:**
- Connection rendering:
  - Use `draw_line()` in _draw() function with antialiased flag
  - Line segments: For each pair of consecutive path tiles, draw line from center to center
  - Line color:
    - Powered: `Color(1.0, 0.87, 0.0, 0.8)` (yellow, 80% opacity) × brightness_factor
    - Unpowered: `Color(0.27, 0.27, 0.27, 0.8)` (gray)
    - Broken: `Color(0.89, 0.29, 0.29, 1.0)` (red) for 0.5 sec, then fade to gray
  - Line width: Powered = 3px, Unpowered = 2px
- Pulse animation:
  - Brightness factor: `lerp(0.8, 1.0, sin(time * PI) * 0.5 + 0.5)`
  - Update in _process() every frame
  - Only pulse powered connections
- Smooth transitions:
  - When connection breaks: Tween color from yellow to red (0.2 sec), red to gray (0.5 sec)
  - When connection established: Tween color from gray to yellow (0.3 sec)

**Acceptance Criteria:**
- [ ] Visual check: Powered connection lines glow with smooth pulse
- [ ] Visual check: Lines are smooth, not pixelated
- [ ] Interaction check: Break connection → see red flash → fade to gray
- [ ] Manual test: Enable overlay → lines look polished and alive, not static

**Shortcuts for This Phase:**
- No animated "flow" effect (just brightness pulse)
- No particle effects along lines
- Simple color transitions only

---

### Feature 4.5: Tutorial Hints System

**Tests:** Can new players understand relay placement without frustration?

**Time:** 1.5 hours

**What Player Sees:**
- First time placing relay: Tooltip appears
  - "Relays distribute power to nearby systems (3-tile radius)"
  - "Systems must be within a powered relay's coverage to function"
  - "Click [OVERLAY] button to see coverage zones"
- First time seeing unpowered system: Tooltip appears
  - "This system is OFFLINE - no relay coverage"
  - "Place a relay within 3 tiles to power this system"
- Tooltips have "Got it" button to dismiss
- Tooltips don't reappear once dismissed (saved in GameState)

**What Player Does:**
- Place first relay → read tooltip → click "Got it"
- See unpowered system → read tooltip → click "Got it"
- Tooltips won't show again in future sessions

**How It Works:**
- GameState tracks tutorial steps:
  - `tutorial_relay_placement_shown: bool = false`
  - `tutorial_unpowered_system_shown: bool = false`
- On relay placement:
  - Check `!GameState.tutorial_relay_placement_shown`
  - If true: Show tooltip panel near relay with message
  - Panel has "Got it" button
  - Button pressed: `GameState.tutorial_relay_placement_shown = true`, hide panel
- On system unpowered (first time):
  - Check `!GameState.tutorial_unpowered_system_shown`
  - If true: Show tooltip panel near system with message
  - Same "Got it" button logic
- Tooltip panel:
  - Panel node with Label + Button
  - Position near target component (offset 50px right)
  - Auto-hide after 10 seconds if not clicked
  - Arrow pointing at target component (visual guide)

**Acceptance Criteria:**
- [ ] Visual check: Place first relay → tooltip appears explaining coverage
- [ ] Visual check: Tooltip has "Got it" button and arrow pointing at relay
- [ ] Interaction check: Click "Got it" → tooltip disappears
- [ ] Manual test: Place relay → dismiss tooltip → place second relay → no tooltip

**Shortcuts for This Phase:**
- Only 2 tutorial tooltips (relay placement, unpowered system)
- No multi-step tutorial sequence
- No "skip all tutorials" option
- Simple text tooltips, no images

---

## SUCCESS METRICS

After implementing all phases, validate the following:

### Usability Validation
- [ ] New player can place relay and understand its coverage within 2 minutes
- [ ] Player can diagnose power failure in combat within 10 seconds (overlay enabled)
- [ ] Player can identify single point of failure in design before launch
- [ ] Overlay toggle feels responsive (<0.3 sec transition)

### Gameplay Validation
- [ ] Power network vulnerability creates strategic tension in combat
- [ ] Relay placement requires trade-offs (coverage vs protection vs space)
- [ ] Losing relay creates meaningful cascade (2-4 systems offline typically)
- [ ] Redundant power networks are buildable but costly (15-25% of budget)

### Technical Validation
- [ ] Pathfinding completes in <50ms for typical grid (8×8 to 10×10)
- [ ] Overlay rendering maintains 60 FPS with 10+ relays and connections
- [ ] Power state updates in <16ms when component destroyed
- [ ] No visual glitches when toggling overlay rapidly

### Balance Validation
- [ ] Relay cost (3 BP) feels appropriate for coverage provided
- [ ] Relay HP (50) survives 2-3 hits from typical enemy weapons
- [ ] 3-tile coverage radius requires 2-4 relays for typical ship
- [ ] Power generation (100 per reactor) supports 8-12 active systems

---

## KNOWN RISKS & MITIGATION

**Risk:** Two-grid system too complex for casual players
**Mitigation:** Auto-routing + tutorial tooltips + clear overlay visualization

**Risk:** Pathfinding performance degrades with large grids
**Mitigation:** Cache paths, only recalculate on grid topology changes, use A* early exit

**Risk:** Overlay clutter with many relays
**Mitigation:** Smooth fade in/out, subtle colors (15% opacity), option to disable

**Risk:** Players ignore power system until combat failure
**Mitigation:** Design-time validation, warnings about coverage gaps, tutorial prompts

**Risk:** Relay destruction feels arbitrary/unfair
**Mitigation:** Clear HP bars, cascade animation shows cause/effect, event log explains what happened

---

*Roadmap prepared for incremental development - each feature delivers visible, testable progress*
