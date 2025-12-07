extends ColorRect
class_name TutorialPopup

## Individual tutorial popup overlay component
## Shows step-by-step instructions with arrows pointing to UI elements

signal skip_requested
signal acknowledged
signal continue_pressed

## No longer using arrow directions - keeping for compatibility
enum ArrowDirection {
	UP,
	DOWN,
	LEFT,
	RIGHT,
	NONE
}

## UI References
@onready var panel: Panel = $Panel
@onready var title_label: Label = $Panel/VBoxContainer/TitleLabel
@onready var message_label: Label = $Panel/VBoxContainer/MessageLabel
@onready var continue_button: Button = $Panel/VBoxContainer/ContinueButton
@onready var skip_button: Button = $SkipButton
@onready var arrow_container: Node2D = $ArrowContainer

## Step data
var step_number: int = 0
var title_text: String = ""
var message_text: String = ""
var arrow_target: Node = null
var arrow_direction: ArrowDirection = ArrowDirection.NONE
var wait_for_event: String = ""

## Highlight box visual nodes
var highlight_box: ColorRect = null
var pulse_tween: Tween = null

func _ready():
	# Initially invisible
	modulate.a = 0.0

	# Connect button signals
	continue_button.pressed.connect(_on_continue_pressed)
	skip_button.pressed.connect(_on_skip_pressed)

## Setup popup with step data (target can be Control or Node2D)
func setup(step: int, title: String, message: String, target: Node = null, direction: ArrowDirection = ArrowDirection.NONE, wait_event: String = ""):
	step_number = step
	title_text = title
	message_text = message
	arrow_target = target
	arrow_direction = direction
	wait_for_event = wait_event

	# Update labels
	title_label.text = "STEP %d: %s" % [step_number, title_text]
	message_label.text = message_text

	# Show continue button for simple acknowledgment steps
	continue_button.visible = (wait_event == "popup_acknowledged")

## Show popup with fade-in animation
func show_popup():
	visible = true

	# Position popup intelligently to avoid blocking the target
	_position_popup_away_from_target()

	# Fade in
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.3)

	# Wait a frame for layout, then draw highlight box
	await get_tree().process_frame
	if arrow_target:
		draw_highlight_box()

## Hide popup with fade-out animation
func hide_popup():
	# Clear highlight box
	clear_highlight_box()

	# Fade out
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	await tween.finished
	visible = false

## Draw highlight box around target UI element
func draw_highlight_box():
	# Clear existing highlight
	clear_highlight_box()

	if not arrow_target:
		return

	# Get target rect (handle both Control and Node2D)
	var target_rect: Rect2
	if arrow_target is Control:
		target_rect = arrow_target.get_global_rect()
	elif arrow_target is Node2D:
		# For Node2D (like ShipGrid), get visual bounds
		var pos = arrow_target.global_position
		# Estimate bounds - for ShipGrid we want a larger area
		var size = Vector2(600, 400)  # Approximate ship grid size
		target_rect = Rect2(pos.x - size.x / 2, pos.y - size.y / 2, size.x, size.y)
	else:
		return  # Unknown type, can't draw highlight

	# Create highlight box as ColorRect with transparent fill and thick border
	highlight_box = ColorRect.new()
	highlight_box.color = Color(0.290, 0.886, 0.886, 0.0)  # Transparent fill

	# CRITICAL: Make highlight box non-interactive so clicks pass through
	highlight_box.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Position and size to match target (global coordinates)
	highlight_box.position = target_rect.position
	highlight_box.size = target_rect.size

	# Add a thick glowing border using a shader or StyleBox
	# For now, use a simple border with ColorRect children
	var border_width = 4
	var border_color = Color(0.290, 0.886, 0.886, 1.0)  # Cyan

	# Create 4 border rects (top, right, bottom, left)
	var top_border = ColorRect.new()
	top_border.color = border_color
	top_border.position = Vector2(0, 0)
	top_border.size = Vector2(target_rect.size.x, border_width)
	top_border.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Non-interactive
	highlight_box.add_child(top_border)

	var right_border = ColorRect.new()
	right_border.color = border_color
	right_border.position = Vector2(target_rect.size.x - border_width, 0)
	right_border.size = Vector2(border_width, target_rect.size.y)
	right_border.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Non-interactive
	highlight_box.add_child(right_border)

	var bottom_border = ColorRect.new()
	bottom_border.color = border_color
	bottom_border.position = Vector2(0, target_rect.size.y - border_width)
	bottom_border.size = Vector2(target_rect.size.x, border_width)
	bottom_border.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Non-interactive
	highlight_box.add_child(bottom_border)

	var left_border = ColorRect.new()
	left_border.color = border_color
	left_border.position = Vector2(0, 0)
	left_border.size = Vector2(border_width, target_rect.size.y)
	left_border.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Non-interactive
	highlight_box.add_child(left_border)

	# Add to root (so it appears on top of everything)
	get_tree().root.add_child(highlight_box)

	# Set z_index high to appear above other UI
	highlight_box.z_index = 999

	# Start pulsing animation
	_start_pulse_animation()

## Clear highlight box visuals
func clear_highlight_box():
	if pulse_tween:
		pulse_tween.kill()
		pulse_tween = null

	if highlight_box:
		highlight_box.queue_free()
		highlight_box = null

## Start pulsing animation for highlight box
func _start_pulse_animation():
	if not highlight_box:
		return

	pulse_tween = create_tween()
	pulse_tween.set_loops()

	# Pulse opacity of borders
	pulse_tween.tween_property(highlight_box, "modulate:a", 1.0, 0.5)
	pulse_tween.tween_property(highlight_box, "modulate:a", 0.6, 0.5)

## Handle continue button press
func _on_continue_pressed():
	continue_pressed.emit()
	acknowledged.emit()

## Handle skip button press
func _on_skip_pressed():
	skip_requested.emit()

## Check if this step's wait condition is met
func check_completion(event: String) -> bool:
	return wait_for_event == event

## Position popup intelligently to avoid blocking the target
func _position_popup_away_from_target():
	# Default to top-right corner if no target
	if not arrow_target:
		panel.position = Vector2(50, 50)
		return

	# Get screen size
	var screen_size = get_viewport().get_visible_rect().size

	# Get target rect
	var target_rect: Rect2
	if arrow_target is Control:
		target_rect = arrow_target.get_global_rect()
	elif arrow_target is Node2D:
		var pos = arrow_target.global_position
		var size = Vector2(600, 400)
		target_rect = Rect2(pos.x - size.x / 2, pos.y - size.y / 2, size.x, size.y)
	else:
		panel.position = Vector2(50, 50)
		return

	# Get target center
	var target_center = target_rect.position + target_rect.size / 2

	# Determine which quadrant the target is in
	var target_in_left_half = target_center.x < screen_size.x / 2
	var target_in_top_half = target_center.y < screen_size.y / 2

	# Position popup in opposite quadrant to avoid blocking
	var popup_pos = Vector2()

	if target_in_left_half and target_in_top_half:
		# Target in top-left, put popup in bottom-right
		popup_pos = Vector2(screen_size.x - panel.size.x - 50, screen_size.y - panel.size.y - 50)
	elif target_in_left_half and not target_in_top_half:
		# Target in bottom-left, put popup in top-right
		popup_pos = Vector2(screen_size.x - panel.size.x - 50, 50)
	elif not target_in_left_half and target_in_top_half:
		# Target in top-right, put popup in bottom-left
		popup_pos = Vector2(50, screen_size.y - panel.size.y - 50)
	else:
		# Target in bottom-right, put popup in top-left
		popup_pos = Vector2(50, 50)

	# Apply position
	panel.position = popup_pos
