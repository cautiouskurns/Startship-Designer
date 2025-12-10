extends Button

## KeybindButton - Individual keybind button for remapping controls
## Displays current key binding and allows player to click and press new key

@export var action_name: String = ""  # InputMap action name (e.g., "camera_up")
@export var action_label: String = ""  # Display name (e.g., "Move Forward")

var is_waiting_for_input: bool = false
var original_text: String = ""

# Signals
signal keybind_changed(action: String, new_key: int)

func _ready():
	# Connect button press signal
	pressed.connect(_on_button_pressed)

	# Display current keybind
	update_button_text()

## Update button text to show current key
func update_button_text():
	if action_name == "":
		text = "Not Assigned"
		return

	var keycode = SettingsManager.get_keybind(action_name)
	if keycode == KEY_NONE:
		text = "Not Assigned"
	else:
		text = OS.get_keycode_string(keycode)

	original_text = text

## Called when button is clicked
func _on_button_pressed():
	if is_waiting_for_input:
		# Cancel input waiting
		is_waiting_for_input = false
		text = original_text
		remove_theme_color_override("font_color")
	else:
		# Start waiting for input
		is_waiting_for_input = true
		text = "Press a key..."
		add_theme_color_override("font_color", Color("#4AE2E2"))  # Cyan

		# Play feedback sound
		if AudioManager:
			AudioManager.play_button_click()

## Handle key input when waiting for new binding
func _input(event: InputEvent):
	if not is_waiting_for_input:
		return

	if event is InputEventKey and event.pressed:
		var keycode = event.keycode

		# Try to set the keybind
		var success = SettingsManager.set_keybind(action_name, keycode)

		if success:
			# Update button text
			is_waiting_for_input = false
			update_button_text()
			remove_theme_color_override("font_color")

			# Play success sound
			if AudioManager:
				AudioManager.play_success()

			# Emit signal
			keybind_changed.emit(action_name, keycode)
		else:
			# Show error (key reserved or already bound)
			is_waiting_for_input = false
			text = "Invalid Key!"
			add_theme_color_override("font_color", Color("#E24A4A"))  # Red

			# Play error sound
			if AudioManager:
				AudioManager.play_failure()

			# Reset after delay
			await get_tree().create_timer(1.0).timeout
			update_button_text()
			remove_theme_color_override("font_color")

		# Accept the event to prevent it from propagating
		get_viewport().set_input_as_handled()
