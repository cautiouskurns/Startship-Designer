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
	RoomType.ENGINE: 3,  # Phase 10.7: Changed from 2 (now occupies 4 tiles in 2×2)
	RoomType.REACTOR: 4,  # Phase 10.7: Changed to 4 (now occupies 6 tiles in 3×2 rectangle)
	RoomType.ARMOR: 1   # Unchanged (occupies 1 tile)
}

## Room shapes - array of [x_offset, y_offset] tile positions relative to anchor
static var shapes = {
	RoomType.EMPTY: [[0, 0]],
	RoomType.BRIDGE: [[0, 0], [1, 0], [0, 1], [1, 1]],  # 2×2 square
	RoomType.WEAPON: [[0, 0], [1, 0]],  # 1×2 horizontal bar
	RoomType.SHIELD: [[0, 0], [1, 0]],  # 1×2 horizontal bar
	RoomType.ENGINE: [[0, 0], [1, 0], [0, 1], [1, 1]],  # 2×2 square (Phase 10.7)
	RoomType.REACTOR: [[0, 0], [1, 0], [2, 0], [0, 1], [1, 1], [2, 1]],  # 3×2 rectangle (Phase 10.7)
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
	RoomType.ARMOR: []         # Any column
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

## Check if room can be placed in column (Phase 10.4 - expanded weapon placement for tapered hulls)
## Ship points RIGHT (→) in combat, so weapons go on right (front), engines on left (back)
static func can_place_in_column(room_type: RoomType, column: int, grid_width: int = -1) -> bool:
	# If grid_width provided, calculate constraints dynamically based on hull
	if grid_width > 0:
		match room_type:
			RoomType.WEAPON:
				# Phase 10.4: Expanded to account for tapered hulls
				# Weapons allowed in right half of ship (front section)
				# Frigate (10 wide): Right half columns [4, 5, 6, 7, 8, 9]
				# Cruiser (8 wide): Right half columns [3, 4, 5, 6, 7]
				# Battleship (7 wide): Right half columns [2, 3, 4, 5, 6]
				var half_point = int(grid_width / 2.0)
				return column >= half_point - 1
			RoomType.ENGINE:
				# Always leftmost 2 columns [0, 1] (back of ship)
				return column in [0, 1]
			_:
				# All other room types can be placed anywhere
				return true

	# Fallback to static placement_columns if grid_width not provided (backwards compatibility)
	var allowed_columns = placement_columns.get(room_type, [])
	# If empty array, any column is allowed
	if allowed_columns.is_empty():
		return true
	# Otherwise check if column is in allowed list
	return column in allowed_columns

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
