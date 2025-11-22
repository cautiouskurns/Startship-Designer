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
	var tween = create_tween()
	# Flash: 0 → 0.5 alpha → 0 alpha over 0.1 seconds
	tween.tween_property(flash_overlay, "color:a", 0.5, 0.05)
	tween.tween_property(flash_overlay, "color:a", 0.0, 0.05)

## Set a room in this tile
func set_room(room: Node) -> void:
	# Clear existing room if any
	clear_room()

	# Add new room
	current_room = room
	add_child(room)

	# Center room in tile (2px margin on all sides for 60x60 room in 64x64 tile)
	if room is Control:
		room.position = Vector2(2, 2)

## Clear the current room from this tile
func clear_room() -> void:
	if current_room:
		remove_child(current_room)
		current_room.queue_free()
		current_room = null

## Get the room type of current room (returns EMPTY if no room)
func get_room_type() -> RoomData.RoomType:
	if current_room and current_room is Room:
		return current_room.room_type
	return RoomData.RoomType.EMPTY
