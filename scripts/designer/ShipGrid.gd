extends Node2D
class_name ShipGrid

## Manages the grid of tiles for ship design (dynamic size based on hull)

## Grid dimensions (Phase 10.1 - made dynamic for hull selection)
var GRID_WIDTH: int = 8
var GRID_HEIGHT: int = 6
const TILE_SIZE = 96
const TILE_SPACING = 10  # Gap between tiles in pixels

## Child nodes for organization
@onready var grid_container: Node2D = $GridContainer
@onready var power_lines_container: Node2D = $PowerLinesContainer

## Preload GridTile scene
var grid_tile_scene = preload("res://scenes/components/GridTile.tscn")

## Store all grid tiles
var grid_tiles: Array[GridTile] = []

## Signals forwarded from tiles
signal tile_clicked(x: int, y: int)
signal tile_right_clicked(x: int, y: int)
signal tile_hovered(tile: GridTile)
signal tile_unhovered(tile: GridTile)

## Flag to prevent auto-creation in _ready (Phase 10.1)
var grid_initialized: bool = false

func _ready():
	# Don't auto-create grid - wait for initialize() call
	# Grid will be created by ShipDesigner after setting dimensions
	pass

## Initialize grid with custom dimensions (Phase 10.1 - for hull selection)
func initialize(width: int, height: int):
	GRID_WIDTH = width
	GRID_HEIGHT = height
	grid_initialized = true
	_create_grid()

## Create an 8x6 grid of tiles
func _create_grid():
	for y in range(GRID_HEIGHT):
		for x in range(GRID_WIDTH):
			# Instantiate a new tile
			var tile: GridTile = grid_tile_scene.instantiate()

			# Set grid coordinates
			tile.grid_x = x
			tile.grid_y = y

			# Position the tile with spacing
			tile.position = Vector2(x * (TILE_SIZE + TILE_SPACING), y * (TILE_SIZE + TILE_SPACING))

			# Connect tile signals (forward to ShipGrid signals)
			tile.tile_clicked.connect(_on_tile_clicked)
			tile.tile_right_clicked.connect(_on_tile_right_clicked)
			tile.tile_hovered.connect(_on_tile_hovered)
			tile.tile_unhovered.connect(_on_tile_unhovered)

			# Add to grid container
			grid_container.add_child(tile)

			# Store reference
			grid_tiles.append(tile)

## Forward tile signals
func _on_tile_clicked(x: int, y: int):
	emit_signal("tile_clicked", x, y)

func _on_tile_right_clicked(x: int, y: int):
	emit_signal("tile_right_clicked", x, y)

func _on_tile_hovered(tile: GridTile):
	emit_signal("tile_hovered", tile)

func _on_tile_unhovered(tile: GridTile):
	emit_signal("tile_unhovered", tile)

## Get tile at grid coordinates
func get_tile_at(x: int, y: int) -> GridTile:
	var index = y * GRID_WIDTH + x
	if index >= 0 and index < grid_tiles.size():
		return grid_tiles[index]
	return null

## Check if coordinates are within grid bounds
func is_in_bounds(x: int, y: int) -> bool:
	return x >= 0 and x < GRID_WIDTH and y >= 0 and y < GRID_HEIGHT

## Get all tiles in a shape from anchor position
func get_tiles_in_shape(anchor_x: int, anchor_y: int, shape: Array) -> Array[GridTile]:
	var tiles: Array[GridTile] = []
	for offset in shape:
		var tile_x = anchor_x + offset[0]
		var tile_y = anchor_y + offset[1]
		if is_in_bounds(tile_x, tile_y):
			var tile = get_tile_at(tile_x, tile_y)
			if tile:
				tiles.append(tile)
	return tiles

## Convert grid coordinates to pixel position
func grid_to_pixel(x: int, y: int) -> Vector2:
	return Vector2(x * (TILE_SIZE + TILE_SPACING), y * (TILE_SIZE + TILE_SPACING))

## Get center of tile in pixel coordinates
func get_tile_center(x: int, y: int) -> Vector2:
	return Vector2(x * (TILE_SIZE + TILE_SPACING) + TILE_SIZE / 2.0, y * (TILE_SIZE + TILE_SPACING) + TILE_SIZE / 2.0)

## Draw power lines from reactors to powered rooms
func draw_power_lines(ship_data: ShipData):
	# Clear existing lines
	for child in power_lines_container.get_children():
		child.queue_free()

	# Find all reactors and draw lines to adjacent powered rooms
	for y in range(GRID_HEIGHT):
		for x in range(GRID_WIDTH):
			var tile = get_tile_at(x, y)
			if not tile or tile.get_room_type() != RoomData.RoomType.REACTOR:
				continue

			# This is a reactor - check all adjacent tiles
			var adjacent_positions = [
				Vector2i(x - 1, y), Vector2i(x + 1, y),
				Vector2i(x, y - 1), Vector2i(x, y + 1)
			]

			for adj_pos in adjacent_positions:
				# Check bounds
				if not is_in_bounds(adj_pos.x, adj_pos.y):
					continue

				var adj_tile = get_tile_at(adj_pos.x, adj_pos.y)
				if not adj_tile:
					continue

				var adj_type = adj_tile.get_room_type()
				# Skip empty tiles, bridges (self-powered), and other reactors
				if adj_type == RoomData.RoomType.EMPTY or adj_type == RoomData.RoomType.BRIDGE or adj_type == RoomData.RoomType.REACTOR:
					continue

				# Check if this adjacent room is actually powered
				if not ship_data.is_room_powered(adj_pos.x, adj_pos.y):
					continue

				# Draw line from reactor center to room center
				var line = Line2D.new()
				line.add_point(get_tile_center(x, y))
				line.add_point(get_tile_center(adj_pos.x, adj_pos.y))
				line.width = 2
				line.default_color = Color(0.29, 0.89, 0.89, 0.5)  # Cyan with transparency
				power_lines_container.add_child(line)

## Pulse power lines brightness (called from _process)
func pulse_power_lines():
	var pulse = 0.5 + 0.2 * sin(Time.get_ticks_msec() / 500.0)
	for child in power_lines_container.get_children():
		if child is Line2D:
			child.default_color = Color(0.29, 0.89, 0.89, pulse)

## Get all tiles
func get_all_tiles() -> Array[GridTile]:
	return grid_tiles
