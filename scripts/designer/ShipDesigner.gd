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
@onready var save_button: Button = $SaveButton
@onready var load_button: Button = $LoadButton

## Room palette panel
@onready var room_palette: RoomPalettePanel = $RoomPalettePanel

## Ship status panel
@onready var ship_status_panel: ShipStatusPanel = $ShipStatusPanel

## Ship stats panel (Phase 10.9)
@onready var ship_stats_panel: ShipStatsPanel = $ShipStatsPanel

## Synergy guide panel
@onready var synergy_guide_panel: SynergyGuidePanel = $SynergyGuidePanel

## Cost indicator label
@onready var cost_indicator: Label = $CostIndicator

## Template UI (Phase 10.8)
@onready var template_name_dialog = $TemplateNameDialog
@onready var template_list_panel = $TemplateListPanel

## Current template index for cycling
var current_template_index: int = 0

## Currently selected room type from palette
var selected_room_type: RoomData.RoomType = RoomData.RoomType.EMPTY

## Current rotation angle for selected room (Phase 7.3)
var current_rotation: int = 0  # 0, 90, 180, or 270

## Currently hovered tile
var hovered_tile: GridTile = null

## Drag-to-place state for conduits (Feature 2.1)
var is_dragging_conduit: bool = false
var drag_start_tile: GridTile = null
var drag_current_line: Array[Vector2i] = []  # Tiles in current drag line

## Preload SynergyIndicator scene
var synergy_indicator_scene = preload("res://scenes/designer/components/SynergyIndicator.tscn")

## Preload Room scenes
var room_scenes = {
	RoomData.RoomType.BRIDGE: preload("res://scenes/components/rooms/Bridge.tscn"),
	RoomData.RoomType.WEAPON: preload("res://scenes/components/rooms/Weapon.tscn"),
	RoomData.RoomType.SHIELD: preload("res://scenes/components/rooms/Shield.tscn"),
	RoomData.RoomType.ENGINE: preload("res://scenes/components/rooms/Engine.tscn"),
	RoomData.RoomType.REACTOR: preload("res://scenes/components/rooms/Reactor.tscn"),
	RoomData.RoomType.ARMOR: preload("res://scenes/components/rooms/Armor.tscn"),
	RoomData.RoomType.CONDUIT: preload("res://scenes/components/rooms/Conduit.tscn")
}

## Track all placed room instances (Phase 7.1 - multi-tile rooms)
var placed_rooms: Array[Room] = []

## Room ID counter for tracking instances (Phase 7.1)
var next_room_id: int = 1

## Zoom and pan variables
var zoom_level: float = 1.0
var min_zoom: float = 0.5
var max_zoom: float = 3.0
var zoom_step: float = 0.1
var pan_offset: Vector2 = Vector2.ZERO
var pan_speed: float = 10.0  # Pixels per frame when holding WASD

func _ready():
	# Load mission budget from GameState
	max_budget = GameState.get_mission_budget(GameState.current_mission)

	# Initialize ship grid with hull-specific dimensions (Phase 10.4 - shaped hulls)
	var hull_data = GameState.get_current_hull_data()
	var grid_size: Vector2i = hull_data["grid_size"]
	var grid_shape: Array = hull_data.get("grid_shape", [])  # Optional hull shape
	ship_grid.initialize(grid_size.x, grid_size.y, grid_shape)

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

	# Connect save/load button signals (Phase 10.8)
	save_button.pressed.connect(_on_save_pressed)
	save_button.mouse_entered.connect(_on_button_hover_start.bind(save_button))
	save_button.mouse_exited.connect(_on_button_hover_end.bind(save_button))
	load_button.pressed.connect(_on_load_pressed)
	load_button.mouse_entered.connect(_on_button_hover_start.bind(load_button))
	load_button.mouse_exited.connect(_on_button_hover_end.bind(load_button))

	# Connect room palette signals
	room_palette.room_type_selected.connect(_on_room_type_selected)
	room_palette.rotation_requested.connect(rotate_selected_room)  # Phase 7.3

	# Connect template UI signals (Phase 10.8)
	template_name_dialog.template_name_entered.connect(_on_template_name_entered)
	template_list_panel.template_selected.connect(_on_template_selected)
	template_list_panel.start_fresh_requested.connect(_on_start_fresh_requested)

	# Initialize palette display
	update_palette_counts()
	update_palette_availability()

	# Initialize status panel
	_update_ship_status()

	# Initialize stats panel (Phase 10.9)
	_update_ship_stats()

	# Check if a template should be auto-loaded (from hull selection)
	if GameState.template_to_load:
		var template = GameState.template_to_load
		GameState.template_to_load = null  # Clear after loading
		# Apply template
		var success = template.apply_to_designer(self)
		if success:
			print("Auto-loaded template: %s" % template.template_name)
		else:
			push_error("Failed to auto-load template")

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

	# Update Hull bonus status (Phase 10.3)
	var hull_data = GameState.get_current_hull_data()
	ship_status_panel.update_hull_bonus(hull_data)

## Update ship stats panel (Phase 10.9)
func _update_ship_stats():
	# Create temporary ShipData to calculate stats
	var temp_ship = ShipData.from_designer_grid(ship_grid.get_all_tiles(), placed_rooms, ship_grid.GRID_WIDTH, ship_grid.GRID_HEIGHT)

	# Get hull bonuses
	var hull_data = GameState.get_current_hull_data()

	# Update panel
	ship_stats_panel.update_stats(temp_ship, hull_data)

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
	# Create temporary ShipData to calculate power grid (Phase 10.2 - pass grid dimensions)
	var temp_ship = ShipData.from_designer_grid(ship_grid.get_all_tiles(), placed_rooms, ship_grid.GRID_WIDTH, ship_grid.GRID_HEIGHT)

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
	# Create temporary ShipData to calculate synergies (Phase 10.2 - pass grid dimensions)
	var temp_ship = ShipData.from_designer_grid(ship_grid.get_all_tiles(), placed_rooms, ship_grid.GRID_WIDTH, ship_grid.GRID_HEIGHT)
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

		# Check column constraints for this specific tile (Phase 10.2 - pass grid width)
		if not RoomData.can_place_in_column(room_type, tile_x, ship_grid.GRID_WIDTH):
			return false

	# Check budget
	var new_cost = RoomData.get_cost(room_type)
	if current_budget + new_cost > max_budget:
		return false

	return true


## Flash all tiles in shape red for invalid placement (Phase 7.1)
func flash_shape_tiles_red(anchor_x: int, anchor_y: int, shape: Array):
	# Play failure sound for invalid placement
	AudioManager.play_failure()

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

	# Check column constraints (Phase 10.2 - pass grid width)
	if not RoomData.can_place_in_column(room_type, x, ship_grid.GRID_WIDTH):
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
	# HP is calculated based on armor count in ShipData (Phase 10.2 - pass grid dimensions)
	return ShipData.from_designer_grid(ship_grid.get_all_tiles(), placed_rooms, ship_grid.GRID_WIDTH, ship_grid.GRID_HEIGHT)

## Update power states for all tiles based on reactor positions
func update_all_power_states():
	# Create temporary ShipData to calculate power grid (Phase 10.2 - pass grid dimensions)
	var temp_ship = ShipData.from_designer_grid(ship_grid.get_all_tiles(), placed_rooms, ship_grid.GRID_WIDTH, ship_grid.GRID_HEIGHT)

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

	# Update synergy guide panel with counts (Phase 10.2 - pass grid dimensions)
	var temp_ship = ShipData.from_designer_grid(ship_grid.get_all_tiles(), placed_rooms, ship_grid.GRID_WIDTH, ship_grid.GRID_HEIGHT)
	var synergy_bonuses = temp_ship.calculate_synergy_bonuses()
	synergy_guide_panel.update_synergy_counts(synergy_bonuses["counts"])

## Pulse power lines brightness, update cost indicator, and handle WASD panning
func _process(_delta):
	# Pulse power lines (delegated to ShipGrid)
	ship_grid.pulse_power_lines()

	# Handle WASD panning when zoomed
	var pan_direction = Vector2.ZERO
	if Input.is_key_pressed(KEY_W):
		pan_direction.y += 1
	if Input.is_key_pressed(KEY_S):
		pan_direction.y -= 1
	if Input.is_key_pressed(KEY_A):
		pan_direction.x += 1
	if Input.is_key_pressed(KEY_D):
		pan_direction.x -= 1

	# Only pan if zoomed in and direction pressed
	if pan_direction != Vector2.ZERO:
		pan_offset += pan_direction * pan_speed
		_apply_zoom_and_pan()

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

## Handle input before GUI processing (Feature 2.1 - conduit drag completion)
func _input(event: InputEvent):
	# Feature 2.1: Detect mouse release to complete conduit drag placement
	# Use _input instead of _unhandled_input to catch release before GUI consumes it
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			if is_dragging_conduit:
				_complete_drag_placement()
				get_viewport().set_input_as_handled()
				return

## Handle keyboard and mouse input
func _unhandled_input(event: InputEvent):
	# Mouse wheel for zoom
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_zoom_in()
			get_viewport().set_input_as_handled()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_zoom_out()
			get_viewport().set_input_as_handled()

	# Keyboard input
	if event is InputEventKey and event.pressed and not event.echo:
		# R key to rotate selected room
		if event.keycode == KEY_R:
			# Only rotate if a room is selected (not EMPTY)
			if selected_room_type != RoomData.RoomType.EMPTY:
				rotate_selected_room()
				get_viewport().set_input_as_handled()

## Zoom in
func _zoom_in():
	zoom_level = min(zoom_level + zoom_step, max_zoom)
	_apply_zoom_and_pan()

## Zoom out
func _zoom_out():
	zoom_level = max(zoom_level - zoom_step, min_zoom)
	_apply_zoom_and_pan()

## Apply zoom and pan transformation to ship_grid
func _apply_zoom_and_pan():
	ship_grid.scale = Vector2(zoom_level, zoom_level)
	ship_grid.position = Vector2(960, 540) + pan_offset

## Handle tile left-click - place selected room type from palette (Phase 7.1/7.3 - shaped rooms with rotation)
## Feature 2.1: Conduits use drag-to-place instead of single-click
func _on_tile_clicked(x: int, y: int):
	var tile = ship_grid.get_tile_at(x, y)
	if not tile:
		return

	# If no room type selected from palette, do nothing
	if selected_room_type == RoomData.RoomType.EMPTY:
		return

	# Feature 2.1: Start drag-to-place mode for conduits
	if selected_room_type == RoomData.RoomType.CONDUIT:
		# Start dragging from this tile
		is_dragging_conduit = true
		drag_start_tile = tile
		drag_current_line = [Vector2i(x, y)]
		# Show initial preview on start tile
		_update_drag_preview()
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
			_update_ship_stats()
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
	_update_ship_stats()
	update_synergies()

	# Play room lock sound for successful room placement
	AudioManager.play_room_lock()

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
	_update_ship_stats()
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
## Feature 2.1: Update drag line when dragging conduits
func _on_tile_hovered(tile: GridTile):
	hovered_tile = tile

	# Only show preview if room type is selected
	if selected_room_type == RoomData.RoomType.EMPTY:
		return

	# Feature 2.1: Update drag line for conduits
	if is_dragging_conduit and drag_start_tile:
		# Calculate new drag line from start to current tile
		drag_current_line = _calculate_drag_line(drag_start_tile.grid_x, drag_start_tile.grid_y, tile.grid_x, tile.grid_y)
		# Update preview
		_update_drag_preview()
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
				var column_valid = RoomData.can_place_in_column(selected_room_type, tile_x, ship_grid.GRID_WIDTH)

				# Show cyan if tile is available, red if blocked
				if tile_empty and column_valid:
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

## Feature 2.1: Calculate drag line from start to end position (horizontal OR vertical, not diagonal)
func _calculate_drag_line(start_x: int, start_y: int, end_x: int, end_y: int) -> Array[Vector2i]:
	var line: Array[Vector2i] = []

	# Calculate deltas
	var dx = abs(end_x - start_x)
	var dy = abs(end_y - start_y)

	# Determine if line is more horizontal or vertical
	if dx >= dy:
		# Horizontal line (lock Y to start_y)
		var min_x = min(start_x, end_x)
		var max_x = max(start_x, end_x)
		for x in range(min_x, max_x + 1):
			line.append(Vector2i(x, start_y))
	else:
		# Vertical line (lock X to start_x)
		var min_y = min(start_y, end_y)
		var max_y = max(start_y, end_y)
		for y in range(min_y, max_y + 1):
			line.append(Vector2i(start_x, y))

	return line

## Feature 2.1: Update drag preview - show valid/invalid state for all tiles in line
func _update_drag_preview():
	# Clear all tile previews first
	for tile in ship_grid.get_all_tiles():
		tile.clear_preview()

	# Show preview on each tile in drag line
	for pos in drag_current_line:
		if not ship_grid.is_in_bounds(pos.x, pos.y):
			continue

		var tile = ship_grid.get_tile_at(pos.x, pos.y)
		if not tile:
			continue

		# Check if this specific tile can have a conduit placed on it
		var tile_empty = not tile.is_occupied()
		var can_afford = (current_budget + RoomData.get_cost(RoomData.RoomType.CONDUIT) * drag_current_line.size()) <= max_budget

		# Show cyan if valid, red if blocked
		if tile_empty and can_afford:
			tile.show_valid_preview()
		else:
			tile.show_invalid_preview()

## Feature 2.1: Place a single conduit at given position
func _place_single_conduit(x: int, y: int) -> bool:
	# Check if we can place a conduit here
	if not ship_grid.is_in_bounds(x, y):
		return false

	var tile = ship_grid.get_tile_at(x, y)
	if not tile or tile.is_occupied():
		return false

	# Check budget
	if current_budget + RoomData.get_cost(RoomData.RoomType.CONDUIT) > max_budget:
		return false

	# Create and place conduit
	var conduit_scene = room_scenes.get(RoomData.RoomType.CONDUIT)
	if not conduit_scene:
		return false

	var conduit: Room = conduit_scene.instantiate()
	conduit.room_type = RoomData.RoomType.CONDUIT
	conduit.room_id = next_room_id
	next_room_id += 1

	# Place on tile
	tile.set_occupying_room(conduit, true)
	conduit.add_occupied_tile(tile)

	# Add to tracking
	placed_rooms.append(conduit)

	return true

## Feature 2.1: Complete drag placement - place all conduits in line
func _complete_drag_placement():
	if drag_current_line.is_empty():
		_clear_drag_state()
		return

	# Validate entire line before placing any
	var can_place_all = true
	for pos in drag_current_line:
		if not ship_grid.is_in_bounds(pos.x, pos.y):
			can_place_all = false
			break

		var tile = ship_grid.get_tile_at(pos.x, pos.y)
		if not tile or tile.is_occupied():
			can_place_all = false
			break

	# Check total budget
	var total_cost = RoomData.get_cost(RoomData.RoomType.CONDUIT) * drag_current_line.size()
	if current_budget + total_cost > max_budget:
		can_place_all = false

	# Place all or flash red
	if can_place_all:
		# Place each conduit
		for pos in drag_current_line:
			_place_single_conduit(pos.x, pos.y)

		# Update displays
		_update_budget_display()
		update_all_power_states()
		update_palette_counts()
		update_palette_availability()
		_update_ship_status()
		_update_ship_stats()
		update_synergies()

		# Play success sound
		AudioManager.play_room_lock()
	else:
		# Flash red on invalid placement
		for pos in drag_current_line:
			if ship_grid.is_in_bounds(pos.x, pos.y):
				var tile = ship_grid.get_tile_at(pos.x, pos.y)
				if tile:
					tile._play_flash_red()

		# Play failure sound
		AudioManager.play_failure()

	# Clear drag state
	_clear_drag_state()

## Feature 2.1: Clear drag state and previews
func _clear_drag_state():
	is_dragging_conduit = false
	drag_start_tile = null
	drag_current_line.clear()

	# Clear all tile previews
	for tile in ship_grid.get_all_tiles():
		tile.clear_preview()

## Update room counts on palette panel (Phase 7.1 - count room instances, not tiles)
func update_palette_counts():
	# Count each room type
	var counts = {
		RoomData.RoomType.BRIDGE: 0,
		RoomData.RoomType.WEAPON: 0,
		RoomData.RoomType.SHIELD: 0,
		RoomData.RoomType.ENGINE: 0,
		RoomData.RoomType.REACTOR: 0,
		RoomData.RoomType.ARMOR: 0,
		RoomData.RoomType.CONDUIT: 0
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
					  RoomData.RoomType.ENGINE, RoomData.RoomType.REACTOR, RoomData.RoomType.ARMOR, RoomData.RoomType.CONDUIT]:
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
				# Check if there's at least one valid column for this room type (Phase 10.2)
				for x in range(ship_grid.GRID_WIDTH):
					if RoomData.can_place_in_column(room_type, x, ship_grid.GRID_WIDTH):
						can_place_somewhere = true
						break

		# Add to available if can afford and can place
		if can_afford and can_place_somewhere:
			available_types.append(room_type)

	# Update palette
	room_palette.update_availability(available_types)

## Handle launch button press
func _on_launch_pressed():
	# Play button click sound
	AudioManager.play_button_click()

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
	# Play button click sound
	AudioManager.play_button_click()

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
	_update_ship_stats()
	update_synergies()

	# Play success sound
	AudioManager.play_success()

## Handle clear grid button press
func _on_clear_grid_pressed():
	# Play button click sound
	AudioManager.play_button_click()

	# Clear all rooms from grid
	_clear_all_rooms()

	# Update all displays
	_update_budget_display()
	update_all_power_states()
	update_palette_counts()
	update_palette_availability()
	_update_ship_status()
	_update_ship_stats()
	update_synergies()

	# Play success sound
	AudioManager.play_success()

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

## Try to place a room for template generation (Phase 10.5 - hull-aware templates)
## Returns true if successfully placed, false otherwise
func _try_place_room_for_template(x: int, y: int, room_type: RoomData.RoomType) -> bool:
	# Validate placement
	if not can_place_shaped_room(x, y, room_type):
		return false

	# Place the room
	_place_room_at(x, y, room_type)

	# CRITICAL: Update budget after placement so next check sees correct value
	current_budget = calculate_current_budget()

	return true

## Get positions adjacent to powered rooms (Phase 10.5 - for power-aware placement)
## Returns array of Vector2i positions that would be powered
func _get_powered_positions() -> Array:
	var powered_positions = []

	# Create temp ship to check power
	var temp_ship = ShipData.from_designer_grid(ship_grid.get_all_tiles(), placed_rooms, ship_grid.GRID_WIDTH, ship_grid.GRID_HEIGHT)

	# Check all grid positions
	for y in range(ship_grid.GRID_HEIGHT):
		for x in range(ship_grid.GRID_WIDTH):
			# Skip if not in bounds (shaped hull)
			if not ship_grid.is_in_bounds(x, y):
				continue

			# Skip if occupied
			var tile = ship_grid.get_tile_at(x, y)
			if tile.is_occupied():
				continue

			# Check if position would be powered by checking adjacency to reactors
			var adjacent_positions = [
				Vector2i(x - 1, y),  # Left
				Vector2i(x + 1, y),  # Right
				Vector2i(x, y - 1),  # Up
				Vector2i(x, y + 1)   # Down
			]

			for adj_pos in adjacent_positions:
				if adj_pos.y >= 0 and adj_pos.y < temp_ship.grid.size():
					if adj_pos.x >= 0 and adj_pos.x < temp_ship.grid[adj_pos.y].size():
						var adj_room = temp_ship.grid[adj_pos.y][adj_pos.x]
						# Powered if adjacent to reactor
						if adj_room == RoomData.RoomType.REACTOR:
							powered_positions.append(Vector2i(x, y))
							break

	return powered_positions

## Fill remaining budget with armor tiles (Phase 10.5 - hull-aware templates)
## Tries to place armor in strategic locations
func _fill_armor_to_budget():
	var armor_cost = RoomData.get_cost(RoomData.RoomType.ARMOR)

	# Try to fill budget with armor (1 BP each)
	while current_budget + armor_cost <= max_budget:
		var placed = false

		# Try to place armor in available spaces (scan grid)
		for y in range(ship_grid.GRID_HEIGHT):
			for x in range(ship_grid.GRID_WIDTH):
				if _try_place_room_for_template(x, y, RoomData.RoomType.ARMOR):
					placed = true
					break
			if placed:
				break

		# If couldn't place any more armor, stop trying
		if not placed:
			break

## Balanced template - good for all missions (Phase 10.5 - hull-aware, power-optimized)
## Ship points RIGHT→ (weapons at right/front, engines at left/back)
## Adapts to Frigate (10×4), Cruiser (8×6), Battleship (7×7)
## Budget: M0=20, M1=25, M2=30 BP - ensures all rooms are powered
func _apply_balanced_template(mission: int):
	var w = ship_grid.GRID_WIDTH
	var h = ship_grid.GRID_HEIGHT
	var center_x = int(w / 2.0) - 1
	var center_y = int(h / 2.0) - 1

	# 1. Place Bridge (2×2) at center - 5 BP (always powered)
	_try_place_room_for_template(center_x, center_y, RoomData.RoomType.BRIDGE)

	# 2. Place first Reactor for power - 3 BP (always powered)
	# Try left-center area for good power coverage
	var reactor_placed = false
	for try_x in [1, 2, 0]:
		for try_y in [center_y, center_y + 1, center_y - 1]:
			if _try_place_room_for_template(try_x, try_y, RoomData.RoomType.REACTOR):
				reactor_placed = true
				break
		if reactor_placed:
			break

	# 3. Get powered positions (adjacent to reactors)
	var powered_pos = _get_powered_positions()

	# 4. Place 2 Weapons in powered positions in right half (front) - 4 BP total
	var weapons_placed = 0
	for pos in powered_pos:
		if weapons_placed >= 2:
			break
		# Check if in right half and valid column
		if pos.x >= int(w / 2.0) - 1 and RoomData.can_place_in_column(RoomData.RoomType.WEAPON, pos.x, w):
			if _try_place_room_for_template(pos.x, pos.y, RoomData.RoomType.WEAPON):
				weapons_placed += 1
				powered_pos = _get_powered_positions()  # Update powered positions

	# 5. Place Shield in powered position - 3 BP
	for pos in powered_pos:
		if _try_place_room_for_template(pos.x, pos.y, RoomData.RoomType.SHIELD):
			powered_pos = _get_powered_positions()
			break

	# 6. Place 1-2 Engines in powered positions in leftmost columns (back) - 2-4 BP
	var engines_placed = 0
	var target_engines = 1 if mission == 0 else 2
	for pos in powered_pos:
		if engines_placed >= target_engines:
			break
		if pos.x <= 1:  # Leftmost columns
			if _try_place_room_for_template(pos.x, pos.y, RoomData.RoomType.ENGINE):
				engines_placed += 1
				powered_pos = _get_powered_positions()

	# 7. For M1+: Add second reactor for better power coverage - 3 BP
	if mission >= 1:
		for try_x in range(w - 3, 1, -1):  # Right-center area
			reactor_placed = false
			for try_y in range(h):
				if _try_place_room_for_template(try_x, try_y, RoomData.RoomType.REACTOR):
					reactor_placed = true
					powered_pos = _get_powered_positions()  # Update after reactor
					break
			if reactor_placed:
				break

	# 8. For M2: Add another weapon in powered position - 2 BP
	if mission >= 2:
		for pos in powered_pos:
			if pos.x >= int(w / 2.0) - 1 and RoomData.can_place_in_column(RoomData.RoomType.WEAPON, pos.x, w):
				if _try_place_room_for_template(pos.x, pos.y, RoomData.RoomType.WEAPON):
					powered_pos = _get_powered_positions()
					break

	# 9. Fill remaining budget with armor (armor doesn't need power)
	_fill_armor_to_budget()

## Aggressive template - max damage (Phase 10.5 - hull-aware, power-optimized)
## Ship points RIGHT→ (weapons at right/front, engines at left/back)
## Focuses on maximum weapons with synergies
## Budget: M0=20, M1=25, M2=30 BP - ensures all rooms are powered
func _apply_aggressive_template(mission: int):
	var w = ship_grid.GRID_WIDTH
	var h = ship_grid.GRID_HEIGHT
	var center_x = int(w / 2.0) - 1
	var center_y = int(h / 2.0) - 1

	# 1. Place Bridge at center - 5 BP (always powered)
	_try_place_room_for_template(center_x, center_y, RoomData.RoomType.BRIDGE)

	# 2. Place reactor for power - 3 BP (always powered)
	var reactor_placed = false
	for try_x in [1, 2, 0]:
		for try_y in [center_y, center_y + 1, center_y - 1]:
			if _try_place_room_for_template(try_x, try_y, RoomData.RoomType.REACTOR):
				reactor_placed = true
				break
		if reactor_placed:
			break

	# 3. Get powered positions
	var powered_pos = _get_powered_positions()

	# 4. Place MAX weapons in powered positions in right half (front)
	# M0: 3 weapons, M1: 3 weapons, M2: 4 weapons
	var target_weapons = 3 if mission < 2 else 4
	var weapons_placed = 0
	for pos in powered_pos:
		if weapons_placed >= target_weapons:
			break
		if pos.x >= int(w / 2.0) - 1 and RoomData.can_place_in_column(RoomData.RoomType.WEAPON, pos.x, w):
			if _try_place_room_for_template(pos.x, pos.y, RoomData.RoomType.WEAPON):
				weapons_placed += 1
				powered_pos = _get_powered_positions()

	# 5. Minimal shield (just 1) in powered position - 3 BP
	for pos in powered_pos:
		if _try_place_room_for_template(pos.x, pos.y, RoomData.RoomType.SHIELD):
			powered_pos = _get_powered_positions()
			break

	# 6. Place 1-2 engines in powered positions - 2-4 BP
	var engines_placed = 0
	var target_engines = 1 if mission == 0 else 2
	for pos in powered_pos:
		if engines_placed >= target_engines:
			break
		if pos.x <= 1:  # Leftmost columns
			if _try_place_room_for_template(pos.x, pos.y, RoomData.RoomType.ENGINE):
				engines_placed += 1
				powered_pos = _get_powered_positions()

	# 7. For M1+: Add second reactor - 3 BP
	if mission >= 1:
		for try_x in range(w - 3, 1, -1):
			reactor_placed = false
			for try_y in range(h):
				if _try_place_room_for_template(try_x, try_y, RoomData.RoomType.REACTOR):
					reactor_placed = true
					powered_pos = _get_powered_positions()
					break
			if reactor_placed:
				break

	# 8. Fill remaining budget with armor (armor doesn't need power, creates durability synergy)
	_fill_armor_to_budget()

## Tank template - high defense (Phase 10.5 - hull-aware, power-optimized)
## Ship points RIGHT→ (weapons at right/front, engines at left/back)
## Focuses on max shields + armor for survivability
## Budget: M0=20, M1=25, M2=30 BP - ensures all rooms are powered
func _apply_tank_template(mission: int):
	var w = ship_grid.GRID_WIDTH
	var h = ship_grid.GRID_HEIGHT
	var center_x = int(w / 2.0) - 1
	var center_y = int(h / 2.0) - 1

	# 1. Place Bridge at center - 5 BP (always powered)
	_try_place_room_for_template(center_x, center_y, RoomData.RoomType.BRIDGE)

	# 2. Place 2 reactors for powering many shields - 6 BP total (always powered)
	var reactors_placed = 0
	for try_x in [1, 2, w - 3, 0]:
		for try_y in [center_y, center_y + 1, center_y - 1]:
			if reactors_placed >= 2:
				break
			if _try_place_room_for_template(try_x, try_y, RoomData.RoomType.REACTOR):
				reactors_placed += 1
		if reactors_placed >= 2:
			break

	# 3. Get powered positions
	var powered_pos = _get_powered_positions()

	# 4. Place MAX shields in powered positions near reactors for synergy
	# M0: 2 shields, M1: 3 shields, M2: 4 shields
	var target_shields = 2 if mission == 0 else (3 if mission == 1 else 4)
	var shields_placed = 0
	for pos in powered_pos:
		if shields_placed >= target_shields:
			break
		if _try_place_room_for_template(pos.x, pos.y, RoomData.RoomType.SHIELD):
			shields_placed += 1
			powered_pos = _get_powered_positions()

	# 5. Minimal weapons (1-2) in powered positions in right half - 2-4 BP
	var target_weapons = 1 if mission == 0 else 2
	var weapons_placed = 0
	for pos in powered_pos:
		if weapons_placed >= target_weapons:
			break
		if pos.x >= int(w / 2.0) - 1 and RoomData.can_place_in_column(RoomData.RoomType.WEAPON, pos.x, w):
			if _try_place_room_for_template(pos.x, pos.y, RoomData.RoomType.WEAPON):
				weapons_placed += 1
				powered_pos = _get_powered_positions()

	# 6. Place 1-2 engines in powered positions - 2-4 BP
	var engines_placed = 0
	var target_engines = 1 if mission == 0 else 2
	for pos in powered_pos:
		if engines_placed >= target_engines:
			break
		if pos.x <= 1:  # Leftmost columns
			if _try_place_room_for_template(pos.x, pos.y, RoomData.RoomType.ENGINE):
				engines_placed += 1
				powered_pos = _get_powered_positions()

	# 7. Fill remaining budget with LOTS of armor for max HP (armor doesn't need power)
	_fill_armor_to_budget()

## Handle save button press (Phase 10.8)
func _on_save_pressed():
	# Play button click sound
	AudioManager.play_button_click()

	# Check if ship has at least a bridge (can save incomplete designs, but need something)
	if placed_rooms.is_empty():
		push_warning("Cannot save empty design")
		AudioManager.play_failure()
		return

	# Show template name dialog
	template_name_dialog.show_dialog()

## Handle load button press (Phase 10.8)
func _on_load_pressed():
	# Play button click sound
	AudioManager.play_button_click()

	# Show template list panel
	template_list_panel.show_panel()

## Handle template name entered (Phase 10.8)
func _on_template_name_entered(template_name: String):
	# Create template from current design
	var template = ShipTemplate.from_ship_designer(self, template_name)

	# Save to manager
	var success = TemplateManager.save_player_template(template)

	if success:
		print("Template '%s' saved successfully" % template_name)
		AudioManager.play_success()
	else:
		push_error("Failed to save template '%s'" % template_name)
		AudioManager.play_failure()

## Handle template selected from list (Phase 10.8)
func _on_template_selected(template: ShipTemplate):
	# Apply template to designer
	var success = template.apply_to_designer(self)

	if success:
		print("Template '%s' loaded successfully" % template.template_name)
		# Update stats panel (Phase 10.9)
		_update_ship_stats()
		AudioManager.play_success()
	else:
		push_error("Failed to load template '%s'" % template.template_name)
		AudioManager.play_failure()

## Handle start fresh request (clear grid and start designing from scratch)
func _on_start_fresh_requested():
	# Clear all rooms from grid
	_clear_all_rooms()

	# Update all displays
	_update_budget_display()
	update_all_power_states()
	update_palette_counts()
	update_palette_availability()
	_update_ship_status()
	_update_ship_stats()
	update_synergies()

	print("Starting fresh - grid cleared for custom design")
	AudioManager.play_success()
