extends Node

## Global template manager singleton (Phase 10.8)
## Manages saving/loading ship design templates and enemy template assignments

## Storage path for templates
const TEMPLATES_FILE = "user://templates/templates.json"

## Player ship templates (Array of ShipTemplate)
var player_templates: Array[ShipTemplate] = []

## Enemy template assignments per mission (mission_index -> template_name or null)
## null = use auto-generation, string = use template with that name
var enemy_assignments: Dictionary = {
	0: null,  # Mission 0: Patrol
	1: null,  # Mission 1: Convoy
	2: null   # Mission 2: Fleet
}

## Signals
signal templates_changed  # Emitted when templates are saved/deleted
signal enemy_assignments_changed  # Emitted when enemy assignments change

func _ready():
	# Ensure templates directory exists
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("templates"):
		dir.make_dir("templates")

	# Load templates on startup
	load_templates()

## Save a player template
func save_player_template(template: ShipTemplate) -> bool:
	# Check for duplicate names and replace if exists
	var existing_index = -1
	for i in range(player_templates.size()):
		if player_templates[i].template_name == template.template_name:
			existing_index = i
			break

	if existing_index >= 0:
		# Replace existing template
		player_templates[existing_index] = template
	else:
		# Add new template
		player_templates.append(template)

	# Persist to disk
	var success = _save_to_disk()
	if success:
		templates_changed.emit()

	return success

## Delete a player template by name
func delete_player_template(template_name: String) -> bool:
	var found = false
	for i in range(player_templates.size()):
		if player_templates[i].template_name == template_name:
			player_templates.remove_at(i)
			found = true
			break

	if found:
		var success = _save_to_disk()
		if success:
			templates_changed.emit()
		return success

	return false

## Get all player templates
func get_player_templates() -> Array[ShipTemplate]:
	return player_templates

## Get player template by name
func get_player_template(template_name: String) -> ShipTemplate:
	for template in player_templates:
		if template.template_name == template_name:
			return template
	return null

## Get templates for specific hull type
func get_templates_for_hull(hull_type: GameState.HullType) -> Array[ShipTemplate]:
	var filtered: Array[ShipTemplate] = []
	for template in player_templates:
		if template.hull_type == hull_type:
			filtered.append(template)
	return filtered

## Check if template name already exists
func template_name_exists(name: String) -> bool:
	for template in player_templates:
		if template.template_name == name:
			return true
	return false

## Set enemy template assignment for a mission
func set_enemy_assignment(mission_index: int, template_name: String):
	if mission_index < 0 or mission_index > 2:
		push_warning("Invalid mission index: %d" % mission_index)
		return

	enemy_assignments[mission_index] = template_name
	_save_to_disk()
	enemy_assignments_changed.emit()

## Clear enemy template assignment (use auto-generation)
func clear_enemy_assignment(mission_index: int):
	if mission_index < 0 or mission_index > 2:
		push_warning("Invalid mission index: %d" % mission_index)
		return

	enemy_assignments[mission_index] = null
	_save_to_disk()
	enemy_assignments_changed.emit()

## Get enemy template assignment for a mission
func get_enemy_assignment(mission_index: int) -> String:
	if mission_index < 0 or mission_index > 2:
		return ""

	var assignment = enemy_assignments.get(mission_index, null)
	if assignment == null:
		return ""

	return assignment

## Check if mission has enemy template assigned
func has_enemy_assignment(mission_index: int) -> bool:
	var assignment = get_enemy_assignment(mission_index)
	return not assignment.is_empty()

## Get enemy template for a mission (returns ShipTemplate or null)
func get_enemy_template(mission_index: int) -> ShipTemplate:
	var assignment = get_enemy_assignment(mission_index)
	if assignment.is_empty():
		return null

	return get_player_template(assignment)

## Save all data to disk
func _save_to_disk() -> bool:
	var data = {
		"version": 1,
		"player_templates": [],
		"enemy_assignments": enemy_assignments
	}

	# Serialize player templates
	for template in player_templates:
		data["player_templates"].append(template.to_dict())

	# Convert to JSON
	var json_string = JSON.stringify(data, "\t")

	# Write to file
	var file = FileAccess.open(TEMPLATES_FILE, FileAccess.WRITE)
	if not file:
		push_error("Failed to open templates file for writing: %s" % TEMPLATES_FILE)
		return false

	file.store_string(json_string)
	file.close()

	return true

## Load all data from disk
func load_templates():
	# Check if file exists
	if not FileAccess.file_exists(TEMPLATES_FILE):
		# No templates file yet, start fresh
		return

	# Read file
	var file = FileAccess.open(TEMPLATES_FILE, FileAccess.READ)
	if not file:
		push_error("Failed to open templates file for reading: %s" % TEMPLATES_FILE)
		return

	var json_string = file.get_as_text()
	file.close()

	# Parse JSON
	var json = JSON.new()
	var error = json.parse(json_string)
	if error != OK:
		push_error("Failed to parse templates JSON: %s" % json.get_error_message())
		return

	var data = json.data
	if typeof(data) != TYPE_DICTIONARY:
		push_error("Templates JSON root is not a dictionary")
		return

	# Load player templates
	player_templates.clear()
	var templates_data = data.get("player_templates", [])
	for template_dict in templates_data:
		var template = ShipTemplate.from_dict(template_dict)
		player_templates.append(template)

	# Load enemy assignments
	var assignments_data = data.get("enemy_assignments", {})
	for mission_index_str in assignments_data:
		var mission_index = int(mission_index_str)
		enemy_assignments[mission_index] = assignments_data[mission_index_str]

	print("Loaded %d player templates from disk" % player_templates.size())

## Export templates to human-readable format (for debugging/sharing)
func export_templates_to_text() -> String:
	var output = "=== SHIP TEMPLATES ===\n\n"

	for template in player_templates:
		output += "Template: %s\n" % template.template_name
		output += "  Hull: %s (%dx%d)\n" % [GameState.get_hull_name(template.hull_type), template.grid_width, template.grid_height]
		output += "  Budget: %d BP\n" % template.budget_used
		output += "  Mission Context: M%d\n" % template.mission_context
		output += "  Created: %s\n" % template.created_date
		output += "  Rooms: %d\n" % template.room_placements.size()

		# Show room counts
		var counts = {}
		for room_data in template.room_placements:
			var room_type = room_data["type"]
			counts[room_type] = counts.get(room_type, 0) + 1

		for room_type in counts:
			output += "    - %s: %d\n" % [RoomData.get_label(room_type), counts[room_type]]

		output += "\n"

	output += "=== ENEMY ASSIGNMENTS ===\n\n"
	for mission_index in [0, 1, 2]:
		var assignment = get_enemy_assignment(mission_index)
		if assignment.is_empty():
			output += "Mission %d: Auto-Generated\n" % mission_index
		else:
			output += "Mission %d: %s\n" % [mission_index, assignment]

	return output
