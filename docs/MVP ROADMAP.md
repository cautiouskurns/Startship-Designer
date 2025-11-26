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

# Ship Designer Visual Enhancement (Figma Design)

**Total Time Estimate:** 10-14 hours
**Tests Critical Questions:** Q5 (Engineering fantasy), Q2 (Placement strategic), Q4 (Budget trade-offs)

**Purpose:** Transform the Ship Designer from basic functional UI to polished sci-fi interface matching Figma design. Enhance visual clarity, improve information hierarchy, and strengthen engineering/blueprint aesthetic.

**Design Reference:** Figma - Vessel Design Blueprint
**Color Palette:**
- Background: Dark navy #0A0A1A
- Primary accent: Cyan #4AE2E2
- Secondary accent: Blue #4A90E2
- Panel backgrounds: Dark gray #1A1A1A with cyan borders
- Text: White #FFFFFF, gray #AAAAAA for labels

---

## Feature 1: Header & Title Treatment

**Tests:** Q5 (Engineering fantasy)
**Time:** 1 hour

### What Player Sees:
- **Top header bar** spanning full width (1920×80px)
  - "VESSEL DESIGN BLUEPRINT" in large display font (32pt, cyan #4AE2E2)
  - "SCHEMATIC VIEW" label in smaller text (14pt, gray #AAAAAA) above title
  - "CLASSIFICATION: [Hull Type] • GRID: [W×H]" subtitle (16pt, white #FFFFFF)
- **Spacelab branding** in top-right corner (optional, small logo/text)
- **Dark background** (#0A0A1A) with subtle horizontal line separator (1px, #2C2C2C)

### What Player Does:
- **See immediately** what screen they're on
- **Understand context** - designing a ship blueprint
- **Know grid size** at a glance without counting tiles

### How It Works:
**Title Bar Structure:**
1. Header container spans top of screen (full width × 80px)
2. Title VBoxContainer with vertical layout:
   - Label 1: "SCHEMATIC VIEW" (small, gray)
   - Label 2: "VESSEL DESIGN BLUEPRINT" (large, cyan, bold)
   - Label 3: "CLASSIFICATION: FIGHTER • GRID: 7×7" (medium, white)
3. Dynamic classification updates based on selected hull type
4. Dynamic grid size reads from current grid dimensions

**Font Treatment:**
- Use monospace or technical font for blueprint feel
- Letter spacing: +2px for title (wider tracking)
- All caps for "VESSEL DESIGN BLUEPRINT" and "SCHEMATIC VIEW"

### Acceptance Criteria:
- [ ] Visual check: "VESSEL DESIGN BLUEPRINT" visible at top in large cyan text
- [ ] Visual check: "SCHEMATIC VIEW" label appears above main title in gray
- [ ] Visual check: Classification shows "FIGHTER • GRID: 7×7" (or current hull/grid size)
- [ ] Manual test: Select different hull → classification text updates to "CRUISER • GRID: 8×6"
- [ ] Visual check: Header has dark background with subtle border below

### Shortcuts for This Phase:
- Use Godot's default font initially (replace with custom font in polish phase)
- Hard-code "SCHEMATIC VIEW" text (don't make it changeable)
- Grid size reads from actual grid dimensions (not manually updated)
- Skip Spacelab logo (just placeholder text if desired)

---

## Feature 2: Components Panel Styling

**Tests:** Q2 (Placement strategic), Q5 (Engineering fantasy)
**Time:** 1.5 hours

### What Player Sees:
- **Left panel** (340×600px, positioned 20px from left edge, 120px from top)
- **Panel header:** "⊕ COMPONENTS" in cyan with icon
- **Component cards** in vertical list:
  - BRIDGE: "2×2 • 2BP" (each card: 300×60px)
  - WEAPON: "1×2 • 3BP"
  - SHIELD: "2×1 • 3BP"
  - ENGINE: "1×2 • 2BP"
  - REACTOR: "2×2 • 2BP"
  - ARMOR: "1×1 • 1BP"
- **Visual style:**
  - Dark background (#1A1A1A)
  - Cyan border (2px, #4AE2E2)
  - Hover state: lighter background (#2C2C2C)
  - Selected state: cyan background overlay (0.2 alpha)
- **Layout:** Component name left-aligned, size/cost right-aligned

### What Player Does:
- **Click component card** → selects that component for placement
- **See hover feedback** → card background lightens
- **See selection** → clicked card has cyan highlight
- **Read size/cost** at a glance without clicking

### How It Works:
**Panel Structure:**
1. VBoxContainer with header label "⊕ COMPONENTS"
2. Six component buttons in vertical list
3. Each button: HBoxContainer with:
   - Label (left): Component name
   - Label (right): "WxH • XBP" format
4. Custom theme for dark background + cyan border

**Interaction:**
- Mouse enter → tween background color to #2C2C2C (0.1s)
- Mouse exit → tween back to #1A1A1A (0.1s)
- Click → emit "component_selected(type)" signal
- Track selected_component variable, apply cyan overlay to that button

**Size/Cost Display:**
- Read from RoomData.gd definitions
- Format: "%dx%d • %dBP" % [width, height, cost]

### Acceptance Criteria:
- [ ] Visual check: Components panel visible on left with dark background and cyan border
- [ ] Visual check: Six component cards listed with names and "WxH • XBP" format
- [ ] Interaction check: Hover over WEAPON card → background lightens
- [ ] Interaction check: Click BRIDGE card → card gets cyan highlight overlay
- [ ] Visual check: "⊕ COMPONENTS" header in cyan at top of panel
- [ ] Manual test: Click different components → previously selected loses highlight, new one gains it

### Shortcuts for This Phase:
- Use simple ColorRect for backgrounds (not custom panel sprites)
- Icons are text symbols (⊕) not custom SVG icons
- Fixed panel size and position (not responsive/resizable)
- Component order hard-coded (don't make it sortable)

---

## Feature 3: Grid Layout Enhancement

**Tests:** Q2 (Placement strategic)
**Time:** 2 hours

### What Player Sees:
- **Center grid area** (700×700px, centered horizontally, 120px from top)
- **Instructions panel** above grid (600×80px):
  - "→ Select component from left panel"
  - "→ Click grid to place component"
  - "→ Click existing component to remove"
  - Text in gray (#AAAAAA), 14pt
- **Clear button** in top-right of grid area (80×40px, white text on dark button)
- **Grid background:** Darker than panels (#0F0F1F) with cyan grid lines (1px, #2C4C4C)
- **Placed components:** Cyan borders when powered, gray when unpowered

### What Player Does:
- **Read instructions** → understand how to place components
- **Click grid tiles** → place selected component
- **Click Clear button** → remove all components, reset grid
- **See visual feedback** → grid glows on hover

### How It Works:
**Instructions Panel:**
1. Panel above grid (600×80px) with dark background
2. VBoxContainer with three Label nodes
3. Each label: "→ [instruction text]"
4. Arrow symbol (→) in cyan, instruction text in gray

**Clear Button:**
1. Button positioned top-right of grid area
2. Click → call clear_grid() function
3. clear_grid() sets all tiles to EMPTY, updates budget to 0
4. Confirmation dialog: "Clear all components? (Cannot undo)"

**Grid Visual Enhancement:**
1. GridContainer or custom grid rendering
2. Draw vertical/horizontal lines between tiles (1px cyan)
3. Tile hover: add subtle cyan glow (ColorRect overlay, 0.2 alpha)
4. Powered tiles: thicker cyan border (2px)
5. Unpowered tiles: gray border (2px, #4C4C4C)

### Acceptance Criteria:
- [ ] Visual check: Instructions panel above grid with three instruction lines
- [ ] Visual check: "Clear" button visible in top-right of grid area
- [ ] Interaction check: Click Clear → confirmation dialog appears
- [ ] Interaction check: Confirm clear → all components removed, grid empty
- [ ] Visual check: Grid has cyan lines between tiles
- [ ] Interaction check: Hover over empty tile → subtle cyan glow appears
- [ ] Visual check: Placed powered component has cyan border
- [ ] Visual check: Placed unpowered component has gray border

### Shortcuts for This Phase:
- Simple confirmation dialog (Godot's ConfirmationDialog node, not custom)
- Grid lines drawn with Line2D (not shader effects)
- Hover glow is ColorRect (not particle effects)
- Instructions are static text (don't animate or highlight)

---

## Feature 4: Performance Panel

**Tests:** Q2 (Placement strategic), Q5 (Engineering fantasy)
**Time:** 1.5 hours

### What Player Sees:
- **Right panel - top section** (340×200px, positioned 1560px from left, 120px from top)
- **Panel header:** "⊙ PERFORMANCE" in cyan with icon
- **Four stat rows:**
  - "◉ OFFENSE" with value (right-aligned, large 24pt)
  - "◉ DEFENSE" with value
  - "⚡ MOBILITY" with value
  - "⚡ POWER" with value
- **Visual style:**
  - Dark background (#1A1A1A), cyan border
  - Icon + label in gray (#AAAAAA)
  - Value in white (#FFFFFF), bold
  - Icons color-coded: red for offense, blue for defense, orange for mobility, yellow for power

### What Player Does:
- **Place components** → see stats update in real-time
- **Compare designs** → quickly scan performance numbers
- **Understand ship capabilities** at a glance

### How It Works:
**Stat Calculation:**
1. OFFENSE = count of powered weapons
2. DEFENSE = count of powered shields
3. MOBILITY = count of powered engines
4. POWER = total power output (reactors × 4 adjacency)

**Real-time Updates:**
- Connect to "component_placed" and "component_removed" signals
- Recalculate all stats when grid changes
- Update label text: "%d" % offense_value
- Tween value changes (scale pulse when stat increases)

**Panel Structure:**
1. VBoxContainer with header "⊙ PERFORMANCE"
2. Four HBoxContainers, each with:
   - Icon label (left): "◉" or "⚡"
   - Stat name (left): "OFFENSE"
   - Value label (right): "0"

### Acceptance Criteria:
- [ ] Visual check: Performance panel visible on right with four stat rows
- [ ] Visual check: Icons color-coded (red ◉ for OFFENSE, blue ◉ for DEFENSE, etc.)
- [ ] Interaction check: Place weapon → OFFENSE increases by 1
- [ ] Interaction check: Place shield → DEFENSE increases by 1
- [ ] Interaction check: Place unpowered weapon → OFFENSE stays 0 (only counts powered)
- [ ] Visual check: Values right-aligned in large white text
- [ ] Manual test: Place reactor + weapon → weapon becomes powered → OFFENSE = 1

### Shortcuts for This Phase:
- Simple text icons (◉ ⚡) not custom sprites
- Color applied via theme color override
- Linear stat calculation (no complex formulas yet)
- Stats don't show max values (just current count)
- No stat comparison to previous design

---

## Feature 5: Inventory Panel

**Tests:** Q4 (Budget trade-offs)
**Time:** 1 hour

### What Player Sees:
- **Right panel - middle section** (340×280px, below performance panel, 10px gap)
- **Panel header:** "⊙ INVENTORY" in cyan
- **Six component rows:**
  - "Bridge:" with count (right-aligned)
  - "Weapons:" with count
  - "Shields:" with count
  - "Engines:" with count
  - "Reactors:" with count
  - "Armor:" with count
- **Visual style:** Same dark background + cyan border as other panels
- **Counts update** in real-time as components placed

### What Player Does:
- **See component usage** at a glance
- **Track how many weapons** placed vs shields (balance check)
- **Verify bridge placed** (should show "1", not "0")

### How It Works:
**Count Tracking:**
1. When component placed → increment count for that type
2. When component removed → decrement count
3. Store counts in Dictionary: {BRIDGE: 0, WEAPON: 0, SHIELD: 0, ...}

**Display Update:**
1. Six labels in VBoxContainer
2. Each label: "%s: %d" % [name, count]
3. Connect to grid signals for updates

**Panel Structure:**
- VBoxContainer with header
- Six HBoxContainers:
  - Label (left): "Bridges:"
  - Label (right): "0"

### Acceptance Criteria:
- [ ] Visual check: Inventory panel below performance panel with six component types
- [ ] Interaction check: Place bridge → "Bridge: 1" appears
- [ ] Interaction check: Place 3 weapons → "Weapons: 3"
- [ ] Interaction check: Remove 1 weapon → "Weapons: 2"
- [ ] Visual check: Counts right-aligned in white text
- [ ] Manual test: Place multiple of each type → all counts update correctly

### Shortcuts for This Phase:
- Simple count (don't differentiate between powered/unpowered)
- No icons next to component names
- Counts don't show max limits (just current)
- Component names plural (hard-coded strings)

---

## Feature 6: Notes Section

**Tests:** Q2 (Placement strategic), Q5 (Engineering fantasy)
**Time:** 0.5 hours

### What Player Sees:
- **Right panel - bottom section** (340×200px, below inventory, 10px gap)
- **Panel header:** "NOTES" in white
- **Bulleted tips list:**
  - "• 2×2 components more efficient"
  - "• Central reactors power more rooms"
  - "• Weapons face forward (top)"
  - "• Engines face aft (bottom)"
  - "• Balance offense vs defense"
- **Visual style:** Same panel styling, text in gray (#AAAAAA), 12pt

### What Player Does:
- **Read strategy tips** while designing
- **Learn placement rules** (weapons top, engines bottom)
- **Understand efficiency** (2×2 components better)

### How It Works:
**Static Content:**
1. VBoxContainer with header "NOTES"
2. Five Label nodes with tips
3. Bullet character: "•" in cyan
4. Tip text in gray

**Optional Enhancement:**
- Tips could be dynamic based on current design
- Example: If no reactors placed, show tip "• Add reactors for power"
- For MVP: static tips are fine

### Acceptance Criteria:
- [ ] Visual check: Notes panel visible with "NOTES" header
- [ ] Visual check: Five tips displayed with bullet points
- [ ] Visual check: Tips mention weapons (top), engines (bottom), reactors (central)
- [ ] Visual check: Text in gray, bullets in cyan

### Shortcuts for This Phase:
- Static tips (don't make them dynamic/contextual)
- Simple bullet character (not custom icon)
- No scrolling if more tips added (fixed 5 tips)
- Tips don't link to documentation

---

## Feature 7: Specifications Panel

**Tests:** Q2 (Placement strategic), Q4 (Budget trade-offs)
**Time:** 1.5 hours

### What Player Sees:
- **Bottom-left panel** (400×260px, positioned 20px from left, 760px from top)
- **Panel header:** "⚒ SPECIFICATIONS" in cyan
- **Selected component details:**
  - "COMPONENT" label with component name (e.g., "Bridge")
  - "DIMENSIONS: 2 × 2 units"
  - "COST: 2 BP"
  - "DESCRIPTION: Command center - required to launch"
- **Visual style:** Same dark panel + cyan border
- **Updates when component selected** from left panel

### What Player Sees (continued):
- **Empty state:** When no component selected, shows "Select a component to view specifications"

### What Player Does:
- **Click component** in left panel → see detailed specs
- **Read description** → understand component purpose
- **Check dimensions** before placing (know how much space needed)
- **Verify cost** before committing to design

### How It Works:
**Component Data:**
1. Store in RoomData.gd or separate ComponentSpecs.gd:
```gdscript
BRIDGE: {
  "dimensions": Vector2i(2, 2),
  "cost": 2,
  "description": "Command center - required to launch"
}
```

**Display Logic:**
1. Connect to "component_selected" signal from components panel
2. When component selected:
   - Get component data from specs dictionary
   - Update labels: component_name_label.text = "Bridge"
   - dimensions_label.text = "DIMENSIONS: %d × %d units" % [w, h]
   - cost_label.text = "COST: %d BP" % cost
   - description_label.text = description

**Panel Structure:**
- VBoxContainer with header
- Four labels:
  1. "COMPONENT" (gray label) + component name (white, large)
  2. "DIMENSIONS" (gray label) + dimensions value (white)
  3. "COST" (gray label) + cost value (white)
  4. "DESCRIPTION" (gray label) + description text (white, wrapped)

### Acceptance Criteria:
- [ ] Visual check: Specifications panel visible bottom-left
- [ ] Interaction check: Click BRIDGE in components panel → specs show "Bridge, 2×2, 2 BP"
- [ ] Interaction check: Click WEAPON → specs update to "Weapon, 1×2, 3 BP"
- [ ] Visual check: Description text wraps if too long (doesn't overflow panel)
- [ ] Visual check: Empty state shows "Select a component..." when nothing selected
- [ ] Manual test: Click each component → all specs display correctly

### Shortcuts for This Phase:
- Hard-code component descriptions (not loaded from external file)
- Simple text wrapping (autowrap_mode enabled, not custom)
- No component icon displayed in specs panel
- Descriptions are short (1 sentence each)

---

## Feature 8: Status Indicators & Bottom Bar

**Tests:** Q4 (Budget trade-offs)
**Time:** 1.5 hours

### What Player Sees:
- **Bottom status bar** spanning center width (1200×80px, bottom edge)
- **Three status boxes** side by side:
  - **BRIDGE:** "✗ MISSING" (red) or "✓ NOMINAL" (green)
  - **BUDGET:** "✓ NOMINAL" (green) or "⚠ OVER BUDGET" (yellow/red)
  - **STATUS:** "⚠ STANDBY" (yellow) or "✓ READY" (green)
- **Launch button** (centered below status boxes, 200×60px):
  - "BRIDGE REQUIRED" (gray, disabled) if no bridge
  - "LAUNCH" (cyan, enabled) if ready
- **Visual style:** Dark background, colored status text, thick borders

### What Player Does:
- **Check status** at a glance → see what's preventing launch
- **See "BRIDGE REQUIRED"** → know to place bridge
- **See "BUDGET NOMINAL"** → know they're within limits
- **Click LAUNCH** when green → proceed to combat

### How It Works:
**Status Calculation:**
1. BRIDGE status:
   - Count bridges in inventory
   - If count == 1: "✓ NOMINAL" (green)
   - If count == 0: "✗ MISSING" (red)
   - If count > 1: "⚠ MULTIPLE" (yellow)

2. BUDGET status:
   - Calculate total_cost from placed components
   - If total_cost <= max_budget: "✓ NOMINAL" (green)
   - If total_cost > max_budget: "⚠ OVER BUDGET" (red)

3. OVERALL status:
   - If bridge nominal AND budget nominal: "✓ READY" (green), enable launch
   - Otherwise: "⚠ STANDBY" (yellow), disable launch

**Launch Button:**
- Disabled state: gray background, "BRIDGE REQUIRED" text
- Enabled state: cyan background, "LAUNCH" text
- Click → emit "launch_combat" signal

**Visual Indicators:**
- ✓ checkmark (green #4AE24A)
- ✗ X mark (red #E24A4A)
- ⚠ warning (yellow #E2D44A)

### Acceptance Criteria:
- [ ] Visual check: Three status boxes visible at bottom (BRIDGE, BUDGET, STATUS)
- [ ] Visual check: Initially shows "BRIDGE: ✗ MISSING" in red
- [ ] Interaction check: Place bridge → "BRIDGE: ✓ NOMINAL" turns green
- [ ] Interaction check: Go over budget → "BUDGET: ⚠ OVER BUDGET" turns red
- [ ] Visual check: Launch button disabled (gray) when requirements not met
- [ ] Visual check: Launch button enabled (cyan) when bridge placed + within budget
- [ ] Interaction check: Click enabled LAUNCH → transitions to combat

### Shortcuts for This Phase:
- Simple text status (not animated progress bars)
- Status symbols are text characters (✓ ✗ ⚠) not custom icons
- Status boxes don't show detailed info on hover (keep simple)
- Budget doesn't show breakdown (just nominal/over)

---

## Feature 9: Resource Allocation Display

**Tests:** Q4 (Budget trade-offs)
**Time:** 0.5 hours

### What Player Sees:
- **Top-right panel** (200×80px, positioned 1700px from left, 20px from top)
- **Header:** "RESOURCE ALLOCATION" in small gray text (10pt)
- **Large budget display:** "0 / 20" in white text (28pt, bold)
- **Visual style:** Dark background, cyan border, centered text

### What Player Does:
- **See budget at a glance** in prominent position
- **Track spending** as they place components (number increases)
- **Know max budget** without checking elsewhere

### How It Works:
**Budget Tracking:**
1. current_budget = sum of all placed component costs
2. max_budget = mission-specific value (20, 25, or 30)
3. Update display: "%d / %d" % [current_budget, max_budget]

**Color Coding:**
- If current_budget <= max_budget: white text
- If current_budget > max_budget: red text (#E24A4A)

**Real-time Update:**
- Connect to component_placed/removed signals
- Recalculate current_budget
- Update label text

### Acceptance Criteria:
- [ ] Visual check: Resource allocation panel visible top-right
- [ ] Visual check: Shows "0 / 20" at start (or mission max budget)
- [ ] Interaction check: Place 2 BP bridge → shows "2 / 20"
- [ ] Interaction check: Place 3 BP weapon → shows "5 / 20"
- [ ] Interaction check: Go over budget → text turns red
- [ ] Manual test: Different missions show different max values (20, 25, 30)

### Shortcuts for This Phase:
- Simple text display (not progress bar or gauge)
- Budget doesn't show "remaining" (just current/max)
- No breakdown by component type
- Max budget hard-coded per mission (not configurable in UI)

---

## Feature 10: Global Styling & Theme

**Tests:** Q5 (Engineering fantasy)
**Time:** 1.5 hours

### What Player Sees:
- **Consistent visual language** across all panels
- **Dark space aesthetic** - deep navy/black backgrounds
- **Cyan accent color** for interactive elements, borders, headers
- **Technical font** (monospace or blueprint-style) for all text
- **Subtle animations** - hover effects, value changes
- **Background texture** - starfield or grid pattern (optional)

### What Player Does:
- **Feel immersed** in ship design/engineering experience
- **See cohesive design** - not mismatched UI elements
- **Experience polish** - smooth transitions, consistent spacing

### How It Works:
**Godot Theme Resource:**
1. Create custom theme (.tres file)
2. Define theme properties:
   - Default colors: bg (#1A1A1A), border (#4AE2E2), text (#FFFFFF)
   - Default fonts: monospace for all labels/buttons
   - Panel StyleBox: dark bg + cyan border (2px)
   - Button StyleBox: normal/hover/pressed states

**Apply Theme:**
- Set theme on root Control node (ShipDesigner scene)
- All child nodes inherit theme properties
- Override specific nodes as needed

**Animations:**
- Button hover: scale 1.0 → 1.05, duration 0.1s
- Value change: scale pulse 1.0 → 1.2 → 1.0, duration 0.3s
- Panel appear: fade in alpha 0 → 1, duration 0.2s

**Optional Background:**
- TextureRect with starfield image (low opacity 0.3)
- Or procedural stars (small white dots, random positions)
- Z-index: -1 (behind all UI)

### Acceptance Criteria:
- [ ] Visual check: All panels have consistent dark backgrounds (#1A1A1A)
- [ ] Visual check: All panels have cyan borders (2px, #4AE2E2)
- [ ] Visual check: All headers use cyan color (#4AE2E2)
- [ ] Visual check: All text uses monospace or technical font
- [ ] Interaction check: Hover any button → smooth scale animation
- [ ] Visual check: Value changes pulse/highlight briefly
- [ ] Visual check: Spacing consistent (10px gaps between panels)
- [ ] Visual check: Background has space/technical aesthetic

### Shortcuts for This Phase:
- Use Godot's default font (or single free monospace font, not multiple fonts)
- Simple StyleBoxFlat for panels (not custom textures)
- Starfield background is optional (solid color acceptable)
- Animations use simple Tween (not complex shader effects)
- Theme applied globally (don't create per-component themes)

---

## IMPLEMENTATION ORDER

**Day 1 (4 hours):**
1. Feature 1: Header & title (1h)
2. Feature 2: Components panel styling (1.5h)
3. Feature 9: Resource allocation display (0.5h)
4. Feature 10: Start global theme setup (1h)

**Day 2 (4 hours):**
1. Feature 3: Grid layout enhancement (2h)
2. Feature 4: Performance panel (1.5h)
3. Feature 5: Inventory panel (1h)

**Day 3 (4 hours):**
1. Feature 6: Notes section (0.5h)
2. Feature 7: Specifications panel (1.5h)
3. Feature 8: Status indicators (1.5h)
4. Feature 10: Finish theme & polish (0.5h)

**Day 4 (1-2 hours):** Testing, tweaks, responsive layout adjustments

---

## SUCCESS METRICS

After implementation, evaluate:

1. **Visual Clarity:** Can player find information quickly? (Component costs, budget, stats)
2. **Engineering Fantasy:** Does UI feel like designing a ship blueprint? (Technical aesthetic)
3. **Information Hierarchy:** Are most important elements most prominent? (Status, budget, launch)
4. **Consistency:** Do all UI elements feel like part of same design system?
5. **Polish:** Do interactions feel smooth? (Animations, hover states)

**Target:** User testing shows <3 seconds to find any specific information, 4+/5 on "feels like engineering" question

---

## CURRENT STATE vs FIGMA DESIGN

**Existing Elements (Keep & Restyle):**
- Grid system (7×7 or 8×6 depending on hull)
- Component placement interaction
- Budget tracking
- Power routing visualization
- Launch button with validation
- Combat transition

**New Elements (Add from Figma):**
- Header with "VESSEL DESIGN BLUEPRINT" title
- Styled components panel with cards
- Instructions panel above grid
- Clear button for grid
- Performance stats panel (real-time)
- Inventory counts panel
- Notes/tips section
- Specifications panel for selected component
- Bottom status bar with three indicators
- Resource allocation prominent display
- Global theme & styling

**Elements in Game but NOT in Figma (Preserve):**
- Power routing lines/indicators
- Hull selection (different screen, not shown in Figma)
- Mission-specific budget values
- Room type colors/icons
- Any existing tooltips or help text

---

## FUTURE ENHANCEMENTS (Out of Scope)

- ❌ Animated background (moving stars, parallax layers)
- ❌ Component preview in grid (ghost placement before click)
- ❌ Undo/redo system for component placement
- ❌ Save/load ship designs to library
- ❌ Design templates/presets
- ❌ Export ship design as image
- ❌ Comparison view (current design vs previous)
- ❌ Design validation checklist (more detailed than status bar)

These defer to post-MVP polish or full game features.

---

**END OF MVP ROADMAP**
