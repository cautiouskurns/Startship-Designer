extends ColorRect

## Dialog for entering template name when saving (Phase 10.8)

signal template_name_entered(template_name: String)
signal cancelled

@onready var line_edit: LineEdit = $Panel/LineEdit
@onready var ok_button: Button = $Panel/OKButton
@onready var cancel_button: Button = $Panel/CancelButton
@onready var error_label: Label = $Panel/ErrorLabel

func _ready():
	# Connect button signals
	ok_button.pressed.connect(_on_ok_pressed)
	cancel_button.pressed.connect(_on_cancel_pressed)
	line_edit.text_submitted.connect(_on_text_submitted)

	# Hide error label initially
	error_label.visible = false

## Show the dialog
func show_dialog():
	visible = true
	line_edit.text = ""
	error_label.visible = false
	line_edit.grab_focus()

## Hide the dialog
func hide_dialog():
	visible = false

func _on_ok_pressed():
	var template_name = line_edit.text.strip_edges()

	# Validate name
	if template_name.is_empty():
		_show_error("Please enter a template name")
		return

	# Check if name already exists
	if TemplateManager.template_name_exists(template_name):
		# Show confirmation that it will be overwritten
		_show_error("Template exists - will be overwritten")
		# Still allow saving (will replace existing)

	# Emit signal and close
	template_name_entered.emit(template_name)
	hide_dialog()

func _on_cancel_pressed():
	cancelled.emit()
	hide_dialog()

func _on_text_submitted(_text: String):
	# Enter key submits
	_on_ok_pressed()

func _show_error(message: String):
	error_label.text = message
	error_label.visible = true
