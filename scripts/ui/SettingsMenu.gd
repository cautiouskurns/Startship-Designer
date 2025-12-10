extends Control

## SettingsMenu - Main controller for settings menu
## Coordinates tabs and handles save/cancel operations

@onready var close_button: Button = $CenterContainer/Panel/MarginContainer/VBoxContainer/TitleBar/CloseButton
@onready var tab_container: TabContainer = $CenterContainer/Panel/MarginContainer/VBoxContainer/TabContainer
@onready var save_button: Button = $CenterContainer/Panel/MarginContainer/VBoxContainer/ButtonRow/SaveButton
@onready var cancel_button: Button = $CenterContainer/Panel/MarginContainer/VBoxContainer/ButtonRow/CancelButton

# Store original settings for cancel functionality
var original_settings: Dictionary = {}

func _ready():
	# Store original settings
	_store_original_settings()

	# Connect signals
	if close_button:
		close_button.pressed.connect(_on_close_pressed)

	if save_button:
		save_button.pressed.connect(_on_save_pressed)

	if cancel_button:
		cancel_button.pressed.connect(_on_cancel_pressed)

	# Handle ESC key
	set_process_input(true)

## Store original settings for cancel functionality
func _store_original_settings():
	original_settings = {
		"audio": SettingsManager.settings["audio"].duplicate(),
		"video": SettingsManager.settings["video"].duplicate(),
		"controls": SettingsManager.settings["controls"].duplicate()
	}

## Handle input (ESC key)
func _input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):  # ESC key
		_on_close_pressed()
		get_viewport().set_input_as_handled()

## Called when close button is pressed
func _on_close_pressed():
	# Check if there are unsaved changes
	if _has_changes():
		# For now, just close without prompting
		# TODO: Add confirmation dialog
		_on_cancel_pressed()
	else:
		_close_menu()

	# Play feedback sound
	if AudioManager:
		AudioManager.play_button_click()

## Called when save button is pressed
func _on_save_pressed():
	# Save settings to disk
	SettingsManager.save_settings()

	# Update original settings
	_store_original_settings()

	# Close menu
	_close_menu()

	# Play feedback sound
	if AudioManager:
		AudioManager.play_success()

## Called when cancel button is pressed
func _on_cancel_pressed():
	# Restore original settings
	SettingsManager.settings["audio"] = original_settings["audio"].duplicate()
	SettingsManager.settings["video"] = original_settings["video"].duplicate()
	SettingsManager.settings["controls"] = original_settings["controls"].duplicate()

	# Apply restored settings
	SettingsManager.apply_settings()

	# Close menu
	_close_menu()

	# Play feedback sound
	if AudioManager:
		AudioManager.play_button_click()

## Check if there are unsaved changes
func _has_changes() -> bool:
	# Compare current settings with original
	if SettingsManager.settings["audio"] != original_settings["audio"]:
		return true
	if SettingsManager.settings["video"] != original_settings["video"]:
		return true
	if SettingsManager.settings["controls"] != original_settings["controls"]:
		return true
	return false

## Close the menu
func _close_menu():
	queue_free()
