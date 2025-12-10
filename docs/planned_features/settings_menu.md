# Settings Menu

**Status:** 🔴 Planned
**Priority:** ⬆️ High
**Estimated Time:** 8-10 hours
**Dependencies:** AudioManager (already exists)
**Assigned To:** AI Assistant

---

## Purpose

**Why does this feature exist?**
Players need control over audio levels, display settings, and input customization to match their preferences and hardware capabilities. A settings menu provides accessibility and improves player experience.

**What does it enable?**
Players can adjust master/SFX/music volumes independently, change resolution and fullscreen mode, and remap keybinds to their preference. Settings persist between sessions.

**Success criteria:**
- Volume sliders immediately affect audio playback
- Resolution changes apply without crashing
- Keybind remapping prevents conflicts and persists
- All settings save to disk and load on startup

---

## How It Works

### Overview
The Settings Menu is accessible from the Main Menu and pause menu during gameplay. It presents three tabs: Audio, Video, and Controls. Changes are applied in real-time (for immediate feedback) and saved to a persistent configuration file when the player exits the menu.

Audio settings control three volume busses (Master, SFX, Music) via sliders. Video settings allow resolution selection and fullscreen toggle. Controls allow clicking a keybind button and pressing a new key to remap it, with conflict detection to prevent duplicate bindings.

### User Flow
```
1. Player clicks "Settings" button in Main Menu or presses ESC during gameplay
2. Settings menu opens with Audio tab active by default
3. Player adjusts sliders → volume changes immediately
4. Player switches to Video tab → selects resolution → clicks Apply → screen resizes
5. Player switches to Controls tab → clicks "Move Forward" bind → presses W → bind updates
6. Player clicks "Save & Exit" → settings saved to disk → menu closes
```

### Rules & Constraints
- Volume range: 0% (mute) to 100% (full volume)
- Master volume affects both SFX and Music proportionally
- Resolution list shows only 16:9 aspect ratios (1280×720, 1920×1080, 2560×1440, 3840×2160)
- Keybind conflicts trigger warning and prevent duplicate assignments
- ESC key cannot be remapped (reserved for menu/pause)
- At least one movement key must be bound at all times

### Edge Cases
- What happens if settings file is corrupted?
  → Load default settings and show warning message
- What happens if player tries to bind ESC or reserved keys?
  → Show error message "This key is reserved" and keep previous binding
- What happens if resolution is not supported by monitor?
  → Revert to previous resolution after 10 seconds with "Keep changes?" prompt
- What happens if two actions are bound to the same key?
  → Show warning "Key already bound to [Action]. Unbind [Action]?"

---

## User Interaction

### Controls
- **Mouse Click**: Interact with buttons, sliders, dropdowns
- **Mouse Drag**: Adjust volume sliders
- **Keyboard**: Navigate tabs with Tab/Arrow keys, confirm with Enter
- **ESC**: Close settings menu (prompts to save if changes detected)

### Visual Feedback
- Sliders show percentage value (e.g., "75%") next to handle
- Volume bars pulse when audio plays (visual confirmation)
- Keybind buttons highlight in cyan when waiting for input
- "Unsaved Changes" indicator appears if settings modified
- Apply button pulses green when resolution changes successfully

### Audio Feedback
- Button clicks play "button_click" SFX
- Slider adjustments trigger soft "slider_move" SFX
- Volume changes immediately affect playback (real-time preview)
- Keybind successful remap plays "confirm" SFX
- Error/conflict plays "error" SFX

---

## Visual Design

### Layout
```
┌────────────────────────────────────────┐
│ SETTINGS                          [X]  │
├────────────────────────────────────────┤
│                                        │
│  [AUDIO] [VIDEO] [CONTROLS]            │
│                                        │
│  ┌──────────────────────────────────┐ │
│  │                                  │ │
│  │  Master Volume    [====|----] 75%│ │
│  │  SFX Volume       [======|--] 85%│ │
│  │  Music Volume     [===|-----] 60%│ │
│  │                                  │ │
│  └──────────────────────────────────┘ │
│                                        │
│         [SAVE & EXIT]  [CANCEL]        │
└────────────────────────────────────────┘
```

### Components
- **Tab Buttons**: Switch between Audio/Video/Controls sections
- **Volume Sliders**: HSlider with percentage label
- **Resolution Dropdown**: OptionButton with available resolutions
- **Fullscreen Checkbox**: CheckButton for windowed/fullscreen toggle
- **Keybind Buttons**: Clickable labels showing current key (e.g., "W")
- **Save/Cancel Buttons**: Apply and persist changes or discard

### Visual Style
- Colors: Dark blue-gray background (#0F1F28), cyan accents (#4AE2E2), white text
- Fonts: Blueprint mono font (same as rest of UI)
- Animations:
  - Tab switch: slide fade (0.2s)
  - Slider drag: smooth lerp (0.1s)
  - Keybind waiting: pulse cyan border (1s loop)

### States
- **Default:** Tab button dark, slider handle white, keybind button gray
- **Hover:** Tab button brightens, slider handle cyan glow, keybind button cyan outline
- **Active:** Tab button cyan underline, slider handle cyan, keybind button cyan fill
- **Disabled:** Grayed out at 50% opacity (not editable)
- **Error:** Keybind button red border with shake animation (0.3s)

---

## Technical Implementation

### Scene Structure
```
SettingsMenu.tscn
├── Panel (background)
├── MarginContainer
│   └── VBoxContainer
│       ├── TitleLabel ("SETTINGS")
│       ├── CloseButton
│       ├── TabContainer
│       │   ├── AudioTab (VBoxContainer)
│       │   │   ├── MasterVolumeSlider (HSlider)
│       │   │   ├── SFXVolumeSlider (HSlider)
│       │   │   └── MusicVolumeSlider (HSlider)
│       │   ├── VideoTab (VBoxContainer)
│       │   │   ├── ResolutionDropdown (OptionButton)
│       │   │   ├── FullscreenCheckbox (CheckButton)
│       │   │   └── ApplyButton
│       │   └── ControlsTab (ScrollContainer)
│       │       └── KeybindList (VBoxContainer)
│       │           ├── KeybindRow (HBoxContainer) x N
│       │           │   ├── ActionLabel
│       │           │   └── KeybindButton
│       └── ButtonRow (HBoxContainer)
│           ├── SaveButton
│           └── CancelButton
```

### Script Responsibilities
- **SettingsMenu.gd:** Main controller, coordinates tabs, handles save/cancel
- **AudioTab.gd:** Manages volume sliders, updates AudioServer busses
- **VideoTab.gd:** Manages resolution dropdown and fullscreen, applies display changes
- **ControlsTab.gd:** Manages keybind list, detects input, handles conflicts
- **KeybindButton.gd:** Individual keybind button, waits for input, validates key
- **SettingsManager.gd (Autoload):** Persists settings to disk, loads on startup

### Data Structures
```gdscript
# SettingsManager.gd (Autoload)
extends Node

const SETTINGS_FILE = "user://settings.cfg"

var settings = {
	"audio": {
		"master_volume": 1.0,  # 0.0 to 1.0
		"sfx_volume": 0.85,
		"music_volume": 0.6
	},
	"video": {
		"resolution": Vector2i(1920, 1080),
		"fullscreen": false
	},
	"controls": {
		"move_forward": KEY_W,
		"move_backward": KEY_S,
		"move_left": KEY_A,
		"move_right": KEY_D,
		"zoom_in": KEY_EQUAL,
		"zoom_out": KEY_MINUS,
		"rotate_room": KEY_R,
		"deselect": KEY_ESCAPE
	}
}

func save_settings():
	var config = ConfigFile.new()

	# Audio
	config.set_value("audio", "master_volume", settings["audio"]["master_volume"])
	config.set_value("audio", "sfx_volume", settings["audio"]["sfx_volume"])
	config.set_value("audio", "music_volume", settings["audio"]["music_volume"])

	# Video
	config.set_value("video", "resolution_x", settings["video"]["resolution"].x)
	config.set_value("video", "resolution_y", settings["video"]["resolution"].y)
	config.set_value("video", "fullscreen", settings["video"]["fullscreen"])

	# Controls
	for action in settings["controls"].keys():
		config.set_value("controls", action, settings["controls"][action])

	config.save(SETTINGS_FILE)

func load_settings():
	var config = ConfigFile.new()
	var err = config.load(SETTINGS_FILE)

	if err != OK:
		print("No settings file found, using defaults")
		return

	# Audio
	settings["audio"]["master_volume"] = config.get_value("audio", "master_volume", 1.0)
	settings["audio"]["sfx_volume"] = config.get_value("audio", "sfx_volume", 0.85)
	settings["audio"]["music_volume"] = config.get_value("audio", "music_volume", 0.6)

	# Video
	var res_x = config.get_value("video", "resolution_x", 1920)
	var res_y = config.get_value("video", "resolution_y", 1080)
	settings["video"]["resolution"] = Vector2i(res_x, res_y)
	settings["video"]["fullscreen"] = config.get_value("video", "fullscreen", false)

	# Controls
	for action in settings["controls"].keys():
		settings["controls"][action] = config.get_value("controls", action, settings["controls"][action])

	apply_settings()

func apply_settings():
	# Apply audio
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(settings["audio"]["master_volume"]))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(settings["audio"]["sfx_volume"]))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(settings["audio"]["music_volume"]))

	# Apply video
	if settings["video"]["fullscreen"]:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		get_window().size = settings["video"]["resolution"]

	# Apply controls (remap InputMap)
	for action in settings["controls"].keys():
		InputMap.action_erase_events(action)
		var event = InputEventKey.new()
		event.keycode = settings["controls"][action]
		InputMap.action_add_event(action, event)
```

### Integration Points
- Connects to: **AudioServer** (volume busses), **DisplayServer** (window mode), **InputMap** (keybinds)
- Emits signals: `settings_changed()`, `settings_saved()`, `settings_cancelled()`
- Listens for: Main Menu "Settings" button press, pause menu "Settings" option
- Modifies: Global audio busses, window resolution/mode, input action mappings

### Configuration
- Settings file: `user://settings.cfg` (uses ConfigFile for INI-style persistence)
- Default keybinds: Defined in `SettingsManager.settings["controls"]` dictionary
- Available resolutions: Hard-coded list in VideoTab (16:9 ratios only)

---

## Acceptance Criteria

Feature is complete when:

- [ ] Settings menu opens from Main Menu and pause menu
- [ ] Volume sliders adjust Master/SFX/Music busses in real-time
- [ ] Resolution dropdown lists common 16:9 resolutions
- [ ] Fullscreen checkbox toggles window mode immediately
- [ ] Keybind buttons detect new key press and update display
- [ ] Duplicate keybind warning prevents conflicts
- [ ] Settings save to `user://settings.cfg` when "Save & Exit" clicked
- [ ] Settings load on game startup and apply automatically
- [ ] Cancel button discards changes and restores previous values
- [ ] ESC key closes settings menu with unsaved changes warning

---

## Testing Checklist

### Functional Tests
- [ ] **Volume Test**: Adjust each slider to 0%, 50%, 100% → verify audio level changes
- [ ] **Resolution Test**: Select each resolution → click Apply → verify window resizes correctly
- [ ] **Fullscreen Test**: Toggle fullscreen on/off → verify mode switches without crash
- [ ] **Keybind Test**: Remap each action → verify new key works in-game
- [ ] **Save Test**: Change settings → save → restart game → verify settings persist
- [ ] **Cancel Test**: Change settings → cancel → verify settings revert

### Edge Case Tests
- [ ] **Corrupted Settings File**: Delete/corrupt `settings.cfg` → game loads defaults
- [ ] **Invalid Resolution**: Set resolution larger than monitor → auto-revert with prompt
- [ ] **Duplicate Keybind**: Try to bind W to two actions → warning shown, prevented
- [ ] **Reserved Key**: Try to bind ESC to action → error shown, prevented
- [ ] **Volume Extremes**: Set all volumes to 0% → verify mute, set to 100% → verify max

### Integration Tests
- [ ] Works with existing AudioManager SFX playback
- [ ] Doesn't break pause menu functionality
- [ ] Keybind remapping affects ShipDesigner controls (zoom, rotate, deselect)
- [ ] Resolution changes don't break UI layout (responsive design)

### Polish Tests
- [ ] Tab switching animations smooth (0.2s fade)
- [ ] Slider drag feels responsive (no lag)
- [ ] Keybind button pulse animation clear (waiting for input)
- [ ] Volume bars pulse with audio playback (visual confirmation)
- [ ] Performance: Settings menu runs at 60 FPS

---

## Known Limitations

- **Limited Resolutions**: Only 16:9 aspect ratios supported (no ultrawide)
  → Future: Add 21:9 and custom resolution input
- **No Gamepad Support**: Keybind remapping only supports keyboard
  → Future: Add gamepad binding system
- **No Audio Preview**: No test sound for volume adjustment
  → Future: Add "Test" button that plays sample SFX/music

---

## Future Enhancements

*(Not for MVP, but worth noting)*

- **Graphics Quality Presets**: Low/Medium/High/Ultra settings
- **Accessibility Options**: Colorblind mode, UI scale, text-to-speech
- **Advanced Audio**: Individual SFX categories (UI, combat, ambient)
- **Gamepad Remapping**: Support for controller button binding
- **Cloud Saves**: Sync settings across devices
- **Import/Export**: Share keybind profiles with other players

---

## Implementation Notes

*(For AI assistant or future you)*

- **Audio Bus Setup**: Ensure AudioManager creates Master/SFX/Music busses in project settings
- **InputMap Actions**: All keybinds must be pre-defined in Project Settings → Input Map
- **Resolution Validation**: Use `DisplayServer.screen_get_size()` to filter invalid resolutions
- **ConfigFile vs JSON**: ConfigFile chosen for simplicity and Godot native support
- **Real-time Apply**: Volume changes apply immediately (no "Apply" button), but video changes need explicit Apply button to prevent accidental window resizing
- **Keybind Conflicts**: Use Dictionary to track action→key mapping and check for duplicates before assigning
- **Alternative Approach Considered**: Godot's built-in ProjectSettings for keybinds (rejected because it doesn't support runtime remapping easily)

---

## Change Log

| Date | Change | Reason |
|------|--------|--------|
| 2025-12-09 | Initial spec | Feature planned for improved UX and accessibility |
