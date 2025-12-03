class_name ShipData

## Represents a ship's configuration and stats for combat

## Flag to track if enemy data has been loaded from JSON
static var _enemy_data_loaded: bool = false

## Enemy ship data loaded from JSON (Phase 3)
static var enemies_data: Dictionary = {}

## Targeting priority for enemy AI (Feature 1 MVP)
enum TargetingPriority {
	RANDOM,         # Target any component (Mission 0 Scout)
	WEAPONS_FIRST,  # Prioritize weapons (Mission 1 Raider)
	POWER_FIRST     # Prioritize reactors/relays (Mission 2 Dreadnought)
}

## 8x6 grid of room types (Phase 7.1 - still used for backward compatibility and power calc)
var grid: Array = []  # Array of Arrays (rows), each containing RoomType values

## 8x6 grid tracking which rooms are powered
var power_grid: Array = []  # Array of Arrays (rows), each containing bool values

## Phase 7.1: 8x6 grid of room instance IDs (-1 for empty tiles)
var room_id_grid: Array = []  # Array of Arrays (rows), each containing int room_id values

## Phase 7.1: Dictionary mapping room_id to room instance data
## Format: {room_id: {type: RoomType, tiles: Array[Vector2i]}}
var room_instances: Dictionary = {}

## Health points
var max_hp: int = 0
var current_hp: int = 0

## Targeting priority for enemy AI (Feature 1 MVP)
var targeting_priority: TargetingPriority = TargetingPriority.RANDOM

## Initialize with grid data and HP
func _init(room_grid: Array = [], hp: int = 100):
	grid = room_grid
	max_hp = hp
	current_hp = hp

## Count number of specific room type in grid (Phase 10.9 - count room instances, not tiles)
func count_room_type(room_type: RoomData.RoomType) -> int:
	# Use room_instances if available (correct for multi-tile rooms)
	if not room_instances.is_empty():
		var count = 0
		for room_id in room_instances:
			var room_data = room_instances[room_id]
			if room_data["type"] == room_type:
				count += 1
		return count
	else:
		# Fallback for old single-tile system
		var count = 0
		for row in grid:
			for cell in row:
				if cell == room_type:
					count += 1
		return count

## Get all active (non-empty) room positions as array of Vector2i
func get_active_room_positions() -> Array:
	var positions = []
	for y in range(grid.size()):
		for x in range(grid[y].size()):
			if grid[y][x] != RoomData.RoomType.EMPTY:
				positions.append(Vector2i(x, y))
	return positions

## Check if ship has a Bridge
func has_bridge() -> bool:
	return count_room_type(RoomData.RoomType.BRIDGE) > 0

## Calculate hull HP based on armor count
func calculate_hull_hp() -> int:
	var armor_count = count_room_type(RoomData.RoomType.ARMOR)
	return BalanceConstants.BASE_HULL_HP + (armor_count * BalanceConstants.HP_PER_ARMOR)

## Destroy room at grid position (old single-tile method, kept for backward compatibility)
func destroy_room_at(x: int, y: int):
	if y >= 0 and y < grid.size() and x >= 0 and x < grid[y].size():
		grid[y][x] = RoomData.RoomType.EMPTY

## Destroy entire room instance by room_id (Phase 7.1 - destroys all tiles of multi-tile room)
func destroy_room_instance(room_id: int):
	# Check if room instance exists
	if not room_id in room_instances:
		return

	var room_data = room_instances[room_id]

	# Clear all tiles occupied by this room
	for tile_pos in room_data["tiles"]:
		var x = tile_pos.x
		var y = tile_pos.y

		# Clear from grid
		if y >= 0 and y < grid.size() and x >= 0 and x < grid[y].size():
			grid[y][x] = RoomData.RoomType.EMPTY

		# Clear from room_id_grid
		if y >= 0 and y < room_id_grid.size() and x >= 0 and x < room_id_grid[y].size():
			room_id_grid[y][x] = -1

	# Remove from room_instances dictionary
	room_instances.erase(room_id)

## Calculate power grid based on reactor positions and relay coverage (Phase 10.2 - multi-tile room support)
## secondary_grid: Optional SecondaryGrid with relay connections for relay coverage calculation
func calculate_power_grid(secondary_grid = null):
	# Initialize power_grid with same dimensions as grid
	power_grid.clear()
	for y in range(grid.size()):
		var power_row = []
		for x in range(grid[y].size()):
			power_row.append(false)
		power_grid.append(power_row)

	# Phase 10.2: Track which room instances are powered (not individual tiles)
	var powered_room_ids = {}  # Dictionary of room_id -> true for powered rooms

	# First pass: Determine which room instances should be powered by reactors
	for y in range(grid.size()):
		for x in range(grid[y].size()):
			var room_type = grid[y][x]

			# Skip empty tiles
			if room_type == RoomData.RoomType.EMPTY:
				continue

			# Get room ID for this tile (if using room instances)
			var room_id = -1
			if not room_id_grid.is_empty():
				if y < room_id_grid.size() and x < room_id_grid[y].size():
					room_id = room_id_grid[y][x]

			# Bridge and Reactor always powered (special cases)
			if room_type == RoomData.RoomType.BRIDGE or room_type == RoomData.RoomType.REACTOR:
				if room_id != -1:
					powered_room_ids[room_id] = true
				else:
					power_grid[y][x] = true  # Fallback for old single-tile system
				continue

			# Check 4 adjacent tiles for reactors
			var adjacent_positions = [
				Vector2i(x - 1, y),  # Left
				Vector2i(x + 1, y),  # Right
				Vector2i(x, y - 1),  # Up
				Vector2i(x, y + 1)   # Down
			]

			for pos in adjacent_positions:
				# Check bounds
				if pos.y >= 0 and pos.y < grid.size() and pos.x >= 0 and pos.x < grid[pos.y].size():
					# Check if adjacent tile is a reactor
					if grid[pos.y][pos.x] == RoomData.RoomType.REACTOR:
						# Power entire room instance (if using room instances)
						if room_id != -1:
							powered_room_ids[room_id] = true
						else:
							# Fallback for old single-tile system
							power_grid[y][x] = true
						break
					# Fallback for enemy ships: treat relays like mini-reactors (power adjacent rooms)
					# Only if no secondary_grid provided (player ships use relay connections)
					elif grid[pos.y][pos.x] == RoomData.RoomType.RELAY and secondary_grid == null:
						# Power entire room instance (if using room instances)
						if room_id != -1:
							powered_room_ids[room_id] = true
						else:
							# Fallback for old single-tile system
							power_grid[y][x] = true
						break

	# Relay coverage pass: Power rooms within 3-tile radius of powered relays
	if secondary_grid and not room_instances.is_empty():
		# Find all relays with valid powered connections
		for room_id in room_instances:
			var room_data = room_instances[room_id]
			if room_data["type"] != RoomData.RoomType.RELAY:
				continue

			# Check if relay has a valid powered connection
			var connection = secondary_grid.get_connection(room_id)
			if connection.is_empty() or not connection.get("is_powered", false):
				continue

			# Calculate relay center (2×2 relay, center is average of all tiles)
			var relay_tiles: Array = room_data["tiles"]
			if relay_tiles.is_empty():
				continue

			var relay_center_x = 0.0
			var relay_center_y = 0.0
			for tile_pos in relay_tiles:
				relay_center_x += tile_pos.x
				relay_center_y += tile_pos.y
			relay_center_x /= relay_tiles.size()
			relay_center_y /= relay_tiles.size()

			# Power all rooms within RELAY_COVERAGE_RADIUS tiles of relay center
			for check_room_id in room_instances:
				var check_room_data = room_instances[check_room_id]
				var check_room_type = check_room_data["type"]

				# Skip if already powered, or if it's EMPTY, BRIDGE, REACTOR (self-powered)
				if check_room_id in powered_room_ids:
					continue
				if check_room_type == RoomData.RoomType.EMPTY or check_room_type == RoomData.RoomType.BRIDGE or check_room_type == RoomData.RoomType.REACTOR:
					continue

				# Calculate distance from relay center to room center
				var room_tiles: Array = check_room_data["tiles"]
				if room_tiles.is_empty():
					continue

				var room_center_x = 0.0
				var room_center_y = 0.0
				for tile_pos in room_tiles:
					room_center_x += tile_pos.x
					room_center_y += tile_pos.y
				room_center_x /= room_tiles.size()
				room_center_y /= room_tiles.size()

				# Check distance (Euclidean distance from centers)
				var dx = room_center_x - relay_center_x
				var dy = room_center_y - relay_center_y
				var distance = sqrt(dx * dx + dy * dy)

				# Power room if within coverage radius
				if distance <= BalanceConstants.RELAY_COVERAGE_RADIUS:
					powered_room_ids[check_room_id] = true

	# Second pass: Apply power to all tiles belonging to powered room instances
	for y in range(grid.size()):
		for x in range(grid[y].size()):
			if not room_id_grid.is_empty():
				if y < room_id_grid.size() and x < room_id_grid[y].size():
					var room_id = room_id_grid[y][x]
					if room_id in powered_room_ids:
						power_grid[y][x] = true

## Check if room at position is powered
func is_room_powered(x: int, y: int) -> bool:
	if power_grid.size() == 0:
		return true  # If power grid not initialized, assume all powered (backward compat)

	if y >= 0 and y < power_grid.size() and x >= 0 and x < power_grid[y].size():
		return power_grid[y][x]

	return false

## Count number of powered rooms of specific type (Phase 10.9 - count room instances, not tiles)
func count_powered_room_type(room_type: RoomData.RoomType) -> int:
	# Use room_instances if available (correct for multi-tile rooms)
	if not room_instances.is_empty():
		var count = 0
		for room_id in room_instances:
			var room_data = room_instances[room_id]
			if room_data["type"] == room_type:
				# Check if any tile of this room instance is powered
				var is_powered = false
				for tile_pos in room_data["tiles"]:
					if is_room_powered(tile_pos.x, tile_pos.y):
						is_powered = true
						break
				if is_powered:
					count += 1
		return count
	else:
		# Fallback for old single-tile system
		var count = 0
		for y in range(grid.size()):
			for x in range(grid[y].size()):
				if grid[y][x] == room_type and is_room_powered(x, y):
					count += 1
		return count

## Recalculate power grid (called when reactor destroyed in combat)
func recalculate_power():
	calculate_power_grid()

## Create ShipData from ShipDesigner's grid_tiles and placed_rooms arrays (Phase 10.4 - sparse grids for shaped hulls)
## secondary_grid: Optional SecondaryGrid with relay connections for relay coverage calculation
static func from_designer_grid(grid_tiles: Array, placed_rooms: Array = [], grid_width: int = 8, grid_height: int = 6, secondary_grid = null) -> ShipData:
	var room_grid = []
	var room_id_grid_data = []

	# Initialize 2D arrays with EMPTY values (Phase 10.4 - handles sparse grids)
	for y in range(grid_height):
		var row = []
		var id_row = []
		for x in range(grid_width):
			row.append(RoomData.RoomType.EMPTY)
			id_row.append(-1)
		room_grid.append(row)
		room_id_grid_data.append(id_row)

	# Fill in data from actual tiles (Phase 10.4 - works with shaped hulls where some positions don't exist)
	for tile in grid_tiles:
		var x = tile.grid_x
		var y = tile.grid_y

		# Set room type
		room_grid[y][x] = tile.get_room_type()

		# Set room ID if occupied
		if tile.is_occupied() and tile.occupying_room:
			room_id_grid_data[y][x] = tile.occupying_room.room_id
		else:
			room_id_grid_data[y][x] = -1

	# Create ship with placeholder HP, then calculate based on armor
	var ship = ShipData.new(room_grid, 0)
	ship.room_id_grid = room_id_grid_data

	# Build room_instances dictionary (Phase 7.1)
	for room in placed_rooms:
		var tile_positions = []
		for tile in room.get_occupied_tiles():
			tile_positions.append(Vector2i(tile.grid_x, tile.grid_y))

		ship.room_instances[room.room_id] = {
			"type": room.room_type,
			"tiles": tile_positions
		}

	var hull_hp = ship.calculate_hull_hp()
	ship.max_hp = hull_hp
	ship.current_hp = hull_hp

	# Calculate power grid with relay coverage
	ship.calculate_power_grid(secondary_grid)

	return ship

## Load enemy ship data from JSON file (Phase 3: Data-driven design)
static func _load_enemy_data_from_json():
	if _enemy_data_loaded:
		return

	# Load JSON file
	var file = FileAccess.open("res://data/enemies.json", FileAccess.READ)
	if not file:
		push_error("Failed to load enemies.json! Using fallback data.")
		_enemy_data_loaded = true  # Prevent infinite retry
		return

	var json_text = file.get_as_text()
	file.close()

	# Parse JSON
	var json = JSON.new()
	var error = json.parse(json_text)
	if error != OK:
		push_error("Failed to parse enemies.json: %s" % json.get_error_message())
		_enemy_data_loaded = true
		return

	var data = json.data
	if not data:
		push_error("enemies.json is empty!")
		_enemy_data_loaded = true
		return

	# Load enemy definitions
	if data.has("enemies"):
		enemies_data = data["enemies"]
		print("Enemy ship data loaded from JSON successfully")

	_enemy_data_loaded = true

## Convert targeting priority string to enum
static func _get_targeting_priority_from_name(name: String) -> TargetingPriority:
	match name:
		"RANDOM": return TargetingPriority.RANDOM
		"WEAPONS_FIRST": return TargetingPriority.WEAPONS_FIRST
		"POWER_FIRST": return TargetingPriority.POWER_FIRST
		_:
			push_warning("Unknown targeting priority: %s" % name)
			return TargetingPriority.RANDOM

## Convert room type string to RoomType enum (for enemy data loading)
static func _get_room_type_from_name(name: String):
	match name:
		"EMPTY": return RoomData.RoomType.EMPTY
		"BRIDGE": return RoomData.RoomType.BRIDGE
		"WEAPON": return RoomData.RoomType.WEAPON
		"SHIELD": return RoomData.RoomType.SHIELD
		"ENGINE": return RoomData.RoomType.ENGINE
		"REACTOR": return RoomData.RoomType.REACTOR
		"ARMOR": return RoomData.RoomType.ARMOR
		"CONDUIT": return RoomData.RoomType.CONDUIT
		"RELAY": return RoomData.RoomType.RELAY
		_:
			push_warning("Unknown room type for enemy: %s" % name)
			return null

## Create enemy ship from JSON data by enemy ID (Phase 3)
static func create_enemy_from_id(enemy_id: String) -> ShipData:
	_load_enemy_data_from_json()  # Ensure data is loaded

	if not enemies_data.has(enemy_id):
		push_error("Enemy ID '%s' not found in enemies.json! Using fallback." % enemy_id)
		# Fallback to original hardcoded functions
		match enemy_id:
			"scout": return create_mission1_scout()
			"raider": return create_mission2_raider()
			"dreadnought": return create_mission3_dreadnought()
			_: return create_mission1_scout()

	var enemy_def = enemies_data[enemy_id]

	# Parse room placements
	var room_placements = []
	if enemy_def.has("room_placements"):
		for placement in enemy_def["room_placements"]:
			var room_type = _get_room_type_from_name(placement.get("type", "EMPTY"))
			if room_type != null:
				room_placements.append({
					"type": room_type,
					"x": placement.get("x", 0),
					"y": placement.get("y", 0)
				})

	# Create ship
	var hp = enemy_def.get("hp", 60)
	var grid_width = enemy_def.get("grid_width", 8)
	var grid_height = enemy_def.get("grid_height", 6)

	var ship = create_enemy_ship_with_shaped_rooms(room_placements, hp, grid_width, grid_height)

	# Set targeting priority
	var priority_name = enemy_def.get("targeting_priority", "RANDOM")
	ship.targeting_priority = _get_targeting_priority_from_name(priority_name)

	return ship

## Helper to create enemy ships with shaped rooms (Phase 10.4)
## room_placements: Array of {type: RoomType, x: int, y: int}
static func create_enemy_ship_with_shaped_rooms(room_placements: Array, hp: int, grid_width: int = 8, grid_height: int = 6) -> ShipData:
	# Initialize grids
	var room_grid = []
	var room_id_grid_data = []

	for y in range(grid_height):
		var row = []
		var id_row = []
		for x in range(grid_width):
			row.append(RoomData.RoomType.EMPTY)
			id_row.append(-1)
		room_grid.append(row)
		room_id_grid_data.append(id_row)

	# Place shaped rooms
	var room_instances_dict = {}
	var next_room_id = 1

	for placement in room_placements:
		var room_type = placement["type"]
		var anchor_x = placement["x"]
		var anchor_y = placement["y"]
		var room_id = next_room_id
		next_room_id += 1

		# Get shape for this room type
		var shape = RoomData.get_shape(room_type)
		var tile_positions = []

		# Place all tiles in the shape
		for offset in shape:
			var tile_x = anchor_x + offset[0]
			var tile_y = anchor_y + offset[1]

			# Bounds check
			if tile_y >= 0 and tile_y < grid_height and tile_x >= 0 and tile_x < grid_width:
				room_grid[tile_y][tile_x] = room_type
				room_id_grid_data[tile_y][tile_x] = room_id
				tile_positions.append(Vector2i(tile_x, tile_y))

		# Add to room_instances dictionary
		room_instances_dict[room_id] = {
			"type": room_type,
			"tiles": tile_positions
		}

	# Create ship
	var ship = ShipData.new(room_grid, hp)
	ship.room_id_grid = room_id_grid_data
	ship.room_instances = room_instances_dict

	# Calculate power grid
	ship.calculate_power_grid()

	return ship

## Create Mission 1 Scout enemy ship (Phase 10.7 - updated for 3×2 reactor)
## Enemy faces LEFT (←): weapons on left, engines on right
## Basic threat: 1 weapon, 1 shield, minimal armor - HP: 60
static func create_mission1_scout() -> ShipData:
	var room_placements = [
		# Reactor (3×2) at (1,1): tiles at (1,1), (2,1), (3,1), (1,2), (2,2), (3,2)
		{"type": RoomData.RoomType.REACTOR, "x": 1, "y": 1},
		# Weapon (1×2) at (0,1): tiles at (0,1), (1,1) - (1,1) IS reactor
		{"type": RoomData.RoomType.WEAPON, "x": 0, "y": 1},
		# Shield (1×2) at (3,0): tiles at (3,0), (4,0) - adjacent to (3,1) reactor
		{"type": RoomData.RoomType.SHIELD, "x": 3, "y": 0},
		# Bridge (2×2) at center-right
		{"type": RoomData.RoomType.BRIDGE, "x": 4, "y": 2},
		# Engine (2×2) at back right
		{"type": RoomData.RoomType.ENGINE, "x": 6, "y": 2},
		# Armor for some HP
		{"type": RoomData.RoomType.ARMOR, "x": 0, "y": 4}
	]

	var ship = create_enemy_ship_with_shaped_rooms(room_placements, 60)
	ship.targeting_priority = TargetingPriority.RANDOM  # Feature 1 MVP: Scout uses random targeting
	return ship

## Create Mission 2 Raider enemy ship (Phase 10.7 - updated for 3×2 reactor)
## Enemy faces LEFT (←): weapons on left, engines on right
## Moderate threat: 3 weapons with synergies, 2 shields, armor - HP: 80
static func create_mission2_raider() -> ShipData:
	var room_placements = [
		# Reactor (3×2) at (1,1): tiles at (1,1), (2,1), (3,1), (1,2), (2,2), (3,2)
		{"type": RoomData.RoomType.REACTOR, "x": 1, "y": 1},
		# Weapons (three 1×2) adjacent to reactor for power and fire rate synergies
		{"type": RoomData.RoomType.WEAPON, "x": 0, "y": 1},  # tiles (0,1), (1,1) - (1,1) IS reactor
		{"type": RoomData.RoomType.WEAPON, "x": 0, "y": 2},  # tiles (0,2), (1,2) - (1,2) IS reactor, adjacent to weapon above
		{"type": RoomData.RoomType.WEAPON, "x": 1, "y": 0},  # tiles (1,0), (2,0) - adjacent to (1,1) and (2,1) reactor
		# Shields (two 1×2) adjacent to reactor for capacity synergy
		{"type": RoomData.RoomType.SHIELD, "x": 3, "y": 0},  # tiles (3,0), (4,0) - adjacent to (3,1) reactor
		{"type": RoomData.RoomType.SHIELD, "x": 2, "y": 2},  # tiles (2,2), (3,2) - (2,2) and (3,2) ARE reactor
		# Bridge (2×2) at center-right
		{"type": RoomData.RoomType.BRIDGE, "x": 4, "y": 2},
		# Engine (2×2) at back right
		{"type": RoomData.RoomType.ENGINE, "x": 6, "y": 2},
		# Armor for HP and durability synergy with weapons
		{"type": RoomData.RoomType.ARMOR, "x": 0, "y": 0},
		{"type": RoomData.RoomType.ARMOR, "x": 0, "y": 3},
		{"type": RoomData.RoomType.ARMOR, "x": 1, "y": 3}
	]

	var ship = create_enemy_ship_with_shaped_rooms(room_placements, 80)
	ship.targeting_priority = TargetingPriority.WEAPONS_FIRST  # Feature 1 MVP: Raider targets weapons
	return ship

## Create Mission 3 Dreadnought enemy ship (Phase 10.7 - updated for 3×2 reactor)
## Enemy faces LEFT (←): weapons on left, engines on right
## Maximum threat: 4 weapons with synergies, 3 shields with synergies, dual reactors, armor - HP: 120
static func create_mission3_dreadnought() -> ShipData:
	var room_placements = [
		# Reactors (two 3×2) for full power coverage
		{"type": RoomData.RoomType.REACTOR, "x": 1, "y": 0},  # tiles (1,0), (2,0), (3,0), (1,1), (2,1), (3,1)
		{"type": RoomData.RoomType.REACTOR, "x": 1, "y": 3},  # tiles (1,3), (2,3), (3,3), (1,4), (2,4), (3,4)
		# Weapons (four 1×2) adjacent to reactors for power and synergies
		{"type": RoomData.RoomType.WEAPON, "x": 0, "y": 0},  # tiles (0,0), (1,0) - (1,0) IS reactor 1
		{"type": RoomData.RoomType.WEAPON, "x": 0, "y": 1},  # tiles (0,1), (1,1) - (1,1) IS reactor 1, adjacent to weapon above
		{"type": RoomData.RoomType.WEAPON, "x": 0, "y": 3},  # tiles (0,3), (1,3) - (1,3) IS reactor 2
		{"type": RoomData.RoomType.WEAPON, "x": 0, "y": 4},  # tiles (0,4), (1,4) - (1,4) IS reactor 2, adjacent to weapon above
		# Shields (three 1×2) adjacent to reactors for capacity synergy (NO overlaps)
		{"type": RoomData.RoomType.SHIELD, "x": 4, "y": 0},  # tiles (4,0), (5,0) - adjacent to (3,0) reactor 1
		{"type": RoomData.RoomType.SHIELD, "x": 1, "y": 2},  # tiles (1,2), (2,2) - adjacent to (1,1) and (2,1) reactor 1
		{"type": RoomData.RoomType.SHIELD, "x": 4, "y": 4},  # tiles (4,4), (5,4) - adjacent to (3,4) reactor 2
		# Bridge (2×2) at center-right
		{"type": RoomData.RoomType.BRIDGE, "x": 5, "y": 1},  # tiles (5,1), (6,1), (5,2), (6,2)
		# Engine (2×2) at back right (no overlap with bridge)
		{"type": RoomData.RoomType.ENGINE, "x": 6, "y": 3},  # tiles (6,3), (7,3), (6,4), (7,4)
		# Armor for HP and durability synergies with weapons
		{"type": RoomData.RoomType.ARMOR, "x": 0, "y": 2},  # Between weapon rows
		{"type": RoomData.RoomType.ARMOR, "x": 3, "y": 2},  # Between reactors
		{"type": RoomData.RoomType.ARMOR, "x": 4, "y": 3},  # Between shields
		{"type": RoomData.RoomType.ARMOR, "x": 0, "y": 5},  # Bottom protection
		{"type": RoomData.RoomType.ARMOR, "x": 1, "y": 5},  # Bottom protection
		{"type": RoomData.RoomType.ARMOR, "x": 4, "y": 5}   # Bottom right protection
	]

	var ship = create_enemy_ship_with_shaped_rooms(room_placements, 120)
	ship.targeting_priority = TargetingPriority.POWER_FIRST  # Feature 1 MVP: Dreadnought targets power systems
	return ship

## Calculate synergy bonuses based on adjacent compatible rooms
## Returns a Dictionary with synergy counts and per-room bonuses
func calculate_synergy_bonuses() -> Dictionary:
	var synergy_counts = {
		RoomData.SynergyType.FIRE_RATE: 0,
		RoomData.SynergyType.SHIELD_CAPACITY: 0,
		RoomData.SynergyType.INITIATIVE: 0,
		RoomData.SynergyType.DURABILITY: 0
	}

	# Track synergies per room position for damage/absorption bonuses
	# Key: Vector2i(x,y), Value: Array of SynergyTypes affecting this room
	var room_synergies = {}

	var checked_pairs = {}

	# Check each room for synergies with adjacent rooms
	for y in range(grid.size()):
		for x in range(grid[y].size()):
			var room_type = grid[y][x]
			if room_type == RoomData.RoomType.EMPTY:
				continue

			# Check right and down only to avoid counting same pair twice
			var adjacent_checks = [
				Vector2i(x + 1, y),  # Right
				Vector2i(x, y + 1)   # Down
			]

			for adj_pos in adjacent_checks:
				# Check bounds
				if adj_pos.y < 0 or adj_pos.y >= grid.size() or adj_pos.x < 0 or adj_pos.x >= grid[adj_pos.y].size():
					continue

				var adj_room_type = grid[adj_pos.y][adj_pos.x]
				if adj_room_type == RoomData.RoomType.EMPTY:
					continue

				# Phase 7.1: Skip if both tiles belong to the same room instance
				# Check room_id_grid to see if they're the same multi-tile room
				if not room_id_grid.is_empty():
					if y < room_id_grid.size() and x < room_id_grid[y].size():
						if adj_pos.y < room_id_grid.size() and adj_pos.x < room_id_grid[adj_pos.y].size():
							var room_id_a = room_id_grid[y][x]
							var room_id_b = room_id_grid[adj_pos.y][adj_pos.x]
							# If both have valid room IDs and they're the same, skip
							if room_id_a != -1 and room_id_b != -1 and room_id_a == room_id_b:
								continue  # Same room instance, skip synergy

				var synergy_type = RoomData.get_synergy_type(room_type, adj_room_type)
				if synergy_type == RoomData.SynergyType.NONE:
					continue

				# Create unique key for this pair to avoid duplicates
				var pair_key = "%d,%d-%d,%d" % [x, y, adj_pos.x, adj_pos.y]
				if pair_key in checked_pairs:
					continue

				checked_pairs[pair_key] = true
				synergy_counts[synergy_type] += 1

				# Track which rooms are affected by this synergy
				var pos_a = Vector2i(x, y)
				var pos_b = Vector2i(adj_pos.x, adj_pos.y)

				if not (pos_a in room_synergies):
					room_synergies[pos_a] = []
				if not (pos_b in room_synergies):
					room_synergies[pos_b] = []

				room_synergies[pos_a].append(synergy_type)
				room_synergies[pos_b].append(synergy_type)

	return {
		"counts": synergy_counts,
		"room_synergies": room_synergies
	}

## Get grid positions of all weapon rooms (Phase 10.6 - for combat visual effects)
## Returns array of Vector2i positions (one per weapon room tile)
func get_weapon_grid_positions() -> Array:
	var weapon_positions = []

	for y in range(grid.size()):
		for x in range(grid[y].size()):
			if grid[y][x] == RoomData.RoomType.WEAPON:
				weapon_positions.append(Vector2i(x, y))

	return weapon_positions

## Get grid positions of only POWERED weapons (for combat visual effects)
## Returns array of Vector2i positions (one per powered weapon room tile)
func get_powered_weapon_grid_positions() -> Array:
	var weapon_positions = []

	for y in range(grid.size()):
		for x in range(grid[y].size()):
			if grid[y][x] == RoomData.RoomType.WEAPON:
				# Only include if this weapon position is powered
				if is_room_powered(x, y):
					weapon_positions.append(Vector2i(x, y))

	return weapon_positions

## Create a deep copy of this ShipData (for replay viewer - preserve original state)
func duplicate_deep() -> ShipData:
	var copy = ShipData.new()

	# Deep copy grid
	copy.grid = []
	for y in range(grid.size()):
		var row = []
		for x in range(grid[y].size()):
			row.append(grid[y][x])
		copy.grid.append(row)

	# Deep copy power_grid
	copy.power_grid = []
	for y in range(power_grid.size()):
		var power_row = []
		for x in range(power_grid[y].size()):
			power_row.append(power_grid[y][x])
		copy.power_grid.append(power_row)

	# Deep copy room_id_grid
	copy.room_id_grid = []
	for y in range(room_id_grid.size()):
		var id_row = []
		for x in range(room_id_grid[y].size()):
			id_row.append(room_id_grid[y][x])
		copy.room_id_grid.append(id_row)

	# Deep copy room_instances
	copy.room_instances = {}
	for room_id in room_instances.keys():
		var room_data = room_instances[room_id]
		var tiles_copy = []
		for tile_pos in room_data["tiles"]:
			tiles_copy.append(Vector2i(tile_pos.x, tile_pos.y))

		copy.room_instances[room_id] = {
			"type": room_data["type"],
			"tiles": tiles_copy
		}

	# Copy simple properties
	copy.max_hp = max_hp
	copy.current_hp = current_hp
	copy.targeting_priority = targeting_priority

	return copy
