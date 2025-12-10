extends Panel

## SaveDialog
## Modal dialog for saving ship designs with custom names

## Signals
signal design_saved(design_name: String)
signal cancelled()

## Node references
@onready var title_label = $MarginContainer/VBoxContainer/Title
@onready var name_input = $MarginContainer/VBoxContainer/InputContainer/NameInput
@onready var char_counter = $MarginContainer/VBoxContainer/InputContainer/CharCounter
@onready var error_label = $MarginContainer/VBoxContainer/ErrorLabel
@onready var cancel_button = $MarginContainer/VBoxContainer/ButtonContainer/CancelButton
@onready var save_button = $MarginContainer/VBoxContainer/ButtonContainer/SaveButton

const MAX_NAME_LENGTH = 20

func _ready():
	# Connect signals
	name_input.text_changed.connect(_on_name_input_changed)
	name_input.text_submitted.connect(_on_name_submitted)
	cancel_button.pressed.connect(_on_cancel_pressed)
	save_button.pressed.connect(_on_save_pressed)

	# Setup initial state
	error_label.text = ""
	error_label.hide()
	name_input.max_length = MAX_NAME_LENGTH
	_update_char_counter()

	# Focus the input field
	name_input.grab_focus()

	# Animate appearance
	modulate.a = 0
	scale = Vector2(0.9, 0.9)
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "modulate:a", 1.0, 0.2)
	tween.tween_property(self, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

## Show the dialog
func show_dialog(default_name: String = ""):
	if default_name:
		name_input.text = default_name
	else:
		name_input.text = ""
	error_label.hide()
	_update_char_counter()
	show()
	name_input.grab_focus()

## Update character counter
func _update_char_counter():
	var current_length = name_input.text.length()
	char_counter.text = "%d/%d" % [current_length, MAX_NAME_LENGTH]

	# Color based on remaining characters
	if current_length >= MAX_NAME_LENGTH:
		char_counter.add_theme_color_override("font_color", Color.ORANGE)
	else:
		char_counter.add_theme_color_override("font_color", Color.WHITE)

## Validate design name
func _validate_name() -> bool:
	var design_name = name_input.text.strip_edges()

	if design_name.is_empty():
		_show_error("Name cannot be empty")
		return false

	# Check for invalid characters (optional - SaveManager sanitizes anyway)
	# For now, allow any characters and let SaveManager handle sanitization

	return true

## Show error message
func _show_error(message: String):
	error_label.text = message
	error_label.show()

	# Flash red border
	var original_color = get_theme_stylebox("panel").border_color
	var style = get_theme_stylebox("panel")
	if style is StyleBoxFlat:
		var tween = create_tween()
		tween.tween_property(style, "border_color", Color.RED, 0.1)
		tween.tween_property(style, "border_color", original_color, 0.3)

## Event handlers
func _on_name_input_changed(new_text: String):
	_update_char_counter()
	error_label.hide()

func _on_name_submitted(new_text: String):
	_on_save_pressed()

func _on_save_pressed():
	if not _validate_name():
		return

	var design_name = name_input.text.strip_edges()
	design_saved.emit(design_name)
	_close_dialog()

func _on_cancel_pressed():
	cancelled.emit()
	_close_dialog()

## Close dialog with animation
func _close_dialog():
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.0, 0.15)
	tween.tween_property(self, "scale", Vector2(0.9, 0.9), 0.15)
	await tween.finished
	queue_free()
