extends Node

## Example script demonstrating SaveManager usage
## This is a reference implementation showing how to integrate save/load functionality

## Save current ship design with dialog
func example_save_with_dialog():
	# Instantiate and show save dialog
	var save_dialog_scene = preload("res://scenes/ui/SaveDialog.tscn")
	var save_dialog = save_dialog_scene.instantiate()
	add_child(save_dialog)

	# Connect signals
	save_dialog.design_saved.connect(_on_save_dialog_design_saved)
	save_dialog.cancelled.connect(_on_save_dialog_cancelled)

	# Show dialog
	save_dialog.show_dialog()

func _on_save_dialog_design_saved(design_name: String):
	print("User entered design name: %s" % design_name)

	# Create design object (you would get this data from ShipDesigner)
	var design = SaveManager.ShipDesign.new()
	design.design_name = design_name
	design.mission_index = 0  # Current mission
	design.budget_used = 25   # Current budget spent
	design.hull_type = 1      # GameState.HullType.CRUISER
	design.grid_data = [
		[0, 0, 1, 0, 0, 0, 0, 0],  # Row 0: Bridge at x=2
		[2, 2, 0, 0, 0, 0, 2, 0],  # Row 1: Weapons
		[0, 0, 0, 4, 0, 0, 0, 0],  # Row 2: Reactor
		[0, 0, 0, 0, 0, 0, 0, 0],  # Row 3: Empty
		[0, 0, 0, 0, 0, 0, 0, 0],  # Row 4: Empty
		[5, 5, 0, 0, 0, 0, 0, 0]   # Row 5: Engines
	]

	# Save design
	var success = SaveManager.save_ship_design(design)
	if success:
		print("Design '%s' saved successfully!" % design_name)
	else:
		print("Failed to save design '%s'" % design_name)

func _on_save_dialog_cancelled():
	print("Save cancelled by user")

## Load ship design with dialog
func example_load_with_dialog():
	# Instantiate and show load dialog
	var load_dialog_scene = preload("res://scenes/ui/LoadDialog.tscn")
	var load_dialog = load_dialog_scene.instantiate()
	add_child(load_dialog)

	# Connect signals
	load_dialog.design_loaded.connect(_on_load_dialog_design_loaded)
	load_dialog.cancelled.connect(_on_load_dialog_cancelled)

func _on_load_dialog_design_loaded(design: SaveManager.ShipDesign):
	print("User selected design: %s" % design.design_name)
	print("Mission: %d, Budget: %d, Hull: %d" % [design.mission_index, design.budget_used, design.hull_type])
	print("Grid data has %d rows" % design.grid_data.size())

	# Apply design to ship designer (you would implement this in ShipDesigner)
	# _import_grid_data(design.grid_data)

func _on_load_dialog_cancelled():
	print("Load cancelled by user")

## Direct save without dialog
func example_direct_save():
	var design = SaveManager.ShipDesign.new()
	design.design_name = "Quick Save"
	design.mission_index = GameState.current_mission
	design.budget_used = 30
	design.hull_type = GameState.current_hull
	design.grid_data = _get_example_grid_data()

	var success = SaveManager.save_ship_design(design)
	if success:
		print("Quick save successful!")

## Direct load without dialog
func example_direct_load():
	var design = SaveManager.load_ship_design("Quick Save")
	if design:
		print("Loaded design: %s" % design.design_name)
		print("Mission %d, Budget %d" % [design.mission_index, design.budget_used])
	else:
		print("Design not found or corrupted")

## List all saved designs
func example_list_designs():
	var designs = SaveManager.get_saved_designs()
	print("Found %d saved designs:" % designs.size())
	for design in designs:
		print("  - %s (M%d, %d BP, %s)" % [
			design.design_name,
			design.mission_index + 1,
			design.budget_used,
			design.last_modified
		])

## Delete a design
func example_delete_design():
	var success = SaveManager.delete_design("Quick Save")
	if success:
		print("Design deleted successfully")
	else:
		print("Failed to delete design")

## Save campaign progress
func example_save_campaign():
	var success = SaveManager.save_campaign_progress()
	if success:
		print("Campaign progress saved!")
		print("Turn %d/%d saved" % [CampaignState.current_turn, CampaignState.max_turns])

## Load campaign progress
func example_load_campaign():
	var success = SaveManager.load_campaign_progress()
	if success:
		print("Campaign progress loaded!")
		print("Currently on turn %d/%d" % [CampaignState.current_turn, CampaignState.max_turns])
	else:
		print("No campaign save file found or corrupted")

## Helper: Get example grid data
func _get_example_grid_data() -> Array:
	return [
		[0, 0, 1, 0, 0, 0, 0, 0],  # Row 0: room type 1 (Bridge) at x=2
		[2, 2, 0, 0, 0, 0, 2, 0],  # Row 1: room type 2 (Weapon) at x=0,1,6
		[0, 0, 0, 4, 0, 0, 0, 0],  # Row 2: room type 4 (Reactor) at x=3
		[0, 0, 0, 0, 0, 0, 0, 0],  # Row 3: empty
		[0, 0, 0, 0, 0, 0, 0, 0],  # Row 4: empty
		[5, 5, 0, 0, 0, 0, 0, 0]   # Row 5: room type 5 (Engine) at x=0,1
	]

## Test all functionality
func run_all_tests():
	print("\n=== SaveManager Test Suite ===\n")

	print("1. Direct save test:")
	example_direct_save()

	print("\n2. List designs test:")
	example_list_designs()

	print("\n3. Direct load test:")
	example_direct_load()

	print("\n4. Campaign save test:")
	example_save_campaign()

	print("\n5. Campaign load test:")
	example_load_campaign()

	print("\n6. Delete design test:")
	example_delete_design()

	print("\n7. List designs after delete:")
	example_list_designs()

	print("\n=== Tests Complete ===\n")
