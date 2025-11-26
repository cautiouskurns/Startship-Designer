extends Node2D
class_name ShipGrid

## Manages the grid of tiles for ship design (dynamic size based on hull)
## Feature 1.1: Visual layer - delegates data queries to MainGrid

## Grid dimensions (Phase 10.1 - made dynamic for hull selection)
# Default dimensions for FREE DESIGN mode
const DEFAULT_FREE_DESIGN_WIDTH: int = 30
const DEFAULT_FREE_DESIGN_HEIGHT: int = 30

var GRID_WIDTH: int = 8
var GRID_HEIGHT: int = 6
const TILE_SIZE = 25
const TILE_SPACING = 2  # Gap between tiles in pixels

## Feature 1.1: MainGrid handles physical tile data
var main_grid: MainGrid = null

## Child nodes for organization
@onready var grid_container: Node2D = $GridContainer
@onready var power_lines_container: Node2D = $PowerLinesContainer
@onready var coverage_container: Node2D = $CoverageContainer  # Feature 1.3

## Feature 2.3: Routing lines container (created dynamically)
var routing_lines_container: Node2D = null

## Hull overlay container (rendered under grid tiles)
var hull_overlay_container: Node2D = null

## Preload GridTile scene
var grid_tile_scene = preload("res://scenes/components/GridTile.tscn")

## Store all grid tiles (kept for backward compatibility, MainGrid also tracks these)
var grid_tiles: Array[GridTile] = []

## Dictionary for fast tile lookup (kept for backward compatibility, MainGrid also has this)
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

	# Feature 1.1: Create MainGrid for physical tile data
	main_grid = MainGrid.new()
	main_grid.initialize(width, height, hull_shape)

	# Feature 2.3: Create routing lines container if it doesn't exist
	if not routing_lines_container:
		routing_lines_container = Node2D.new()
		routing_lines_container.name = "RoutingLinesContainer"
		routing_lines_container.z_index = 0  # Same level as coverage circles (visible above grid)
		add_child(routing_lines_container)

	# Create hull overlay container if it doesn't exist
	if not hull_overlay_container:
		hull_overlay_container = Node2D.new()
		hull_overlay_container.name = "HullOverlayContainer"
		hull_overlay_container.z_index = 0  # Same as grid, but render first (behind tiles and components)
		add_child(hull_overlay_container)
		# Move to first position to render behind everything else
		move_child(hull_overlay_container, 0)

	grid_initialized = true
	_create_grid()

## Create grid tiles (Phase 10.4 - only at valid positions for shaped hulls, Feature 1.1 - register with MainGrid)
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

			# Store references (backward compatibility)
			grid_tiles.append(tile)
			tile_lookup["%d,%d" % [x, y]] = tile

			# Feature 1.1: Register tile with MainGrid
			main_grid.register_tile(tile)

## Forward tile signals
func _on_tile_clicked(x: int, y: int):
	emit_signal("tile_clicked", x, y)

func _on_tile_right_clicked(x: int, y: int):
	emit_signal("tile_right_clicked", x, y)

func _on_tile_hovered(tile: GridTile):
	emit_signal("tile_hovered", tile)

func _on_tile_unhovered(tile: GridTile):
	emit_signal("tile_unhovered", tile)

## Get tile at grid coordinates (Feature 1.1 - delegates to MainGrid)
func get_tile_at(x: int, y: int) -> GridTile:
	if main_grid:
		return main_grid.get_tile_at(x, y)
	# Fallback for backward compatibility
	var key = "%d,%d" % [x, y]
	return tile_lookup.get(key, null)

## Check if coordinates are within grid bounds (Feature 1.1 - delegates to MainGrid)
func is_in_bounds(x: int, y: int) -> bool:
	if main_grid:
		return main_grid.is_in_bounds(x, y)
	# Fallback for backward compatibility
	if x < 0 or x >= GRID_WIDTH or y < 0 or y >= GRID_HEIGHT:
		return false
	var key = "%d,%d" % [x, y]
	return tile_lookup.has(key)

## Get all tiles in a shape from anchor position (Feature 1.1 - delegates to MainGrid)
func get_tiles_in_shape(anchor_x: int, anchor_y: int, shape: Array) -> Array[GridTile]:
	if main_grid:
		return main_grid.get_tiles_in_shape(anchor_x, anchor_y, shape)
	# Fallback for backward compatibility
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

## Draw coverage for a single relay WITHOUT clearing existing coverage (Feature 1.4)
func draw_relay_coverage_for_relay(relay_x: int, relay_y: int):
	# Calculate relay center (2×2 module, center is midpoint between all 4 tiles)
	# Get centers of top-left and bottom-right tiles, then average them
	var top_left_center = get_tile_center(relay_x, relay_y)
	var bottom_right_center = get_tile_center(relay_x + 1, relay_y + 1)
	var center_pixel = (top_left_center + bottom_right_center) / 2.0

	# Calculate radius in pixels (3 tiles)
	var radius_tiles = 3.0
	var radius_pixels = radius_tiles * (TILE_SIZE + TILE_SPACING)

	# Create filled circle polygon (32 vertices)
	var circle = Polygon2D.new()
	var points = PackedVector2Array()
	var num_segments = 32
	for i in range(num_segments):
		var angle = (i * TAU) / num_segments
		var x = center_pixel.x + cos(angle) * radius_pixels
		var y = center_pixel.y + sin(angle) * radius_pixels
		points.append(Vector2(x, y))
	circle.polygon = points
	circle.color = Color(1.0, 0.867, 0.0, 0.15)  # #FFDD00 yellow at 15% opacity

	# Add border line (Line2D circle outline, 2px width)
	var border = Line2D.new()
	border.default_color = Color(1.0, 0.867, 0.0, 0.8)  # #FFDD00 yellow at 80% opacity
	border.width = 2
	border.closed = true
	for i in range(num_segments + 1):  # +1 to close the circle
		var angle = (i * TAU) / num_segments
		var x = center_pixel.x + cos(angle) * radius_pixels
		var y = center_pixel.y + sin(angle) * radius_pixels
		border.add_point(Vector2(x, y))

	# Add to coverage container
	coverage_container.add_child(circle)
	coverage_container.add_child(border)

	# Fade in animation
	circle.modulate.a = 0.0
	border.modulate.a = 0.0
	var tween = create_tween().set_parallel(true)
	tween.tween_property(circle, "modulate:a", 1.0, 0.3)
	tween.tween_property(border, "modulate:a", 1.0, 0.3)

## Draw coverage zones for ALL placed relays (Feature 1.4 - overlay mode)
func draw_all_relay_coverages(placed_rooms: Array[Room]):
	clear_relay_coverage()
	for room in placed_rooms:
		if room.room_type == RoomData.RoomType.RELAY:
			var anchor_tile = room.get_anchor_tile()
			if anchor_tile:
				draw_relay_coverage_for_relay(anchor_tile.grid_x, anchor_tile.grid_y)

## Draw single relay coverage for hover (Feature 1.3 - backward compatible)
func draw_single_relay_coverage(relay_x: int, relay_y: int):
	clear_relay_coverage()
	draw_relay_coverage_for_relay(relay_x, relay_y)

## Clear relay coverage display (Feature 1.3)
func clear_relay_coverage():
	for child in coverage_container.get_children():
		child.queue_free()

## Get all tiles
func get_all_tiles() -> Array[GridTile]:
	return grid_tiles

## Draw routing lines from reactors to relays (Feature 2.3)
func draw_routing_lines(secondary_grid: SecondaryGrid):
	# Safety check: ensure routing_lines_container exists
	if not routing_lines_container:
		print("Feature 2.3 DEBUG ERROR: routing_lines_container is null!")
		return

	print("Feature 2.3 DEBUG: routing_lines_container exists, z_index=", routing_lines_container.z_index)

	# Clear existing routing lines
	clear_routing_lines()

	# Get all connections from secondary grid
	var connections = secondary_grid.get_all_connections()
	print("Feature 2.3 DEBUG: Drawing routing lines, found ", connections.size(), " connections")

	# Draw line for each connection
	for connection in connections:
		var path: Array = connection.get("path", [])
		print("Feature 2.3 DEBUG: Connection path size: ", path.size())
		if path.is_empty():
			print("Feature 2.3 DEBUG: Path is empty, skipping")
			continue

		# Feature 2.4: Color-code lines based on powered state
		var is_powered = connection.get("is_powered", false)
		var line_color: Color
		if is_powered:
			line_color = Color(1.0, 0.867, 0.0, 0.8)  # Yellow #FFDD00 at 80% opacity (powered)
		else:
			line_color = Color(0.4, 0.4, 0.4, 0.5)  # Gray #666666 at 50% opacity (unpowered)

		# Draw line segments between consecutive path positions
		for i in range(path.size() - 1):
			var start_pos: Vector2i = path[i]
			var end_pos: Vector2i = path[i + 1]

			# Create line segment
			var line = Line2D.new()
			var start_pixel = get_tile_center(start_pos.x, start_pos.y)
			var end_pixel = get_tile_center(end_pos.x, end_pos.y)
			line.add_point(start_pixel)
			line.add_point(end_pixel)
			line.width = 2
			line.default_color = line_color  # Feature 2.4: Use powered/unpowered color
			routing_lines_container.add_child(line)
			print("Feature 2.3 DEBUG: Added line segment from ", start_pos, " to ", end_pos, " (pixels: ", start_pixel, " to ", end_pixel, ")")

## Clear routing lines display (Feature 2.3)
func clear_routing_lines():
	if not routing_lines_container:
		return
	for child in routing_lines_container.get_children():
		child.queue_free()

## Draw hull overlay from hull shape (array of tile positions)
## Renders semi-transparent outline behind placed components
func draw_hull_overlay(hull_shape: Array):
	# Clear existing overlay
	clear_hull_overlay()

	# Skip if shape is empty (NONE hull type)
	if hull_shape.is_empty():
		return

	# Get visual config from HullData
	var fill_color = HullData.overlay_config["fill_color"]
	var border_color = HullData.overlay_config["border_color"]
	var border_width = HullData.overlay_config["border_width"]

	# Create individual tile rectangles for each position in hull shape
	var tiles_drawn = 0
	for tile_pos in hull_shape:
		var tile_x = tile_pos[0]
		var tile_y = tile_pos[1]

		# Check if tile position is within grid bounds
		if tile_x < 0 or tile_x >= GRID_WIDTH or tile_y < 0 or tile_y >= GRID_HEIGHT:
			continue

		var tile_center = get_tile_center(tile_x, tile_y)
		var half_size = TILE_SIZE / 2.0

		# Create filled rectangle for this tile
		var tile_rect = Polygon2D.new()
		var rect_points = PackedVector2Array([
			tile_center + Vector2(-half_size, -half_size),  # Top-left
			tile_center + Vector2(half_size, -half_size),   # Top-right
			tile_center + Vector2(half_size, half_size),    # Bottom-right
			tile_center + Vector2(-half_size, half_size)    # Bottom-left
		])
		tile_rect.polygon = rect_points
		tile_rect.color = fill_color
		hull_overlay_container.add_child(tile_rect)

		# Create border for this tile
		var tile_border = Line2D.new()
		tile_border.default_color = border_color
		tile_border.width = border_width
		tile_border.closed = true
		for point in rect_points:
			tile_border.add_point(point)
		hull_overlay_container.add_child(tile_border)

		tiles_drawn += 1

## Clear hull overlay display
func clear_hull_overlay():
	if not hull_overlay_container:
		return
	for child in hull_overlay_container.get_children():
		child.queue_free()
