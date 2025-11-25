class_name MainGrid

## Data model for physical component placement on the ship grid
## Separates physical tile tracking from visual rendering (ShipGrid) and electrical routing (SecondaryGrid)
## Feature 1.1: Two-Grid Architecture - Physical Layer

## Grid dimensions
var grid_width: int = 0
var grid_height: int = 0

## Valid tile positions for shaped hulls
## Dictionary of "x,y" -> true for positions that exist in hull shape
var valid_positions: Dictionary = {}

## All grid tiles (references to GridTile nodes created by ShipGrid)
## MainGrid doesn't own these nodes, just tracks them
var grid_tiles: Array[GridTile] = []

## Fast lookup dictionary for tile queries
## Key: "x,y" string, Value: GridTile reference
var tile_lookup: Dictionary = {}

## Initialize grid with dimensions and optional hull shape
## hull_shape: array of strings where 'X' = valid tile, '.' = empty
func initialize(width: int, height: int, hull_shape: Array = []):
	grid_width = width
	grid_height = height

	# Parse hull shape if provided
	if not hull_shape.is_empty():
		_parse_hull_shape(hull_shape)
	else:
		# No shape provided - all positions valid (full rectangle)
		valid_positions.clear()
		for y in range(height):
			for x in range(width):
				valid_positions["%d,%d" % [x, y]] = true

## Parse hull shape strings into valid position set
func _parse_hull_shape(hull_shape: Array):
	valid_positions.clear()
	for y in range(hull_shape.size()):
		var row_str: String = hull_shape[y]
		for x in range(row_str.length()):
			if row_str[x] == 'X':
				valid_positions["%d,%d" % [x, y]] = true

## Register a tile with the main grid (called by ShipGrid after creating GridTile nodes)
## MainGrid doesn't create tiles, just tracks references to them
func register_tile(tile: GridTile):
	if not tile:
		return

	# Add to arrays
	grid_tiles.append(tile)

	# Add to lookup dictionary
	var key = "%d,%d" % [tile.grid_x, tile.grid_y]
	tile_lookup[key] = tile

## Check if coordinates are within grid bounds and valid for this hull shape
func is_in_bounds(x: int, y: int) -> bool:
	# First check rectangle bounds
	if x < 0 or x >= grid_width or y < 0 or y >= grid_height:
		return false

	# Then check if position is valid in hull shape
	var key = "%d,%d" % [x, y]
	return valid_positions.has(key)

## Get tile at grid coordinates
## Returns null if coordinates invalid or no tile exists
func get_tile_at(x: int, y: int) -> GridTile:
	var key = "%d,%d" % [x, y]
	return tile_lookup.get(key, null)

## Get all tiles in the grid
func get_all_tiles() -> Array[GridTile]:
	return grid_tiles

## Check if tile at coordinates is occupied by a room
func is_tile_occupied(x: int, y: int) -> bool:
	var tile = get_tile_at(x, y)
	if not tile:
		return false
	return tile.is_occupied()

## Get all tiles in a shape from anchor position
## Used for multi-tile room placement validation
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

## Clear all tile references (used when reinitializing grid)
func clear():
	grid_tiles.clear()
	tile_lookup.clear()
	valid_positions.clear()
