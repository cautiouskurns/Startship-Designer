# Save/Load System

**Status:** 🔴 Planned
**Priority:** ⬆️ High
**Estimated Time:** 4-6 hours
**Dependencies:** GameState autoload, Mission progression system (Feature 3.5)
**Assigned To:** AI assistant

---

## Purpose

**Why does this feature exist?**
Players need to preserve their campaign progress and ship designs across play sessions without losing mission unlocks or having to replay completed content.

**What does it enable?**
Players can close the game mid-campaign and resume exactly where they left off, including mission progression, unlocked content, and saved ship designs for different missions.

**Success criteria:**
- Player quits after beating Mission 1, relaunches game → Mission 2 still unlocked
- Player saves a ship design, loads it later → all rooms in correct positions with same budget
- Save file corrupted/missing → game gracefully handles error and starts fresh

---

## How It Works

### Overview
The save system automatically persists game state to disk using Godot's user:// directory (platform-appropriate local storage). The system saves two types of data: **campaign progress** (mission unlocks, current mission) and **ship designs** (named ship blueprints with room layouts).

Auto-save triggers after key events (mission completed, mission started, ship design launched). Manual save allows players to name and store ship designs for later reuse. Load happens automatically on game start, with manual load options in the ship designer for loading saved designs.

Save data uses JSON format for human-readability and easy debugging. The system includes version checking to handle future format changes and graceful degradation if save files are corrupted.

### User Flow

**Auto-save (Campaign Progress):**
```
1. Player completes Mission 1 (wins combat)
2. System auto-saves: missions_unlocked = [true, true, false], current_mission = 1
3. Player returns to Mission Select screen
4. Player quits game
5. Player relaunches game
6. System auto-loads save file on startup
7. Result: Mission Select shows Missions 1-2 unlocked, player continues from Mission 2
```

**Manual Save (Ship Design):**
```
1. Player designs ship in Ship Designer
2. Player clicks "Save Design" button
3. Dialog appears: "Enter design name"
4. Player types "Glass Cannon"
5. System saves ship layout + budget + mission to user://saves/designs/glass_cannon.json
6. Confirmation: "Design saved!"
7. Result: Player can load "Glass Cannon" design later
```

**Manual Load (Ship Design):**
```
1. Player in Ship Designer, clicks "Load Design" button
2. List appears showing saved designs: "Glass Cannon", "Balanced Tank", "Speed Raider"
3. Player clicks "Glass Cannon"
4. System loads room layout from glass_cannon.json
5. Grid updates to show saved layout
6. Result: Player sees previously saved design, can modify and launch
```

### Rules & Constraints

- **One campaign save:** Only one active campaign progression (no multiple save slots)
- **Auto-save timing:** After mission win, after mission start, when launching into combat
- **Design save limit:** Max 10 saved ship designs (oldest auto-deleted if exceeded)
- **File location:** All saves in `user://saves/` (Godot's user data directory)
- **Save format:** JSON for human-readability and debugging
- **Version checking:** Save files include version number for future compatibility

### Edge Cases

- **What happens if save file is corrupted?**
  System logs error, deletes corrupted file, starts fresh campaign (all missions locked except Mission 1), notifies player "Save data corrupted - starting new campaign"

- **What happens if player loads a design for wrong mission?**
  System checks budget compatibility - if saved design exceeds current mission budget, show warning "This design exceeds budget (35/30) - load anyway?" and allow over-budget load (player must fix before launching)

- **What happens if game version changes and breaks save format?**
  Save file includes `save_version` field - if version mismatch detected, attempt migration (v1 → v2), fallback to fresh start if migration fails

- **What happens if player tries to save design with no Bridge?**
  Allow save (don't validate) - design validation only happens at launch, not at save time

---

## User Interaction

### Controls

**In Ship Designer:**
- **Save Design button** (top-left): Opens save dialog
- **Load Design button** (top-left): Opens load dialog
- **Keyboard shortcut Ctrl+S / Cmd+S:** Quick-save with auto-generated name

**In Save Dialog:**
- **Text input:** Type design name (max 20 characters)
- **Confirm button:** Save design
- **Cancel button:** Close dialog without saving

**In Load Dialog:**
- **Design list:** Scrollable list of saved designs (shows name, mission, budget, date)
- **Click design:** Selects design
- **Load button:** Loads selected design
- **Delete button:** Deletes selected design (with confirmation)
- **Cancel button:** Close dialog

### Visual Feedback

**Auto-save indicator:**
- Small "Saving..." text appears bottom-right (1 second, fades out)
- Disk icon pulses during save operation

**Save dialog:**
- Text input highlighted, cursor blinking
- Character counter shows remaining characters (e.g., "12/20")
- Invalid names (empty, duplicate) show red border + error text

**Load dialog:**
- Saved designs show thumbnail preview (miniature grid with rooms)
- Hover over design → preview highlights
- Selected design → border turns cyan

**Success feedback:**
- "Design saved!" confirmation (green text, 2 seconds)
- "Design loaded!" confirmation (green text, 2 seconds)

**Error feedback:**
- "Save failed!" (red text, includes reason)
- "Load failed - file corrupted" (red text)

### Audio Feedback (if applicable)

- Save success: Soft "ping" sound (satisfying confirmation)
- Load success: Soft "whoosh" sound (data loaded)
- Error: Gentle "error" beep (not jarring)

---

## Visual Design

### Layout

**Ship Designer additions:**
```
┌─────────────────────────────────────────────┐
│ [Save] [Load]          SHIP DESIGNER        │ ← Top bar
├─────────────────────────────────────────────┤
│                                             │
│            [8×6 Grid]      [Budget Panel]   │
│                                             │
│                            [Launch Button]  │
│                                             │
│                          💾 Saving... ─┐    │ ← Auto-save indicator
└─────────────────────────────────────────────┘
```

**Save Dialog (modal overlay):**
```
┌───────────────────────────────┐
│       Save Ship Design        │
│                               │
│  Name: [________________] 12/20│
│                               │
│  [Cancel]         [Save]      │
└───────────────────────────────┘
```

**Load Dialog (modal overlay):**
```
┌───────────────────────────────────┐
│       Load Ship Design            │
│ ┌───────────────────────────────┐ │
│ │ 📋 Glass Cannon    M1  20pts  │ │ ← Design entry
│ │ 📋 Balanced Tank   M2  25pts  │ │
│ │ 📋 Speed Raider    M1  18pts  │ │
│ └───────────────────────────────┘ │
│                                   │
│ [Delete] [Cancel]      [Load]    │
└───────────────────────────────────┘
```

### Components

- **Save/Load buttons:** 80×40 pixel buttons, top-left of Ship Designer
- **Save dialog:** 400×200 pixel modal panel, center screen
- **Load dialog:** 500×400 pixel modal panel, center screen
- **Design list entry:** Shows design name, mission number, budget used, last modified date
- **Auto-save indicator:** 100×30 pixel text label, bottom-right, fades in/out

### Visual Style

- **Colors:**
  - Panel background: #1A1A1A (dark)
  - Input field: #2C2C2C (darker gray)
  - Buttons: #2C4A8C (blue, matches Launch button)
  - Error text: #E24A4A (red)
  - Success text: #4AE24A (green)
- **Fonts:**
  - Dialog title: 24pt bold
  - Input text: 18pt regular
  - Design list: 16pt regular
- **Animations:**
  - Dialog appear: fade in + scale (0.9 → 1.0, 0.2s)
  - Auto-save indicator: fade in (0.1s), hold (0.8s), fade out (0.3s)

### States

- **Save button:**
  - **Default:** Blue (#2C4A8C), white text
  - **Hover:** Lighter blue (#3A5A9C), scales 1.05
  - **Active:** Pressed appearance (darker, scale 0.98)
  - **Disabled:** Gray (#4C4C4C) - never disabled for save

- **Load button:**
  - **Default:** Blue (#2C4A8C), white text
  - **Hover:** Lighter blue (#3A5A9C), scales 1.05
  - **Active:** Pressed appearance
  - **Disabled:** Gray (#4C4C4C) - when no saved designs exist

- **Design list entry:**
  - **Default:** Dark background (#2C2C2C)
  - **Hover:** Border highlights cyan (#4AE2E2)
  - **Selected:** Background lightens (#3C3C3C), cyan border
  - **Error:** (Corrupted save) Red tint, strikethrough text

---

## Technical Implementation

### Scene Structure

```
ShipDesigner.tscn
├── TopBar
│   ├── SaveButton
│   └── LoadButton
├── Grid (existing)
├── BudgetPanel (existing)
├── LaunchButton (existing)
└── UI_Layer
    ├── SaveDialog (instance of SaveDialog.tscn)
    ├── LoadDialog (instance of LoadDialog.tscn)
    └── AutoSaveIndicator (Label)
```

**New scenes:**
```
SaveDialog.tscn
├── Panel
│   ├── Title (Label "Save Ship Design")
│   ├── NameInput (LineEdit)
│   ├── CharCounter (Label)
│   ├── CancelButton
│   └── ConfirmButton

LoadDialog.tscn
├── Panel
│   ├── Title (Label "Load Ship Design")
│   ├── DesignList (ScrollContainer)
│   │   └── VBoxContainer (populated with DesignEntry instances)
│   ├── DeleteButton
│   ├── CancelButton
│   └── LoadButton
```

### Script Responsibilities

- **SaveManager.gd (autoload):** Centralized save/load operations
  - Handles file I/O (read/write JSON)
  - Campaign progress auto-save
  - Ship design save/load
  - Error handling and validation

- **ShipDesigner.gd (modified):** Integrates save/load UI
  - Listens for Save/Load button clicks
  - Opens save/load dialogs
  - Applies loaded designs to grid
  - Triggers auto-save before combat launch

- **SaveDialog.gd:** Save dialog logic
  - Validates input (non-empty, unique name)
  - Emits `design_saved(design_name)` signal
  - Closes on confirm/cancel

- **LoadDialog.gd:** Load dialog logic
  - Populates list from SaveManager.get_saved_designs()
  - Emits `design_loaded(design_data)` signal
  - Handles delete confirmation

### Data Structures

```gdscript
# SaveManager.gd (autoload)
class_name SaveManager
extends Node

const SAVE_VERSION = 1
const SAVE_DIR = "user://saves/"
const CAMPAIGN_SAVE_PATH = "user://saves/campaign.json"
const DESIGNS_DIR = "user://saves/designs/"
const MAX_SAVED_DESIGNS = 10

var campaign_data = {
	"save_version": SAVE_VERSION,
	"missions_unlocked": [true, false, false],
	"current_mission": 0,
	"total_play_time": 0.0,
	"last_saved": ""  # ISO timestamp
}

class ShipDesign:
	var design_name: String
	var mission_index: int
	var budget_used: int
	var grid_data: Array  # 8×6 array of room type enums
	var last_modified: String  # ISO timestamp

	func to_dict() -> Dictionary:
		return {
			"save_version": SAVE_VERSION,
			"design_name": design_name,
			"mission_index": mission_index,
			"budget_used": budget_used,
			"grid_data": grid_data,
			"last_modified": Time.get_datetime_string_from_system()
		}

	static func from_dict(data: Dictionary) -> ShipDesign:
		var design = ShipDesign.new()
		design.design_name = data.get("design_name", "Unnamed")
		design.mission_index = data.get("mission_index", 0)
		design.budget_used = data.get("budget_used", 0)
		design.grid_data = data.get("grid_data", [])
		design.last_modified = data.get("last_modified", "")
		return design

func save_campaign_progress() -> bool:
	# Writes campaign_data to CAMPAIGN_SAVE_PATH
	# Returns true if successful
	pass

func load_campaign_progress() -> bool:
	# Reads from CAMPAIGN_SAVE_PATH into campaign_data
	# Returns true if successful, false if no save or corrupted
	pass

func save_ship_design(design: ShipDesign) -> bool:
	# Writes design to DESIGNS_DIR/[sanitized_name].json
	# Checks MAX_SAVED_DESIGNS limit, deletes oldest if needed
	pass

func load_ship_design(design_name: String) -> ShipDesign:
	# Reads from DESIGNS_DIR/[sanitized_name].json
	# Returns null if not found or corrupted
	pass

func get_saved_designs() -> Array[ShipDesign]:
	# Lists all .json files in DESIGNS_DIR
	# Returns array of ShipDesign objects
	pass

func delete_design(design_name: String) -> bool:
	# Deletes DESIGNS_DIR/[sanitized_name].json
	pass

func _sanitize_filename(name: String) -> String:
	# Converts "Glass Cannon" → "glass_cannon"
	# Removes special characters, lowercase, replace spaces with _
	pass
```

### Integration Points

- **Connects to:** GameState autoload (reads/writes missions_unlocked, current_mission)
- **Emits signals:**
  - `campaign_loaded()` - fired on game start after load
  - `campaign_saved()` - fired after auto-save
  - `design_saved(design_name)` - fired after manual design save
  - `design_loaded(design_name)` - fired after design load
  - `save_error(error_message)` - fired on save/load failure

- **Listens for:**
  - GameState.mission_completed - triggers auto-save
  - ShipDesigner.launch_pressed - triggers auto-save before combat

- **Modifies:**
  - GameState.missions_unlocked array
  - GameState.current_mission integer
  - ShipDesigner grid state (when loading design)

### Configuration

- **Constants (in SaveManager.gd):**
  ```gdscript
  const SAVE_VERSION = 1  # Increment when format changes
  const MAX_SAVED_DESIGNS = 10
  const AUTO_SAVE_ENABLED = true
  const SAVE_DIR = "user://saves/"
  ```

- **No JSON config needed** - save/load is pure code

---

## Acceptance Criteria

Feature is complete when:

- [ ] Campaign progress auto-saves after mission completion
- [ ] Campaign progress auto-loads on game launch
- [ ] Player can manually save ship design with custom name
- [ ] Player can load saved ship design from list
- [ ] Player can delete saved ship designs
- [ ] Corrupted save files handled gracefully (no crash, fresh start)
- [ ] Save file includes version for future compatibility
- [ ] Max 10 saved designs enforced (oldest deleted automatically)
- [ ] Save/Load UI integrated into Ship Designer scene
- [ ] Visual feedback for save/load success and errors

---

## Testing Checklist

### Functional Tests

- [ ] **Campaign auto-save:** Complete Mission 1, quit game, relaunch → Mission 2 unlocked
- [ ] **Campaign auto-load:** Delete save file, launch game → starts fresh (only Mission 1 unlocked)
- [ ] **Manual design save:** Design ship, click Save, enter name "Test" → file appears in user://saves/designs/test.json
- [ ] **Manual design load:** Save design "Test", clear grid, click Load, select "Test" → grid restores saved layout
- [ ] **Design delete:** Save design "Test", click Delete in load dialog → design removed from list and filesystem

### Edge Case Tests

- [ ] **Corrupted campaign save:** Manually corrupt campaign.json (invalid JSON), launch game → starts fresh with warning
- [ ] **Corrupted design save:** Corrupt test.json, try to load → shows error, doesn't crash
- [ ] **Over-budget design load:** Save 30pt design, load into Mission 1 (20pt budget) → loads with warning "Exceeds budget"
- [ ] **Empty design name:** Try to save with empty name → shows error "Name required"
- [ ] **Duplicate design name:** Save "Test", save another "Test" → overwrites with confirmation
- [ ] **Max designs limit:** Save 11 designs → oldest auto-deleted, only 10 remain
- [ ] **Save during combat:** (Not allowed) Save/Load buttons hidden in Combat scene

### Integration Tests

- [ ] Works with GameState autoload (missions_unlocked updates)
- [ ] Works with Ship Designer grid (loads room layout correctly)
- [ ] Doesn't break mission progression flow
- [ ] Doesn't break combat launch

### Polish Tests

- [ ] Dialogs animate smoothly (fade in/scale)
- [ ] Auto-save indicator appears/disappears correctly
- [ ] Design list scrolls properly with 10+ items
- [ ] Load dialog shows design previews (thumbnail grid)
- [ ] Character counter updates in real-time

---

## Known Limitations

- **No cloud saves:** Local only (user:// directory), doesn't sync across devices
  *Why:* Weekend prototype scope, add cloud sync in full release

- **Single campaign slot:** Can't have multiple parallel campaigns
  *Why:* Simpler UX for prototype, add multi-slot in v1.0

- **No design thumbnails in v1:** Text-only list (grid preview planned for polish)
  *Why:* Generating thumbnails adds complexity, defer to Phase 4 polish

---

## Future Enhancements

*(Not for MVP, but worth noting)*

- **Cloud save sync:** Steam Cloud, Google Play, iCloud integration
- **Design sharing:** Export design as code, share with friends
- **Design stats:** Track win rate, average attempts per design
- **Auto-save frequency:** Configurable (after every placement vs. only on launch)
- **Design categories:** Tag designs as "Offense", "Defense", "Balanced" for easier browsing
- **Undo/Redo:** Save intermediate design states during editing session

---

## Implementation Notes

*(For AI assistant or future you)*

- **File paths:** Use Godot's `user://` prefix (resolves to platform-specific app data folder)
  - Windows: `%APPDATA%\Godot\app_userdata\starship-designer\`
  - macOS: `~/Library/Application Support/Godot/app_userdata/starship-designer/`
  - Linux: `~/.local/share/godot/app_userdata/starship-designer/`

- **JSON serialization:** Use `JSON.stringify()` and `JSON.parse()` (Godot 4.x)
  - Old Godot 3.x uses `JSON.print()` and `JSON.parse()`

- **Grid data storage:** Store as 2D array of integers (room type enums)
  ```gdscript
  # Example grid_data for 8×6 grid
  [
    [0, 0, 1, 0, 0, 0, 0, 0],  # Row 0: room type 1 (Bridge) at x=2
    [2, 2, 0, 0, 0, 0, 2, 0],  # Row 1: room type 2 (Weapon) at x=0,1,6
    # ... 4 more rows
  ]
  ```

- **Gotcha:** Room type enum must be stable across saves (don't reorder room types in code)
  - Solution: Define explicit enum values, add comment "DO NOT REORDER"

- **Alternative considered:** Binary save format (faster, smaller)
  *Rejected because:* JSON is human-readable, easier to debug, supports modding

---

## Change Log

| Date | Change | Reason |
|------|--------|--------|
| 2024-12-08 | Initial spec | Feature planned for post-prototype expansion |
