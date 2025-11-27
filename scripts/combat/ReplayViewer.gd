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

## Battle data
var battle_result: BattleResult = null
var original_player_data: ShipData = null
var original_enemy_data: ShipData = null
var current_turn: int = 0

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

	# Display initial state (Turn 0)
	_update_displays_for_turn(0)

## Handle turn change from timeline scrubbing
func _on_turn_changed(turn: int):
	current_turn = turn
	_update_displays_for_turn(turn)

## Update all displays for a specific turn
func _update_displays_for_turn(turn: int):
	var snapshot = battle_result.get_turn_snapshot(turn)

	if not snapshot:
		push_warning("No snapshot found for turn %d" % turn)
		return

	print("DEBUG ReplayViewer: Displaying turn ", turn, " - ", snapshot.get_summary())

	# Reconstruct ship data from snapshot
	var player_ship = _reconstruct_ship_data_from_snapshot(snapshot, true)
	var enemy_ship = _reconstruct_ship_data_from_snapshot(snapshot, false)

	# Update ship displays
	player_ship_display.set_ship_data(player_ship)
	enemy_ship_display.set_ship_data(enemy_ship)

	# Update power visuals
	player_ship_display.update_power_visuals(player_ship)
	enemy_ship_display.update_power_visuals(enemy_ship)

	# Update turn indicator
	turn_indicator.text = "TURN %d / %d" % [turn + 1, battle_result.total_turns]  # 1-indexed for display

	# Update health labels
	player_health_label.text = "%d / %d HP" % [snapshot.player_hull_hp, original_player_data.max_hp]
	enemy_health_label.text = "%d / %d HP" % [snapshot.enemy_hull_hp, original_enemy_data.max_hp]

	# Display events for this turn
	_display_turn_events(turn)

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
	_return_to_combat()

## Return to combat scene
func _return_to_combat():
	# Return to combat scene (or designer if combat has ended)
	get_tree().change_scene_to_file("res://scenes/combat/Combat.tscn")
