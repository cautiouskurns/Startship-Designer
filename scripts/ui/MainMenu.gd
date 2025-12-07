extends Control

@onready var new_game_button = $MenuButtons/NewGameButton
@onready var load_button = $MenuButtons/LoadButton
@onready var quit_button = $MenuButtons/QuitButton

func _ready():
	# Connect button signals
	new_game_button.pressed.connect(_on_new_game_pressed)
	load_button.pressed.connect(_on_load_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

	# Disable load button for now (no save system yet)
	load_button.disabled = true
	load_button.tooltip_text = "No save system implemented yet"

func _on_new_game_pressed():
	# Reset game state and go to campaign map
	GameState.reset_game()
	get_tree().change_scene_to_file("res://scenes/campaign/CampaignMap.tscn")

func _on_load_pressed():
	# TODO: Implement load game functionality
	print("Load game not yet implemented")

func _on_quit_pressed():
	get_tree().quit()
