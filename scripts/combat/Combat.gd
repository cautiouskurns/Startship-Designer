extends Control

## Ship display nodes
@onready var player_ship_display: ShipDisplay = $ShipBattleArea/PlayerShipContainer/PlayerShipDisplay
@onready var enemy_ship_display: ShipDisplay = $ShipBattleArea/EnemyShipContainer/EnemyShipDisplay

## Health bar nodes
@onready var player_health_bar: ProgressBar = $PlayerHealthBar
@onready var enemy_health_bar: ProgressBar = $EnemyHealthBar

## Health label nodes
@onready var player_health_label: Label = $PlayerHealthBar/PlayerHealthLabel
@onready var enemy_health_label: Label = $EnemyHealthBar/EnemyHealthLabel

## Ship stats panels (Phase 10.9)
@onready var player_stats_panel: ShipStatsPanel = $PlayerStatsPanel
@onready var enemy_stats_panel: ShipStatsPanel = $EnemyStatsPanel

## Turn indicator
@onready var turn_indicator: Label = $TurnIndicator
@onready var turn_glow: ColorRect = $TurnIndicator/TurnGlow

## Redesign button
@onready var redesign_button: Button = $RedesignButton

## Pause button
@onready var pause_button: Button = $PauseButton

## Fast Forward button
@onready var ff_button: Button = $FFButton

## Combat log
@onready var combat_log: CombatLog = $CombatLog

## Combat visual effects manager (Phase 10.6)
@onready var combat_fx: CombatFX = $CombatFX

## Result overlay nodes
@onready var result_overlay: ColorRect = $ResultOverlay
@onready var result_label: Label = $ResultOverlay/ResultLabel

## Victory overlay nodes (for mission 3 completion)
@onready var victory_overlay: ColorRect = $VictoryOverlay
@onready var victory_return_button: Button = $VictoryOverlay/ReturnButton

## Ship data
var player_data: ShipData = null
var enemy_data: ShipData = null

## Combat state
var is_player_turn: bool = true
var combat_active: bool = false
var turn_count: int = 0
var current_mission: int = 0
var is_paused: bool = false

## Speed control (2.0 = 0.5x speed by default)
var speed_multiplier: float = 2.0  # 4.0 = 0.25x, 2.0 = 0.5x, 1.0 = 1x, 0.5 = 2x

func _ready():
	# Connect buttons
	redesign_button.pressed.connect(_on_redesign_pressed)
	victory_return_button.pressed.connect(_on_victory_return_pressed)
	pause_button.pressed.connect(_on_pause_pressed)
	ff_button.pressed.connect(_on_ff_pressed)

	# Set initial button text
	pause_button.text = "PAUSE"
	ff_button.text = "Speed: 0.5x"

	# Connect hover scale effects
	redesign_button.mouse_entered.connect(_on_button_hover_start.bind(redesign_button))
	redesign_button.mouse_exited.connect(_on_button_hover_end.bind(redesign_button))
	victory_return_button.mouse_entered.connect(_on_button_hover_start.bind(victory_return_button))
	victory_return_button.mouse_exited.connect(_on_button_hover_end.bind(victory_return_button))
	pause_button.mouse_entered.connect(_on_button_hover_start.bind(pause_button))
	pause_button.mouse_exited.connect(_on_button_hover_end.bind(pause_button))
	ff_button.mouse_entered.connect(_on_button_hover_start.bind(ff_button))
	ff_button.mouse_exited.connect(_on_button_hover_end.bind(ff_button))

## Start combat with player ship data and mission index
func start_combat(player_ship: ShipData, mission_index: int = 0):
	print("DEBUG Combat.start_combat: Received player_ship with HP: ", player_ship.current_hp if player_ship else "NULL")
	player_data = player_ship
	current_mission = mission_index
	print("DEBUG Combat.start_combat: player_data set, mission: ", mission_index)

	# Apply hull bonuses (Phase 10.1)
	var hull_data = GameState.get_current_hull_data()
	var bonus_type: String = hull_data["bonus_type"]
	var bonus_value: int = hull_data["bonus_value"]

	if bonus_type == "hull_hp":
		# Apply HP bonus (Battleship)
		player_data.max_hp += bonus_value
		player_data.current_hp += bonus_value

	# Load enemy based on mission (Phase 10.8 - check for template assignment first)
	var enemy_template = TemplateManager.get_enemy_template(mission_index)
	if enemy_template:
		# Use template for enemy ship
		enemy_data = _create_enemy_from_template(enemy_template)
	else:
		# Fallback to auto-generated enemy
		match mission_index:
			0:
				enemy_data = ShipData.create_mission1_scout()
			1:
				enemy_data = ShipData.create_mission2_raider()
			2:
				enemy_data = ShipData.create_mission3_dreadnought()
			_:
				enemy_data = ShipData.create_mission1_scout()  # Default fallback

	# Set up ship displays
	print("DEBUG Combat: Setting player_ship_display with grid size: ", player_data.grid.size(), "x", player_data.grid[0].size() if player_data.grid.size() > 0 else 0)
	print("DEBUG Combat: Player ship has ", player_data.room_instances.size(), " room instances")
	player_ship_display.set_ship_data(player_data)
	print("DEBUG Combat: Setting enemy_ship_display with grid size: ", enemy_data.grid.size(), "x", enemy_data.grid[0].size() if enemy_data.grid.size() > 0 else 0)
	enemy_ship_display.set_ship_data(enemy_data)

	# Position ships to face each other at the center with dynamic scaling
	var player_grid_width = player_ship_display.GRID_WIDTH
	var player_grid_height = player_ship_display.GRID_HEIGHT
	var enemy_grid_width = enemy_ship_display.GRID_WIDTH
	var enemy_grid_height = enemy_ship_display.GRID_HEIGHT
	var tile_size = 96.0  # ShipDisplay.TILE_SIZE
	var container_height = 600.0
	var container_width = 600.0
	var margin = 50.0  # Margin from edges

	# Calculate required scale for each ship to fit in container
	var max_container_size = container_width - margin * 2  # Leave margins
	var player_max_dimension = max(player_grid_width * tile_size, player_grid_height * tile_size)
	var enemy_max_dimension = max(enemy_grid_width * tile_size, enemy_grid_height * tile_size)

	# Calculate scale factors to fit each ship (never scale up, only down)
	var player_scale = min(1.0, max_container_size / player_max_dimension) if player_max_dimension > 0 else 0.6
	var enemy_scale = min(1.0, max_container_size / enemy_max_dimension) if enemy_max_dimension > 0 else 0.6

	# Use smaller scale to ensure both ships are comparable in size
	var uniform_scale = min(player_scale, enemy_scale, 0.6)  # Cap at 0.6 max

	# Apply scale to ship displays
	player_ship_display.scale = Vector2(uniform_scale, uniform_scale)
	# Feature 1 MVP: Flip enemy ship horizontally so it faces the player (left)
	enemy_ship_display.scale = Vector2(-uniform_scale, uniform_scale)  # Negative X = horizontal flip

	# Calculate visual sizes with the new scale
	var player_visual_width = player_grid_width * tile_size * uniform_scale
	var player_visual_height = player_grid_height * tile_size * uniform_scale
	var enemy_visual_width = enemy_grid_width * tile_size * uniform_scale
	var enemy_visual_height = enemy_grid_height * tile_size * uniform_scale

	# Find max visual height to align centers vertically
	var max_visual_height = max(player_visual_height, enemy_visual_height)
	var base_y = (container_height - max_visual_height) / 2.0

	# Offset to align ship centers vertically
	var player_y_offset = (max_visual_height - player_visual_height) / 2.0
	var enemy_y_offset = (max_visual_height - enemy_visual_height) / 2.0

	# Position horizontally: player ship on right side of left container, enemy on right side of right container
	var player_x = container_width - player_visual_width - 50  # 50px gap from center
	# Enemy is flipped (negative scale), so position at RIGHT edge (it draws backwards to the left)
	var enemy_x = container_width - 50  # Position at right edge, ship draws leftward

	# Apply positions
	player_ship_display.position = Vector2(player_x, base_y + player_y_offset)
	enemy_ship_display.position = Vector2(enemy_x, base_y + enemy_y_offset)

	print("DEBUG Combat scaling: Player grid=%dx%d, Enemy grid=%dx%d, Scale=%.2f" % [player_grid_width, player_grid_height, enemy_grid_width, enemy_grid_height, uniform_scale])
	print("DEBUG Combat positions: Player ShipDisplay pos=", player_ship_display.position, ", Enemy ShipDisplay pos=", enemy_ship_display.position)
	print("DEBUG Combat containers: Player container global_pos=", player_ship_display.get_parent().global_position, ", Enemy container global_pos=", enemy_ship_display.get_parent().global_position)

	# Update power visuals (Phase 10.9 - show powered/unpowered rooms)
	print("DEBUG: Player powered weapons: ", player_data.count_powered_room_type(RoomData.RoomType.WEAPON))
	print("DEBUG: Player powered shields: ", player_data.count_powered_room_type(RoomData.RoomType.SHIELD))
	print("DEBUG: Player powered engines: ", player_data.count_powered_room_type(RoomData.RoomType.ENGINE))
	player_ship_display.update_power_visuals(player_data)

	print("DEBUG: Enemy powered weapons: ", enemy_data.count_powered_room_type(RoomData.RoomType.WEAPON))
	print("DEBUG: Enemy powered shields: ", enemy_data.count_powered_room_type(RoomData.RoomType.SHIELD))
	print("DEBUG: Enemy powered engines: ", enemy_data.count_powered_room_type(RoomData.RoomType.ENGINE))
	enemy_ship_display.update_power_visuals(enemy_data)

	# Initialize health bars
	_update_player_health()
	_update_enemy_health()

	# Initialize stats panels (Phase 10.9)
	_update_player_stats()
	_update_enemy_stats()

	# Determine initiative (who goes first)
	var initiative_data = _determine_initiative_detailed()
	is_player_turn = initiative_data["player_first"]

	# Log initiative
	if combat_log:
		var bonus_text = ""
		if hull_data["bonus_type"] == "initiative":
			bonus_text = "(+%d Initiative bonus)" % hull_data["bonus_value"]
		combat_log.add_initiative(
			"player" if is_player_turn else "enemy",
			initiative_data["player_engines"],
			initiative_data["enemy_engines"],
			bonus_text
		)

	# Set initial turn indicator with visual emphasis
	_update_turn_indicator(is_player_turn)

	# Show initiative message if hull bonus gave player advantage (Phase 10.3)
	if is_player_turn and hull_data["bonus_type"] == "initiative":
		var init_label = Label.new()
		init_label.text = "Player shoots first! (+%d Initiative)" % hull_data["bonus_value"]
		init_label.add_theme_font_size_override("font_size", 40)
		init_label.add_theme_color_override("font_color", Color(0.29, 0.89, 0.89, 1))  # Cyan
		init_label.add_theme_constant_override("outline_size", 4)
		init_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
		init_label.position = Vector2(480, 300)  # Above center
		init_label.z_index = 100
		add_child(init_label)

		# Animate
		var tween = create_tween()
		tween.tween_property(init_label, "scale", Vector2(1.1, 1.1), 0.2)
		tween.tween_property(init_label, "scale", Vector2(1.0, 1.0), 0.2)
		tween.tween_interval(1.0)
		tween.tween_property(init_label, "modulate:a", 0.0, 0.3)
		tween.tween_callback(init_label.queue_free)

	# Start combat loop (deferred to allow scene to fully initialize)
	run_combat_loop.call_deferred()

## Update player health bar and label
func _update_player_health():
	player_health_bar.max_value = player_data.max_hp
	# Animate health bar smoothly
	var tween = create_tween()
	tween.tween_property(player_health_bar, "value", player_data.current_hp, 0.3 * speed_multiplier)
	player_health_label.text = "%d / %d HP" % [player_data.current_hp, player_data.max_hp]
	_update_health_bar_color(player_health_bar)

## Update enemy health bar and label
func _update_enemy_health():
	enemy_health_bar.max_value = enemy_data.max_hp
	# Animate health bar smoothly
	var tween = create_tween()
	tween.tween_property(enemy_health_bar, "value", enemy_data.current_hp, 0.3 * speed_multiplier)
	enemy_health_label.text = "%d / %d HP" % [enemy_data.current_hp, enemy_data.max_hp]
	_update_health_bar_color(enemy_health_bar)

## Update health bar color based on HP percentage
func _update_health_bar_color(bar: ProgressBar):
	var percentage = bar.value / bar.max_value

	if percentage > 0.5:
		# Green #4AE24A
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.290196, 0.886275, 0.290196, 1)
		bar.add_theme_stylebox_override("fill", style)
	elif percentage > 0.25:
		# Yellow #E2D44A
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.886275, 0.831373, 0.290196, 1)
		bar.add_theme_stylebox_override("fill", style)
	else:
		# Red #E24A4A
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.886275, 0.290196, 0.290196, 1)
		bar.add_theme_stylebox_override("fill", style)

## Update player stats panel (Phase 10.9)
func _update_player_stats():
	if player_stats_panel and player_data:
		var hull_data = GameState.get_current_hull_data()
		player_stats_panel.update_stats(player_data, hull_data)

## Update enemy stats panel (Phase 10.9)
func _update_enemy_stats():
	if enemy_stats_panel and enemy_data:
		# Enemies don't have hull bonuses
		enemy_stats_panel.update_stats(enemy_data, {})

## Main combat loop
func run_combat_loop():
	combat_active = true

	# Play event start sound
	AudioManager.play_event_start()

	# Log combat start
	if combat_log:
		combat_log.add_combat_start()

	# Show "COMBAT START!" message
	var start_label = Label.new()
	start_label.text = "COMBAT START!"
	start_label.add_theme_font_size_override("font_size", 56)
	start_label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	start_label.add_theme_constant_override("outline_size", 5)
	start_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	start_label.position = Vector2(480, 400)  # Center of screen
	start_label.z_index = 100  # On top of everything
	add_child(start_label)

	# Animate the start message
	var tween = create_tween()
	tween.tween_property(start_label, "scale", Vector2(1.3, 1.3), 0.3)
	tween.tween_property(start_label, "scale", Vector2(1.0, 1.0), 0.3)
	tween.tween_interval(0.8)  # Hold for a moment
	tween.tween_property(start_label, "modulate:a", 0.0, 0.4)
	tween.tween_callback(start_label.queue_free)

	# Wait for message to complete
	await get_tree().create_timer(1.8 * speed_multiplier).timeout

	# Combat loop
	while combat_active:
		# Wait while paused
		while is_paused:
			await get_tree().create_timer(0.1).timeout

		await _execute_turn()

		# Check win condition
		var winner = _check_win_condition()
		if winner != "":
			combat_active = false
			_show_combat_end(winner)
			break

		# Switch turns
		is_player_turn = !is_player_turn
		turn_count += 1

		# Wait between turns
		await get_tree().create_timer(0.3 * speed_multiplier).timeout

## Execute one ship's turn
func _execute_turn():
	# Determine attacker and defender
	var attacker: ShipData
	var defender: ShipData
	var attacker_display: ShipDisplay
	var defender_display: ShipDisplay
	var is_player_attacking: bool

	if is_player_turn:
		attacker = player_data
		defender = enemy_data
		attacker_display = player_ship_display
		defender_display = enemy_ship_display
		is_player_attacking = true
	else:
		attacker = enemy_data
		defender = player_data
		attacker_display = enemy_ship_display
		defender_display = player_ship_display
		is_player_attacking = false

	# Update turn indicator with visual emphasis
	_update_turn_indicator(is_player_turn)

	# Log turn start
	var attacker_name = "PLAYER" if is_player_attacking else "ENEMY"
	var defender_name = "ENEMY" if is_player_attacking else "PLAYER"
	if combat_log:
		combat_log.add_turn_start(turn_count, is_player_turn)

	# Wait to see turn indicator
	await get_tree().create_timer(0.5 * speed_multiplier).timeout

	# Check pause after indicator
	while is_paused:
		await get_tree().create_timer(0.1).timeout

	# Calculate damage first (needed for visual effects)
	var weapons = attacker.count_powered_room_type(RoomData.RoomType.WEAPON)
	var damage = _calculate_damage(attacker)
	var shield_absorption = _calculate_shield_absorption(defender, damage)
	var net_damage = max(0, damage - shield_absorption)

	# Feature 1 MVP: Select primary target for visual feedback
	var primary_target_id = -1
	if not defender.room_instances.is_empty():
		primary_target_id = _select_target_room(defender, attacker)

	# Feature 1 MVP: Log targeting selection
	if combat_log and primary_target_id != -1:
		var target_type = RoomData.get_label(defender.room_instances[primary_target_id]["type"])
		combat_log.add_targeting(attacker_name, target_type, defender_name)

	# Phase 10.6: Fire weapons with visual effects (muzzle flashes, projectiles, impacts)
	# Feature 1 MVP: Pass primary target for targeting line visual
	await _fire_weapons_with_effects(attacker, defender, attacker_display, defender_display, damage, shield_absorption, primary_target_id)

	# Check pause after weapons fire
	while is_paused:
		await get_tree().create_timer(0.1).timeout

	# Log attack
	if combat_log:
		combat_log.add_attack(attacker_name, weapons, damage, shield_absorption, net_damage)

	# Apply damage to HP
	defender.current_hp = max(0, defender.current_hp - net_damage)

	# Log HP remaining
	if combat_log:
		combat_log.add_hp_remaining(defender_name, defender.current_hp, defender.max_hp)

	# Update health display
	if is_player_attacking:
		_update_enemy_health()
	else:
		_update_player_health()

	# Flash defender when taking damage
	if net_damage > 0:
		_flash_ship(defender_display, Color(0.89, 0.29, 0.29))  # Red flash
		await get_tree().create_timer(0.1 * speed_multiplier).timeout

	# Spawn damage number
	_spawn_damage_number(net_damage, damage, shield_absorption, !is_player_attacking)

	# Check pause after damage display
	while is_paused:
		await get_tree().create_timer(0.1).timeout

	# Destroy rooms (1 per 10 damage - adjusted from 20 for more frequent destruction)
	var rooms_to_destroy = int(net_damage / 10)
	print("DEBUG Combat: net_damage=", net_damage, ", rooms_to_destroy=", rooms_to_destroy, ", defender=", defender_name)
	if rooms_to_destroy > 0:
		print("DEBUG Combat: Calling _destroy_random_rooms with count=", rooms_to_destroy)
		# Feature 1 MVP: Pass primary_target_id so we destroy the same target shown in visuals/log
		await _destroy_random_rooms(defender, defender_display, rooms_to_destroy, defender_name, attacker, primary_target_id)
	else:
		print("DEBUG Combat: No rooms to destroy (damage too low or fully absorbed)")

	# Check pause after room destruction
	while is_paused:
		await get_tree().create_timer(0.1).timeout

	# Wait a moment to see final state
	await get_tree().create_timer(0.3 * speed_multiplier).timeout

## Determine which ship shoots first based on engine count (returns detailed data)
func _determine_initiative_detailed() -> Dictionary:
	var player_engines = player_data.count_powered_room_type(RoomData.RoomType.ENGINE)
	var enemy_engines = enemy_data.count_powered_room_type(RoomData.RoomType.ENGINE)

	# Apply synergy bonuses (Engine+Engine gives +1 initiative)
	var player_synergies = player_data.calculate_synergy_bonuses()
	var enemy_synergies = enemy_data.calculate_synergy_bonuses()

	player_engines += player_synergies["counts"][RoomData.SynergyType.INITIATIVE]
	enemy_engines += enemy_synergies["counts"][RoomData.SynergyType.INITIATIVE]

	# Apply hull initiative bonus (Phase 10.1 - Frigate gets +2)
	var hull_data = GameState.get_current_hull_data()
	if hull_data["bonus_type"] == "initiative":
		player_engines += hull_data["bonus_value"]

	# Higher engine count shoots first, player wins ties
	return {
		"player_first": player_engines >= enemy_engines,
		"player_engines": player_engines,
		"enemy_engines": enemy_engines
	}

## Calculate damage dealt by attacker
func _calculate_damage(attacker: ShipData) -> int:
	var weapons = attacker.count_powered_room_type(RoomData.RoomType.WEAPON)
	var base_damage = weapons * 10

	# Apply synergy bonuses (Weapon+Weapon gives +15% damage per weapon in synergy)
	var synergies = attacker.calculate_synergy_bonuses()
	var room_synergies = synergies["room_synergies"]

	# Count how many weapons have FIRE_RATE synergy
	var weapons_with_synergy = 0
	for y in range(attacker.grid.size()):
		for x in range(attacker.grid[y].size()):
			var room_type = attacker.grid[y][x]
			if room_type == RoomData.RoomType.WEAPON and attacker.is_room_powered(x, y):
				var pos = Vector2i(x, y)
				if pos in room_synergies:
					if RoomData.SynergyType.FIRE_RATE in room_synergies[pos]:
						weapons_with_synergy += 1

	# Add 15% bonus damage for each weapon with synergy
	var synergy_damage = int(weapons_with_synergy * 10 * 0.15)
	return base_damage + synergy_damage

## Calculate shield absorption for defender
func _calculate_shield_absorption(defender: ShipData, damage: int) -> int:
	var shields = defender.count_powered_room_type(RoomData.RoomType.SHIELD)
	var base_absorption = shields * 15

	# Apply synergy bonuses (Shield+Reactor gives +20% absorption per shield in synergy)
	var synergies = defender.calculate_synergy_bonuses()
	var room_synergies = synergies["room_synergies"]

	# Count how many shields have SHIELD_CAPACITY synergy
	var shields_with_synergy = 0
	for y in range(defender.grid.size()):
		for x in range(defender.grid[y].size()):
			var room_type = defender.grid[y][x]
			if room_type == RoomData.RoomType.SHIELD and defender.is_room_powered(x, y):
				var pos = Vector2i(x, y)
				if pos in room_synergies:
					if RoomData.SynergyType.SHIELD_CAPACITY in room_synergies[pos]:
						shields_with_synergy += 1

	# Add 20% bonus absorption for each shield with synergy
	var synergy_absorption = int(shields_with_synergy * 15 * 0.20)
	var total_absorption = base_absorption + synergy_absorption

	return min(damage, total_absorption)

## Fire weapons with visual effects (Phase 10.6 - lasers, torpedos, shield impacts)
## Feature 1 MVP: target_room_id - primary target for visual targeting line (-1 if none)
## Returns after all weapon effects have completed
func _fire_weapons_with_effects(attacker: ShipData, defender: ShipData, attacker_display: ShipDisplay, defender_display: ShipDisplay, damage: int, shield_absorption: int, target_room_id: int = -1):
	# Get weapon grid positions from attacker
	var weapon_positions = attacker.get_weapon_grid_positions()

	if weapon_positions.is_empty():
		return  # No weapons to fire

	# Convert weapon grid positions to world positions
	var weapon_world_positions = []
	for grid_pos in weapon_positions:
		var world_pos = attacker_display.grid_to_world_position(grid_pos.x, grid_pos.y)
		weapon_world_positions.append(world_pos)

	# Get target position on defender (default to center, but prefer specific target room)
	var target_position = defender_display.get_ship_center_world_position()

	# Feature 1 MVP: Calculate specific target room position if available
	if target_room_id != -1 and target_room_id in defender.room_instances:
		var room_data = defender.room_instances[target_room_id]
		var target_tiles = room_data["tiles"]

		# Calculate target room center from its tiles
		var target_center_x = 0.0
		var target_center_y = 0.0
		for tile_pos in target_tiles:
			target_center_x += tile_pos.x
			target_center_y += tile_pos.y
		target_center_x /= target_tiles.size()
		target_center_y /= target_tiles.size()

		# Get world position of target center - THIS is where projectiles should go
		target_position = defender_display.grid_to_world_position(int(target_center_x), int(target_center_y))

	# Feature 1 MVP: Draw targeting line with arrow to specific target
	var targeting_line: Line2D = null
	if target_room_id != -1 and target_room_id in defender.room_instances:
		# Draw dashed targeting line from attacker center to target
		var attacker_center = attacker_display.get_ship_center_world_position()

		# Create main line (more transparent, thinner)
		targeting_line = Line2D.new()
		targeting_line.add_point(attacker_center)
		targeting_line.add_point(target_position)
		targeting_line.default_color = Color(1.0, 0.867, 0.0, 0.5)  # Yellow with 50% transparency
		targeting_line.width = 3.0
		targeting_line.z_index = 100  # On top
		add_child(targeting_line)

		# Create arrow at the end pointing to target
		var arrow = Polygon2D.new()
		var direction = (target_position - attacker_center).normalized()
		var perpendicular = Vector2(-direction.y, direction.x)

		# Arrow pointing toward target (triangle at end of line)
		var arrow_size = 15.0
		var arrow_points = PackedVector2Array([
			target_position,  # Tip of arrow at target
			target_position - direction * arrow_size + perpendicular * (arrow_size * 0.5),  # Left wing
			target_position - direction * arrow_size - perpendicular * (arrow_size * 0.5)   # Right wing
		])
		arrow.polygon = arrow_points
		arrow.color = Color(1.0, 0.867, 0.0, 0.7)  # Slightly more opaque than line
		arrow.z_index = 101
		add_child(arrow)

		# Fade out targeting line and arrow after 0.2s
		var line_tween = create_tween()
		line_tween.tween_interval(0.2 * speed_multiplier)
		line_tween.tween_property(targeting_line, "modulate:a", 0.0, 0.1 * speed_multiplier)
		line_tween.parallel().tween_property(arrow, "modulate:a", 0.0, 0.1 * speed_multiplier)
		line_tween.tween_callback(targeting_line.queue_free)
		line_tween.tween_callback(arrow.queue_free)

		# Wait for targeting line to display
		await get_tree().create_timer(0.15 * speed_multiplier).timeout

		# Feature 1 MVP: Flash target component white (2 flashes) before hit
		if target_room_id in defender_display.room_instance_nodes:
			var room_container = defender_display.room_instance_nodes[target_room_id]
			for i in range(2):
				# Flash white
				room_container.modulate = Color(2.0, 2.0, 2.0, 1.0)  # Bright white flash
				await get_tree().create_timer(0.05 * speed_multiplier).timeout

				# Return to normal
				room_container.modulate = Color(1.0, 1.0, 1.0, 1.0)  # Normal color
				await get_tree().create_timer(0.05 * speed_multiplier).timeout

	# Determine weapon type based on mission/ship (player uses lasers, enemy uses torpedos for variety)
	var use_lasers = (attacker == player_data)

	# Play laser fire sound
	AudioManager.play_laser_fire()

	# Fire all weapons simultaneously (all targeting the same target_position)
	for weapon_pos in weapon_world_positions:
		# Spawn muzzle flash at weapon position
		if combat_fx:
			combat_fx.spawn_muzzle_flash(weapon_pos, 0.1)

		# Small delay between muzzle flash and projectile
		await get_tree().create_timer(0.05 * speed_multiplier).timeout

		# Fire projectile toward the specific target (not just ship center!)
		if combat_fx:
			if use_lasers:
				combat_fx.spawn_laser_beam(weapon_pos, target_position, 0.3)
			else:
				combat_fx.spawn_torpedo(weapon_pos, target_position, 0.5)

	# Wait for projectiles to reach target
	var projectile_travel_time = 0.3 if use_lasers else 0.5
	await get_tree().create_timer(projectile_travel_time * speed_multiplier).timeout

	# Spawn impacts at the specific target position (not ship center!)
	if combat_fx:
		if shield_absorption > 0:
			# Shields absorbed some/all damage - show shield impact at target
			combat_fx.spawn_shield_impact(target_position, 60.0, 0.4)

		if damage - shield_absorption > 0:
			# Some damage got through - show hull impact at target
			combat_fx.spawn_hull_impact(target_position, 30, 0.5)

			# Screen shake for significant hits
			if damage - shield_absorption > 20:
				combat_fx.spawn_screen_shake(5.0, 0.2)

	# Wait for impacts to complete
	await get_tree().create_timer(0.3 * speed_multiplier).timeout

## Select target room based on attacker's targeting priority (Feature 1 MVP)
## Returns room_id of selected target, or -1 if no valid target
func _select_target_room(defender: ShipData, attacker: ShipData) -> int:
	var targeting_priority = attacker.targeting_priority
	var active_room_ids = []

	# Get list of active room instances (exclude Bridge initially)
	for room_id in defender.room_instances:
		var room_data = defender.room_instances[room_id]
		if room_data["type"] != RoomData.RoomType.BRIDGE:
			active_room_ids.append(room_id)

	# Filter by priority
	var filtered_ids = []

	if targeting_priority == ShipData.TargetingPriority.WEAPONS_FIRST:
		# Target weapons only
		for room_id in active_room_ids:
			var room_data = defender.room_instances[room_id]
			if room_data["type"] == RoomData.RoomType.WEAPON:
				filtered_ids.append(room_id)

	elif targeting_priority == ShipData.TargetingPriority.POWER_FIRST:
		# Target reactors and relays only
		for room_id in active_room_ids:
			var room_data = defender.room_instances[room_id]
			if room_data["type"] == RoomData.RoomType.REACTOR or room_data["type"] == RoomData.RoomType.RELAY:
				filtered_ids.append(room_id)

	# Fallback to random if no priority targets available
	if filtered_ids.is_empty():
		filtered_ids = active_room_ids

	# Return random from filtered list
	if not filtered_ids.is_empty():
		return filtered_ids[randi() % filtered_ids.size()]

	return -1  # No valid target

## Spawn floating damage number above target ship
func _spawn_damage_number(net_damage: int, _total_damage: int, shield_absorption: int, is_player_target: bool):
	var damage_label = Label.new()
	damage_label.text = "-%d" % net_damage

	# Larger, more visible font
	damage_label.add_theme_font_size_override("font_size", 48)

	# Color code based on shield absorption effectiveness
	var damage_color: Color
	if net_damage > 0 and shield_absorption > 0:
		# Partial absorption - some got through shields
		damage_color = Color(1, 0.5, 0.2, 1)  # Orange
	elif net_damage > 0:
		# No shields or shields overwhelmed - pure hull damage
		damage_color = Color(1, 0.2, 0.2, 1)  # Red
	else:
		# Fully absorbed by shields - no hull damage
		damage_color = Color(0.2, 0.9, 0.9, 1)  # Cyan

	damage_label.add_theme_color_override("font_color", damage_color)

	# Add outline for better visibility
	damage_label.add_theme_constant_override("outline_size", 4)
	damage_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))

	# Position above health bars for better clarity
	if is_player_target:
		damage_label.position = Vector2(120, 180)
	else:
		damage_label.position = Vector2(1000, 180)

	add_child(damage_label)

	# Tween to float up and fade out
	var tween = create_tween()
	tween.tween_property(damage_label, "position:y", damage_label.position.y - 60, 0.8 * speed_multiplier)
	tween.parallel().tween_property(damage_label, "modulate:a", 0.0, 0.8 * speed_multiplier)
	tween.tween_callback(damage_label.queue_free)

## Destroy random rooms from defender (Phase 7.1 - destroys entire multi-tile room instances)
## Feature 1 MVP: Uses pre-selected primary_target_id for consistent targeting
func _destroy_random_rooms(defender: ShipData, defender_display: ShipDisplay, count: int, defender_name: String = "", attacker: ShipData = null, primary_target_id: int = -1):
	print("DEBUG _destroy_random_rooms: ENTERED with count=", count, ", defender=", defender_name)
	print("DEBUG: defender.room_instances.size()=", defender.room_instances.size())
	print("DEBUG: defender.room_instances.keys()=", defender.room_instances.keys())
	print("DEBUG: Feature 1 - Using pre-selected primary_target_id=", primary_target_id)

	if count <= 0:
		print("DEBUG: Exiting early - count <= 0")
		return

	# Track if any reactors were destroyed
	var reactor_destroyed = false

	# Get synergy data for DURABILITY bonus
	var synergies = defender.calculate_synergy_bonuses()
	var room_synergies = synergies["room_synergies"]

	# Phase 7.1: Get list of unique room instances (excluding Bridge initially)
	var active_room_ids = []
	for room_id in defender.room_instances:
		var room_data = defender.room_instances[room_id]
		if room_data["type"] != RoomData.RoomType.BRIDGE:
			active_room_ids.append(room_id)

	print("DEBUG: active_room_ids (non-Bridge)=", active_room_ids)

	# Fallback for old single-tile enemies (no room_instances yet)
	# Get all active room positions if room_instances is empty
	var active_rooms_fallback = []
	if defender.room_instances.is_empty():
		for pos in defender.get_active_room_positions():
			var room_type = defender.grid[pos.y][pos.x]
			if room_type != RoomData.RoomType.BRIDGE:
				active_rooms_fallback.append(pos)

	# Destroy targeted rooms sequentially with animation (Feature 1 MVP: primary target first)
	var destroyed = 0
	while destroyed < count:
		# Phase 7.1: Use room instance destruction if available
		if not defender.room_instances.is_empty():
			if active_room_ids.is_empty():
				break  # No more rooms to destroy

			# Feature 1 MVP: Pick primary target first, then random for remaining destructions
			var room_id: int
			var index: int
			if primary_target_id != -1 and primary_target_id in active_room_ids:
				# Destroy primary target first
				room_id = primary_target_id
				index = active_room_ids.find(room_id)
				primary_target_id = -1  # Clear so we only use it once
			else:
				# Pick random room instance
				index = randi() % active_room_ids.size()
				room_id = active_room_ids[index]
			var room_data = defender.room_instances[room_id]
			var room_type = room_data["type"]

			# Check if this weapon has DURABILITY synergy (25% chance to resist destruction)
			var resisted = false
			if room_type == RoomData.RoomType.WEAPON:
				# Check if any tile of this room has DURABILITY synergy
				for tile_pos in room_data["tiles"]:
					if tile_pos in room_synergies:
						if RoomData.SynergyType.DURABILITY in room_synergies[tile_pos]:
							# 25% chance to resist destruction
							if randf() < 0.25:
								resisted = true
								break

			if resisted:
				# Weapon resisted destruction, try another room
				if combat_log:
					combat_log.add_durability_resist(RoomData.get_label(room_type), defender_name)
				active_room_ids.remove_at(index)
				continue

			# Check if this is a reactor
			if room_type == RoomData.RoomType.REACTOR:
				reactor_destroyed = true

			# Log destruction
			if combat_log:
				combat_log.add_room_destroyed(RoomData.get_label(room_type), defender_name)

			# Play explosion sound
			AudioManager.play_explosion()

			# Destroy entire room instance (data)
			defender.destroy_room_instance(room_id)

			# Phase 7.4: Destroy entire shaped room visual with all tiles simultaneously
			var first_tile = room_data["tiles"][0]
			print("DEBUG Combat: Destroying room_id=", room_id, ", type=", RoomData.get_label(room_type), ", tiles=", room_data["tiles"].size())
			await defender_display.destroy_room_visual(
				first_tile.x, first_tile.y, speed_multiplier, room_data["tiles"], room_id
			)

			# Small delay between room destructions
			await get_tree().create_timer(0.1 * speed_multiplier).timeout

			# Remove from active list
			active_room_ids.remove_at(index)
			destroyed += 1

		else:
			# Fallback: Old single-tile destruction for enemy ships
			if active_rooms_fallback.is_empty():
				break

			var index = randi() % active_rooms_fallback.size()
			var pos = active_rooms_fallback[index]
			var room_type = defender.grid[pos.y][pos.x]

			# Check DURABILITY synergy
			if room_type == RoomData.RoomType.WEAPON:
				if pos in room_synergies:
					if RoomData.SynergyType.DURABILITY in room_synergies[pos]:
						if randf() < 0.25:
							if combat_log:
								combat_log.add_durability_resist(RoomData.get_label(room_type), defender_name)
							active_rooms_fallback.remove_at(index)
							continue

			if room_type == RoomData.RoomType.REACTOR:
				reactor_destroyed = true

			# Log destruction
			if combat_log:
				combat_log.add_room_destroyed(RoomData.get_label(room_type), defender_name)

			# Play explosion sound
			AudioManager.play_explosion()

			defender.destroy_room_at(pos.x, pos.y)
			await defender_display.destroy_room_visual(pos.x, pos.y, speed_multiplier)
			await get_tree().create_timer(0.1 * speed_multiplier).timeout

			active_rooms_fallback.remove_at(index)
			destroyed += 1

	# If all non-Bridge rooms destroyed and more damage remains, destroy Bridge
	if destroyed < count and defender.has_bridge():
		# Phase 7.1/7.4: Check if using room instances
		if not defender.room_instances.is_empty():
			# Find Bridge room instance
			for room_id in defender.room_instances:
				var room_data = defender.room_instances[room_id]
				if room_data["type"] == RoomData.RoomType.BRIDGE:
					# Destroy entire Bridge instance
					defender.destroy_room_instance(room_id)

					# Phase 7.4: Destroy visuals for entire shaped Bridge simultaneously
					var first_tile = room_data["tiles"][0]
					await defender_display.destroy_room_visual(
						first_tile.x, first_tile.y, speed_multiplier, room_data["tiles"], room_id
					)
					break
		else:
			# Fallback: Old single-tile Bridge destruction
			for pos in defender.get_active_room_positions():
				var room_type = defender.grid[pos.y][pos.x]
				if room_type == RoomData.RoomType.BRIDGE:
					defender.destroy_room_at(pos.x, pos.y)
					await defender_display.destroy_room_visual(pos.x, pos.y, speed_multiplier)
					break

	# If reactor was destroyed, recalculate power and update visuals
	if reactor_destroyed:
		if combat_log:
			combat_log.add_reactor_destroyed(defender_name)
		# Play reactor powerdown sound
		AudioManager.play_reactor_powerdown()
		defender.recalculate_power()
		defender_display.update_power_visuals(defender)

	# Update stats panels after room destruction (Phase 10.9)
	_update_player_stats()
	_update_enemy_stats()

## Flash ship with color
func _flash_ship(display: ShipDisplay, color: Color):
	display.flash(color)

## Update turn indicator with visual emphasis
func _update_turn_indicator(player_turn: bool):
	if player_turn:
		turn_indicator.text = "PLAYER TURN"
		turn_indicator.add_theme_color_override("font_color", Color(0.29, 0.89, 0.89, 1))  # Cyan
		turn_glow.color = Color(0.29, 0.89, 0.89, 0.3)  # Cyan glow
	else:
		turn_indicator.text = "ENEMY TURN"
		turn_indicator.add_theme_color_override("font_color", Color(0.89, 0.29, 0.29, 1))  # Red
		turn_glow.color = Color(0.89, 0.29, 0.29, 0.3)  # Red glow

	# Pulse animation to draw attention
	var tween = create_tween()
	tween.tween_property(turn_indicator, "scale", Vector2(1.2, 1.2), 0.2)
	tween.tween_property(turn_indicator, "scale", Vector2(1.0, 1.0), 0.2)

## Show combat end screen
func _show_combat_end(winner: String):
	# Log victory/defeat
	if combat_log:
		combat_log.add_victory(winner)

	# Flash winner green, loser red
	if winner == "player":
		# Play victory sound
		AudioManager.play_victory()

		_flash_ship(player_ship_display, Color(0.29, 0.89, 0.29))  # Green
		_flash_ship(enemy_ship_display, Color(0.89, 0.29, 0.29))   # Red
		result_label.text = "VICTORY"

		# Wait for flash to complete
		await get_tree().create_timer(0.5).timeout

		# Handle victory based on mission
		if current_mission < 2:
			# Unlock next mission
			GameState.unlock_mission(current_mission + 1)

			# Return to Mission Select
			get_tree().change_scene_to_file("res://scenes/mission/MissionSelect.tscn")
		else:
			# Mission 3 complete - show final victory screen
			victory_overlay.visible = true
	else:
		# Play death sound
		AudioManager.play_death()

		_flash_ship(player_ship_display, Color(0.89, 0.29, 0.29))  # Red
		_flash_ship(enemy_ship_display, Color(0.29, 0.89, 0.29))   # Green
		result_label.text = "DEFEAT"

		# Show result overlay
		result_overlay.visible = true

		# Wait a moment, then return to designer for redesign
		await get_tree().create_timer(2.0).timeout
		get_tree().change_scene_to_file("res://scenes/designer/ShipDesigner.tscn")

## Check win condition
func _check_win_condition() -> String:
	# Check if enemy defeated
	if enemy_data.current_hp <= 0 or not enemy_data.has_bridge():
		return "player"

	# Check if player defeated
	if player_data.current_hp <= 0 or not player_data.has_bridge():
		return "enemy"

	return ""  # Combat continues

## Handle redesign button press
func _on_redesign_pressed():
	# Play button click sound
	AudioManager.play_button_click()

	# Return to ShipDesigner scene
	get_tree().change_scene_to_file("res://scenes/designer/ShipDesigner.tscn")

## Handle victory return button press
func _on_victory_return_pressed():
	# Play button click sound
	AudioManager.play_button_click()

	# Return to Mission Select
	get_tree().change_scene_to_file("res://scenes/mission/MissionSelect.tscn")

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

## Handle Pause button press - toggle pause state
func _on_pause_pressed():
	# Play button click sound
	AudioManager.play_button_click()

	is_paused = !is_paused
	if is_paused:
		pause_button.text = "RESUME"
	else:
		pause_button.text = "PAUSE"

## Handle Fast Forward button press - cycle through speeds
func _on_ff_pressed():
	# Play button click sound
	AudioManager.play_button_click()
	# Cycle: 0.5x → 1x → 2x → 0.25x → 0.5x
	if speed_multiplier == 2.0:  # 0.5x → 1x
		speed_multiplier = 1.0
		ff_button.text = "Speed: 1x"
	elif speed_multiplier == 1.0:  # 1x → 2x
		speed_multiplier = 0.5
		ff_button.text = "Speed: 2x"
	elif speed_multiplier == 0.5:  # 2x → 0.25x
		speed_multiplier = 4.0
		ff_button.text = "Speed: 0.25x"
	else:  # 0.25x → 0.5x
		speed_multiplier = 2.0
		ff_button.text = "Speed: 0.5x"

## Get current speed multiplier (Phase 10.6 - for CombatFX to access)
func _get_speed_multiplier_value() -> float:
	return speed_multiplier

## Create enemy ship from template (Phase 10.8 - template system)
func _create_enemy_from_template(template: ShipTemplate) -> ShipData:
	# Create empty grid based on template dimensions
	var grid = []
	for _y in range(template.grid_height):
		var row = []
		for _x in range(template.grid_width):
			row.append(RoomData.RoomType.EMPTY)
		grid.append(row)

	# Fill grid with rooms from template
	var room_instances = {}
	var next_room_id = 1

	for room_placement in template.room_placements:
		var room_type = room_placement["type"]
		var tiles = room_placement["tiles"]

		# Add to room_instances (for multi-tile room tracking)
		room_instances[next_room_id] = {
			"type": room_type,
			"tiles": tiles
		}

		# Fill grid tiles
		for tile_pos in tiles:
			if tile_pos.y >= 0 and tile_pos.y < grid.size():
				if tile_pos.x >= 0 and tile_pos.x < grid[tile_pos.y].size():
					grid[tile_pos.y][tile_pos.x] = room_type

		next_room_id += 1

	# Create ShipData from grid
	var ship_data = ShipData.new()
	ship_data.grid = grid
	ship_data.room_instances = room_instances

	# Calculate HP from armor count
	var armor_count = 0
	for y in range(grid.size()):
		for x in range(grid[y].size()):
			if grid[y][x] == RoomData.RoomType.ARMOR:
				armor_count += 1

	ship_data.max_hp = 20 + (armor_count * 10)
	ship_data.current_hp = ship_data.max_hp

	# Recalculate power for enemy ship
	ship_data.recalculate_power()

	return ship_data
