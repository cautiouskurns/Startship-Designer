class_name RoomData

## Room type enumeration
enum RoomType {
	EMPTY,
	BRIDGE,
	WEAPON,
	SHIELD,
	ENGINE,
	REACTOR,
	ARMOR,
	CONDUIT,
	RELAY  # Feature 1.2: Power relay module (2×2)
}

## Flag to track if data has been loaded from JSON
static var _data_loaded: bool = false

## Helper function to generate rectangular room shape from width and height
static func make_rect_shape(width: int, height: int) -> Array:
	var shape = []
	for y in range(height):
		for x in range(width):
			shape.append([x, y])
	return shape

## Load room and synergy data from JSON file (Phase 2: Data-driven design)
static func _load_data_from_json():
	if _data_loaded:
		return

	# Load JSON file
	var file = FileAccess.open("res://data/rooms.json", FileAccess.READ)
	if not file:
		push_error("Failed to load rooms.json! Using fallback data.")
		_data_loaded = true  # Prevent infinite retry
		return

	var json_text = file.get_as_text()
	file.close()

	# Parse JSON
	var json = JSON.new()
	var error = json.parse(json_text)
	if error != OK:
		push_error("Failed to parse rooms.json: %s" % json.get_error_message())
		_data_loaded = true
		return

	var data = json.data
	if not data:
		push_error("rooms.json is empty!")
		_data_loaded = true
		return

	# Load room definitions
	if data.has("rooms"):
		var rooms_data = data["rooms"]
		for room_name in rooms_data.keys():
			var room_type = _get_room_type_from_name(room_name)
			if room_type == null:
				continue

			var room_def = rooms_data[room_name]

			# Load cost
			if room_def.has("cost"):
				costs[room_type] = room_def["cost"]

			# Load shape (convert [width, height] array to coordinate array)
			if room_def.has("shape"):
				var shape_array = room_def["shape"]
				if shape_array.size() == 2:
					shapes[room_type] = make_rect_shape(shape_array[0], shape_array[1])

			# Load color (convert hex string to Color)
			if room_def.has("color"):
				colors[room_type] = _hex_to_color(room_def["color"])

			# Load label
			if room_def.has("label"):
				labels[room_type] = room_def["label"]

			# Load placement columns
			if room_def.has("placement_columns"):
				placement_columns[room_type] = room_def["placement_columns"]

	# Load synergy definitions
	if data.has("synergies"):
		var synergies_data = data["synergies"]
		for synergy_name in synergies_data.keys():
			var synergy_type = _get_synergy_type_from_name(synergy_name)
			if synergy_type == null:
				continue

			var synergy_def = synergies_data[synergy_name]

			# Load synergy color
			if synergy_def.has("color"):
				synergy_colors[synergy_type] = _hex_to_color(synergy_def["color"])

			# Load synergy pairs
			if synergy_def.has("pairs"):
				for pair in synergy_def["pairs"]:
					if pair.size() == 2:
						var room_a = _get_room_type_from_name(pair[0])
						var room_b = _get_room_type_from_name(pair[1])
						if room_a != null and room_b != null:
							synergy_pairs[[room_a, room_b]] = synergy_type

	_data_loaded = true
	print("Room data loaded from JSON successfully")

## Convert hex color string to Color object (supports #RRGGBB, #RRGGBBAA)
static func _hex_to_color(hex: String) -> Color:
	# Godot 4 Color.html() method for parsing hex colors
	# Ensure hex starts with #
	if not hex.begins_with("#"):
		hex = "#" + hex

	# Use Godot's built-in hex color parser
	return Color.html(hex)

## Convert room name string to RoomType enum
static func _get_room_type_from_name(name: String):
	match name:
		"EMPTY": return RoomType.EMPTY
		"BRIDGE": return RoomType.BRIDGE
		"WEAPON": return RoomType.WEAPON
		"SHIELD": return RoomType.SHIELD
		"ENGINE": return RoomType.ENGINE
		"REACTOR": return RoomType.REACTOR
		"ARMOR": return RoomType.ARMOR
		"CONDUIT": return RoomType.CONDUIT
		"RELAY": return RoomType.RELAY
		_:
			push_warning("Unknown room type: %s" % name)
			return null

## Convert synergy name string to SynergyType enum
static func _get_synergy_type_from_name(name: String):
	match name:
		"FIRE_RATE": return SynergyType.FIRE_RATE
		"SHIELD_CAPACITY": return SynergyType.SHIELD_CAPACITY
		"INITIATIVE": return SynergyType.INITIATIVE
		"DURABILITY": return SynergyType.DURABILITY
		_:
			push_warning("Unknown synergy type: %s" % name)
			return null

## Room costs in budget points (Phase 7.1 updated costs)
## Now loaded from JSON, these are fallback values
static var costs = {
	RoomType.EMPTY: 0,
	RoomType.BRIDGE: 5,  # Changed from 2 (occupies 4 tiles)
	RoomType.WEAPON: 2,  # Changed from 3 (occupies 2 tiles)
	RoomType.SHIELD: 3,  # Unchanged (occupies 2 tiles)
	RoomType.ENGINE: 3,  # Phase 10.7: Changed from 2 (now occupies 4 tiles in 2×2)
	RoomType.REACTOR: 4,  # Phase 10.7: Changed to 4 (now occupies 6 tiles in 3×2 rectangle)
	RoomType.ARMOR: 1,   # Unchanged (occupies 1 tile)
	RoomType.CONDUIT: 1,  # Feature 2.1: EPS conduit (occupies 1 tile)
	RoomType.RELAY: 3  # Feature 1.2: Power relay (occupies 4 tiles in 2×2)
}

## Room shapes - just specify width×height, helper function generates coordinates
static var shapes = {
	RoomType.EMPTY: make_rect_shape(1, 1),   # 1×1
	RoomType.BRIDGE: make_rect_shape(2, 2),  # 2×2 square
	RoomType.WEAPON: make_rect_shape(2, 1),  # 2×1 horizontal bar
	RoomType.SHIELD: make_rect_shape(2, 1),  # 2×1 horizontal bar
	RoomType.ENGINE: make_rect_shape(2, 2),  # 2×2 square
	RoomType.REACTOR: make_rect_shape(3, 2), # 3×2 rectangle
	RoomType.ARMOR: make_rect_shape(1, 1),   # 1×1 single tile
	RoomType.CONDUIT: make_rect_shape(1, 1),  # 1×1 single tile
	RoomType.RELAY: make_rect_shape(2, 2)  # 2×2 square (Feature 1.2)
}

## Room colors (hex values from design doc)
static var colors = {
	RoomType.EMPTY: Color(0, 0, 0, 0),  # Transparent
	RoomType.BRIDGE: Color(0.290, 0.565, 0.886),    # #4A90E2 blue
	RoomType.WEAPON: Color(0.886, 0.290, 0.290),    # #E24A4A red
	RoomType.SHIELD: Color(0.290, 0.886, 0.886),    # #4AE2E2 cyan
	RoomType.ENGINE: Color(0.886, 0.627, 0.290),    # #E2A04A orange
	RoomType.REACTOR: Color(0.886, 0.831, 0.290),   # #E2D44A yellow
	RoomType.ARMOR: Color(0.424, 0.424, 0.424),     # #6C6C6C gray
	RoomType.CONDUIT: Color(1.0, 0.667, 0.0),        # #FFAA00 yellow-orange
	RoomType.RELAY: Color(1.0, 0.533, 0.0)        # #FF8800 orange (Feature 1.2)
}

## Room display labels
static var labels = {
	RoomType.EMPTY: "",
	RoomType.BRIDGE: "⭐ BRIDGE",
	RoomType.WEAPON: "▶ WEAPON",
	RoomType.SHIELD: "◆ SHIELD",
	RoomType.ENGINE: "▲ ENGINE",
	RoomType.REACTOR: "⊕ REACTOR",
	RoomType.ARMOR: "█ ARMOR",
	RoomType.CONDUIT: "─ CONDUIT",
	RoomType.RELAY: "◈ RELAY"  # Feature 1.2
}

## Placement constraints (column indices, -1 means any column)
## Ship points RIGHT in combat (→), so:
## Weapons: rightmost columns (front/bow of ship)
## Engines: leftmost columns (back/stern of ship)
## Others: any column
static var placement_columns = {
	RoomType.EMPTY: [],
	RoomType.BRIDGE: [],       # Any column
	RoomType.WEAPON: [6, 7],   # Rightmost 2 columns (default for 8-wide grid)
	RoomType.SHIELD: [],       # Any column
	RoomType.ENGINE: [0, 1],   # Leftmost 2 columns (back of ship)
	RoomType.REACTOR: [],      # Any column
	RoomType.ARMOR: [],        # Any column
	RoomType.CONDUIT: [],       # Any column
	RoomType.RELAY: []         # Any column (Feature 1.2)
}

## Get cost for a room type
static func get_cost(room_type: RoomType) -> int:
	_load_data_from_json()  # Ensure data is loaded
	return costs.get(room_type, 0)

## Get color for a room type
static func get_color(room_type: RoomType) -> Color:
	_load_data_from_json()  # Ensure data is loaded
	return colors.get(room_type, Color.WHITE)

## Get label for a room type
static func get_label(room_type: RoomType) -> String:
	_load_data_from_json()  # Ensure data is loaded
	return labels.get(room_type, "")

## Synergy type enumeration
enum SynergyType {
	NONE,
	FIRE_RATE,        # Weapon + Weapon
	SHIELD_CAPACITY,  # Shield + Reactor
	INITIATIVE,       # Engine + Engine
	DURABILITY        # Weapon + Armor
}

## Synergy pairs - defines which room combinations create synergies
## Key is array of two RoomTypes, value is the synergy type
static var synergy_pairs = {
	# Weapon + Weapon synergy
	[RoomType.WEAPON, RoomType.WEAPON]: SynergyType.FIRE_RATE,
	# Shield + Reactor synergy
	[RoomType.SHIELD, RoomType.REACTOR]: SynergyType.SHIELD_CAPACITY,
	[RoomType.REACTOR, RoomType.SHIELD]: SynergyType.SHIELD_CAPACITY,
	# Engine + Engine synergy
	[RoomType.ENGINE, RoomType.ENGINE]: SynergyType.INITIATIVE,
	# Weapon + Armor synergy
	[RoomType.WEAPON, RoomType.ARMOR]: SynergyType.DURABILITY,
	[RoomType.ARMOR, RoomType.WEAPON]: SynergyType.DURABILITY
}

## Synergy colors for visual indicators
static var synergy_colors = {
	SynergyType.FIRE_RATE: Color(0.886, 0.565, 0.290),       # Orange #E2904A
	SynergyType.SHIELD_CAPACITY: Color(0.290, 0.886, 0.886), # Cyan #4AE2E2
	SynergyType.INITIATIVE: Color(0.290, 0.565, 0.886),      # Blue #4A90E2
	SynergyType.DURABILITY: Color(0.886, 0.290, 0.290)       # Red #E24A4A
}

## Check if room can be placed in column
## Constraints removed - all rooms can be placed anywhere
static func can_place_in_column(room_type: RoomType, column: int, grid_width: int = -1) -> bool:
	# No placement constraints - allow all rooms in all columns
	return true

## Get synergy type between two room types (order-independent)
static func get_synergy_type(room_type_a: RoomType, room_type_b: RoomType) -> SynergyType:
	_load_data_from_json()  # Ensure data is loaded
	# Check both orderings since dictionary keys are ordered
	var key = [room_type_a, room_type_b]
	if key in synergy_pairs:
		return synergy_pairs[key]
	return SynergyType.NONE

## Get color for synergy type
static func get_synergy_color(synergy_type: SynergyType) -> Color:
	_load_data_from_json()  # Ensure data is loaded
	return synergy_colors.get(synergy_type, Color.WHITE)

## Get shape (array of tile offsets) for a room type
static func get_shape(room_type: RoomType) -> Array:
	_load_data_from_json()  # Ensure data is loaded
	return shapes.get(room_type, [[0, 0]])

## Get bounding box size for a room shape (for tooltips/display)
static func get_shape_size(room_type: RoomType) -> Vector2i:
	var shape = get_shape(room_type)
	if shape.is_empty():
		return Vector2i(1, 1)

	var min_x = 0
	var max_x = 0
	var min_y = 0
	var max_y = 0

	for offset in shape:
		min_x = min(min_x, offset[0])
		max_x = max(max_x, offset[0])
		min_y = min(min_y, offset[1])
		max_y = max(max_y, offset[1])

	return Vector2i(max_x - min_x + 1, max_y - min_y + 1)

## Rotate a room shape by given angle (0°, 90°, 180°, 270°) - Phase 7.3
## Returns new shape array with rotated offsets, normalized to positive coordinates
static func rotate_shape(shape: Array, rotation: int) -> Array:
	# No rotation needed for 0° or invalid angles
	if rotation == 0 or rotation not in [0, 90, 180, 270]:
		return shape

	var rotated_shape = []

	# Apply rotation transform to each offset
	for offset in shape:
		var x = offset[0]
		var y = offset[1]
		var new_x: int
		var new_y: int

		match rotation:
			90:  # 90° CW: [x,y] → [-y,x]
				new_x = -y
				new_y = x
			180:  # 180°: [x,y] → [-x,-y]
				new_x = -x
				new_y = -y
			270:  # 270° CW: [x,y] → [y,-x]
				new_x = y
				new_y = -x
			_:
				new_x = x
				new_y = y

		rotated_shape.append([new_x, new_y])

	# Normalize to positive coordinates (shift so min x = 0, min y = 0)
	var min_x = 0
	var min_y = 0

	for offset in rotated_shape:
		min_x = min(min_x, offset[0])
		min_y = min(min_y, offset[1])

	# Shift all offsets
	var normalized_shape = []
	for offset in rotated_shape:
		normalized_shape.append([offset[0] - min_x, offset[1] - min_y])

	return normalized_shape
