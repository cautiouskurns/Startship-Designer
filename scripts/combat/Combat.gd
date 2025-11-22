extends Control

## Ship display nodes
@onready var player_ship_display: ShipDisplay = $PlayerShipDisplay
@onready var enemy_ship_display: ShipDisplay = $EnemyShipDisplay

## Health bar nodes
@onready var player_health_bar: ProgressBar = $PlayerHealthBar
@onready var enemy_health_bar: ProgressBar = $EnemyHealthBar

## Health label nodes
@onready var player_health_label: Label = $PlayerHealthBar/PlayerHealthLabel
@onready var enemy_health_label: Label = $EnemyHealthBar/EnemyHealthLabel

## Turn indicator
@onready var turn_indicator: Label = $TurnIndicator

## Redesign button
@onready var redesign_button: Button = $RedesignButton

## Result overlay nodes
@onready var result_overlay: ColorRect = $ResultOverlay
@onready var result_label: Label = $ResultOverlay/ResultLabel

## Ship data
var player_data: ShipData = null
var enemy_data: ShipData = null

## Combat state
var is_player_turn: bool = true
var combat_active: bool = false
var turn_count: int = 0

func _ready():
	# Connect redesign button
	redesign_button.pressed.connect(_on_redesign_pressed)

## Start combat with player ship data
func start_combat(player_ship: ShipData):
	player_data = player_ship
	enemy_data = ShipData.create_mission1_scout()

	# Set up ship displays
	player_ship_display.set_ship_data(player_data)
	enemy_ship_display.set_ship_data(enemy_data)

	# Initialize health bars
	_update_player_health()
	_update_enemy_health()

	# Determine initiative (who goes first)
	is_player_turn = _determine_initiative()

	# Set initial turn indicator with visual emphasis
	_update_turn_indicator(is_player_turn)

	# Start combat loop (deferred to allow scene to fully initialize)
	run_combat_loop.call_deferred()

## Update player health bar and label
func _update_player_health():
	player_health_bar.max_value = player_data.max_hp
	# Animate health bar smoothly
	var tween = create_tween()
	tween.tween_property(player_health_bar, "value", player_data.current_hp, 0.5)
	player_health_label.text = "%d / %d HP" % [player_data.current_hp, player_data.max_hp]
	_update_health_bar_color(player_health_bar)

## Update enemy health bar and label
func _update_enemy_health():
	enemy_health_bar.max_value = enemy_data.max_hp
	# Animate health bar smoothly
	var tween = create_tween()
	tween.tween_property(enemy_health_bar, "value", enemy_data.current_hp, 0.5)
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

## Main combat loop
func run_combat_loop():
	combat_active = true

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
	await get_tree().create_timer(1.8).timeout

	# Combat loop
	while combat_active:
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

		# Wait between turns (longer pause to see results)
		await get_tree().create_timer(1.5).timeout

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

	# Flash attacking ship
	_flash_ship(attacker_display, Color(1, 1, 1))  # White flash

	# Longer delay to see who's attacking
	await get_tree().create_timer(0.6).timeout

	# Calculate damage
	var damage = _calculate_damage(attacker)
	var shield_absorption = _calculate_shield_absorption(defender, damage)
	var net_damage = max(0, damage - shield_absorption)

	# Debug output
	print("Turn %d: %s attacks for %d damage, %d absorbed by shields, %d net damage" % [
		turn_count,
		"PLAYER" if is_player_attacking else "ENEMY",
		damage,
		shield_absorption,
		net_damage
	])

	# Apply damage to HP
	defender.current_hp = max(0, defender.current_hp - net_damage)

	print("  Defender HP: %d / %d" % [defender.current_hp, defender.max_hp])

	# Update health display
	if is_player_attacking:
		_update_enemy_health()
	else:
		_update_player_health()

	# Spawn damage number
	_spawn_damage_number(net_damage, !is_player_attacking)

	# Destroy rooms (1 per 20 damage)
	var rooms_to_destroy = int(net_damage / 20)
	if rooms_to_destroy > 0:
		await _destroy_random_rooms(defender, defender_display, rooms_to_destroy)

	# Wait a moment to see final state
	await get_tree().create_timer(0.5).timeout

## Determine which ship shoots first based on engine count
func _determine_initiative() -> bool:
	var player_engines = player_data.count_powered_room_type(RoomData.RoomType.ENGINE)
	var enemy_engines = enemy_data.count_powered_room_type(RoomData.RoomType.ENGINE)

	# Higher engine count shoots first, player wins ties
	return player_engines >= enemy_engines

## Calculate damage dealt by attacker
func _calculate_damage(attacker: ShipData) -> int:
	var weapons = attacker.count_powered_room_type(RoomData.RoomType.WEAPON)
	return weapons * 10

## Calculate shield absorption for defender
func _calculate_shield_absorption(defender: ShipData, damage: int) -> int:
	var shields = defender.count_powered_room_type(RoomData.RoomType.SHIELD)
	return min(damage, shields * 15)

## Spawn floating damage number above target ship
func _spawn_damage_number(amount: int, is_player_target: bool):
	var damage_label = Label.new()
	damage_label.text = "-%d" % amount

	# Larger, more visible font
	damage_label.add_theme_font_size_override("font_size", 48)

	# Color code based on damage amount
	var damage_color: Color
	if amount >= 30:
		damage_color = Color(1, 0.2, 0.2, 1)  # Bright red for high damage
	elif amount >= 15:
		damage_color = Color(1, 0.5, 0.2, 1)  # Orange for medium damage
	else:
		damage_color = Color(1, 0.8, 0.3, 1)  # Yellow for low damage

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

	# Tween to float up and fade out (slightly slower for readability)
	var tween = create_tween()
	tween.tween_property(damage_label, "position:y", damage_label.position.y - 60, 1.2)
	tween.parallel().tween_property(damage_label, "modulate:a", 0.0, 1.2)
	tween.tween_callback(damage_label.queue_free)

## Destroy random rooms from defender
func _destroy_random_rooms(defender: ShipData, defender_display: ShipDisplay, count: int):
	if count <= 0:
		return

	# Track if any reactors were destroyed
	var reactor_destroyed = false

	# Get all active room positions, excluding Bridge initially
	var active_rooms = []
	for pos in defender.get_active_room_positions():
		var room_type = defender.grid[pos.y][pos.x]
		if room_type != RoomData.RoomType.BRIDGE:
			active_rooms.append(pos)

	# Destroy random rooms sequentially with animation
	var destroyed = 0
	while destroyed < count and active_rooms.size() > 0:
		# Pick random room
		var index = randi() % active_rooms.size()
		var pos = active_rooms[index]

		# Check if this is a reactor
		if defender.grid[pos.y][pos.x] == RoomData.RoomType.REACTOR:
			reactor_destroyed = true

		# Destroy it (data)
		defender.destroy_room_at(pos.x, pos.y)

		# Destroy it (visual with animation) - AWAIT
		await defender_display.destroy_room_visual(pos.x, pos.y)

		# Small delay between room destructions
		await get_tree().create_timer(0.2).timeout

		# Remove from list
		active_rooms.remove_at(index)
		destroyed += 1

	# If all non-Bridge rooms destroyed and more damage remains, destroy Bridge
	if destroyed < count and defender.has_bridge():
		# Find Bridge position
		for pos in defender.get_active_room_positions():
			var room_type = defender.grid[pos.y][pos.x]
			if room_type == RoomData.RoomType.BRIDGE:
				# Destroy data
				defender.destroy_room_at(pos.x, pos.y)

				# Destroy visual with animation - AWAIT
				await defender_display.destroy_room_visual(pos.x, pos.y)
				break

	# If reactor was destroyed, recalculate power and update visuals
	if reactor_destroyed:
		defender.recalculate_power()
		defender_display.update_power_visuals(defender)

## Flash ship with color
func _flash_ship(display: ShipDisplay, color: Color):
	display.flash(color)

## Update turn indicator with visual emphasis
func _update_turn_indicator(player_turn: bool):
	if player_turn:
		turn_indicator.text = "PLAYER TURN"
		turn_indicator.add_theme_color_override("font_color", Color(0.29, 0.89, 0.89, 1))  # Cyan
	else:
		turn_indicator.text = "ENEMY TURN"
		turn_indicator.add_theme_color_override("font_color", Color(0.89, 0.29, 0.29, 1))  # Red

	# Pulse animation to draw attention
	var tween = create_tween()
	tween.tween_property(turn_indicator, "scale", Vector2(1.2, 1.2), 0.2)
	tween.tween_property(turn_indicator, "scale", Vector2(1.0, 1.0), 0.2)

## Show combat end screen
func _show_combat_end(winner: String):
	# Flash winner green, loser red
	if winner == "player":
		_flash_ship(player_ship_display, Color(0.29, 0.89, 0.29))  # Green
		_flash_ship(enemy_ship_display, Color(0.89, 0.29, 0.29))   # Red
		result_label.text = "VICTORY"
	else:
		_flash_ship(player_ship_display, Color(0.89, 0.29, 0.29))  # Red
		_flash_ship(enemy_ship_display, Color(0.29, 0.89, 0.29))   # Green
		result_label.text = "DEFEAT"

	# Show result overlay
	result_overlay.visible = true

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
	# Return to ShipDesigner scene
	get_tree().change_scene_to_file("res://scenes/designer/ShipDesigner.tscn")
