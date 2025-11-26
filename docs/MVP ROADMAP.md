# MVP Feature Roadmap

**Project:** Starship Designer
**Status:** Active Development
**Last Updated:** November 26, 2024

This document contains feature specifications for MVP development. Each feature follows the standard specification format for clear implementation guidance.

---

# Component-Specific Targeting

**Total Time Estimate:** 5-7 hours
**Tests Critical Questions:** Q3 (Combat readable), Q2 (Placement strategic)

---

## Feature 1: Target Selection System

**Tests:** Q3 (Combat readable), Q2 (Placement strategic)
**Time:** 2 hours

### What Player Sees:
- **During combat:** Brief targeting line (2px yellow line) appears from attacker to specific target component (0.2s duration)
- **Hit component:** Target component flashes white (2 flashes) before damage animation
- **Combat log:** New line shows "Enemy [Type] targets your [Component]" in white text
- **Visual state:** Same position as existing combat UI, log panel bottom-left

### What Player Does:
- **Watch combat:** Player sees enemy deliberately targeting specific components (not random anymore)
- **Read log:** Player understands which systems are being attacked
- **Notice patterns:** After 2-3 combats, player recognizes enemy targeting preferences
- **Adjust designs:** Player moves critical components to safer positions

### How It Works:
**Core Logic:**
1. When weapon fires, instead of random component, select target based on priority
2. Enemy weapons have targeting priority: WEAPONS_FIRST, POWER_FIRST, or RANDOM
3. Filter available components by priority (e.g., WEAPONS_FIRST only considers enemy weapon rooms)
4. If priority list is empty, fall back to random selection
5. Draw targeting line from attacker center to target component center
6. Apply damage to selected component (existing damage system)

**Targeting Priorities:**
- WEAPONS_FIRST: Target enemy weapons (disarm threat)
- POWER_FIRST: Target reactors/relays (cripple ship)
- RANDOM: Any component (current behavior)

**Enemy Type Mapping:**
- Mission 0 (Scout): RANDOM (tutorial, predictable)
- Mission 1 (Raider): WEAPONS_FIRST (aggressive)
- Mission 2 (Dreadnought): POWER_FIRST (tactical)

### Acceptance Criteria:
- [ ] Visual check: See yellow targeting line appear briefly when enemy fires
- [ ] Visual check: Target component flashes white before damage
- [ ] Interaction check: Combat log shows "Enemy Raider targets your Weapon" messages
- [ ] Manual test: Fight Raider (Mission 1) with 3 weapons → enemy prioritizes destroying weapons first
- [ ] Manual test: Fight Dreadnought (Mission 2) with 2 reactors → enemy targets reactors/relays first
- [ ] Manual test: If no priority targets exist, enemy still hits something (fallback works)

### Shortcuts for This Phase:
- Hard-code 3 priority types (don't make it data-driven yet)
- Simple line drawing (no arc or animated beam)
- Target line disappears instantly (no fade-out animation)
- Don't calculate line-of-sight or armor blocking yet (always hit selected target)
- Combat log shows targeting, but don't add filtering/search

---

## Feature 2: Component Exposure & Protection

**Tests:** Q2 (Placement strategic), Q4 (Budget trade-offs)
**Time:** 2.5 hours

### What Player Sees:
**In Combat:**
- **Exposed components:** Edge components get hit more often (observable pattern over multiple fights)
- **Protected components:** Interior components targeted less frequently
- **Armor shields:** When armor adjacent to target, damage message shows "Armor absorbs hit!"

**In Designer (Future Enhancement - Phase 2):**
- **Exposure overlay:** Toggle button shows color-coded exposure levels
  - Red tiles: High exposure (hull edge)
  - Yellow tiles: Medium exposure (1 tile from edge)
  - Green tiles: Low exposure (2+ tiles interior)

### What Player Does:
- **Notice vulnerability:** After losing edge-mounted reactors repeatedly, player learns placement matters
- **Bury critical systems:** Player places reactor/bridge in ship interior
- **Use armor tactically:** Player places armor adjacent to critical components
- **Iterate designs:** Player redesigns after seeing which components die first

### How It Works:
**Exposure Calculation:**
1. For each component, calculate distance to nearest hull edge
2. Edge (0 tiles away): High exposure = +20% targeting weight
3. Near-edge (1 tile away): Medium exposure = Normal targeting weight
4. Interior (2+ tiles away): Low exposure = -20% targeting weight
5. When selecting target, multiply base chance by exposure modifier

**Armor Protection Logic:**
1. After selecting target component, check adjacent tiles for armor
2. If armor found adjacent to target, 50% chance armor absorbs hit instead
3. Damage goes to armor component, not original target
4. Combat log shows "Armor protects [Component]!"

**Exposure Formula:**
```
exposure_modifier = 1.0
if distance_to_edge == 0: exposure_modifier = 1.2
elif distance_to_edge >= 2: exposure_modifier = 0.8

target_weight = base_priority * exposure_modifier
```

### Acceptance Criteria:
- [ ] Manual test: Place reactor on ship edge → gets targeted more frequently than interior reactor
- [ ] Manual test: Place reactor 3 tiles from edge → survives longer than edge reactor
- [ ] Manual test: Place armor adjacent to weapon → some hits absorbed by armor instead
- [ ] Visual check: Combat log shows "Armor protects Weapon!" messages
- [ ] Manual test: Fight 5 times with edge reactor vs 5 times with interior reactor → interior survives ~30% more often

### Shortcuts for This Phase:
- Simple distance-to-edge calculation (Manhattan distance, not true shortest path)
- Only check 4 adjacent tiles for armor (not diagonal)
- 50% armor block chance (don't make it depend on armor count)
- Don't add exposure overlay to designer yet (defer to polish phase)
- Don't weight targeting by component size (all components equal weight for now)

---

## Feature 3: Enhanced Visual Feedback

**Tests:** Q3 (Combat readable), Q5 (Engineering fantasy)
**Time:** 1.5 hours

### What Player Sees:
- **Targeting beam:** Yellow line animates from attacker → target (0.3s duration, fades out)
- **Target locked:** Small crosshair sprite appears over target component (0.2s before hit)
- **Hit feedback:** Larger flash + "CRITICAL" text if hitting a power/weapon component
- **Combat log colors:**
  - Red text: "Enemy targets your Reactor" (critical system)
  - Yellow text: "Enemy targets your Weapon" (important system)
  - White text: "Enemy targets your Armor" (expendable)
- **Pause option:** "PAUSE" button appears during combat (player can read log at own pace)

### What Player Does:
- **Watch beam:** Player follows visual line to see what enemy is aiming at
- **Read critical hits:** Player immediately notices when reactor/bridge targeted
- **Use pause:** Player clicks PAUSE to read combat log details mid-fight
- **Learn patterns:** After 3 fights, player predicts enemy targeting from beam direction

### How It Works:
**Beam Animation:**
1. Create Line2D from attacker center to target center
2. Animate alpha: 0 → 1.0 over 0.1s, hold at 1.0 for 0.2s, fade 1.0 → 0 over 0.1s
3. Width = 3px, color = yellow #FFDD00

**Crosshair Indicator:**
1. Small sprite (16×16px) with crosshair icon
2. Position = target component center
3. Appears 0.2s before damage applied
4. Disappears after damage flash

**Critical System Detection:**
- If target is REACTOR or BRIDGE or RELAY: show "CRITICAL" red text above component
- If target is WEAPON or SHIELD: show "HIT" yellow text
- If target is ARMOR or CONDUIT: show "DAMAGE" white text

**Combat Log Colors:**
- Add theme color overrides to RichTextLabel
- Use BBCode: `[color=red]Enemy targets your Reactor[/color]`

### Acceptance Criteria:
- [ ] Visual check: See animated yellow beam from enemy to target component
- [ ] Visual check: Small crosshair appears over target 0.2s before hit
- [ ] Visual check: "CRITICAL" red text appears when reactor/bridge hit
- [ ] Visual check: Combat log shows red text for critical systems, yellow for weapons/shields
- [ ] Interaction check: Click PAUSE button → combat freezes, can read log
- [ ] Manual test: Watch 3 consecutive fights → can predict which component will be hit by watching beam

### Shortcuts for This Phase:
- Crosshair is simple sprite (not animated spinning)
- Beam is straight line (no arc or laser effect)
- Pause stops all animation (don't add step-by-step controls)
- Critical text appears above component (don't add dramatic screen shake)
- Combat log doesn't save history (clears each fight)

---

## Feature 4: Combat Zoom Controls

**Tests:** Q3 (Combat readable), Q5 (Engineering fantasy)
**Time:** 1 hour

### What Player Sees:
- **Zoom buttons** in top-right corner (40×40px each):
  - "+" button (zoom in)
  - "−" button (zoom out)
  - Current zoom level: "100%" displayed between buttons
- **Mouse wheel** also controls zoom (scroll up = zoom in, scroll down = zoom out)
- **Zoom levels:** 50%, 75%, 100%, 125%, 150% (5 steps)
- **Ships scale** smoothly when zooming in/out
- **Camera pans** to keep focused ship centered when zooming

### What Player Does:
- **Scroll mouse wheel** up/down to zoom in/out during combat
- **Click + button** to zoom in one step (100% → 125%)
- **Click − button** to zoom out one step (125% → 100%)
- **See larger details** at 150% zoom (individual room damage visible)
- **See full battlefield** at 50% zoom (both ships visible at once)

### How It Works:
**Zoom Levels:**
- 50% = 0.5x scale (far view, see whole battlefield)
- 75% = 0.75x scale
- 100% = 1.0x scale (default, current view)
- 125% = 1.25x scale
- 150% = 1.5x scale (close view, see room details)

**Zoom Application:**
1. Current zoom stored as float: current_zoom = 1.0
2. On zoom in: current_zoom = min(1.5, current_zoom + 0.25)
3. On zoom out: current_zoom = max(0.5, current_zoom - 0.25)
4. Apply to camera: camera.zoom = Vector2(current_zoom, current_zoom)
5. Smooth tween over 0.2s for visual polish

**Mouse Wheel:**
- _input(event) captures InputEventMouseButton
- If event.button_index == MOUSE_BUTTON_WHEEL_UP: zoom in
- If event.button_index == MOUSE_BUTTON_WHEEL_DOWN: zoom out

**Camera Centering:**
- When zooming, keep center point between both ships
- Calculate midpoint = (player_ship.position + enemy_ship.position) / 2
- Camera focuses on midpoint, so both ships stay visible

### Acceptance Criteria:
- [ ] Interaction check: Scroll mouse wheel up → camera zooms in smoothly
- [ ] Interaction check: Scroll mouse wheel down → camera zooms out smoothly
- [ ] Interaction check: Click + button 2 times → zoom goes from 100% → 125% → 150%
- [ ] Interaction check: Click − button at 150% → zoom returns to 125%
- [ ] Visual check: At 150% zoom, can clearly see individual room damage/destruction
- [ ] Visual check: At 50% zoom, both ships fully visible on screen
- [ ] Manual test: Zoom during active combat → combat continues, animations still play correctly
- [ ] Visual check: Zoom level text updates to show current percentage

### Shortcuts for This Phase:
- Fixed zoom steps (don't allow free zoom between steps)
- Simple button sprites (use + and − text, not custom icons)
- Don't save zoom preference (resets to 100% each battle)
- Don't add keyboard shortcuts (+ and − keys) yet
- Camera centers on midpoint (don't add manual camera panning yet)
- Zoom affects entire combat scene (don't zoom ships independently)

---

## IMPLEMENTATION ORDER

**Day 1 (2.5 hours):**
1. Feature 1 basic targeting (1.5h)
2. Combat log integration (0.5h)
3. Test with all 3 missions (0.5h)

**Day 2 (2 hours):**
1. Feature 2 exposure calculation (1h)
2. Feature 2 armor protection (1h)

**Day 3 (2.5 hours):**
1. Feature 3 visual feedback (1h)
2. Feature 4 zoom controls (1h)
3. Polish & balance testing (0.5h)

---

## SUCCESS METRICS

After implementation, test 5 critical questions:

1. **Can player explain why they lost?** → "Enemy kept hitting my reactor" (not "bad luck")
2. **Does placement feel strategic?** → Player moves reactor from edge to interior
3. **Is armor now valuable?** → Player adds armor around critical components
4. **Is combat more readable?** → Player follows targeting beams, understands flow
5. **Does redundancy matter?** → Player adds backup reactors/weapons

**Target:** All 5 questions score 4+/5 after feature complete

---

## FUTURE ENHANCEMENTS (Out of Scope)

- ❌ Line-of-sight blocking (components behind others harder to hit)
- ❌ Component size weighting (larger components easier to hit)
- ❌ Player weapon targeting control (player chooses enemy targets)
- ❌ Exposure overlay in designer (show risk levels before combat)
- ❌ Targeting AI learning (enemy adapts to player strategy)

These defer to post-prototype or full game development.

---

# Post-Battle Replay

**Total Time Estimate:** 8-12 hours
**Tests Critical Questions:** Q1 (Design → iterate loop), Q3 (Combat readable)

**Purpose:** Allow players to review completed battles, scrub through timeline, and understand exactly what happened and when. Answers "why did I lose?" with clear visual evidence. Drives informed iteration on ship design.

---

## Feature 1: State Capture & Replay Data

**Tests:** Q1 (Design → iterate loop), Q3 (Combat readable)
**Time:** 1.5 hours

### What Player Sees:
- **No visible change during combat** - state capture happens invisibly
- **New "View Replay" button** appears on victory/defeat screen (150×50px, bottom-right of result overlay)

### What Player Does:
- **Finish battle** as normal
- **See result screen** with new "View Replay" option
- **Click "View Replay"** to enter replay mode

### How It Works:
**State Capture During Combat:**
1. At end of each turn, snapshot ship states:
   - Each component: room_id, HP, powered status, destroyed flag
   - Player and enemy ships separately
2. Store events from turn:
   - "Enemy Raider targets your Weapon"
   - "Weapon Alpha destroyed - 30 damage"
   - "Reactor offline - no power"
3. Bundle all snapshots into BattleResult resource
4. Save BattleResult with battle outcome

**Data Structure:**
```
BattleResult:
  - total_turns: int
  - turn_snapshots: Array[TurnSnapshot]
  - player_won: bool

TurnSnapshot:
  - turn_number: int
  - player_ship_state: Dictionary (room_id → {hp, powered, destroyed})
  - enemy_ship_state: Dictionary
  - events: Array[String]
```

**Storage:**
- Typical battle: 20-40 turns
- ~50 components per ship
- Lightweight data (~5-10KB per battle)

### Acceptance Criteria:
- [ ] Manual test: Fight a battle → check console shows "Captured state for Turn X" messages
- [ ] Manual test: Win/lose battle → see "View Replay" button on result screen
- [ ] Visual check: Button is gray/disabled initially (replay scene not built yet)

### Shortcuts for This Phase:
- Store full state every turn (don't delta-compress)
- Simple Dictionary structure (not custom Resource classes)
- Don't persist to disk yet (just in-memory for current session)
- Don't worry about large battles (assume <50 turns)

---

## Feature 2: Timeline Bar & Scrubbing

**Tests:** Q1 (Design → iterate loop), Q3 (Combat readable)
**Time:** 2 hours

### What Player Sees:
- **Timeline bar** at bottom of screen (1800×50px, positioned 60px from bottom)
- **Horizontal bar** showing full battle duration (Turn 1 to final turn)
- **Playhead** - vertical line with draggable handle (4px wide, yellow #FFDD00)
- **Turn labels** below bar: "Turn 1", "Turn 5", "Turn 10", etc.
- **Background** - dark gray (#2C2C2C) with lighter gray (#4C4C4C) fill showing progress

### What Player Does:
- **Click anywhere** on timeline bar → playhead jumps to that position
- **Drag playhead** left/right → scrub through battle turns
- **See turn number** update in real-time as playhead moves
- **Release mouse** → ship states update to show selected turn

### How It Works:
**Timeline Calculation:**
1. Bar width = 1800px
2. Total turns = battle_result.total_turns (e.g., 15)
3. Pixels per turn = 1800 / 15 = 120px
4. Click position X → turn = int(X / 120)
5. Update playhead position and current turn index

**Scrubbing Logic:**
1. Mouse down on playhead → start drag
2. Mouse move → update playhead.position.x (clamped to bar bounds)
3. Calculate current_turn from position
4. Mouse up → emit signal "turn_changed(current_turn)"

**Responsive Updates:**
- Update current turn label every frame while dragging
- Ship state updates only on mouse release (not every pixel, too expensive)

### Acceptance Criteria:
- [ ] Visual check: See timeline bar at bottom with playhead at start (Turn 1)
- [ ] Interaction check: Click middle of bar → playhead jumps to that position
- [ ] Interaction check: Drag playhead left/right → see turn number update smoothly
- [ ] Manual test: Drag from Turn 1 to Turn 15 → playhead moves smoothly across full bar
- [ ] Manual test: Release at Turn 7 → playhead stays at Turn 7

### Shortcuts for This Phase:
- No markers on timeline yet (just the bar and playhead)
- Linear timeline (don't compress/expand based on event density)
- No tooltip on hover showing turn details
- Snap to full turns (don't show fractional turns like "Turn 4.5")

---

## Feature 3: Ship State Display & Replay Scene

**Tests:** Q3 (Combat readable)
**Time:** 2.5 hours

### What Player Sees:
- **Replay screen** with familiar combat layout (same as Combat.tscn)
- **Both ships** visible (player left, enemy right) showing state at selected turn
- **Components** appear/disappear as playhead moves (destroyed components gray/wrecked)
- **Health bars** update to reflect HP at selected turn
- **Turn indicator** shows "REPLAY - Turn X / Y" at top-center

### What Player Does:
- **Scrub timeline** → watch components get destroyed/appear
- **See ship evolution** as battle progressed turn by turn
- **Identify failure points** - "Ah, reactor died Turn 8, that's when I lost power"

### How It Works:
**Replay Scene Architecture:**
- New scene: BattleReplay.tscn (similar to Combat.tscn but read-only)
- Reuses ShipDisplay component from combat
- Loads BattleResult passed from victory/defeat screen

**State Rendering:**
1. When turn_changed(turn_num) signal received:
2. Get turn_snapshot = battle_result.turn_snapshots[turn_num]
3. Update player_ship_display:
   - For each room_id in turn_snapshot.player_ship_state:
   - If destroyed: show gray/wrecked sprite
   - If powered: normal colors
   - If unpowered: gray overlay
4. Repeat for enemy_ship_display
5. Update health bars to show HP at that turn

**Scene Transition:**
- Combat → Victory/Defeat screen (stores BattleResult)
- Click "View Replay" → load BattleReplay.tscn
- Pass BattleResult to replay scene via start_replay(battle_result) function

### Acceptance Criteria:
- [ ] Manual test: Fight battle with component destruction → click View Replay
- [ ] Visual check: See replay screen with ships at Turn 1 state (all components intact)
- [ ] Interaction check: Drag timeline to Turn 10 → see components destroyed up to Turn 10 appear gray
- [ ] Interaction check: Drag back to Turn 5 → see components restored (not yet destroyed)
- [ ] Visual check: Health bars update as timeline scrubs (shows HP at that turn)

### Shortcuts for This Phase:
- Ships are static (no attack animations during replay)
- No "play" button yet (scrubbing only)
- Don't show power routing lines (just powered/unpowered colors)
- Use same scale/positioning as combat scene
- Zoom controls from Feature 4 (Combat Zoom) work in replay too

---

## Feature 4: Playback Controls

**Tests:** Q1 (Design → iterate loop)
**Time:** 1.5 hours

### What Player Sees:
- **Control bar** next to timeline (centered, 300×50px)
- **Buttons in row:**
  - "⏮ Start" (jump to Turn 1)
  - "◀ Prev" (previous turn)
  - "▶ Play/Pause" (auto-advance through turns)
  - "▶▶ Next" (next turn)
  - "⏭ End" (jump to final turn)
  - "Speed: 1x" (cycle: 0.5x → 1x → 2x)
- **Button colors:** Blue (#4A90E2) when idle, cyan (#4AE2E2) when hovered

### What Player Does:
- **Click ◀/▶▶** to step turn by turn
- **Click Play ▶** to watch battle auto-replay at selected speed
- **Click Pause** to stop auto-replay
- **Click ⏮/⏭** to jump to start/end instantly
- **Click Speed** to change playback speed (0.5x = slow, 2x = fast)

### How It Works:
**Step Controls:**
- Prev: current_turn = max(0, current_turn - 1), update_display()
- Next: current_turn = min(total_turns - 1, current_turn + 1), update_display()
- Start: current_turn = 0, update_display()
- End: current_turn = total_turns - 1, update_display()

**Auto-Play:**
- Play pressed → start timer (wait_time = 1.0 / playback_speed)
- On timeout → current_turn += 1, update_display()
- If current_turn >= total_turns → stop auto-play
- Pause pressed → stop timer

**Speed Cycling:**
- 0.5x = 2 seconds per turn
- 1x = 1 second per turn
- 2x = 0.5 seconds per turn
- Click Speed button → cycle through speeds

### Acceptance Criteria:
- [ ] Interaction check: Click "Next" 5 times → advances 5 turns, ships update each time
- [ ] Interaction check: Click "Prev" → goes back 1 turn
- [ ] Interaction check: Click "Play" → battle auto-advances at 1 turn/second
- [ ] Interaction check: Click "Pause" → auto-play stops, can scrub manually
- [ ] Interaction check: Set Speed to 2x, click Play → advances at 2 turns/second
- [ ] Manual test: Play from Turn 1 to end → automatically stops at final turn

### Shortcuts for This Phase:
- Simple linear playback (don't add rewind/reverse play)
- Fixed speed options (don't make slider for custom speed)
- No keyboard shortcuts yet (arrow keys for prev/next would be nice but defer)
- Play button doesn't remember last position (always continues from current turn)

---

## Feature 5: Event Log Sync

**Tests:** Q3 (Combat readable)
**Time:** 1.5 hours

### What Player Sees:
- **Event log panel** on right side (400×600px, same as combat log)
- **Events listed** with turn numbers: "[Turn 3] Enemy Raider targets your Weapon"
- **Current turn's events** highlighted in yellow background (#E2D44A with 0.3 alpha)
- **Auto-scroll** - log scrolls to show current turn's events when timeline scrubbed

### What Player Does:
- **Scrub timeline** → event log scrolls to matching turn
- **Read events** for current turn to understand what happened
- **Click event** in log → timeline jumps to that turn (interactive link)

### How It Works:
**Event Storage in Snapshot:**
```
TurnSnapshot:
  events: [
    "Enemy Raider targets your Weapon Alpha",
    "Weapon Alpha destroyed - 30 damage",
    "Forward power grid offline"
  ]
```

**Log Rendering:**
1. For each turn_snapshot in battle_result:
2. Add turn header: "[Turn X]" in bold
3. Add each event as indented line
4. Store line_to_turn mapping for click detection

**Sync Logic:**
- When current_turn changes:
  - Find log entry for that turn (stored index)
  - Scroll log so turn header is visible
  - Apply yellow highlight to current turn's events
  - Remove highlight from previous turn

**Click Interaction:**
- Event log entries are clickable
- Click → get turn number from line_to_turn mapping
- Emit turn_changed(turn_num)
- Timeline playhead jumps to that turn

### Acceptance Criteria:
- [ ] Visual check: Event log shows all turns with "[Turn X]" headers
- [ ] Interaction check: Scrub to Turn 7 → log scrolls to show Turn 7 events highlighted
- [ ] Interaction check: Scrub to Turn 2 → log shows Turn 2 events highlighted, Turn 7 no longer highlighted
- [ ] Interaction check: Click "[Turn 10]" in log → timeline jumps to Turn 10
- [ ] Manual test: Long battle (30 turns) → log scrolls smoothly, doesn't lag

### Shortcuts for This Phase:
- Plain text log (no colored text for event types yet)
- Simple yellow highlight (no fancy selection box)
- Click entire line to jump (don't need precise hit detection on turn number)
- Log doesn't filter events (shows all event types)

---

## Feature 6: Timeline Markers

**Tests:** Q3 (Combat readable)
**Time:** 1 hour

### What Player Sees:
- **Small icons** above timeline bar (8×12px each):
  - **Red ▼**: Component destroyed
  - **Yellow ▼**: System went offline (lost power)
  - **Green ▼**: Major damage dealt to enemy (>30 HP)
- **Hover tooltip**: "Turn 5: Main Reactor destroyed"

### What Player Does:
- **Look at timeline** → see visual markers for key events
- **Identify critical moments** at a glance (lots of red markers = bad turn)
- **Hover marker** → read what happened
- **Click marker** → jump timeline to that turn

### How It Works:
**Marker Generation:**
1. After battle complete, analyze all turn_snapshots
2. For each turn, check events:
   - If "destroyed" in event → add red marker
   - If "offline" in event → add yellow marker
   - If damage > 30 to enemy → add green marker
3. Store markers array: [{turn: 5, type: RED, tooltip: "Reactor destroyed"}]

**Rendering:**
1. Draw timeline bar
2. For each marker in markers:
   - x_pos = (marker.turn / total_turns) * bar_width
   - Draw icon at (x_pos, bar.top - 12)
3. On hover → show tooltip

**Click Handling:**
- Marker is clickable Area2D node
- Click → emit turn_changed(marker.turn)

### Acceptance Criteria:
- [ ] Visual check: After battle with 3 destroyed components → see 3 red markers on timeline
- [ ] Visual check: Turn where power went offline → see yellow marker
- [ ] Visual check: Turn where enemy took 50 damage → see green marker
- [ ] Interaction check: Hover red marker → tooltip shows "Turn 8: Relay Alpha destroyed"
- [ ] Interaction check: Click marker → timeline jumps to that turn

### Shortcuts for This Phase:
- Simple triangle icons (don't need custom sprites)
- Max 3 marker types (don't add white/blue for minor events)
- Stack markers if multiple events same turn (don't spread horizontally)
- Tooltip appears instantly (no fade-in delay)

---

## Feature 7: Return to Designer Integration

**Tests:** Q1 (Design → iterate loop)
**Time:** 0.5 hours

### What Player Sees:
- **"Return to Designer" button** top-left of replay screen (150×50px)
- **ESC key** also returns to designer
- **Same ship design** loaded in designer (can immediately iterate)

### What Player Does:
- **Watch replay** → identify problem (e.g., "Reactor exposed on edge")
- **Click "Return to Designer"** → goes back to ship designer
- **See same ship** loaded → make adjustments (move reactor interior)
- **Launch again** → test fix

### How It Works:
**Scene Flow:**
1. Combat → Victory/Defeat (stores BattleResult + player ShipData)
2. Click "View Replay" → BattleReplay.tscn (stores ShipData)
3. Click "Return to Designer" → ShipDesigner.tscn (loads stored ShipData)

**ShipData Persistence:**
- Combat stores player's ShipData in GameState singleton
- Designer reads GameState.last_ship_design
- If not null → load design into grid
- If null → empty grid

### Acceptance Criteria:
- [ ] Interaction check: From replay, click "Return to Designer" → loads designer scene
- [ ] Visual check: Same ship design appears in designer grid
- [ ] Interaction check: Press ESC in replay → returns to designer
- [ ] Manual test: Fight → Replay → Designer → Launch → Combat → all works seamlessly

### Shortcuts for This Phase:
- Store ShipData in GameState autoload (simple singleton)
- Don't persist to disk (lost on game restart, that's okay for MVP)
- Don't show "unsaved changes" warning
- Return always goes to designer (don't add "Return to Mission Select" option yet)

---

## IMPLEMENTATION ORDER

**Day 1 (3 hours):**
1. Feature 1: State capture (1.5h)
2. Feature 2: Timeline bar UI (1.5h)

**Day 2 (4 hours):**
3. Feature 3: Ship state rendering (2.5h)
4. Feature 4: Playback controls (1.5h)

**Day 3 (3 hours):**
5. Feature 5: Event log sync (1.5h)
6. Feature 6: Timeline markers (1h)
7. Feature 7: Return to designer (0.5h)

**Day 4 (1-2 hours):** Polish & testing

---

## SUCCESS METRICS

After implementation, test critical questions:

1. **Can player explain specific failure?** → "Reactor destroyed Turn 8, lost power" (not "I just died")
2. **Does replay drive iteration?** → Player watches replay, identifies issue, redesigns immediately
3. **Is replay readable?** → Player can scrub timeline and follow what happened
4. **Does player use replay?** → 50%+ of losses result in replay usage

**Target:** 4+/5 on readability, 70%+ replay usage on losses

---

## OPTIONAL: Failure Analysis Panel

**Tests:** Q1 (Design → iterate loop)
**Time:** 2-3 hours (OPTIONAL - defer if time-constrained)

### What Player Sees:
- **"Analysis" tab** next to event log
- **Causal chain** showing root cause to defeat:
  ```
  Defeat at Turn 12

  └─ All weapons offline (Turn 10)
     └─ Relay Alpha destroyed (Turn 8)
        └─ No armor protection
           └─ Exposed position on hull edge
  ```
- **Click any item** → timeline jumps to that turn

### How It Works:
**Causal Analysis:**
1. Work backward from defeat
2. If all weapons offline → find when last weapon disabled
3. If weapon disabled → find what component failure caused it
4. If component destroyed → check if armor adjacent (protection)
5. If no armor → check if edge position (exposure)
6. Build tree of causes

This feature is OPTIONAL - only implement if core replay features are complete and tested.

---

## FUTURE ENHANCEMENTS (Out of Scope)

- ❌ Save replays to disk for later viewing
- ❌ Share replays with other players (export to file)
- ❌ Side-by-side comparison (replay two battles simultaneously)
- ❌ Heat map overlay (show damage concentration)
- ❌ Victory screen shows "key moment" clip (highlight turn that won/lost battle)

These defer to post-MVP development.

---

# Future Features

*Add new feature specifications below following the same format*

---

## Feature Template

**Tests:** [Which critical question from design doc]
**Time:** [Hours estimate]

### What Player Sees:
- **Position & size:** Where on screen, dimensions
- **Colors & appearance:** Visual style, theme
- **Visual states:** Normal/hover/active/disabled

### What Player Does:
- **Action 1:** Click/hover/input description
- **Action 2:** Resulting immediate feedback
- **Action 3:** Learning outcome

### How It Works:
**Core Logic:**
1. Step by step explanation
2. Key formulas or rules
3. Connection to existing systems

**Important Numbers:**
- Value 1: Description and source (from GDD or testing)
- Value 2: Why this value matters

### Acceptance Criteria:
- [ ] Visual check: Can see [X] at [Y position]
- [ ] Interaction check: Click [A] → see [B] happen
- [ ] Manual test: Do [steps], expect [result]

### Shortcuts for This Phase:
- Hard-code [X] instead of making it configurable
- Use placeholder [Y] instead of final art
- Don't implement [Z] until later phase
- Defer [W] to polish

---

**END OF MVP ROADMAP**
