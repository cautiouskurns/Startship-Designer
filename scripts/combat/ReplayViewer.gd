extends Control

## Replay viewer for battle history (Feature 2: Timeline Bar & Scrubbing)
## Allows scrubbing through turn-by-turn state to analyze battle outcomes

## Child nodes (assigned in scene)
@onready var player_ship_display: ShipDisplay = $ShipBattleArea/PlayerShipContainer/PlayerShipDisplay
@onready var enemy_ship_display: ShipDisplay = $ShipBattleArea/EnemyShipContainer/EnemyShipDisplay
@onready var timeline_bar: TimelineBar = $TimelineBar
@onready var turn_indicator: Label = $TurnIndicator
@onready var player_health_label: Label = $PlayerHealthLabel
@onready var enemy_health_label: Label = $EnemyHealthLabel
@onready var events_log: RichTextLabel = $EventsPanel/EventsLog
@onready var back_button: Button = $BackButton
@onready var continue_button: Button = $ContinueButton
@onready var play_button: Button = $PlayButton
@onready var pause_button: Button = $PauseButton
@onready var restart_button: Button = $RestartButton
@onready var end_button: Button = $EndButton
@onready var combat_fx: CombatFX = $CombatFX

## Battle data
var battle_result: BattleResult = null
var original_player_data: ShipData = null
var original_enemy_data: ShipData = null
var current_turn: int = 0

## Reconstructed ship data for current turn (for action playback)
var player_data: ShipData = null
var enemy_data: ShipData = null

## Speed control for action playback
var speed_multiplier: float = 1.0

## Playback controls
var is_playing: bool = false
const PLAYBACK_TURN_DELAY: float = 1.5  # Seconds between turns during auto-play

func _ready():
	print("DEBUG ReplayViewer: _ready() called - scene is loading")
	# Load battle result from GameState
	battle_result = GameState.get_battle_result()
	print("DEBUG ReplayViewer: battle_result retrieved from GameState: ", battle_result)

	if not battle_result:
		push_error("No battle result found in GameState!")
		_return_to_combat()
		return

	# Load original ship data from GameState (stored by Combat.gd)
	original_player_data = GameState.original_player_data
	original_enemy_data = GameState.original_enemy_data
	print("DEBUG ReplayViewer: original_player_data = ", original_player_data)
	print("DEBUG ReplayViewer: original_enemy_data = ", original_enemy_data)

	if not original_player_data or not original_enemy_data:
		push_error("Original ship data not found in GameState!")
		_return_to_combat()
		return

	print("DEBUG ReplayViewer: Loaded battle result - ", battle_result.get_summary())

	# Initialize timeline
	timeline_bar.set_total_turns(battle_result.total_turns)
	timeline_bar.set_current_turn(0)
	timeline_bar.turn_changed.connect(_on_turn_changed)

	# Connect back button
	back_button.pressed.connect(_on_back_pressed)
	back_button.mouse_entered.connect(_on_button_hover_start.bind(back_button))
	back_button.mouse_exited.connect(_on_button_hover_end.bind(back_button))

	# Connect continue button
	continue_button.pressed.connect(_on_continue_pressed)
	continue_button.mouse_entered.connect(_on_button_hover_start.bind(continue_button))
	continue_button.mouse_exited.connect(_on_button_hover_end.bind(continue_button))

	# Configure continue button based on mission and outcome
	var current_mission = battle_result.mission_index
	if current_mission >= 2 or not battle_result.player_won:
		# Final mission completed or battle lost - hide continue button
		continue_button.visible = false
	elif current_mission == 1:
		# Mission 2 completed - next is the final mission
		continue_button.text = "FINAL MISSION"

	# Connect playback control buttons
	play_button.pressed.connect(_on_play_pressed)
	pause_button.pressed.connect(_on_pause_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	end_button.pressed.connect(_on_end_pressed)

	# Connect hover effects for playback buttons
	play_button.mouse_entered.connect(_on_button_hover_start.bind(play_button))
	play_button.mouse_exited.connect(_on_button_hover_end.bind(play_button))
	pause_button.mouse_entered.connect(_on_button_hover_start.bind(pause_button))
	pause_button.mouse_exited.connect(_on_button_hover_end.bind(pause_button))
	restart_button.mouse_entered.connect(_on_button_hover_start.bind(restart_button))
	restart_button.mouse_exited.connect(_on_button_hover_end.bind(restart_button))
	end_button.mouse_entered.connect(_on_button_hover_start.bind(end_button))
	end_button.mouse_exited.connect(_on_button_hover_end.bind(end_button))

	# Initially disable pause button (nothing playing yet)
	pause_button.disabled = true

	# Display initial state (Turn 0) - deferred to allow layout to complete
	_update_displays_for_turn.call_deferred(0)

## Handle turn change from timeline scrubbing
func _on_turn_changed(turn: int):
	current_turn = turn
	await _update_displays_for_turn(turn)

## Update all displays for a specific turn
func _update_displays_for_turn(turn: int):
	var snapshot = battle_result.get_turn_snapshot(turn)

	if not snapshot:
		push_warning("No snapshot found for turn %d" % turn)
		return

	print("DEBUG ReplayViewer: Displaying turn ", turn, " - ", snapshot.get_summary())

	# Reconstruct ship data from snapshot and store as instance variables
	player_data = _reconstruct_ship_data_from_snapshot(snapshot, true)
	enemy_data = _reconstruct_ship_data_from_snapshot(snapshot, false)

	# Update ship displays
	print("DEBUG ReplayViewer: Player ship grid size: ", player_data.grid.size(), "x", player_data.grid[0].size() if player_data.grid.size() > 0 else 0)
	print("DEBUG ReplayViewer: Player ship room_instances: ", player_data.room_instances.size())
	print("DEBUG ReplayViewer: Enemy ship grid size: ", enemy_data.grid.size(), "x", enemy_data.grid[0].size() if enemy_data.grid.size() > 0 else 0)
	print("DEBUG ReplayViewer: Enemy ship room_instances: ", enemy_data.room_instances.size())
	print("DEBUG ReplayViewer: Enemy ship room_instances keys: ", enemy_data.room_instances.keys())

	# Check if grid has actual rooms
	var enemy_room_count = 0
	for y in range(enemy_data.grid.size()):
		for x in range(enemy_data.grid[y].size()):
			if enemy_data.grid[y][x] != 0:  # RoomData.RoomType.EMPTY
				enemy_room_count += 1
	print("DEBUG ReplayViewer: Enemy ship non-empty tiles in grid: ", enemy_room_count)

	player_ship_display.set_ship_data(player_data)
	print("DEBUG ReplayViewer: Player ship children after set_ship_data: ", player_ship_display.get_child_count())

	enemy_ship_display.set_ship_data(enemy_data)
	print("DEBUG ReplayViewer: Enemy ship children after set_ship_data: ", enemy_ship_display.get_child_count())

	# Position ships properly (deferred to allow layout to complete)
	_position_ships.call_deferred()

	# Update power visuals
	player_ship_display.update_power_visuals(player_data)
	enemy_ship_display.update_power_visuals(enemy_data)

	# Update turn indicator
	turn_indicator.text = "TURN %d / %d" % [turn + 1, battle_result.total_turns]  # 1-indexed for display

	# Update health labels
	player_health_label.text = "%d / %d HP" % [snapshot.player_hull_hp, original_player_data.max_hp]
	enemy_health_label.text = "%d / %d HP" % [snapshot.enemy_hull_hp, original_enemy_data.max_hp]

	# Display events for this turn
	_display_turn_events(turn)

	# Play visual actions for this turn (Feature: Visual Replay Actions)
	await _play_turn_actions(snapshot)

## Position ships after layout pass (same logic as Combat.gd)
func _position_ships():
	print("DEBUG ReplayViewer: _position_ships() CALLED")
	print("DEBUG ReplayViewer: enemy_ship_display exists in _position_ships: ", enemy_ship_display != null)
	print("DEBUG ReplayViewer: enemy_ship_display visible in _position_ships: ", enemy_ship_display.visible if enemy_ship_display else "null")

	var player_grid_width = player_ship_display.GRID_WIDTH
	var player_grid_height = player_ship_display.GRID_HEIGHT
	var enemy_grid_width = enemy_ship_display.GRID_WIDTH
	var enemy_grid_height = enemy_ship_display.GRID_HEIGHT
	var tile_size = 96.0  # ShipDisplay.TILE_SIZE
	var container_height = 600.0
	var container_width = 600.0
	var margin = 50.0

	print("DEBUG ReplayViewer: enemy GRID_WIDTH = ", enemy_grid_width, ", GRID_HEIGHT = ", enemy_grid_height)

	# Calculate scale
	var max_container_size = container_width - margin * 2
	var player_max_dimension = max(player_grid_width * tile_size, player_grid_height * tile_size)
	var enemy_max_dimension = max(enemy_grid_width * tile_size, enemy_grid_height * tile_size)
	var player_scale = min(1.0, max_container_size / player_max_dimension) if player_max_dimension > 0 else 0.6
	var enemy_scale = min(1.0, max_container_size / enemy_max_dimension) if enemy_max_dimension > 0 else 0.6
	var uniform_scale = min(player_scale, enemy_scale, 0.6)

	print("DEBUG ReplayViewer: uniform_scale = ", uniform_scale)

	# Apply scale
	player_ship_display.scale = Vector2(uniform_scale, uniform_scale)
	# Don't flip enemy - just use positive scale
	enemy_ship_display.scale = Vector2(uniform_scale, uniform_scale)

	print("DEBUG ReplayViewer: After setting scale - enemy_ship_display.scale = ", enemy_ship_display.scale)

	# Don't manually set positions - let scene anchors/offsets handle it (same as Combat.gd)
	# Positions come from scene file: PlayerShipDisplay at (298, -4), EnemyShipDisplay at (300, 0)

	print("DEBUG ReplayViewer scaling: Player grid=%dx%d, Enemy grid=%dx%d, Scale=%.2f" % [player_grid_width, player_grid_height, enemy_grid_width, enemy_grid_height, uniform_scale])
	print("DEBUG ReplayViewer positions: Player ShipDisplay pos=", player_ship_display.position, ", Enemy ShipDisplay pos=", enemy_ship_display.position)
	print("DEBUG ReplayViewer containers: Player container global_pos=", player_ship_display.get_parent().global_position, ", Enemy container global_pos=", enemy_ship_display.get_parent().global_position)
	print("DEBUG Player ship scale: ", player_ship_display.scale)
	print("DEBUG Enemy ship scale: ", enemy_ship_display.scale)
	print("DEBUG Player ship global position: ", player_ship_display.global_position)
	print("DEBUG Enemy ship global position: ", enemy_ship_display.global_position)

## Reconstruct ShipData from TurnSnapshot by applying deltas to original data
func _reconstruct_ship_data_from_snapshot(snapshot: TurnSnapshot, is_player: bool) -> ShipData:
	# Get original ship data
	var original: ShipData
	var active_room_ids: Array[int]
	var powered_room_ids: Array[int]
	var hull_hp: int

	if is_player:
		original = original_player_data
		active_room_ids = snapshot.player_active_room_ids
		powered_room_ids = snapshot.player_powered_room_ids
		hull_hp = snapshot.player_hull_hp
	else:
		original = original_enemy_data
		active_room_ids = snapshot.enemy_active_room_ids
		powered_room_ids = snapshot.enemy_powered_room_ids
		hull_hp = snapshot.enemy_hull_hp

	# Create a new ShipData by cloning original's grid structure
	var reconstructed = ShipData.new()

	# Deep copy grid
	reconstructed.grid = []
	for y in range(original.grid.size()):
		var row = []
		for x in range(original.grid[y].size()):
			row.append(original.grid[y][x])
		reconstructed.grid.append(row)

	# Deep copy room_id_grid
	reconstructed.room_id_grid = []
	for y in range(original.room_id_grid.size()):
		var row = []
		for x in range(original.room_id_grid[y].size()):
			row.append(original.room_id_grid[y][x])
		reconstructed.room_id_grid.append(row)

	# Filter room_instances to only include active rooms
	reconstructed.room_instances = {}
	for room_id in active_room_ids:
		if room_id in original.room_instances:
			# Deep copy room instance data
			var original_room_data = original.room_instances[room_id]
			var tiles_copy = []
			for tile_pos in original_room_data["tiles"]:
				tiles_copy.append(tile_pos)

			reconstructed.room_instances[room_id] = {
				"type": original_room_data["type"],
				"tiles": tiles_copy
			}

	# Update HP
	reconstructed.max_hp = original.max_hp
	reconstructed.current_hp = hull_hp

	# Update power grid based on powered_room_ids
	_reconstruct_power_grid(reconstructed, powered_room_ids)

	return reconstructed

## Reconstruct power grid for a ship based on powered room IDs
func _reconstruct_power_grid(ship: ShipData, powered_room_ids: Array[int]):
	# Initialize power_grid with all false
	ship.power_grid = []
	for y in range(ship.grid.size()):
		var power_row = []
		for x in range(ship.grid[y].size()):
			power_row.append(false)
		ship.power_grid.append(power_row)

	# Mark tiles as powered if their room_id is in powered_room_ids
	for y in range(ship.room_id_grid.size()):
		for x in range(ship.room_id_grid[y].size()):
			var room_id = ship.room_id_grid[y][x]
			if room_id in powered_room_ids:
				ship.power_grid[y][x] = true

## Display events that occurred during this turn
func _display_turn_events(turn: int):
	var snapshot = battle_result.get_turn_snapshot(turn)

	if not snapshot:
		events_log.clear()
		return

	# Build formatted event text
	var event_text = "[b]TURN %d EVENTS:[/b]\n" % (turn + 1)

	if snapshot.events.is_empty():
		event_text += "[color=gray]No events recorded[/color]"
	else:
		for event in snapshot.events:
			event_text += "• %s\n" % event

	events_log.clear()
	events_log.append_text(event_text)

## Handle back button press
func _on_back_pressed():
	AudioManager.play_button_click()
	_return_to_combat()

## Handle continue button press
func _on_continue_pressed():
	AudioManager.play_button_click()
	# Go to mission select to choose next mission
	get_tree().change_scene_to_file("res://scenes/mission/MissionSelect.tscn")

## Return to combat scene
func _return_to_combat():
	# Return to combat scene (or designer if combat has ended)
	get_tree().change_scene_to_file("res://scenes/combat/Combat.tscn")

## Get current speed multiplier (for CombatFX to access)
func _get_speed_multiplier_value() -> float:
	return speed_multiplier

## Play back all actions from a turn snapshot (Feature: Visual Replay Actions)
func _play_turn_actions(snapshot: TurnSnapshot):
	# Play weapon fire actions
	for action in snapshot.weapon_fire_actions:
		await _play_weapon_fire_action(action)

	# Play room destruction actions
	for action in snapshot.room_destruction_actions:
		await _play_room_destruction_action(action)

## Play back a single weapon fire action
func _play_weapon_fire_action(action: Dictionary):
	# Get attacker and defender displays
	var attacker_display: ShipDisplay
	var defender_display: ShipDisplay

	if action["attacker"] == "player":
		attacker_display = player_ship_display
		defender_display = enemy_ship_display
	else:
		attacker_display = enemy_ship_display
		defender_display = player_ship_display

	# Get weapon grid positions
	var weapon_positions: Array = action["weapon_positions"]
	if weapon_positions.is_empty():
		return

	# Convert grid positions to world positions
	var weapon_world_positions = []
	for grid_pos in weapon_positions:
		var world_pos = attacker_display.grid_to_world_position(grid_pos.x, grid_pos.y)
		weapon_world_positions.append(world_pos)

	# Get target position
	var target_position: Vector2 = action["target_position"]
	var use_lasers: bool = action["use_lasers"]
	var damage: int = action["damage"]
	var shield_absorption: int = action["shield_absorption"]

	# Play laser fire sound
	AudioManager.play_laser_fire()

	# Fire all weapons simultaneously
	for weapon_pos in weapon_world_positions:
		# Spawn muzzle flash
		if combat_fx:
			combat_fx.spawn_muzzle_flash(weapon_pos, 0.1)

		# Small delay between muzzle flash and projectile
		await get_tree().create_timer(0.05 * speed_multiplier).timeout

		# Fire projectile
		if combat_fx:
			if use_lasers:
				combat_fx.spawn_laser_beam(weapon_pos, target_position, 0.3)
			else:
				combat_fx.spawn_torpedo(weapon_pos, target_position, 0.5)

	# Wait for projectiles to reach target
	var projectile_travel_time = 0.3 if use_lasers else 0.5
	await get_tree().create_timer(projectile_travel_time * speed_multiplier).timeout

	# Spawn impacts
	if combat_fx:
		if shield_absorption > 0:
			combat_fx.spawn_shield_impact(target_position, 60.0, 0.4)

		if damage - shield_absorption > 0:
			combat_fx.spawn_hull_impact(target_position, 30, 0.5)

			if damage - shield_absorption > 20:
				combat_fx.spawn_screen_shake(5.0, 0.2)

	# Wait for impacts to complete
	await get_tree().create_timer(0.3 * speed_multiplier).timeout

## Play back a single room destruction action
func _play_room_destruction_action(action: Dictionary):
	# Get the ship display
	var ship_display: ShipDisplay

	if action["owner"] == "player":
		ship_display = player_ship_display
	else:
		ship_display = enemy_ship_display

	var room_type: int = action["room_type"]
	var tiles: Array = action["tiles"]
	var room_id: int = action["room_id"]

	# Play explosion sound
	AudioManager.play_explosion()

	# Destroy room visual
	var first_tile = tiles[0]
	await ship_display.destroy_room_visual(
		first_tile.x, first_tile.y, speed_multiplier, tiles, room_id
	)

	# Small delay between destructions
	await get_tree().create_timer(0.1 * speed_multiplier).timeout

	# If reactor destroyed, update power visuals
	if action["is_reactor"]:
		# Note: The ship data already has the correct power state from the snapshot
		# We just need to update the visuals to match
		if action["owner"] == "player":
			player_ship_display.update_power_visuals(player_data)
		else:
			enemy_ship_display.update_power_visuals(enemy_data)

## Handle play button press
func _on_play_pressed():
	AudioManager.play_button_click()

	if is_playing:
		return  # Already playing

	is_playing = true

	# Update button states
	play_button.disabled = true
	pause_button.disabled = false

	# If at the end, restart from beginning
	if current_turn >= battle_result.total_turns - 1:
		current_turn = 0
		timeline_bar.set_current_turn(0)
		await _update_displays_for_turn(0)

	# Start auto-play coroutine
	_auto_play_turns()

## Auto-play through all turns (coroutine)
func _auto_play_turns():
	while is_playing and current_turn < battle_result.total_turns - 1:
		# Wait for delay before advancing to next turn
		await get_tree().create_timer(PLAYBACK_TURN_DELAY).timeout

		# Check if still playing (might have been paused during delay)
		if not is_playing:
			break

		# Advance to next turn
		var next_turn = current_turn + 1
		current_turn = next_turn
		timeline_bar.set_current_turn(next_turn)

		# Wait for turn display and actions to complete
		await _update_displays_for_turn(next_turn)

	# Reached the end or was stopped, update button states
	if is_playing:
		_stop_playback()

## Handle pause button press
func _on_pause_pressed():
	AudioManager.play_button_click()
	_stop_playback()

## Stop playback (internal helper)
func _stop_playback():
	is_playing = false

	# Update button states
	play_button.disabled = false
	pause_button.disabled = true

## Handle restart button press
func _on_restart_pressed():
	AudioManager.play_button_click()

	# Stop playback if playing
	if is_playing:
		_stop_playback()

	# Jump to turn 0
	timeline_bar.set_current_turn(0)

## Handle end button press
func _on_end_pressed():
	AudioManager.play_button_click()

	# Stop playback if playing
	if is_playing:
		_stop_playback()

	# Jump to last turn
	timeline_bar.set_current_turn(battle_result.total_turns - 1)

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
