extends Control

## Narrative Popup
## Displays transmission-style narrative messages during campaign

signal continue_pressed

## UI Elements
@onready var panel: Panel = $CenterContainer/Panel
@onready var title_label: Label = $CenterContainer/Panel/MarginContainer/VBoxContainer/TitleLabel
@onready var text_label: Label = $CenterContainer/Panel/MarginContainer/VBoxContainer/TextLabel
@onready var continue_button: Button = $CenterContainer/Panel/MarginContainer/VBoxContainer/ContinueButton

## Auto-continue settings
var auto_continue: bool = false
var continue_delay: float = 3.0
var auto_timer: Timer = null

func _ready():
	# Connect button signal
	if continue_button:
		continue_button.pressed.connect(_on_continue_pressed)

	# Hide initially
	visible = false

	# Create auto-continue timer
	auto_timer = Timer.new()
	auto_timer.one_shot = true
	auto_timer.timeout.connect(_on_auto_continue_timeout)
	add_child(auto_timer)

## Display a narrative event
func show_event(event: NarrativeEvent):
	if not event:
		return

	# Set content
	title_label.text = event.event_title
	text_label.text = event.text

	# Configure auto-continue
	auto_continue = event.auto_continue
	continue_delay = event.continue_delay

	# Show popup
	visible = true

	# Start auto-continue timer if enabled
	if auto_continue and auto_timer:
		auto_timer.start(continue_delay)

## Display custom text (for dynamic mission briefs)
func show_custom(title: String, text: String, auto_dismiss: bool = false, delay: float = 3.0):
	title_label.text = title
	text_label.text = text
	auto_continue = auto_dismiss
	continue_delay = delay

	visible = true

	if auto_continue and auto_timer:
		auto_timer.start(continue_delay)

## Handle continue button press
func _on_continue_pressed():
	# Stop auto-timer if running
	if auto_timer and not auto_timer.is_stopped():
		auto_timer.stop()

	# Hide popup
	visible = false

	# Emit signal
	continue_pressed.emit()

## Handle auto-continue timeout
func _on_auto_continue_timeout():
	_on_continue_pressed()

## Close popup without signal
func close():
	if auto_timer and not auto_timer.is_stopped():
		auto_timer.stop()
	visible = false
