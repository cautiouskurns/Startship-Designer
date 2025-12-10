extends Control

@onready var new_game_button = $MenuButtons/NewGameButton
@onready var load_button = $MenuButtons/LoadButton
@onready var settings_button = $MenuButtons/SettingsButton
@onready var quit_button = $MenuButtons/QuitButton

# Settings menu scene
var settings_menu_scene = preload("res://scenes/ui/SettingsMenu.tscn")

func _ready():
	# Connect button signals
	new_game_button.pressed.connect(_on_new_game_pressed)
	load_button.pressed.connect(_on_load_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

	# Disable load button for now (no save system yet)
	load_button.disabled = true
	load_button.tooltip_text = "No save system implemented yet"

func _on_new_game_pressed():
	# Reset game state
	GameState.reset_game()
	CampaignState.reset_campaign()

	# Feature 7: Reset narrative state and show opening crawl
	if NarrativeManager:
		NarrativeManager.reset()

	# Go to opening crawl (which will transition to campaign map)
	get_tree().change_scene_to_file("res://scenes/ui/OpeningCrawl.tscn")

func _on_load_pressed():
	# TODO: Implement load game functionality
	print("Load game not yet implemented")

func _on_settings_pressed():
	# Instantiate and add settings menu
	var settings_menu = settings_menu_scene.instantiate()
	add_child(settings_menu)

	# Play button click sound
	if AudioManager:
		AudioManager.play_button_click()

func _on_quit_pressed():
	get_tree().quit()
