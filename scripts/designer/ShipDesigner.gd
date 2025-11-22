extends Control

## Grid dimensions
const GRID_WIDTH = 8
const GRID_HEIGHT = 6
const TILE_SIZE = 64

## Budget values
var max_budget: int = 30  # Hard-coded for Phase 1
var current_budget: int = 0

## Grid container node
@onready var grid_container: Node2D = $GridContainer

## Budget UI elements
@onready var budget_label: Label = $BudgetPanel/BudgetLabel
@onready var remaining_label: Label = $BudgetPanel/RemainingLabel

## Launch button
@onready var launch_button: Button = $LaunchButton

## Preload GridTile scene
var grid_tile_scene = preload("res://scenes/components/GridTile.tscn")

## Preload Room scenes
var room_scenes = {
	RoomData.RoomType.BRIDGE: preload("res://scenes/components/rooms/Bridge.tscn"),
	RoomData.RoomType.WEAPON: preload("res://scenes/components/rooms/Weapon.tscn"),
	RoomData.RoomType.SHIELD: preload("res://scenes/components/rooms/Shield.tscn"),
	RoomData.RoomType.ENGINE: preload("res://scenes/components/rooms/Engine.tscn"),
	RoomData.RoomType.REACTOR: preload("res://scenes/components/rooms/Reactor.tscn"),
	RoomData.RoomType.ARMOR: preload("res://scenes/components/rooms/Armor.tscn")
}

## Store all grid tiles
var grid_tiles: Array[GridTile] = []

func _ready():
	_create_grid()
	_update_budget_display()

func _create_grid():
	"""Create an 8x6 grid of tiles"""
	for y in range(GRID_HEIGHT):
		for x in range(GRID_WIDTH):
			# Instantiate a new tile
			var tile: GridTile = grid_tile_scene.instantiate()

			# Set grid coordinates
			tile.grid_x = x
			tile.grid_y = y

			# Position the tile
			tile.position = Vector2(x * TILE_SIZE, y * TILE_SIZE)

			# Connect tile signals
			tile.tile_clicked.connect(_on_tile_clicked)
			tile.tile_right_clicked.connect(_on_tile_right_clicked)

			# Add to grid container
			grid_container.add_child(tile)

			# Store reference
			grid_tiles.append(tile)

## Calculate current budget from all placed rooms
func calculate_current_budget() -> int:
	var total = 0
	for tile in grid_tiles:
		var room_type = tile.get_room_type()
		if room_type != RoomData.RoomType.EMPTY:
			total += RoomData.get_cost(room_type)
	return total

## Update the budget display labels
func _update_budget_display():
	current_budget = calculate_current_budget()
	var remaining = max_budget - current_budget

	# Update budget label
	budget_label.text = "BUDGET: %d/%d" % [current_budget, max_budget]

	# Update remaining label with color
	remaining_label.text = "Remaining: %d" % remaining
	remaining_label.add_theme_color_override("font_color", _get_remaining_color(remaining))

## Get color for remaining budget based on value
func _get_remaining_color(remaining: int) -> Color:
	if remaining > 5:
		return Color(0.290, 0.886, 0.290)  # Green #4AE24A
	elif remaining >= 1:
		return Color(0.886, 0.831, 0.290)  # Yellow #E2D44A
	else:
		return Color(0.886, 0.290, 0.290)  # Red #E24A4A

## Get tile at grid coordinates
func get_tile_at(x: int, y: int) -> GridTile:
	var index = y * GRID_WIDTH + x
	if index >= 0 and index < grid_tiles.size():
		return grid_tiles[index]
	return null

## Get next room type in cycling order
func get_next_room_type(current: RoomData.RoomType) -> RoomData.RoomType:
	# Cycle: EMPTY → BRIDGE → WEAPON → SHIELD → ENGINE → REACTOR → ARMOR → EMPTY
	var next_value = (int(current) + 1) % 7
	return next_value as RoomData.RoomType

## Handle tile left-click - cycle through room types
func _on_tile_clicked(x: int, y: int):
	print("Left-click at [%d, %d]" % [x, y])
	var tile = get_tile_at(x, y)
	if not tile:
		print("ERROR: Tile not found!")
		return

	# Get current room type and determine next type
	var current_type = tile.get_room_type()
	var next_type = get_next_room_type(current_type)
	print("Current type: %d, Next type: %d" % [current_type, next_type])

	# If next type is EMPTY, clear the room
	if next_type == RoomData.RoomType.EMPTY:
		print("Clearing room")
		tile.clear_room()
	else:
		# Instantiate and place the new room
		var room_scene = room_scenes.get(next_type)
		if room_scene:
			print("Instantiating room type: %d" % next_type)
			var room = room_scene.instantiate()
			tile.set_room(room)
		else:
			print("ERROR: Room scene not found for type %d" % next_type)

	# Update budget display
	_update_budget_display()

## Handle tile right-click - remove room
func _on_tile_right_clicked(x: int, y: int):
	print("Right-click at [%d, %d]" % [x, y])
	var tile = get_tile_at(x, y)
	if not tile:
		print("ERROR: Tile not found!")
		return

	# Clear the room
	print("Clearing room from tile")
	tile.clear_room()

	# Update budget display
	_update_budget_display()
