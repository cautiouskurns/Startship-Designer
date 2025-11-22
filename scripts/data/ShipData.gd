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

## Create ShipData from ShipDesigner's grid_tiles array
static func from_designer_grid(grid_tiles: Array, hp: int = 100) -> ShipData:
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

	return ShipData.new(room_grid, hp)

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

	# Row 3: Empty
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
