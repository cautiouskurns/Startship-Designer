extends Control

## Mission selection screen

## UI nodes
@onready var mission1_button: Button = $MissionButtons/Mission1Button
@onready var mission2_button: Button = $MissionButtons/Mission2Button
@onready var mission3_button: Button = $MissionButtons/Mission3Button
@onready var brief_panel: Panel = $BriefPanel
@onready var brief_label: Label = $BriefPanel/BriefLabel
@onready var back_button: Button = $BackButton

func _ready():
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
	_load_mission(0)

## Mission 2 pressed
func _on_mission2_pressed():
	_load_mission(1)

## Mission 3 pressed
func _on_mission3_pressed():
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
