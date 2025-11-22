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

## Ship data
var player_data: ShipData = null
var enemy_data: ShipData = null

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

	# Set turn indicator
	turn_indicator.text = "PLAYER TURN"

## Update player health bar and label
func _update_player_health():
	player_health_bar.max_value = player_data.max_hp
	player_health_bar.value = player_data.current_hp
	player_health_label.text = "%d / %d HP" % [player_data.current_hp, player_data.max_hp]
	_update_health_bar_color(player_health_bar)

## Update enemy health bar and label
func _update_enemy_health():
	enemy_health_bar.max_value = enemy_data.max_hp
	enemy_health_bar.value = enemy_data.current_hp
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

## Handle redesign button press
func _on_redesign_pressed():
	# Return to ShipDesigner scene
	get_tree().change_scene_to_file("res://scenes/designer/ShipDesigner.tscn")
