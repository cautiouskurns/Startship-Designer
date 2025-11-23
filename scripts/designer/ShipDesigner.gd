extends Control

## Signal emitted when player clicks Launch button with valid ship design
signal launch_pressed

## Budget values
var max_budget: int = 30  # Loaded from GameState based on mission
var current_budget: int = 0

## Ship grid (handles all grid/tile management)
@onready var ship_grid: ShipGrid = $ShipGrid

## Synergy container (now inside ShipGrid for correct positioning)
@onready var synergy_container: Node2D = $ShipGrid/SynergyContainer

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

## Synergy guide panel
@onready var synergy_guide_panel: SynergyGuidePanel = $SynergyGuidePanel

## Cost indicator label
@onready var cost_indicator: Label = $CostIndicator

## Current template index for cycling
var current_template_index: int = 0

## Currently selected room type from palette
var selected_room_type: RoomData.RoomType = RoomData.RoomType.EMPTY

## Current rotation angle for selected room (Phase 7.3)
var current_rotation: int = 0  # 0, 90, 180, or 270

## Currently hovered tile
var hovered_tile: GridTile = null

## Preload SynergyIndicator scene
var synergy_indicator_scene = preload("res://scenes/designer/components/SynergyIndicator.tscn")

## Preload Room scenes
var room_scenes = {
	RoomData.RoomType.BRIDGE: preload("res://scenes/components/rooms/Bridge.tscn"),
	RoomData.RoomType.WEAPON: preload("res://scenes/components/rooms/Weapon.tscn"),
	RoomData.RoomType.SHIELD: preload("res://scenes/components/rooms/Shield.tscn"),
	RoomData.RoomType.ENGINE: preload("res://scenes/components/rooms/Engine.tscn"),
	RoomData.RoomType.REACTOR: preload("res://scenes/components/rooms/Reactor.tscn"),
	RoomData.RoomType.ARMOR: preload("res://scenes/components/rooms/Armor.tscn")
}

## Track all placed room instances (Phase 7.1 - multi-tile rooms)
var placed_rooms: Array[Room] = []

## Room ID counter for tracking instances (Phase 7.1)
var next_room_id: int = 1

func _ready():
	# Load mission budget from GameState
	max_budget = GameState.get_mission_budget(GameState.current_mission)

	# Initialize ship grid with hull-specific dimensions (Phase 10.1)
	var hull_data = GameState.get_current_hull_data()
	var grid_size: Vector2i = hull_data["grid_size"]
	ship_grid.initialize(grid_size.x, grid_size.y)

	_update_budget_display()

	# Connect ship grid signals
	ship_grid.tile_clicked.connect(_on_tile_clicked)
	ship_grid.tile_right_clicked.connect(_on_tile_right_clicked)
	ship_grid.tile_hovered.connect(_on_tile_hovered)
	ship_grid.tile_unhovered.connect(_on_tile_unhovered)

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
	room_palette.rotation_requested.connect(rotate_selected_room)  # Phase 7.3

	# Initialize palette display
	update_palette_counts()
	update_palette_availability()

	# Initialize status panel
	_update_ship_status()

## Calculate current budget from all placed rooms (Phase 7.1 - count room instances, not tiles)
func calculate_current_budget() -> int:
	var total = 0
	for room in placed_rooms:
		total += RoomData.get_cost(room.room_type)
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

	# Update Synergy status
	var synergy_count = count_synergies()
	ship_status_panel.update_synergy_status(synergy_count)

## Get color for remaining budget based on value
func _get_remaining_color(remaining: int) -> Color:
	if remaining > 5:
		return Color(0.290, 0.886, 0.290)  # Green #4AE24A
	elif remaining >= 1:
		return Color(0.886, 0.831, 0.290)  # Yellow #E2D44A
	else:
		return Color(0.886, 0.290, 0.290)  # Red #E24A4A

## Get next room type in cycling order
func get_next_room_type(current: RoomData.RoomType) -> RoomData.RoomType:
	# Cycle: EMPTY → BRIDGE → WEAPON → SHIELD → ENGINE → REACTOR → ARMOR → EMPTY
	var next_value = (int(current) + 1) % 7
	return next_value as RoomData.RoomType

## Rotate selected room by 90° clockwise (Phase 7.3)
func rotate_selected_room():
	# Increment rotation by 90°
	current_rotation = (current_rotation + 90) % 360

	# Update palette rotation display
	room_palette.update_rotation_display(current_rotation)

	# Update preview if we're hovering over a tile
	if hovered_tile and selected_room_type != RoomData.RoomType.EMPTY:
		# Save reference before clearing (unhovered sets hovered_tile to null)
		var tile_to_refresh = hovered_tile
		# Clear current preview
		_on_tile_unhovered(tile_to_refresh)
		# Show new preview with rotated shape
		_on_tile_hovered(tile_to_refresh)

## Get the shape for selected room type with current rotation applied (Phase 7.3)
func get_rotated_shape(room_type: RoomData.RoomType) -> Array:
	var base_shape = RoomData.get_shape(room_type)
	return RoomData.rotate_shape(base_shape, current_rotation)

## Count number of Bridge rooms currently placed (Phase 7.1 - count room instances, not tiles)
func count_bridges() -> int:
	var count = 0
	for room in placed_rooms:
		if room.room_type == RoomData.RoomType.BRIDGE:
			count += 1
	return count

## Count number of unpowered rooms (excluding EMPTY and ARMOR)
func count_unpowered_rooms() -> int:
	# Create temporary ShipData to calculate power grid
	var temp_ship = ShipData.from_designer_grid(ship_grid.get_all_tiles(), placed_rooms)

	var unpowered_count = 0
	for tile in ship_grid.get_all_tiles():
		var room_type = tile.get_room_type()

		# Skip empty tiles and armor (armor doesn't need power)
		if room_type == RoomData.RoomType.EMPTY or room_type == RoomData.RoomType.ARMOR:
			continue

		# Check if this room is powered
		if not temp_ship.is_room_powered(tile.grid_x, tile.grid_y):
			unpowered_count += 1

	return unpowered_count

## Count number of active synergies
func count_synergies() -> int:
	# Create temporary ShipData to calculate synergies
	var temp_ship = ShipData.from_designer_grid(ship_grid.get_all_tiles(), placed_rooms)
	var synergy_bonuses = temp_ship.calculate_synergy_bonuses()
	var synergy_counts = synergy_bonuses["counts"]

	# Sum all synergy types
	var total = 0
	for synergy_type in synergy_counts:
		total += synergy_counts[synergy_type]

	return total

## Check if a shaped room can be placed at given position (Phase 7.1/7.3 - with optional rotated shape)
func can_place_shaped_room(anchor_x: int, anchor_y: int, room_type: RoomData.RoomType, custom_shape: Array = []) -> bool:
	# Can't place EMPTY
	if room_type == RoomData.RoomType.EMPTY:
		return false

	# Get shape for this room type (use custom_shape if provided, otherwise base shape)
	var shape = custom_shape if not custom_shape.is_empty() else RoomData.get_shape(room_type)

	# Check Bridge limit (only 1 allowed)
	if room_type == RoomData.RoomType.BRIDGE and count_bridges() >= 1:
		return false

	# Validate each tile in the shape
	for offset in shape:
		var tile_x = anchor_x + offset[0]
		var tile_y = anchor_y + offset[1]

		# Check bounds
		if not ship_grid.is_in_bounds(tile_x, tile_y):
			return false

		# Check if tile is occupied
		var tile = ship_grid.get_tile_at(tile_x, tile_y)
		if tile.is_occupied():
			return false

		# Check row constraints for this specific tile
		if not RoomData.can_place_in_row(room_type, tile_y):
			return false

	# Check budget
	var new_cost = RoomData.get_cost(room_type)
	if current_budget + new_cost > max_budget:
		return false

	return true


## Flash all tiles in shape red for invalid placement (Phase 7.1)
func flash_shape_tiles_red(anchor_x: int, anchor_y: int, shape: Array):
	for offset in shape:
		var tile_x = anchor_x + offset[0]
		var tile_y = anchor_y + offset[1]

		# Only flash if tile is in bounds
		if ship_grid.is_in_bounds(tile_x, tile_y):
			var tile = ship_grid.get_tile_at(tile_x, tile_y)
			if tile:
				tile._play_flash_red()

## Remove entire room instance from all tiles it occupies (Phase 7.1)
func _remove_room_at_tile(tile: GridTile):
	if not tile or not tile.is_occupied():
		return

	var room = tile.occupying_room
	if not room:
		return

	# Get all tiles occupied by this room
	var occupied_tiles = room.get_occupied_tiles()

	# Clear room reference from all occupied tiles
	for occupied_tile in occupied_tiles:
		occupied_tile.clear_occupying_room()

	# Remove room from placed_rooms tracking array
	placed_rooms.erase(room)

	# Free the room instance
	room.queue_free()

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
	return ShipData.from_designer_grid(ship_grid.get_all_tiles(), placed_rooms)

## Update power states for all tiles based on reactor positions
func update_all_power_states():
	# Create temporary ShipData to calculate power grid
	var temp_ship = ShipData.from_designer_grid(ship_grid.get_all_tiles(), placed_rooms)

	# Update visual power state for each tile
	for tile in ship_grid.get_all_tiles():
		# Skip empty tiles
		if tile.get_room_type() == RoomData.RoomType.EMPTY:
			continue

		# Check if this position is powered
		var is_powered = temp_ship.is_room_powered(tile.grid_x, tile.grid_y)

		# Update visual state
		tile.set_powered_state(is_powered)

	# Update power lines visual (delegated to ShipGrid)
	ship_grid.draw_power_lines(temp_ship)

## Update synergy indicators based on room adjacencies
func update_synergies():
	# Clear existing synergy indicators
	for child in synergy_container.get_children():
		child.queue_free()

	# Track which synergies we've already created (to avoid duplicates)
	var created_synergies = {}

	# Check each tile for potential synergies
	for y in range(ship_grid.GRID_HEIGHT):
		for x in range(ship_grid.GRID_WIDTH):
			var tile = ship_grid.get_tile_at(x, y)
			if not tile:
				continue

			var room_type = tile.get_room_type()
			if room_type == RoomData.RoomType.EMPTY:
				continue

			# Check 4 adjacent tiles (right and down only to avoid duplicates)
			var adjacent_checks = [
				Vector2i(x + 1, y),  # Right
				Vector2i(x, y + 1)   # Down
			]

			for adj_pos in adjacent_checks:
				# Check bounds
				if not ship_grid.is_in_bounds(adj_pos.x, adj_pos.y):
					continue

				var adj_tile = ship_grid.get_tile_at(adj_pos.x, adj_pos.y)
				if not adj_tile:
					continue

				var adj_room_type = adj_tile.get_room_type()
				if adj_room_type == RoomData.RoomType.EMPTY:
					continue

				# Phase 7.1: Skip if both tiles belong to the same room instance
				# (prevents synergies between tiles of multi-tile rooms like 2×2 Bridge)
				if tile.occupying_room and adj_tile.occupying_room:
					if tile.occupying_room == adj_tile.occupying_room:
						continue  # Same room instance, skip synergy

				# Check if these two room types create a synergy
				var synergy_type = RoomData.get_synergy_type(room_type, adj_room_type)
				if synergy_type == RoomData.SynergyType.NONE:
					continue

				# Create unique key for this synergy to avoid duplicates
				var synergy_key = "%d,%d-%d,%d" % [x, y, adj_pos.x, adj_pos.y]
				if synergy_key in created_synergies:
					continue

				# Create synergy indicator
				var indicator: SynergyIndicator = synergy_indicator_scene.instantiate()
				indicator.setup(tile, adj_tile, synergy_type)
				synergy_container.add_child(indicator)

				# Mark as created
				created_synergies[synergy_key] = true

	# Update synergy guide panel with counts
	var temp_ship = ShipData.from_designer_grid(ship_grid.get_all_tiles(), placed_rooms)
	var synergy_bonuses = temp_ship.calculate_synergy_bonuses()
	synergy_guide_panel.update_synergy_counts(synergy_bonuses["counts"])

## Pulse power lines brightness and update cost indicator
func _process(_delta):
	# Pulse power lines (delegated to ShipGrid)
	ship_grid.pulse_power_lines()

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

## Handle keyboard input (Phase 7.3 - R key for rotation)
func _unhandled_input(event: InputEvent):
	if event is InputEventKey and event.pressed and not event.echo:
		# R key to rotate selected room
		if event.keycode == KEY_R:
			# Only rotate if a room is selected (not EMPTY)
			if selected_room_type != RoomData.RoomType.EMPTY:
				rotate_selected_room()
				get_viewport().set_input_as_handled()

## Handle tile left-click - place selected room type from palette (Phase 7.1/7.3 - shaped rooms with rotation)
func _on_tile_clicked(x: int, y: int):
	var tile = ship_grid.get_tile_at(x, y)
	if not tile:
		return

	# If no room type selected from palette, do nothing
	if selected_room_type == RoomData.RoomType.EMPTY:
		return

	# Get shape for selected room type with current rotation (Phase 7.3)
	var shape = get_rotated_shape(selected_room_type)

	# If clicking a tile that's already occupied by a room
	if tile.is_occupied():
		# If it's the same room type as selected, remove the entire room
		if tile.get_room_type() == selected_room_type:
			_remove_room_at_tile(tile)
			_update_budget_display()
			update_all_power_states()
			update_palette_counts()
			update_palette_availability()
			_update_ship_status()
			update_synergies()
			return
		else:
			# Different room type - can't place on occupied tile, flash red
			flash_shape_tiles_red(x, y, shape)
			return

	# Validate shaped room placement with rotated shape (Phase 7.3)
	var can_place = can_place_shaped_room(x, y, selected_room_type, shape)

	# If can't place, flash all tiles in shape red and return
	if not can_place:
		flash_shape_tiles_red(x, y, shape)
		return

	# Create and place the shaped room
	var room_scene = room_scenes.get(selected_room_type)
	if not room_scene:
		return

	# Instantiate room
	var room: Room = room_scene.instantiate()
	room.room_type = selected_room_type
	room.room_id = next_room_id
	next_room_id += 1

	# Place room on all tiles in shape
	var is_first = true
	for offset in shape:
		var tile_x = x + offset[0]
		var tile_y = y + offset[1]
		var target_tile = ship_grid.get_tile_at(tile_x, tile_y)

		if target_tile:
			# Set occupying room (first tile is anchor, owns visual)
			target_tile.set_occupying_room(room, is_first)
			# Add tile to room's occupation list
			room.add_occupied_tile(target_tile)
			is_first = false

	# Add to placed rooms tracking array
	placed_rooms.append(room)

	# Update budget display and power states
	_update_budget_display()
	update_all_power_states()
	update_palette_counts()
	update_palette_availability()
	_update_ship_status()
	update_synergies()

## Handle tile right-click - remove room (Phase 7.1 - removes entire multi-tile room)
func _on_tile_right_clicked(x: int, y: int):
	var tile = ship_grid.get_tile_at(x, y)
	if not tile:
		return

	# Remove entire room instance (works for both single-tile and multi-tile rooms)
	_remove_room_at_tile(tile)

	# Update budget display and power states
	_update_budget_display()
	update_all_power_states()
	update_palette_counts()
	update_palette_availability()
	_update_ship_status()
	update_synergies()

## Handle room type selection from palette (Phase 7.3 - reset rotation)
func _on_room_type_selected(room_type: RoomData.RoomType):
	selected_room_type = room_type
	# Reset rotation to 0° when changing room selection
	current_rotation = 0
	# Update palette rotation display
	room_palette.update_rotation_display(current_rotation)
	# Update button availability based on new selection
	update_palette_availability()

## Handle tile hover - show preview (Phase 7.2/7.3 - per-tile mixed preview states with rotation)
func _on_tile_hovered(tile: GridTile):
	hovered_tile = tile

	# Only show preview if room type is selected
	if selected_room_type == RoomData.RoomType.EMPTY:
		return

	# Get shape for selected room type with current rotation (Phase 7.3)
	var shape = get_rotated_shape(selected_room_type)

	# Show preview on all tiles in the shape with per-tile state feedback
	for offset in shape:
		var tile_x = tile.grid_x + offset[0]
		var tile_y = tile.grid_y + offset[1]

		# Check bounds
		if ship_grid.is_in_bounds(tile_x, tile_y):
			var preview_tile = ship_grid.get_tile_at(tile_x, tile_y)
			if preview_tile:
				# Check THIS specific tile's state for mixed preview feedback
				var tile_empty = not preview_tile.is_occupied()
				var row_valid = RoomData.can_place_in_row(selected_room_type, tile_y)

				# Show cyan if tile is available, red if blocked
				if tile_empty and row_valid:
					preview_tile.show_valid_preview()  # Cyan border
				else:
					preview_tile.show_invalid_preview()  # Red border

## Handle tile unhover - clear preview (Phase 7.2/7.3 - clear multi-tile preview with rotation)
func _on_tile_unhovered(tile: GridTile):
	# Clear preview from previously hovered tile and its shape
	if hovered_tile and selected_room_type != RoomData.RoomType.EMPTY:
		var shape = get_rotated_shape(selected_room_type)

		# Clear preview on all tiles in the shape
		for offset in shape:
			var tile_x = hovered_tile.grid_x + offset[0]
			var tile_y = hovered_tile.grid_y + offset[1]

			# Check bounds
			if ship_grid.is_in_bounds(tile_x, tile_y):
				var preview_tile = ship_grid.get_tile_at(tile_x, tile_y)
				if preview_tile:
					preview_tile.clear_preview()

	hovered_tile = null

## Update room counts on palette panel (Phase 7.1 - count room instances, not tiles)
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

	# Count room instances (not tiles, to avoid counting multi-tile rooms multiple times)
	for room in placed_rooms:
		if counts.has(room.room_type):
			counts[room.room_type] += 1

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
				for y in range(ship_grid.GRID_HEIGHT):
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
	update_synergies()

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
	update_synergies()

## Clear all rooms from the grid (Phase 7.1 - free room instances)
func _clear_all_rooms():
	# Create a copy of placed_rooms array to iterate (since we'll modify the original)
	var rooms_to_remove = placed_rooms.duplicate()

	# Remove each room instance
	for room in rooms_to_remove:
		# Get all tiles and clear references
		var occupied_tiles = room.get_occupied_tiles()
		for tile in occupied_tiles:
			tile.clear_occupying_room()

		# Free the room instance
		room.queue_free()

	# Clear the placed_rooms tracking array
	placed_rooms.clear()

## Place a shaped room at grid position (Phase 7.1 - anchor tile is top-left of room)
func _place_room_at(x: int, y: int, room_type: RoomData.RoomType):
	# Get shape for this room type
	var shape = RoomData.get_shape(room_type)

	# Validate placement (should always succeed in templates, but check anyway)
	if not can_place_shaped_room(x, y, room_type):
		push_warning("Template tried to place %s at (%d,%d) but placement failed!" % [RoomData.get_label(room_type), x, y])
		return

	# Create room instance
	var room_scene = room_scenes.get(room_type)
	if not room_scene:
		return

	var room: Room = room_scene.instantiate()
	room.room_type = room_type
	room.room_id = next_room_id
	next_room_id += 1

	# Place room on all tiles in shape
	var is_first = true
	for offset in shape:
		var tile_x = x + offset[0]
		var tile_y = y + offset[1]
		var target_tile = ship_grid.get_tile_at(tile_x, tile_y)

		if target_tile:
			target_tile.set_occupying_room(room, is_first)
			room.add_occupied_tile(target_tile)
			is_first = false

	# Add to placed rooms tracking array
	placed_rooms.append(room)

## Balanced template - good for all missions (Phase 7.1 - shaped rooms)
## Bridge 2×2, Weapons/Shields/Engines 1×2, Reactor T-shape, Armor 1×1
## Budget: Mission 0=15, Mission 1=23, Mission 2=29
func _apply_balanced_template(mission: int):
	# Core: Bridge (2×2 in center) + Reactor (T-shape adjacent for power)
	_place_room_at(3, 2, RoomData.RoomType.BRIDGE)     # 5 BP - (3,2),(4,2),(3,3),(4,3)
	_place_room_at(1, 1, RoomData.RoomType.REACTOR)    # 3 BP - T: (1,2),(2,1),(2,2),(2,3)

	# Weapons (1×2 horizontal, rows 0-1 only)
	_place_room_at(0, 0, RoomData.RoomType.WEAPON)     # 2 BP - (0,0),(1,0)
	_place_room_at(4, 1, RoomData.RoomType.WEAPON)     # 2 BP - (4,1),(5,1)

	# Shield (1×2 horizontal, adjacent to reactor)
	_place_room_at(0, 2, RoomData.RoomType.SHIELD)     # 3 BP - (0,2),(1,2)
	# Total: 15 BP

	if mission >= 1:
		# Add Engine + Armor
		_place_room_at(3, 4, RoomData.RoomType.ENGINE)   # 2 BP - (3,4),(4,4) rows 4-5
		_place_room_at(5, 3, RoomData.RoomType.ARMOR)    # 1 BP
		_place_room_at(5, 2, RoomData.RoomType.ARMOR)    # 1 BP
		# Add Reactor for more power
		_place_room_at(5, 0, RoomData.RoomType.REACTOR)  # 3 BP - T-shape
		# Total: 23 BP

	if mission >= 2:
		# Add Weapon + Engine + Armor
		_place_room_at(6, 1, RoomData.RoomType.WEAPON)   # 2 BP - (6,1),(7,1)
		_place_room_at(5, 4, RoomData.RoomType.ENGINE)   # 2 BP - (5,4),(6,4)
		_place_room_at(0, 4, RoomData.RoomType.ARMOR)    # 1 BP
		_place_room_at(2, 5, RoomData.RoomType.ARMOR)    # 1 BP
		# Total: 29 BP

## Aggressive template - max damage (Phase 7.1 - shaped rooms)
## Focuses on weapons for high damage output
## Budget: Mission 0=17, Mission 1=25, Mission 2=30
func _apply_aggressive_template(mission: int):
	# Core: Bridge + Reactor for power
	_place_room_at(3, 2, RoomData.RoomType.BRIDGE)     # 5 BP - (3,2),(4,2),(3,3),(4,3)
	_place_room_at(1, 0, RoomData.RoomType.REACTOR)    # 3 BP - T: (1,1),(2,0),(2,1),(2,2)

	# Max weapons (1×2 horizontal, rows 0-1 only)
	_place_room_at(0, 0, RoomData.RoomType.WEAPON)     # 2 BP - (0,0),(1,0)
	_place_room_at(4, 0, RoomData.RoomType.WEAPON)     # 2 BP - (4,0),(5,0)
	_place_room_at(4, 1, RoomData.RoomType.WEAPON)     # 2 BP - (4,1),(5,1)

	# Minimal shield
	_place_room_at(0, 2, RoomData.RoomType.SHIELD)     # 3 BP - (0,2),(1,2)
	# Total: 17 BP

	if mission >= 1:
		# Add more weapons + engine
		_place_room_at(6, 0, RoomData.RoomType.WEAPON)   # 2 BP - (6,0),(7,0)
		_place_room_at(6, 1, RoomData.RoomType.WEAPON)   # 2 BP - (6,1),(7,1)
		_place_room_at(3, 4, RoomData.RoomType.ENGINE)   # 2 BP - (3,4),(4,4)
		_place_room_at(0, 4, RoomData.RoomType.ENGINE)   # 2 BP - (0,4),(1,4)
		# Total: 25 BP

	if mission >= 2:
		# Add Reactor for more power + armor
		_place_room_at(5, 2, RoomData.RoomType.REACTOR)  # 3 BP - T-shape
		_place_room_at(5, 5, RoomData.RoomType.ARMOR)    # 1 BP
		_place_room_at(2, 5, RoomData.RoomType.ARMOR)    # 1 BP
		# Total: 30 BP

## Tank template - high defense (Phase 7.1 - shaped rooms)
## Focuses on shields and armor for survivability
## Budget: Mission 0=17, Mission 1=26, Mission 2=30
func _apply_tank_template(mission: int):
	# Core: Bridge + Reactor
	_place_room_at(3, 2, RoomData.RoomType.BRIDGE)     # 5 BP - (3,2),(4,2),(3,3),(4,3)
	_place_room_at(1, 1, RoomData.RoomType.REACTOR)    # 3 BP - T: (1,2),(2,1),(2,2),(2,3)

	# Minimal weapon
	_place_room_at(4, 0, RoomData.RoomType.WEAPON)     # 2 BP - (4,0),(5,0)

	# Max shields (1×2 horizontal)
	_place_room_at(0, 2, RoomData.RoomType.SHIELD)     # 3 BP - (0,2),(1,2)
	_place_room_at(5, 2, RoomData.RoomType.SHIELD)     # 3 BP - (5,2),(6,2)

	# Armor
	_place_room_at(5, 3, RoomData.RoomType.ARMOR)      # 1 BP
	# Total: 17 BP

	if mission >= 1:
		# Add more shields + reactor + engine + armor
		_place_room_at(5, 0, RoomData.RoomType.REACTOR)  # 3 BP - T-shape
		_place_room_at(0, 4, RoomData.RoomType.SHIELD)   # 3 BP - (0,4),(1,4)
		_place_room_at(3, 4, RoomData.RoomType.ENGINE)   # 2 BP - (3,4),(4,4)
		_place_room_at(7, 2, RoomData.RoomType.ARMOR)    # 1 BP
		# Total: 26 BP

	if mission >= 2:
		# Add more armor
		_place_room_at(2, 5, RoomData.RoomType.ARMOR)    # 1 BP
		_place_room_at(5, 5, RoomData.RoomType.ARMOR)    # 1 BP
		_place_room_at(6, 4, RoomData.RoomType.ARMOR)    # 1 BP
		_place_room_at(0, 3, RoomData.RoomType.ARMOR)    # 1 BP
		# Total: 30 BP
