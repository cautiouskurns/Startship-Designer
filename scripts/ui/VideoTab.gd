extends VBoxContainer

## VideoTab - Manages video settings (resolution, fullscreen)

@onready var resolution_dropdown: OptionButton = $ResolutionContainer/ResolutionDropdown
@onready var fullscreen_checkbox: CheckButton = $FullscreenContainer/FullscreenCheckbox
@onready var apply_button: Button = $ApplyButton

var pending_resolution: Vector2i
var pending_fullscreen: bool
var has_pending_changes: bool = false

func _ready():
	# Populate resolution dropdown
	_populate_resolutions()

	# Connect signals
	if resolution_dropdown:
		resolution_dropdown.item_selected.connect(_on_resolution_selected)

	if fullscreen_checkbox:
		fullscreen_checkbox.toggled.connect(_on_fullscreen_toggled)

	if apply_button:
		apply_button.pressed.connect(_on_apply_pressed)
		apply_button.disabled = true

	# Load current values
	load_values()

## Populate resolution dropdown with available resolutions
func _populate_resolutions():
	if not resolution_dropdown:
		return

	resolution_dropdown.clear()
	var resolutions = SettingsManager.get_available_resolutions()

	for i in range(resolutions.size()):
		var res = resolutions[i]
		var text = str(res.x) + " × " + str(res.y)
		resolution_dropdown.add_item(text, i)

## Load current video settings
func load_values():
	var current_res = SettingsManager.settings["video"]["resolution"]
	var current_fullscreen = SettingsManager.settings["video"]["fullscreen"]

	# Set resolution dropdown
	if resolution_dropdown:
		var resolutions = SettingsManager.get_available_resolutions()
		for i in range(resolutions.size()):
			if resolutions[i] == current_res:
				resolution_dropdown.selected = i
				break

	# Set fullscreen checkbox
	if fullscreen_checkbox:
		fullscreen_checkbox.button_pressed = current_fullscreen

	# Reset pending changes
	pending_resolution = current_res
	pending_fullscreen = current_fullscreen
	has_pending_changes = false

	if apply_button:
		apply_button.disabled = true

## Called when resolution is selected from dropdown
func _on_resolution_selected(index: int):
	var resolutions = SettingsManager.get_available_resolutions()
	if index >= 0 and index < resolutions.size():
		pending_resolution = resolutions[index]
		_check_for_changes()

	# Play feedback sound
	if AudioManager:
		AudioManager.play_button_click()

## Called when fullscreen checkbox is toggled
func _on_fullscreen_toggled(enabled: bool):
	pending_fullscreen = enabled
	_check_for_changes()

	# Play feedback sound
	if AudioManager:
		AudioManager.play_button_click()

## Check if there are pending changes
func _check_for_changes():
	var current_res = SettingsManager.settings["video"]["resolution"]
	var current_fullscreen = SettingsManager.settings["video"]["fullscreen"]

	has_pending_changes = (pending_resolution != current_res) or (pending_fullscreen != current_fullscreen)

	if apply_button:
		apply_button.disabled = not has_pending_changes

## Apply video settings
func _on_apply_pressed():
	if not has_pending_changes:
		return

	# Apply resolution
	SettingsManager.set_resolution(pending_resolution)

	# Apply fullscreen
	SettingsManager.set_fullscreen(pending_fullscreen)

	# Reset pending changes
	has_pending_changes = false
	if apply_button:
		apply_button.disabled = true

	# Play success sound
	if AudioManager:
		AudioManager.play_success()
