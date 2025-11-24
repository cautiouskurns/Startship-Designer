extends Node2D
class_name ShipGrid

## Manages the grid of tiles for ship design (dynamic size based on hull)

## Grid dimensions (Phase 10.1 - made dynamic for hull selection)
# Default dimensions for FREE DESIGN mode
const DEFAULT_FREE_DESIGN_WIDTH: int = 50
const DEFAULT_FREE_DESIGN_HEIGHT: int = 50

var GRID_WIDTH: int = 8
var GRID_HEIGHT: int = 6
const TILE_SIZE = 15
const TILE_SPACING = 2  # Gap between tiles in pixels

## Phase 10.4: Valid tile positions for shaped hulls
## Dictionary of "x,y" -> true for positions that exist in hull shape
var valid_positions: Dictionary = {}

## Child nodes for organization
@onready var grid_container: Node2D = $GridContainer
@onready var power_lines_container: Node2D = $PowerLinesContainer

## Preload GridTile scene
var grid_tile_scene = preload("res://scenes/components/GridTile.tscn")

## Store all grid tiles
var grid_tiles: Array[GridTile] = []

## Phase 10.4: Dictionary for fast tile lookup in shaped hulls
## Key: "x,y" -> GridTile
var tile_lookup: Dictionary = {}

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

## Initialize grid with custom dimensions (Phase 10.4 - supports shaped hulls)
## hull_shape: optional array of strings where 'X' = valid tile, '.' = empty
func initialize(width: int, height: int, hull_shape: Array = []):
	GRID_WIDTH = width
	GRID_HEIGHT = height

	# Parse hull shape if provided (Phase 10.4)
	if not hull_shape.is_empty():
		_parse_hull_shape(hull_shape)
	else:
		# No shape provided - all positions valid (full rectangle)
		valid_positions.clear()
		for y in range(height):
			for x in range(width):
				valid_positions["%d,%d" % [x, y]] = true

	grid_initialized = true
	_create_grid()

## Parse hull shape strings into valid position set (Phase 10.4)
func _parse_hull_shape(hull_shape: Array):
	valid_positions.clear()
	for y in range(hull_shape.size()):
		var row_str: String = hull_shape[y]
		for x in range(row_str.length()):
			if row_str[x] == 'X':
				valid_positions["%d,%d" % [x, y]] = true

## Create grid tiles (Phase 10.4 - only at valid positions for shaped hulls)
func _create_grid():
	# Clear existing tiles and lookup
	for child in grid_container.get_children():
		child.queue_free()
	grid_tiles.clear()
	tile_lookup.clear()

	# Calculate center offset to position grid from its center
	var total_grid_width = GRID_WIDTH * (TILE_SIZE + TILE_SPACING) - TILE_SPACING
	var total_grid_height = GRID_HEIGHT * (TILE_SIZE + TILE_SPACING) - TILE_SPACING
	var center_offset = Vector2(-total_grid_width / 2.0, -total_grid_height / 2.0)

	for y in range(GRID_HEIGHT):
		for x in range(GRID_WIDTH):
			# Phase 10.4: Skip invalid positions for shaped hulls
			if not is_in_bounds(x, y):
				continue

			# Instantiate a new tile
			var tile: GridTile = grid_tile_scene.instantiate()

			# Set grid coordinates
			tile.grid_x = x
			tile.grid_y = y

			# Position the tile with spacing, centered
			tile.position = Vector2(x * (TILE_SIZE + TILE_SPACING), y * (TILE_SIZE + TILE_SPACING)) + center_offset

			# Set tile size dynamically based on TILE_SIZE constant
			tile.custom_minimum_size = Vector2(TILE_SIZE, TILE_SIZE)

			# Connect tile signals (forward to ShipGrid signals)
			tile.tile_clicked.connect(_on_tile_clicked)
			tile.tile_right_clicked.connect(_on_tile_right_clicked)
			tile.tile_hovered.connect(_on_tile_hovered)
			tile.tile_unhovered.connect(_on_tile_unhovered)

			# Add to grid container
			grid_container.add_child(tile)

			# Force size update after adding to tree
			tile.reset_size()

			# Store references
			grid_tiles.append(tile)
			tile_lookup["%d,%d" % [x, y]] = tile

## Forward tile signals
func _on_tile_clicked(x: int, y: int):
	emit_signal("tile_clicked", x, y)

func _on_tile_right_clicked(x: int, y: int):
	emit_signal("tile_right_clicked", x, y)

func _on_tile_hovered(tile: GridTile):
	emit_signal("tile_hovered", tile)

func _on_tile_unhovered(tile: GridTile):
	emit_signal("tile_unhovered", tile)

## Get tile at grid coordinates (Phase 10.4 - uses lookup dictionary for shaped hulls)
func get_tile_at(x: int, y: int) -> GridTile:
	var key = "%d,%d" % [x, y]
	return tile_lookup.get(key, null)

## Check if coordinates are within grid bounds (Phase 10.4 - checks hull shape)
func is_in_bounds(x: int, y: int) -> bool:
	# First check rectangle bounds
	if x < 0 or x >= GRID_WIDTH or y < 0 or y >= GRID_HEIGHT:
		return false

	# Then check if position is valid in hull shape
	var key = "%d,%d" % [x, y]
	return valid_positions.has(key)

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
	# Calculate center offset to match tile positioning
	var total_grid_width = GRID_WIDTH * (TILE_SIZE + TILE_SPACING) - TILE_SPACING
	var total_grid_height = GRID_HEIGHT * (TILE_SIZE + TILE_SPACING) - TILE_SPACING
	var center_offset = Vector2(-total_grid_width / 2.0, -total_grid_height / 2.0)

	return Vector2(x * (TILE_SIZE + TILE_SPACING), y * (TILE_SIZE + TILE_SPACING)) + center_offset

## Get center of tile in pixel coordinates
func get_tile_center(x: int, y: int) -> Vector2:
	# Calculate center offset to match tile positioning
	var total_grid_width = GRID_WIDTH * (TILE_SIZE + TILE_SPACING) - TILE_SPACING
	var total_grid_height = GRID_HEIGHT * (TILE_SIZE + TILE_SPACING) - TILE_SPACING
	var center_offset = Vector2(-total_grid_width / 2.0, -total_grid_height / 2.0)

	return Vector2(x * (TILE_SIZE + TILE_SPACING) + TILE_SIZE / 2.0, y * (TILE_SIZE + TILE_SPACING) + TILE_SIZE / 2.0) + center_offset

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
