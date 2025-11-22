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
