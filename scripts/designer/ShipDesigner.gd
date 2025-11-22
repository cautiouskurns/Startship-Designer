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

## Buttons
@onready var launch_button: Button = $LaunchButton
@onready var auto_fill_button: Button = $AutoFillButton
@onready var clear_grid_button: Button = $ClearGridButton

## Room palette panel
@onready var room_palette: RoomPalettePanel = $RoomPalettePanel

## Ship status panel
@onready var ship_status_panel: ShipStatusPanel = $ShipStatusPanel

## Cost indicator label
@onready var cost_indicator: Label = $CostIndicator

## Current template index for cycling
var current_template_index: int = 0

## Currently selected room type from palette
var selected_room_type: RoomData.RoomType = RoomData.RoomType.EMPTY

## Currently hovered tile
var hovered_tile: GridTile = null

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

	# Connect auto-fill button signals
	auto_fill_button.pressed.connect(_on_auto_fill_pressed)
	auto_fill_button.mouse_entered.connect(_on_button_hover_start.bind(auto_fill_button))
	auto_fill_button.mouse_exited.connect(_on_button_hover_end.bind(auto_fill_button))

	# Connect clear grid button signals
	clear_grid_button.pressed.connect(_on_clear_grid_pressed)
	clear_grid_button.mouse_entered.connect(_on_button_hover_start.bind(clear_grid_button))
	clear_grid_button.mouse_exited.connect(_on_button_hover_end.bind(clear_grid_button))

	# Connect room palette signals
	room_palette.room_type_selected.connect(_on_room_type_selected)

	# Initialize palette display
	update_palette_counts()
	update_palette_availability()

	# Initialize status panel
	_update_ship_status()

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
			tile.tile_hovered.connect(_on_tile_hovered)
			tile.tile_unhovered.connect(_on_tile_unhovered)

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

## Update ship status panel
func _update_ship_status():
	# Update Bridge status
	var bridge_count = count_bridges()
	ship_status_panel.update_bridge_status(bridge_count)

	# Update Budget status
	ship_status_panel.update_budget_status(current_budget, max_budget)

	# Update Power status
	var unpowered_count = count_unpowered_rooms()
	ship_status_panel.update_power_status(unpowered_count)

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

## Count number of unpowered rooms (excluding EMPTY and ARMOR)
func count_unpowered_rooms() -> int:
	# Create temporary ShipData to calculate power grid
	var temp_ship = ShipData.from_designer_grid(grid_tiles)

	var unpowered_count = 0
	for tile in grid_tiles:
		var room_type = tile.get_room_type()

		# Skip empty tiles and armor (armor doesn't need power)
		if room_type == RoomData.RoomType.EMPTY or room_type == RoomData.RoomType.ARMOR:
			continue

		# Check if this room is powered
		if not temp_ship.is_room_powered(tile.grid_x, tile.grid_y):
			unpowered_count += 1

	return unpowered_count

## Check if a room can be placed at given position
func can_place_room_at(room_type: RoomData.RoomType, x: int, y: int, current_type: RoomData.RoomType) -> bool:
	# Can't place EMPTY (that's for clearing)
	if room_type == RoomData.RoomType.EMPTY:
		return false

	# Check Bridge limit (only 1 allowed, unless this tile already has it)
	if room_type == RoomData.RoomType.BRIDGE and current_type != RoomData.RoomType.BRIDGE and count_bridges() >= 1:
		return false

	# Check row constraints
	if not RoomData.can_place_in_row(room_type, y):
		return false

	# Check budget
	var old_cost = RoomData.get_cost(current_type)
	var new_cost = RoomData.get_cost(room_type)
	var new_budget = current_budget - old_cost + new_cost
	if new_budget > max_budget:
		return false

	return true

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

## Pulse power lines brightness and update cost indicator
func _process(_delta):
	# Pulse alpha between 0.3 and 0.7
	var pulse = 0.5 + 0.2 * sin(Time.get_ticks_msec() / 500.0)
	for child in power_lines_container.get_children():
		if child is Line2D:
			child.default_color = Color(0.29, 0.89, 0.89, pulse)

	# Update cost indicator
	if selected_room_type != RoomData.RoomType.EMPTY and hovered_tile != null:
		# Show cost indicator near cursor
		var mouse_pos = get_global_mouse_position()
		cost_indicator.position = mouse_pos + Vector2(15, 15)  # Offset from cursor
		cost_indicator.visible = true

		# Update cost and color based on validity
		var cost = RoomData.get_cost(selected_room_type)
		cost_indicator.text = "+%d" % cost

		# Check if placement is valid
		var current_type = hovered_tile.get_room_type()
		var can_place = can_place_room_at(selected_room_type, hovered_tile.grid_x, hovered_tile.grid_y, current_type)

		# Set color: white if valid, red if invalid
		if can_place:
			cost_indicator.add_theme_color_override("font_color", Color(1, 1, 1))  # White
		else:
			cost_indicator.add_theme_color_override("font_color", Color(0.886, 0.290, 0.290))  # Red
	else:
		# Hide cost indicator when not hovering or no room selected
		cost_indicator.visible = false

## Handle tile left-click - place selected room type from palette
func _on_tile_clicked(x: int, y: int):
	var tile = get_tile_at(x, y)
	if not tile:
		return

	# Get current room type at this tile
	var current_type = tile.get_room_type()

	# If no room type selected from palette, do nothing
	if selected_room_type == RoomData.RoomType.EMPTY:
		return

	# If clicking same type, deselect it (clear the room)
	if current_type == selected_room_type:
		tile.clear_room()
		_update_budget_display()
		update_all_power_states()
		update_palette_counts()
		update_palette_availability()
		_update_ship_status()
		return

	# Validate placement using helper method
	var can_place = can_place_room_at(selected_room_type, x, y, current_type)

	# If can't place, flash red and return
	if not can_place:
		tile._play_flash_red()
		return

	# Place the room
	var room_scene = room_scenes.get(selected_room_type)
	if room_scene:
		var room = room_scene.instantiate()
		tile.set_room(room)

	# Update budget display and power states
	_update_budget_display()
	update_all_power_states()
	update_palette_counts()
	update_palette_availability()
	_update_ship_status()

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
	update_palette_counts()
	update_palette_availability()
	_update_ship_status()

## Handle room type selection from palette
func _on_room_type_selected(room_type: RoomData.RoomType):
	selected_room_type = room_type
	# Update button availability based on new selection
	update_palette_availability()

## Handle tile hover - show preview
func _on_tile_hovered(tile: GridTile):
	hovered_tile = tile

	# Only show preview if room type is selected
	if selected_room_type == RoomData.RoomType.EMPTY:
		return

	# Check if placement is valid
	var current_type = tile.get_room_type()
	var can_place = can_place_room_at(selected_room_type, tile.grid_x, tile.grid_y, current_type)

	# Show appropriate preview
	if can_place:
		tile.show_valid_preview()
	else:
		tile.show_invalid_preview()

## Handle tile unhover - clear preview
func _on_tile_unhovered(tile: GridTile):
	hovered_tile = null
	tile.clear_preview()

## Update room counts on palette panel
func update_palette_counts():
	# Count each room type
	var counts = {
		RoomData.RoomType.BRIDGE: 0,
		RoomData.RoomType.WEAPON: 0,
		RoomData.RoomType.SHIELD: 0,
		RoomData.RoomType.ENGINE: 0,
		RoomData.RoomType.REACTOR: 0,
		RoomData.RoomType.ARMOR: 0
	}

	for tile in grid_tiles:
		var room_type = tile.get_room_type()
		if counts.has(room_type):
			counts[room_type] += 1

	# Update palette display
	room_palette.update_counts(counts)

## Update which room types can be placed (enable/disable buttons)
func update_palette_availability():
	var available_types = []

	# Check each room type
	for room_type in [RoomData.RoomType.BRIDGE, RoomData.RoomType.WEAPON, RoomData.RoomType.SHIELD,
					  RoomData.RoomType.ENGINE, RoomData.RoomType.REACTOR, RoomData.RoomType.ARMOR]:
		var can_afford = true
		var can_place_somewhere = false

		# Check if we can afford it
		var cost = RoomData.get_cost(room_type)
		if current_budget + cost > max_budget:
			can_afford = false

		# Check if we can place it somewhere (at least one valid row)
		if can_afford:
			# Check Bridge limit
			if room_type == RoomData.RoomType.BRIDGE and count_bridges() >= 1:
				can_place_somewhere = false
			else:
				# Check if there's at least one valid row for this room type
				for y in range(GRID_HEIGHT):
					if RoomData.can_place_in_row(room_type, y):
						can_place_somewhere = true
						break

		# Add to available if can afford and can place
		if can_afford and can_place_somewhere:
			available_types.append(room_type)

	# Update palette
	room_palette.update_availability(available_types)

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

## Handle auto-fill button press - cycles through templates
func _on_auto_fill_pressed():
	# Clear current grid
	_clear_all_rooms()

	# Apply template based on current mission and template index
	var mission = GameState.current_mission

	match current_template_index:
		0:
			_apply_balanced_template(mission)
		1:
			_apply_aggressive_template(mission)
		2:
			_apply_tank_template(mission)

	# Cycle to next template
	current_template_index = (current_template_index + 1) % 3

	# Update display
	_update_budget_display()
	update_all_power_states()
	update_palette_counts()
	update_palette_availability()
	_update_ship_status()

## Handle clear grid button press
func _on_clear_grid_pressed():
	# Clear all rooms from grid
	_clear_all_rooms()

	# Update all displays
	_update_budget_display()
	update_all_power_states()
	update_palette_counts()
	update_palette_availability()
	_update_ship_status()

## Clear all rooms from the grid
func _clear_all_rooms():
	for tile in grid_tiles:
		tile.clear_room()

## Place a room at grid position
func _place_room_at(x: int, y: int, room_type: RoomData.RoomType):
	var tile = get_tile_at(x, y)
	if not tile:
		return

	var room_scene = room_scenes.get(room_type)
	if room_scene:
		var room = room_scene.instantiate()
		tile.set_room(room)

## Balanced template - good for all missions
## Budget: Mission 0=19, Mission 1=25, Mission 2=29
func _apply_balanced_template(mission: int):
	# Common core: Bridge + Reactor
	_place_room_at(3, 2, RoomData.RoomType.BRIDGE)  # 5
	_place_room_at(2, 2, RoomData.RoomType.REACTOR)  # 3 (total: 8)

	# All missions: 2 Weapons, 1 Shield, 1 Armor
	_place_room_at(2, 1, RoomData.RoomType.WEAPON)  # 2
	_place_room_at(2, 3, RoomData.RoomType.WEAPON)  # 2
	_place_room_at(3, 1, RoomData.RoomType.SHIELD)  # 3 (total: 15)
	_place_room_at(3, 4, RoomData.RoomType.ARMOR)  # 4 (total: 19)

	if mission >= 1:
		# Mission 1+: Add reactor and engine
		_place_room_at(4, 2, RoomData.RoomType.REACTOR)  # 3
		_place_room_at(4, 1, RoomData.RoomType.ENGINE)  # 2 (total: 24)

	if mission >= 2:
		# Mission 2: Add weapon, shield
		_place_room_at(4, 3, RoomData.RoomType.WEAPON)  # 2
		_place_room_at(3, 3, RoomData.RoomType.SHIELD)  # 3 (total: 29)

## Aggressive template - max damage
## Budget: Mission 0=20, Mission 1=25, Mission 2=30
func _apply_aggressive_template(mission: int):
	# Common core: Bridge + Reactor
	_place_room_at(3, 2, RoomData.RoomType.BRIDGE)  # 5
	_place_room_at(2, 2, RoomData.RoomType.REACTOR)  # 3 (total: 8)

	# All missions: 3 Weapons, 1 Shield
	_place_room_at(2, 1, RoomData.RoomType.WEAPON)  # 2
	_place_room_at(2, 3, RoomData.RoomType.WEAPON)  # 2
	_place_room_at(2, 0, RoomData.RoomType.WEAPON)  # 2
	_place_room_at(3, 1, RoomData.RoomType.SHIELD)  # 3 (total: 17)

	if mission >= 1:
		# Mission 1+: Add reactor, weapon, engine
		_place_room_at(4, 2, RoomData.RoomType.REACTOR)  # 3
		_place_room_at(4, 1, RoomData.RoomType.WEAPON)  # 2
		_place_room_at(3, 0, RoomData.RoomType.ENGINE)  # 2 (total: 24)

	if mission >= 2:
		# Mission 2: Add 2 more weapons
		_place_room_at(4, 3, RoomData.RoomType.WEAPON)  # 2
		_place_room_at(3, 3, RoomData.RoomType.WEAPON)  # 2 (total: 28)

## Tank template - high defense
## Budget: Mission 0=20, Mission 1=25, Mission 2=30
func _apply_tank_template(mission: int):
	# Common core: Bridge + Reactor
	_place_room_at(3, 2, RoomData.RoomType.BRIDGE)  # 5
	_place_room_at(2, 2, RoomData.RoomType.REACTOR)  # 3 (total: 8)

	# All missions: 1 Weapon, 2 Shields, 1 Armor
	_place_room_at(2, 1, RoomData.RoomType.WEAPON)  # 2
	_place_room_at(2, 3, RoomData.RoomType.SHIELD)  # 3
	_place_room_at(3, 1, RoomData.RoomType.SHIELD)  # 3
	_place_room_at(3, 4, RoomData.RoomType.ARMOR)  # 4 (total: 20)

	if mission == 1:
		# Mission 1: Add reactor, weapon
		_place_room_at(4, 2, RoomData.RoomType.REACTOR)  # 3
		_place_room_at(4, 1, RoomData.RoomType.WEAPON)  # 2 (total: 25)

	if mission == 2:
		# Mission 2: Add reactor, shield, armor
		_place_room_at(4, 2, RoomData.RoomType.REACTOR)  # 3
		_place_room_at(4, 1, RoomData.RoomType.SHIELD)  # 3
		_place_room_at(2, 4, RoomData.RoomType.ARMOR)  # 4 (total: 30)
