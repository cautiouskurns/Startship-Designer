class_name ShipTemplate

## Data structure for saving/loading ship designs as templates (Phase 10.8)

## Template metadata
var template_name: String = "Unnamed Template"
var hull_type: GameState.HullType = GameState.HullType.CRUISER
var created_date: String = ""
var budget_used: int = 0
var mission_context: int = 0  # Optional: which mission this was designed for

## Room placements - array of room data dictionaries
## Each entry: {type: RoomType, tiles: Array[Vector2i]}
## Tiles are stored as absolute grid positions for the room
var room_placements: Array = []

## Grid dimensions (based on hull type at time of capture)
var grid_width: int = 8
var grid_height: int = 6

## Template categories/tags (optional metadata for filtering)
var tags: Array[String] = []

## Serialize to JSON-compatible dictionary
func to_dict() -> Dictionary:
	# Convert room placements to serializable format
	var serialized_rooms = []
	for room_data in room_placements:
		var tiles_array = []
		for tile_pos in room_data["tiles"]:
			tiles_array.append({"x": tile_pos.x, "y": tile_pos.y})

		serialized_rooms.append({
			"type": int(room_data["type"]),
			"tiles": tiles_array
		})

	return {
		"template_name": template_name,
		"hull_type": int(hull_type),
		"created_date": created_date,
		"budget_used": budget_used,
		"mission_context": mission_context,
		"room_placements": serialized_rooms,
		"grid_width": grid_width,
		"grid_height": grid_height,
		"tags": tags
	}

## Deserialize from dictionary
static func from_dict(data: Dictionary) -> ShipTemplate:
	var template = ShipTemplate.new()

	template.template_name = data.get("template_name", "Unnamed Template")
	template.hull_type = data.get("hull_type", GameState.HullType.CRUISER) as GameState.HullType
	template.created_date = data.get("created_date", "")
	template.budget_used = data.get("budget_used", 0)
	template.mission_context = data.get("mission_context", 0)
	template.grid_width = data.get("grid_width", 8)
	template.grid_height = data.get("grid_height", 6)

	# Convert regular Array to Array[String] for tags
	var tags_data = data.get("tags", [])
	for tag in tags_data:
		template.tags.append(str(tag))

	# Deserialize room placements
	var serialized_rooms = data.get("room_placements", [])
	for room_data in serialized_rooms:
		var tiles = []
		for tile_dict in room_data["tiles"]:
			tiles.append(Vector2i(tile_dict["x"], tile_dict["y"]))

		template.room_placements.append({
			"type": room_data["type"] as RoomData.RoomType,
			"tiles": tiles
		})

	return template

## Create template from current ShipDesigner state
static func from_ship_designer(designer: Node, name: String) -> ShipTemplate:
	var template = ShipTemplate.new()

	# Set metadata
	template.template_name = name
	template.hull_type = GameState.current_hull
	template.created_date = Time.get_datetime_string_from_system()
	template.budget_used = designer.calculate_current_budget()
	template.mission_context = GameState.current_mission
	template.grid_width = designer.ship_grid.GRID_WIDTH
	template.grid_height = designer.ship_grid.GRID_HEIGHT

	# Capture all placed rooms
	for room in designer.placed_rooms:
		var room_type = room.room_type
		var tiles = []

		# Get all tile positions occupied by this room
		var occupied_tiles = room.get_occupied_tiles()
		for tile in occupied_tiles:
			tiles.append(Vector2i(tile.grid_x, tile.grid_y))

		# Sort tiles by position for consistency (top-left to bottom-right)
		tiles.sort_custom(func(a, b): return a.y < b.y or (a.y == b.y and a.x < b.x))

		template.room_placements.append({
			"type": room_type,
			"tiles": tiles
		})

	return template

## Apply template to ShipDesigner
## Clears current design and places all rooms from template
func apply_to_designer(designer: Node) -> bool:
	# Validate hull type match
	if hull_type != GameState.current_hull:
		push_warning("Template hull type (%d) doesn't match current hull (%d)" % [hull_type, GameState.current_hull])
		return false

	# Clear existing design
	designer._clear_all_rooms()

	# Place each room from template
	for room_data in room_placements:
		var room_type = room_data["type"]
		var tiles = room_data["tiles"]

		if tiles.is_empty():
			continue

		# Use first tile as anchor (templates store tiles sorted)
		var anchor = tiles[0]

		# Calculate shape offsets relative to anchor
		var shape = []
		for tile_pos in tiles:
			var offset = [tile_pos.x - anchor.x, tile_pos.y - anchor.y]
			shape.append(offset)

		# Validate and place room with custom shape
		if designer.can_place_shaped_room(anchor.x, anchor.y, room_type, shape):
			# Need to temporarily set the custom shape for placement
			# Since _place_room_at uses RoomData.get_shape(), we'll manually place
			_place_room_manually(designer, anchor.x, anchor.y, room_type, shape)
		else:
			push_warning("Could not place %s at (%d, %d) from template" % [RoomData.get_label(room_type), anchor.x, anchor.y])
			# Continue trying to place other rooms

	# Update all displays
	designer._update_budget_display()
	designer.update_all_power_states()
	designer.update_palette_counts()
	designer.update_palette_availability()
	designer._update_ship_status()
	designer.update_synergies()

	return true

## Manually place a room with custom shape (for template loading)
## This is needed because _place_room_at uses RoomData.get_shape() which doesn't know about rotations
static func _place_room_manually(designer: Node, anchor_x: int, anchor_y: int, room_type: RoomData.RoomType, shape: Array):
	# Get room scene
	var room_scene = designer.room_scenes.get(room_type)
	if not room_scene:
		return

	# Create room instance
	var room = room_scene.instantiate()
	room.room_type = room_type
	room.room_id = designer.next_room_id
	designer.next_room_id += 1

	# Place room on all tiles in shape
	var is_first = true
	for offset in shape:
		var tile_x = anchor_x + offset[0]
		var tile_y = anchor_y + offset[1]
		var target_tile = designer.ship_grid.get_tile_at(tile_x, tile_y)

		if target_tile:
			target_tile.set_occupying_room(room, is_first)
			room.add_occupied_tile(target_tile)
			is_first = false

	# Add to placed rooms tracking array
	designer.placed_rooms.append(room)

	# Update budget
	designer.current_budget = designer.calculate_current_budget()

## Get display summary for UI (e.g., "Frigate - 25 BP - 3 Weapons")
func get_summary() -> String:
	# Count room types
	var weapon_count = 0
	var shield_count = 0
	var engine_count = 0

	for room_data in room_placements:
		match room_data["type"]:
			RoomData.RoomType.WEAPON:
				weapon_count += 1
			RoomData.RoomType.SHIELD:
				shield_count += 1
			RoomData.RoomType.ENGINE:
				engine_count += 1

	var hull_name = GameState.get_hull_name(hull_type)
	return "%s - %d BP - %dW/%dS/%dE" % [hull_name, budget_used, weapon_count, shield_count, engine_count]

## Validate template (check if all placements are valid for current grid)
func is_valid_for_current_hull() -> bool:
	# Check hull type match
	if hull_type != GameState.current_hull:
		return false

	# Check all room positions are within bounds
	var hull_data = GameState.get_current_hull_data()
	var max_width = hull_data["grid_size"].x
	var max_height = hull_data["grid_size"].y

	for room_data in room_placements:
		for tile_pos in room_data["tiles"]:
			if tile_pos.x < 0 or tile_pos.x >= max_width:
				return false
			if tile_pos.y < 0 or tile_pos.y >= max_height:
				return false

	return true
