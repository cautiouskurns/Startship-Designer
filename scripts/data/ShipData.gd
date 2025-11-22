class_name ShipData

## Represents a ship's configuration and stats for combat

## 8x6 grid of room types
var grid: Array = []  # Array of Arrays (rows), each containing RoomType values

## 8x6 grid tracking which rooms are powered
var power_grid: Array = []  # Array of Arrays (rows), each containing bool values

## Health points
var max_hp: int = 0
var current_hp: int = 0

## Initialize with grid data and HP
func _init(room_grid: Array = [], hp: int = 100):
	grid = room_grid
	max_hp = hp
	current_hp = hp

## Count number of specific room type in grid
func count_room_type(room_type: RoomData.RoomType) -> int:
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
	return 60 + (armor_count * 20)

## Destroy room at grid position
func destroy_room_at(x: int, y: int):
	if y >= 0 and y < grid.size() and x >= 0 and x < grid[y].size():
		grid[y][x] = RoomData.RoomType.EMPTY

## Calculate power grid based on reactor positions
func calculate_power_grid():
	# Initialize power_grid with same dimensions as grid
	power_grid.clear()
	for y in range(grid.size()):
		var power_row = []
		for x in range(grid[y].size()):
			power_row.append(false)
		power_grid.append(power_row)

	# Determine which rooms are powered
	for y in range(grid.size()):
		for x in range(grid[y].size()):
			var room_type = grid[y][x]

			# Skip empty tiles
			if room_type == RoomData.RoomType.EMPTY:
				continue

			# Bridge and Reactor always powered (special cases)
			if room_type == RoomData.RoomType.BRIDGE or room_type == RoomData.RoomType.REACTOR:
				power_grid[y][x] = true
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
						power_grid[y][x] = true
						break

## Check if room at position is powered
func is_room_powered(x: int, y: int) -> bool:
	if power_grid.size() == 0:
		return true  # If power grid not initialized, assume all powered (backward compat)

	if y >= 0 and y < power_grid.size() and x >= 0 and x < power_grid[y].size():
		return power_grid[y][x]

	return false

## Count number of powered rooms of specific type
func count_powered_room_type(room_type: RoomData.RoomType) -> int:
	var count = 0
	for y in range(grid.size()):
		for x in range(grid[y].size()):
			if grid[y][x] == room_type and is_room_powered(x, y):
				count += 1
	return count

## Recalculate power grid (called when reactor destroyed in combat)
func recalculate_power():
	calculate_power_grid()

## Create ShipData from ShipDesigner's grid_tiles array
static func from_designer_grid(grid_tiles: Array) -> ShipData:
	var room_grid = []

	# Convert grid_tiles (1D array) to 2D array (8 columns × 6 rows)
	for y in range(6):  # 6 rows
		var row = []
		for x in range(8):  # 8 columns
			var index = y * 8 + x
			if index < grid_tiles.size():
				var tile = grid_tiles[index]
				row.append(tile.get_room_type())
			else:
				row.append(RoomData.RoomType.EMPTY)
		room_grid.append(row)

	# Create ship with placeholder HP, then calculate based on armor
	var ship = ShipData.new(room_grid, 0)
	var hull_hp = ship.calculate_hull_hp()
	ship.max_hp = hull_hp
	ship.current_hp = hull_hp

	# Calculate power grid
	ship.calculate_power_grid()

	return ship

## Create Mission 1 Scout enemy ship (hard-coded)
static func create_mission1_scout() -> ShipData:
	var room_grid = []

	# Row 0: 1 Weapon + 1 Reactor (rows 0-1 allowed for weapons)
	room_grid.append([
		RoomData.RoomType.WEAPON,
		RoomData.RoomType.REACTOR,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY
	])

	# Row 1: 1 Weapon (powered by reactor above)
	room_grid.append([
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.WEAPON,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY
	])

	# Row 2: 1 Shield (powered by reactor above)
	room_grid.append([
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.SHIELD,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY
	])

	# Row 3: 1 Bridge (rows 2-3 allowed for bridge)
	room_grid.append([
		RoomData.RoomType.BRIDGE,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY
	])

	# Row 4: 2 Engines (rows 4-5 allowed for engines)
	room_grid.append([
		RoomData.RoomType.ENGINE,
		RoomData.RoomType.ENGINE,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY
	])

	# Row 5: Empty
	room_grid.append([
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY
	])

	var ship = ShipData.new(room_grid, 40)  # 40 HP for Mission 1 Scout

	# Calculate power grid
	ship.calculate_power_grid()

	return ship

## Create Mission 2 Raider enemy ship (hard-coded)
static func create_mission2_raider() -> ShipData:
	var room_grid = []

	# Row 0: 2 Weapons + 1 Reactor
	room_grid.append([
		RoomData.RoomType.WEAPON,
		RoomData.RoomType.REACTOR,
		RoomData.RoomType.WEAPON,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY
	])

	# Row 1: 1 Weapon + 1 Shield (powered by reactor above)
	room_grid.append([
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.WEAPON,
		RoomData.RoomType.SHIELD,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY
	])

	# Row 2: 1 Shield + 1 Reactor (powers shields and bridge below)
	room_grid.append([
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.SHIELD,
		RoomData.RoomType.REACTOR,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY
	])

	# Row 3: 1 Bridge (powered by reactor above)
	room_grid.append([
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.BRIDGE,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY
	])

	# Row 4: 1 Engine (NOT powered - too far from reactors)
	room_grid.append([
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.ENGINE,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY
	])

	# Row 5: Empty
	room_grid.append([
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY
	])

	var ship = ShipData.new(room_grid, 60)  # 60 HP for Mission 2 Raider

	# Calculate power grid
	ship.calculate_power_grid()

	return ship

## Create Mission 3 Dreadnought enemy ship (hard-coded)
static func create_mission3_dreadnought() -> ShipData:
	var room_grid = []

	# Row 0: 3 Weapons + 1 Reactor
	room_grid.append([
		RoomData.RoomType.WEAPON,
		RoomData.RoomType.REACTOR,
		RoomData.RoomType.WEAPON,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.WEAPON,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY
	])

	# Row 1: 2 Weapons + 1 Reactor (powers weapons and shields below)
	room_grid.append([
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.WEAPON,
		RoomData.RoomType.REACTOR,
		RoomData.RoomType.WEAPON,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY
	])

	# Row 2: 2 Shields + 1 Reactor (center reactor powers shields and bridge)
	room_grid.append([
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.SHIELD,
		RoomData.RoomType.REACTOR,
		RoomData.RoomType.SHIELD,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY
	])

	# Row 3: 1 Shield + 1 Bridge (both powered by reactor above)
	room_grid.append([
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.SHIELD,
		RoomData.RoomType.BRIDGE,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY
	])

	# Row 4: 2 Engines (NOT powered - would need reactor nearby)
	room_grid.append([
		RoomData.RoomType.ENGINE,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.ENGINE,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY
	])

	# Row 5: Empty
	room_grid.append([
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY
	])

	var ship = ShipData.new(room_grid, 100)  # 100 HP for Mission 3 Dreadnought

	# Calculate power grid
	ship.calculate_power_grid()

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
