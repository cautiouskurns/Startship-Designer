extends Control
class_name TimelineBar

## Interactive timeline bar for battle replay scrubbing (Feature 2)
## Allows clicking/dragging to jump to any turn in the battle

## Signals
signal turn_changed(turn: int)

## Properties
var total_turns: int = 0
var current_turn: int = 0
var is_dragging: bool = false

## Child nodes
var background: ColorRect
var progress_fill: ColorRect
var playhead: Panel
var turn_labels_container: HBoxContainer

## Constants
const BAR_WIDTH: float = 1160.0  # Fits 1280px screen with margins
const BAR_HEIGHT: float = 50.0
const PLAYHEAD_WIDTH: float = 4.0
const PLAYHEAD_COLOR: Color = Color(1.0, 0.867, 0.0, 1.0)  # Yellow #FFDD00
const BG_COLOR: Color = Color(0.172, 0.172, 0.172, 1.0)  # Dark gray #2C2C2C
const FILL_COLOR: Color = Color(0.298, 0.298, 0.298, 1.0)  # Light gray #4C4C4C

func _ready():
	# Set control size
	custom_minimum_size = Vector2(BAR_WIDTH, BAR_HEIGHT)
	size = Vector2(BAR_WIDTH, BAR_HEIGHT)

	# Create background
	background = ColorRect.new()
	background.color = BG_COLOR
	background.size = Vector2(BAR_WIDTH, BAR_HEIGHT)
	background.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(background)

	# Create progress fill
	progress_fill = ColorRect.new()
	progress_fill.color = FILL_COLOR
	progress_fill.size = Vector2(0, BAR_HEIGHT)
	progress_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(progress_fill)

	# Create playhead
	playhead = Panel.new()
	playhead.custom_minimum_size = Vector2(PLAYHEAD_WIDTH, BAR_HEIGHT)
	playhead.size = Vector2(PLAYHEAD_WIDTH, BAR_HEIGHT)
	var style = StyleBoxFlat.new()
	style.bg_color = PLAYHEAD_COLOR
	playhead.add_theme_stylebox_override("panel", style)
	playhead.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(playhead)

	# Create turn labels container
	turn_labels_container = HBoxContainer.new()
	turn_labels_container.position = Vector2(0, BAR_HEIGHT + 5)
	turn_labels_container.size = Vector2(BAR_WIDTH, 20)
	turn_labels_container.alignment = BoxContainer.ALIGNMENT_BEGIN
	turn_labels_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(turn_labels_container)

	print("DEBUG TimelineBar: Ready - bar size: ", BAR_WIDTH, "x", BAR_HEIGHT)

## Initialize timeline with total turns
func set_total_turns(turns: int):
	total_turns = turns
	current_turn = 0
	_update_playhead_position()
	_create_turn_labels()
	print("DEBUG TimelineBar: Set total_turns to ", turns)

## Set current turn and update playhead
func set_current_turn(turn: int):
	current_turn = clamp(turn, 0, total_turns - 1)
	_update_playhead_position()
	_update_progress_fill()
	print("DEBUG TimelineBar: Set current_turn to ", current_turn)

## Handle mouse input for clicking and dragging
func _gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Start dragging or jump to click position
				is_dragging = true
				_handle_mouse_position(event.position.x)
			else:
				# Stop dragging, emit final turn_changed
				is_dragging = false
				emit_signal("turn_changed", current_turn)
				print("DEBUG TimelineBar: Mouse released - final turn: ", current_turn)

	elif event is InputEventMouseMotion:
		if is_dragging:
			# Update playhead position while dragging
			_handle_mouse_position(event.position.x)

## Handle mouse position to update turn
func _handle_mouse_position(mouse_x: float):
	# Clamp mouse position to bar bounds
	mouse_x = clamp(mouse_x, 0, BAR_WIDTH)

	# Calculate turn from position
	var turn = _calculate_turn_from_position(mouse_x)

	# Update if turn changed
	if turn != current_turn:
		current_turn = turn
		_update_playhead_position()
		_update_progress_fill()
		# Only emit while dragging for continuous updates (ship display updates on release)
		print("DEBUG TimelineBar: Scrubbing to turn ", current_turn)

## Calculate turn number from pixel X position
func _calculate_turn_from_position(x: float) -> int:
	if total_turns <= 0:
		return 0

	# Convert position to turn (0-indexed)
	var turn_float = (x / BAR_WIDTH) * total_turns
	var turn = int(turn_float)

	# Clamp to valid range
	return clamp(turn, 0, total_turns - 1)

## Calculate pixel X position from turn number
func _calculate_position_from_turn(turn: int) -> float:
	if total_turns <= 0:
		return 0.0

	# Convert turn to position
	return (float(turn) / float(total_turns)) * BAR_WIDTH

## Update playhead visual position
func _update_playhead_position():
	var x_pos = _calculate_position_from_turn(current_turn)
	playhead.position.x = x_pos - (PLAYHEAD_WIDTH / 2.0)  # Center playhead on position

## Update progress fill width
func _update_progress_fill():
	var x_pos = _calculate_position_from_turn(current_turn)
	progress_fill.size.x = x_pos

## Create turn labels below timeline bar
func _create_turn_labels():
	# Clear existing labels
	for child in turn_labels_container.get_children():
		child.queue_free()

	if total_turns <= 0:
		return

	# Show labels at regular intervals (every 5 turns, plus first and last)
	var label_interval = 5
	var labels_to_show = []

	# Always show Turn 1
	labels_to_show.append(0)

	# Show every 5th turn
	for i in range(1, total_turns):
		if (i + 1) % label_interval == 0:
			labels_to_show.append(i)

	# Always show last turn
	if total_turns - 1 not in labels_to_show:
		labels_to_show.append(total_turns - 1)

	# Create labels
	for turn_index in labels_to_show:
		var label = Label.new()
		label.text = "Turn %d" % (turn_index + 1)  # Display as 1-indexed
		label.add_theme_font_size_override("font_size", 12)
		label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8, 1.0))

		# Position label at appropriate X coordinate
		var x_pos = _calculate_position_from_turn(turn_index)
		label.position.x = x_pos - 30  # Center label (approximate)

		turn_labels_container.add_child(label)

	print("DEBUG TimelineBar: Created ", labels_to_show.size(), " turn labels")
