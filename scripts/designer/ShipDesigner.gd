extends Control

## Signal emitted when player clicks Launch button with valid ship design
signal launch_pressed

## Grid dimensions
const GRID_WIDTH = 8
const GRID_HEIGHT = 6
const TILE_SIZE = 64

## Budget values
var max_budget: int = 30  # Loaded from GameState based on mission
var current_budget: int = 0

## Grid container node
@onready var grid_container: Node2D = $GridContainer

## Power lines container
@onready var power_lines_container: Node2D = $PowerLinesContainer

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
	# Load mission budget from GameState
	max_budget = GameState.get_mission_budget(GameState.current_mission)

	_create_grid()
	_update_budget_display()

	# Connect launch button signals
	launch_button.pressed.connect(_on_launch_pressed)
	launch_button.mouse_entered.connect(_on_button_hover_start.bind(launch_button))
	launch_button.mouse_exited.connect(_on_button_hover_end.bind(launch_button))

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

	# Check if Bridge is missing
	if count_bridges() == 0:
		# Show "NEED BRIDGE" warning in red
		remaining_label.text = "NEED BRIDGE"
		remaining_label.add_theme_color_override("font_color", Color(0.886, 0.290, 0.290))  # Red #E24A4A
	else:
		# Show normal remaining budget with color coding
		remaining_label.text = "Remaining: %d" % remaining
		remaining_label.add_theme_color_override("font_color", _get_remaining_color(remaining))

	# Update launch button state
	_update_launch_button()

## Update launch button enabled/disabled state
func _update_launch_button():
	# Ship is valid if: has exactly 1 Bridge AND within budget
	var is_valid = (count_bridges() == 1) and (current_budget <= max_budget)
	launch_button.disabled = !is_valid

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

## Count number of Bridge rooms currently placed
func count_bridges() -> int:
	var count = 0
	for tile in grid_tiles:
		if tile.get_room_type() == RoomData.RoomType.BRIDGE:
			count += 1
	return count

## Export current ship design as ShipData for combat
func export_ship_data() -> ShipData:
	# HP is calculated based on armor count in ShipData
	return ShipData.from_designer_grid(grid_tiles)

## Update power states for all tiles based on reactor positions
func update_all_power_states():
	# Create temporary ShipData to calculate power grid
	var temp_ship = ShipData.from_designer_grid(grid_tiles)

	# Update visual power state for each tile
	for tile in grid_tiles:
		# Skip empty tiles
		if tile.get_room_type() == RoomData.RoomType.EMPTY:
			continue

		# Check if this position is powered
		var is_powered = temp_ship.is_room_powered(tile.grid_x, tile.grid_y)

		# Update visual state
		tile.set_powered_state(is_powered)

	# Update power lines visual
	draw_power_lines()

## Draw power lines from reactors to powered rooms
func draw_power_lines():
	# Clear existing lines
	for child in power_lines_container.get_children():
		child.queue_free()

	# Create temporary ShipData to calculate power grid
	var temp_ship = ShipData.from_designer_grid(grid_tiles)

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
				if adj_pos.x < 0 or adj_pos.x >= GRID_WIDTH or adj_pos.y < 0 or adj_pos.y >= GRID_HEIGHT:
					continue

				var adj_tile = get_tile_at(adj_pos.x, adj_pos.y)
				if not adj_tile:
					continue

				var adj_type = adj_tile.get_room_type()
				# Skip empty tiles, bridges (self-powered), and other reactors
				if adj_type == RoomData.RoomType.EMPTY or adj_type == RoomData.RoomType.BRIDGE or adj_type == RoomData.RoomType.REACTOR:
					continue

				# Check if this adjacent room is actually powered
				if not temp_ship.is_room_powered(adj_pos.x, adj_pos.y):
					continue

				# Draw line from reactor center to room center
				var line = Line2D.new()
				line.add_point(Vector2(x * TILE_SIZE + TILE_SIZE / 2, y * TILE_SIZE + TILE_SIZE / 2))
				line.add_point(Vector2(adj_pos.x * TILE_SIZE + TILE_SIZE / 2, adj_pos.y * TILE_SIZE + TILE_SIZE / 2))
				line.width = 2
				line.default_color = Color(0.29, 0.89, 0.89, 0.5)  # Cyan with transparency
				power_lines_container.add_child(line)

## Pulse power lines brightness
func _process(_delta):
	# Pulse alpha between 0.3 and 0.7
	var pulse = 0.5 + 0.2 * sin(Time.get_ticks_msec() / 500.0)
	for child in power_lines_container.get_children():
		if child is Line2D:
			child.default_color = Color(0.29, 0.89, 0.89, pulse)

## Handle tile left-click - cycle through room types
func _on_tile_clicked(x: int, y: int):
	var tile = get_tile_at(x, y)
	if not tile:
		return

	# Get current room type and determine next type
	var current_type = tile.get_room_type()
	var next_type = get_next_room_type(current_type)

	# Auto-skip room types that can't be placed here
	# Keep cycling until we find a valid room or reach EMPTY
	var attempts = 0
	while next_type != RoomData.RoomType.EMPTY and attempts < 7:
		var can_place = true

		# Skip Bridge if we already have one (unless this tile has it)
		if next_type == RoomData.RoomType.BRIDGE and current_type != RoomData.RoomType.BRIDGE and count_bridges() >= 1:
			can_place = false

		# Skip if row constraint violated
		if not RoomData.can_place_in_row(next_type, y):
			can_place = false

		# Skip if would exceed budget
		var old_cost = RoomData.get_cost(current_type)
		var new_cost = RoomData.get_cost(next_type)
		var new_budget = current_budget - old_cost + new_cost
		if new_budget > max_budget:
			can_place = false

		if can_place:
			break  # Found valid room type

		# Try next room type
		next_type = get_next_room_type(next_type)
		attempts += 1

	# If next type is EMPTY, clear the room (always allowed)
	if next_type == RoomData.RoomType.EMPTY:
		tile.clear_room()
		_update_budget_display()
		update_all_power_states()
		return

	# Place the room (validation already done in auto-skip loop)
	var room_scene = room_scenes.get(next_type)
	if room_scene:
		var room = room_scene.instantiate()
		tile.set_room(room)

	# Update budget display and power states
	_update_budget_display()
	update_all_power_states()

## Handle tile right-click - remove room
func _on_tile_right_clicked(x: int, y: int):
	var tile = get_tile_at(x, y)
	if not tile:
		return

	# Clear the room
	tile.clear_room()

	# Update budget display and power states
	_update_budget_display()
	update_all_power_states()

## Handle launch button press
func _on_launch_pressed():
	# Emit signal
	emit_signal("launch_pressed")

	# Export player ship data
	var player_ship = export_ship_data()

	# Load combat scene
	var combat_scene = preload("res://scenes/combat/Combat.tscn")
	var combat_instance = combat_scene.instantiate()

	# Switch to combat scene
	get_tree().root.add_child(combat_instance)
	get_tree().current_scene = combat_instance

	# Start combat after scene is in tree with mission index
	combat_instance.call_deferred("start_combat", player_ship, GameState.current_mission)

	# Remove designer scene
	queue_free()

## Button hover start - scale up
func _on_button_hover_start(button: Button):
	if button.disabled:
		return
	var tween = create_tween()
	tween.tween_property(button, "scale", Vector2(1.05, 1.05), 0.1)

## Button hover end - scale back
func _on_button_hover_end(button: Button):
	var tween = create_tween()
	tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.1)
