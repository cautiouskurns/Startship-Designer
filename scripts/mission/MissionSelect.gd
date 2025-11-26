extends Control

## Mission selection screen

## DEBUG: Set to true to skip straight to combat for testing (Feature 1 MVP)
const DEBUG_QUICK_START = false  # Change to false to disable
const DEBUG_MISSION = 1  # 0 = Scout (RANDOM), 1 = Raider (WEAPONS_FIRST), 2 = Dreadnought (POWER_FIRST)

## UI nodes
@onready var mission1_button: Button = $MissionButtons/Mission1Button
@onready var mission2_button: Button = $MissionButtons/Mission2Button
@onready var mission3_button: Button = $MissionButtons/Mission3Button
@onready var brief_panel: Panel = $BriefPanel
@onready var brief_label: Label = $BriefPanel/BriefLabel
@onready var back_button: Button = $BackButton
# Enemy setup moved to ShipDesigner

func _ready():
	# DEBUG: Quick start to combat (Feature 1 MVP testing)
	if DEBUG_QUICK_START:
		# Defer to next frame to ensure scene is fully initialized
		await get_tree().process_frame
		_debug_quick_start()
		return

	# Connect button signals
	mission1_button.pressed.connect(_on_mission1_pressed)
	mission2_button.pressed.connect(_on_mission2_pressed)
	mission3_button.pressed.connect(_on_mission3_pressed)
	mission1_button.mouse_entered.connect(_on_mission1_hovered)
	mission2_button.mouse_entered.connect(_on_mission2_hovered)
	mission3_button.mouse_entered.connect(_on_mission3_hovered)
	back_button.pressed.connect(_on_back_pressed)

	# Connect hover scale effects
	mission1_button.mouse_entered.connect(_on_button_hover_start.bind(mission1_button))
	mission1_button.mouse_exited.connect(_on_button_hover_end.bind(mission1_button))
	mission2_button.mouse_entered.connect(_on_button_hover_start.bind(mission2_button))
	mission2_button.mouse_exited.connect(_on_button_hover_end.bind(mission2_button))
	mission3_button.mouse_entered.connect(_on_button_hover_start.bind(mission3_button))
	mission3_button.mouse_exited.connect(_on_button_hover_end.bind(mission3_button))
	back_button.mouse_entered.connect(_on_button_hover_start.bind(back_button))
	back_button.mouse_exited.connect(_on_button_hover_end.bind(back_button))

	# Hide brief panel initially
	brief_panel.visible = false

	# Update mission states
	_update_mission_states()

## Update mission button states based on GameState
func _update_mission_states():
	# Mission 1
	if GameState.is_mission_unlocked(0):
		mission1_button.disabled = false
		mission1_button.modulate = Color(1, 1, 1, 1)  # Full color
	else:
		mission1_button.disabled = true
		mission1_button.modulate = Color(0.5, 0.5, 0.5, 1)  # Grayed out

	# Mission 2
	if GameState.is_mission_unlocked(1):
		mission2_button.disabled = false
		mission2_button.modulate = Color(1, 1, 1, 1)
	else:
		mission2_button.disabled = true
		mission2_button.modulate = Color(0.5, 0.5, 0.5, 1)

	# Mission 3
	if GameState.is_mission_unlocked(2):
		mission3_button.disabled = false
		mission3_button.modulate = Color(1, 1, 1, 1)
	else:
		mission3_button.disabled = true
		mission3_button.modulate = Color(0.5, 0.5, 0.5, 1)

## Show mission brief on hover
func _show_brief(mission_index: int):
	if GameState.is_mission_unlocked(mission_index):
		brief_label.text = GameState.get_mission_brief(mission_index)
		brief_panel.visible = true

## Mission 1 pressed
func _on_mission1_pressed():
	AudioManager.play_button_click()
	_load_mission(0)

## Mission 2 pressed
func _on_mission2_pressed():
	AudioManager.play_button_click()
	_load_mission(1)

## Mission 3 pressed
func _on_mission3_pressed():
	AudioManager.play_button_click()
	_load_mission(2)

## Mission 1 hovered
func _on_mission1_hovered():
	_show_brief(0)

## Mission 2 hovered
func _on_mission2_hovered():
	_show_brief(1)

## Mission 3 hovered
func _on_mission3_hovered():
	_show_brief(2)

## Load mission and transition to hull selection (Phase 10.1)
func _load_mission(mission_index: int):
	# Set current mission in GameState
	GameState.current_mission = mission_index

	# Load Hull Selection scene (Phase 10.1 - choose hull before designing)
	get_tree().change_scene_to_file("res://scenes/hull/HullSelect.tscn")

## Back button pressed
func _on_back_pressed():
	# Play button click sound
	AudioManager.play_button_click()

	# For now, just exit
	get_tree().quit()

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

## DEBUG: Quick start to combat with test ship (Feature 1 MVP)
func _debug_quick_start():
	print("DEBUG: Quick starting to combat - Mission ", DEBUG_MISSION)

	# Set up GameState
	GameState.current_mission = DEBUG_MISSION
	GameState.current_hull = GameState.HullType.CRUISER  # Set default hull

	# Create a test player ship with multiple weapons and reactors
	# Grid: 8x6 with a balanced loadout for testing targeting
	var test_grid = []
	for y in range(6):
		var row = []
		for x in range(8):
			row.append(RoomData.RoomType.EMPTY)
		test_grid.append(row)

	# Place test rooms (weapons in top 2 rows, engines in bottom 2 rows)
	# Row 0: 3 Weapons (for testing WEAPONS_FIRST targeting)
	test_grid[0][2] = RoomData.RoomType.WEAPON
	test_grid[0][4] = RoomData.RoomType.WEAPON
	test_grid[0][6] = RoomData.RoomType.WEAPON

	# Row 1: Shields
	test_grid[1][1] = RoomData.RoomType.SHIELD
	test_grid[1][5] = RoomData.RoomType.SHIELD

	# Row 2: Reactors (for testing POWER_FIRST targeting)
	test_grid[2][2] = RoomData.RoomType.REACTOR
	test_grid[2][5] = RoomData.RoomType.REACTOR

	# Row 3: Bridge + Armor
	test_grid[3][3] = RoomData.RoomType.BRIDGE
	test_grid[3][1] = RoomData.RoomType.ARMOR
	test_grid[3][6] = RoomData.RoomType.ARMOR

	# Row 4: Engines
	test_grid[4][2] = RoomData.RoomType.ENGINE
	test_grid[4][5] = RoomData.RoomType.ENGINE

	# Row 5: More Armor
	test_grid[5][3] = RoomData.RoomType.ARMOR

	# Create ShipData
	var test_ship = ShipData.new(test_grid, 0)
	test_ship.max_hp = test_ship.calculate_hull_hp()
	test_ship.current_hp = test_ship.max_hp
	test_ship.recalculate_power()
	print("DEBUG: Created test_ship - HP: ", test_ship.current_hp, "/", test_ship.max_hp)
	print("DEBUG: Test ship grid size: ", test_ship.grid.size(), "x", test_ship.grid[0].size())

	# Create room_instances for the test ship (single-tile rooms for simplicity)
	var room_id = 1
	for y in range(6):
		for x in range(8):
			if test_grid[y][x] != RoomData.RoomType.EMPTY:
				test_ship.room_instances[room_id] = {
					"type": test_grid[y][x],
					"tiles": [Vector2i(x, y)]
				}
				room_id += 1

	print("DEBUG: Created ", test_ship.room_instances.size(), " room instances")

	# Load and start combat scene
	print("DEBUG: About to preload Combat.tscn...")
	var combat_scene = preload("res://scenes/combat/Combat.tscn")
	if not combat_scene:
		print("ERROR: Failed to preload Combat.tscn!")
		return
	print("DEBUG: Combat scene preloaded, instantiating...")
	var combat_instance = combat_scene.instantiate()
	if not combat_instance:
		print("ERROR: Failed to instantiate combat scene!")
		return
	print("DEBUG: Combat instance created")

	# Add to scene tree first
	print("DEBUG: Adding combat instance to scene tree...")
	get_tree().root.add_child(combat_instance)
	print("DEBUG: Combat instance added to tree")

	# Wait one frame for combat scene's _ready() to complete
	await get_tree().process_frame
	print("DEBUG: Waited one frame, calling start_combat...")

	# Now start combat (nodes are initialized after _ready)
	combat_instance.start_combat(test_ship, GameState.current_mission)
	print("DEBUG: start_combat called successfully")

	# Switch current scene reference
	get_tree().current_scene = combat_instance
	print("DEBUG: Set as current scene")

	# Remove mission select scene
	queue_free()
	print("DEBUG: Queued mission select for removal")
