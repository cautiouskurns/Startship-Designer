# Save/Load System - Integration Guide

## Implementation Status

✅ **Completed Components:**
- SaveManager.gd autoload (registered in project.godot)
- SaveDialog.tscn and SaveDialog.gd
- LoadDialog.tscn and LoadDialog.gd
- Campaign auto-save infrastructure

## Current State

The Save/Load System has been implemented with the following architecture:

### 1. SaveManager Autoload (`scripts/autoload/SaveManager.gd`)

Provides centralized save/load operations:

**Campaign Progress:**
- `save_campaign_progress()` - Saves campaign state to `user://saves/campaign.json`
- `load_campaign_progress()` - Loads campaign state on startup (auto-called in `_ready()`)
- Integrates with `CampaignState` autoload

**Ship Designs:**
- `save_ship_design(design: ShipDesign)` - Save named ship design
- `load_ship_design(design_name: String)` - Load ship design by name
- `get_saved_designs()` - List all saved designs
- `delete_design(design_name: String)` - Delete a saved design
- Max 10 saved designs (oldest auto-deleted)

### 2. Dialog Scenes

**SaveDialog** (`scenes/ui/SaveDialog.tscn`):
- Modal dialog for entering design name
- Character counter (max 20 characters)
- Validation and error display
- Signals: `design_saved(design_name)`, `cancelled()`

**LoadDialog** (`scenes/ui/LoadDialog.tscn`):
- Modal dialog showing list of saved designs
- Shows design name, mission, budget, and date
- Delete functionality
- Signals: `design_loaded(design)`, `cancelled()`

## Integration with Existing Systems

### Existing Template System

ShipDesigner currently uses a **TemplateManager** system for save/load:
- Lines 1909-1959 in `ShipDesigner.gd`
- Uses `ShipTemplate` objects
- Connected to save/load buttons (lines 33-34, 192-197)

### Recommended Integration Path

**Option 1: Replace Template System (Breaking Change)**
- Remove TemplateManager references
- Replace save/load handlers with SaveManager calls
- Migrate existing templates to SaveManager format

**Option 2: Parallel Systems (Non-Breaking)**
- Keep TemplateManager for templates
- Use SaveManager for campaign auto-save only
- Add separate "Quick Save" buttons that use SaveManager

**Option 3: Hybrid Approach (Recommended)**
- Keep TemplateManager for ship templates (design library)
- Use SaveManager for:
  - Campaign progress auto-save
  - "Current design" auto-save on combat launch
  - Design restore after combat defeat

## Auto-Save Implementation

### Campaign Auto-Save Trigger Points

Add `SaveManager.save_campaign_progress()` at:

1. **After mission completion** (`Combat.gd` when returning to map)
2. **After deployment** (`ShipDesigner.gd` before launching combat) - line 1397
3. **Turn advancement** (`CampaignState.advance_turn()` - already has state)

### Current Design Auto-Save

Replace lines 1375-1377 in `ShipDesigner.gd`:

```gdscript
# OLD (Template system):
var current_template = ShipTemplate.from_ship_designer(self, "Redesign")
GameState.redesign_template = current_template

# NEW (SaveManager system):
var design = SaveManager.ShipDesign.new()
design.design_name = "_autosave_current"
design.mission_index = GameState.current_mission
design.budget_used = current_budget
design.hull_type = GameState.current_hull
design.grid_data = _export_grid_data()
SaveManager.save_ship_design(design)
SaveManager.save_campaign_progress()  # Also save campaign state
```

### Helper Function for Grid Export

Add to `ShipDesigner.gd`:

```gdscript
## Export grid data as 2D array for save system
func _export_grid_data() -> Array:
	var grid_data = []
	for y in range(main_grid.grid_height):
		var row = []
		for x in range(main_grid.grid_width):
			var tile = main_grid.get_tile_at(x, y)
			row.append(int(tile.get_room_type()))
		grid_data.append(row)
	return grid_data

## Import grid data from 2D array for load system
func _import_grid_data(grid_data: Array):
	_clear_all_rooms()  # Clear existing

	for y in range(grid_data.size()):
		var row = grid_data[y]
		for x in range(row.size()):
			var room_type = row[x] as RoomData.RoomType
			if room_type != RoomData.RoomType.EMPTY:
				_place_room_at(x, y, room_type)

	# Update displays
	_update_budget_display()
	update_all_power_states()
	update_palette_counts()
	update_palette_availability()
	_update_ship_status()
	_update_ship_stats()
	update_synergies()
```

## Save File Locations

**macOS:** `~/Library/Application Support/Godot/app_userdata/starship-designer/saves/`
**Windows:** `%APPDATA%\Godot\app_userdata\starship-designer\saves\`
**Linux:** `~/.local/share/godot/app_userdata/starship-designer/saves/`

### File Structure

```
user://saves/
├── campaign.json           # Campaign progress (auto-save)
└── designs/
    ├── glass_cannon.json   # Player-saved design
    ├── balanced_tank.json
    └── _autosave_current.json  # Auto-saved current design
```

## Usage Examples

### Manual Save (from code)

```gdscript
# Create design object
var design = SaveManager.ShipDesign.new()
design.design_name = "My Awesome Ship"
design.mission_index = GameState.current_mission
design.budget_used = current_budget
design.hull_type = GameState.current_hull
design.grid_data = _export_grid_data()

# Save
var success = SaveManager.save_ship_design(design)
if success:
	print("Design saved!")
```

### Manual Load (from code)

```gdscript
# Load design
var design = SaveManager.load_ship_design("My Awesome Ship")
if design:
	_import_grid_data(design.grid_data)
	print("Design loaded!")
```

### Using Dialogs

```gdscript
# Show save dialog
var save_dialog = preload("res://scenes/ui/SaveDialog.tscn").instantiate()
add_child(save_dialog)
save_dialog.design_saved.connect(_on_save_dialog_design_saved)
save_dialog.show_dialog()

func _on_save_dialog_design_saved(design_name: String):
	# Create and save design
	var design = SaveManager.ShipDesign.new()
	design.design_name = design_name
	# ... fill in other fields ...
	SaveManager.save_ship_design(design)
```

## Testing Checklist

- [ ] Campaign progress saves after mission completion
- [ ] Campaign progress loads on game startup
- [ ] SaveDialog validates input (empty name, character limit)
- [ ] LoadDialog shows all saved designs
- [ ] Designs can be deleted from LoadDialog
- [ ] Max 10 designs enforced (oldest deleted)
- [ ] Corrupted save files handled gracefully
- [ ] Grid data export/import works correctly
- [ ] Multi-tile rooms save/load correctly
- [ ] Power routing state restores after load

## Next Steps

1. **Decide on integration approach** (Option 1, 2, or 3 above)
2. **Add auto-save triggers** to campaign flow
3. **Test save/load with real designs**
4. **Add visual feedback** (auto-save indicator)
5. **Handle edge cases** (save while over budget, etc.)

## Notes

- SaveManager auto-loads campaign on startup (`_ready()` in SaveManager.gd)
- Current implementation doesn't save multi-tile room rotation state (future enhancement)
- Relay routing connections not saved (auto-routed on load)
- Design thumbnails not generated (text-only list for now)
