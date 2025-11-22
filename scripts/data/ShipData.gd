class_name ShipData

## Represents a ship's configuration and stats for combat

## 8x6 grid of room types
var grid: Array = []  # Array of Arrays (rows), each containing RoomType values

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
	return ship

## Create Mission 1 Scout enemy ship (hard-coded)
static func create_mission1_scout() -> ShipData:
	var room_grid = []

	# Row 0: 2 Weapons (rows 0-1 allowed for weapons)
	room_grid.append([
		RoomData.RoomType.WEAPON,
		RoomData.RoomType.WEAPON,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY,
		RoomData.RoomType.EMPTY
	])

	# Row 1: Empty
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

	# Row 2: 1 Shield
	room_grid.append([
		RoomData.RoomType.SHIELD,
		RoomData.RoomType.EMPTY,
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

	return ShipData.new(room_grid, 40)  # 40 HP for Mission 1 Scout
