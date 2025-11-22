extends Panel
class_name GridTile

## Signals for tile interaction
signal tile_clicked(x: int, y: int)
signal tile_right_clicked(x: int, y: int)

## Grid position coordinates
@export var grid_x: int = 0
@export var grid_y: int = 0

## Current room placed in this tile (null if empty)
var current_room: Node = null

## Style and visual elements
var style_box: StyleBoxFlat
@onready var flash_overlay: ColorRect = $FlashOverlay

## Power state overlay (shown when room is unpowered)
var unpowered_overlay: ColorRect = null

## Hover tracking
var is_hovering: bool = false

func _ready():
	# Set fixed size
	custom_minimum_size = Vector2(64, 64)
	size = Vector2(64, 64)

	# Get and duplicate StyleBoxFlat so we can modify it
	style_box = get_theme_stylebox("panel").duplicate()
	add_theme_stylebox_override("panel", style_box)

	# Enable mouse input
	mouse_filter = Control.MOUSE_FILTER_STOP

	# Connect mouse signals
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			# Left click
			emit_signal("tile_clicked", grid_x, grid_y)
			_play_flash()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			# Right click
			emit_signal("tile_right_clicked", grid_x, grid_y)
			_play_flash()

## Handle mouse entering tile
func _on_mouse_entered():
	is_hovering = true
	# Change border to cyan
	style_box.border_color = Color(0.290, 0.886, 0.886)  # #4AE2E2 cyan
	# Change cursor to pointing hand
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

## Handle mouse leaving tile
func _on_mouse_exited():
	is_hovering = false
	# Restore border to white
	style_box.border_color = Color(1, 1, 1)  # #FFFFFF white
	# Restore cursor to arrow
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)

## Play flash animation on click
func _play_flash():
	if not flash_overlay:
		return
	flash_overlay.z_index = 10  # Draw on top
	var tween = create_tween()
	# Flash: 0 → 0.5 alpha → 0 alpha over 0.1 seconds
	tween.tween_property(flash_overlay, "color:a", 0.5, 0.05)
	tween.tween_property(flash_overlay, "color:a", 0.0, 0.05)

## Play red flash animation for rejected placement
func _play_flash_red():
	if not flash_overlay:
		return
	# Set color to red for rejection feedback
	flash_overlay.color = Color(0.886, 0.290, 0.290)  # Red #E24A4A
	flash_overlay.z_index = 10
	var tween = create_tween()
	# Red flash: 0 → 0.6 alpha → 0 alpha over 0.3 seconds
	tween.tween_property(flash_overlay, "color:a", 0.6, 0.15)
	tween.tween_property(flash_overlay, "color:a", 0.0, 0.15)
	# Reset to white after animation completes
	tween.tween_callback(func(): flash_overlay.color = Color(1, 1, 1, 0))

## Set a room in this tile
func set_room(room: Node) -> void:
	# Clear existing room if any
	clear_room()

	# Add new room
	current_room = room
	add_child(room)

	# Center room in tile (2px margin on all sides for 60x60 room in 64x64 tile)
	if room is Control:
		# MUST set position AFTER add_child, before or during _ready() it gets overridden
		room.position = Vector2(2, 2)
		room.z_index = 1  # Draw on top of FlashOverlay
		room.visible = true  # Ensure visibility
		room.modulate = Color(1, 1, 1, 1)  # Ensure full opacity
		room.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Let clicks pass through to GridTile

## Clear the current room from this tile
func clear_room() -> void:
	if current_room:
		remove_child(current_room)
		current_room.queue_free()
		current_room = null

	# Also clear unpowered overlay if it exists
	if unpowered_overlay:
		remove_child(unpowered_overlay)
		unpowered_overlay.queue_free()
		unpowered_overlay = null

## Get the room type of current room (returns EMPTY if no room)
func get_room_type() -> RoomData.RoomType:
	if current_room and current_room is Room:
		return current_room.room_type
	return RoomData.RoomType.EMPTY

## Set the powered state of the room visually
func set_powered_state(powered: bool):
	# If no room, nothing to do
	if not current_room:
		return

	if powered:
		# Powered: full opacity, no overlay
		if current_room is Control:
			current_room.modulate = Color(1, 1, 1, 1)

		# Remove unpowered overlay if it exists
		if unpowered_overlay:
			remove_child(unpowered_overlay)
			unpowered_overlay.queue_free()
			unpowered_overlay = null
	else:
		# Unpowered: 50% opacity + gray overlay
		if current_room is Control:
			current_room.modulate = Color(1, 1, 1, 0.5)

		# Create gray overlay if it doesn't exist
		if not unpowered_overlay:
			unpowered_overlay = ColorRect.new()
			unpowered_overlay.color = Color(0.3, 0.3, 0.3, 0.3)  # Dark gray, semi-transparent
			unpowered_overlay.size = Vector2(60, 60)
			unpowered_overlay.position = Vector2(2, 2)
			unpowered_overlay.z_index = 2  # Above room but below flash
			unpowered_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
			add_child(unpowered_overlay)
