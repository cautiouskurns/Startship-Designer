extends ScrollContainer

## ControlsTab - Manages keybind remapping

@onready var keybind_list: VBoxContainer = $KeybindList

# Keybind button scene (will be created dynamically)
var keybind_button_script = preload("res://scripts/ui/KeybindButton.gd")

# Action display names
var action_labels = {
	"camera_up": "Move Camera Up",
	"camera_down": "Move Camera Down",
	"camera_left": "Move Camera Left",
	"camera_right": "Move Camera Right",
	"zoom_in": "Zoom In",
	"zoom_out": "Zoom Out"
}

func _ready():
	_populate_keybinds()

## Populate the keybind list with buttons
func _populate_keybinds():
	if not keybind_list:
		return

	# Clear existing children
	for child in keybind_list.get_children():
		child.queue_free()

	# Get all control actions from SettingsManager
	var actions = SettingsManager.settings["controls"].keys()

	# Create a row for each action
	for action in actions:
		_create_keybind_row(action)

## Create a row with label and keybind button
func _create_keybind_row(action: String):
	# Create horizontal container for the row
	var row = HBoxContainer.new()
	row.custom_minimum_size = Vector2(0, 40)

	# Create action label
	var label = Label.new()
	label.text = action_labels.get(action, action.capitalize())
	label.custom_minimum_size = Vector2(200, 0)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(label)

	# Add spacer
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(20, 0)
	row.add_child(spacer)

	# Create keybind button
	var button = Button.new()
	button.custom_minimum_size = Vector2(150, 30)
	button.set_script(keybind_button_script)
	button.action_name = action
	button.action_label = action_labels.get(action, action.capitalize())

	# Connect keybind changed signal
	button.keybind_changed.connect(_on_keybind_changed)

	row.add_child(button)

	# Add row to list
	keybind_list.add_child(row)

	# Call _ready() on the button manually since it was just created
	button._ready()

## Called when a keybind is changed
func _on_keybind_changed(action: String, new_key: int):
	print("Keybind changed: " + action + " -> " + OS.get_keycode_string(new_key))
