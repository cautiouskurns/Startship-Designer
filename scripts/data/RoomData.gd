class_name RoomData

## Room type enumeration
enum RoomType {
	EMPTY,
	BRIDGE,
	WEAPON,
	SHIELD,
	ENGINE,
	REACTOR,
	ARMOR
}

## Room costs in budget points (Phase 7.1 updated costs)
static var costs = {
	RoomType.EMPTY: 0,
	RoomType.BRIDGE: 5,  # Changed from 2 (occupies 4 tiles)
	RoomType.WEAPON: 2,  # Changed from 3 (occupies 2 tiles)
	RoomType.SHIELD: 3,  # Unchanged (occupies 2 tiles)
	RoomType.ENGINE: 2,  # Unchanged (occupies 2 tiles)
	RoomType.REACTOR: 3,  # Changed from 2 (occupies 4 tiles in T-shape)
	RoomType.ARMOR: 1   # Unchanged (occupies 1 tile)
}

## Room shapes - array of [x_offset, y_offset] tile positions relative to anchor
static var shapes = {
	RoomType.EMPTY: [[0, 0]],
	RoomType.BRIDGE: [[0, 0], [1, 0], [0, 1], [1, 1]],  # 2×2 square
	RoomType.WEAPON: [[0, 0], [1, 0]],  # 1×2 horizontal bar
	RoomType.SHIELD: [[0, 0], [1, 0]],  # 1×2 horizontal bar
	RoomType.ENGINE: [[0, 0], [1, 0]],  # 1×2 horizontal bar
	RoomType.REACTOR: [[0, 1], [1, 0], [1, 1], [1, 2]],  # T-shape (center top, 3 below)
	RoomType.ARMOR: [[0, 0]]   # 1×1 single tile
}

## Room colors (hex values from design doc)
static var colors = {
	RoomType.EMPTY: Color(0, 0, 0, 0),  # Transparent
	RoomType.BRIDGE: Color(0.290, 0.565, 0.886),    # #4A90E2 blue
	RoomType.WEAPON: Color(0.886, 0.290, 0.290),    # #E24A4A red
	RoomType.SHIELD: Color(0.290, 0.886, 0.886),    # #4AE2E2 cyan
	RoomType.ENGINE: Color(0.886, 0.627, 0.290),    # #E2A04A orange
	RoomType.REACTOR: Color(0.886, 0.831, 0.290),   # #E2D44A yellow
	RoomType.ARMOR: Color(0.424, 0.424, 0.424)      # #6C6C6C gray
}

## Room display labels
static var labels = {
	RoomType.EMPTY: "",
	RoomType.BRIDGE: "BRIDGE",
	RoomType.WEAPON: "WEAPON",
	RoomType.SHIELD: "SHIELD",
	RoomType.ENGINE: "ENGINE",
	RoomType.REACTOR: "REACTOR",
	RoomType.ARMOR: "ARMOR"
}

## Placement constraints (row indices, -1 means any row)
## Weapons: rows 0-1 (top 2 rows)
## Engines: rows 4-5 (bottom 2 rows)
## Others: any row
static var placement_rows = {
	RoomType.EMPTY: [],
	RoomType.BRIDGE: [],      # Any row
	RoomType.WEAPON: [0, 1],  # Top 2 rows only
	RoomType.SHIELD: [],      # Any row
	RoomType.ENGINE: [4, 5],  # Bottom 2 rows only
	RoomType.REACTOR: [],     # Any row
	RoomType.ARMOR: []        # Any row
}

## Get cost for a room type
static func get_cost(room_type: RoomType) -> int:
	return costs.get(room_type, 0)

## Get color for a room type
static func get_color(room_type: RoomType) -> Color:
	return colors.get(room_type, Color.WHITE)

## Get label for a room type
static func get_label(room_type: RoomType) -> String:
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

## Check if room can be placed in row (Phase 10.2 - dynamic constraints based on hull grid height)
static func can_place_in_row(room_type: RoomType, row: int, grid_height: int = -1) -> bool:
	# If grid_height provided, calculate constraints dynamically based on hull
	if grid_height > 0:
		match room_type:
			RoomType.WEAPON:
				# Frigate/Cruiser (4/6 rows): Top 2 rows [0, 1]
				# Battleship (7 rows): Top 3 rows [0, 1, 2]
				if grid_height >= 7:
					return row in [0, 1, 2]
				else:
					return row in [0, 1]
			RoomType.ENGINE:
				# Always bottom 2 rows [grid_height - 2, grid_height - 1]
				return row in [grid_height - 2, grid_height - 1]
			_:
				# All other room types can be placed anywhere
				return true

	# Fallback to static placement_rows if grid_height not provided (backwards compatibility)
	var allowed_rows = placement_rows.get(room_type, [])
	# If empty array, any row is allowed
	if allowed_rows.is_empty():
		return true
	# Otherwise check if room is in allowed list
	return row in allowed_rows

## Get synergy type between two room types (order-independent)
static func get_synergy_type(room_type_a: RoomType, room_type_b: RoomType) -> SynergyType:
	# Check both orderings since dictionary keys are ordered
	var key = [room_type_a, room_type_b]
	if key in synergy_pairs:
		return synergy_pairs[key]
	return SynergyType.NONE

## Get color for synergy type
static func get_synergy_color(synergy_type: SynergyType) -> Color:
	return synergy_colors.get(synergy_type, Color.WHITE)

## Get shape (array of tile offsets) for a room type
static func get_shape(room_type: RoomType) -> Array:
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
