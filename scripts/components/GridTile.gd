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
			print("GridTile: Emitting tile_clicked signal for [%d, %d]" % [grid_x, grid_y])
			emit_signal("tile_clicked", grid_x, grid_y)
			_play_flash()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			# Right click
			print("GridTile: Emitting tile_right_clicked signal for [%d, %d]" % [grid_x, grid_y])
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
	print("GridTile: Playing flash animation")
	if not flash_overlay:
		print("ERROR: flash_overlay is null!")
		return
	# Make flash more visible for debugging
	flash_overlay.z_index = 10  # Draw on top
	var tween = create_tween()
	# Flash: 0 → 0.8 alpha → 0 alpha over 0.3 seconds (longer and brighter)
	tween.tween_property(flash_overlay, "color:a", 0.8, 0.15)
	tween.tween_property(flash_overlay, "color:a", 0.0, 0.15)

## Set a room in this tile
func set_room(room: Node) -> void:
	print("GridTile [%d,%d]: set_room called with room: %s" % [grid_x, grid_y, room])
	# Clear existing room if any
	clear_room()

	# Add new room
	current_room = room
	add_child(room)
	print("  Room added as child. Room type: %s" % (room.room_type if room is Room else "NOT A ROOM"))

	# Center room in tile (2px margin on all sides for 60x60 room in 64x64 tile)
	if room is Control:
		room.position = Vector2(2, 2)
		room.z_index = 1  # Draw on top of FlashOverlay
		room.visible = true  # Ensure visibility
		room.modulate = Color(1, 1, 1, 1)  # Ensure full opacity
		room.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Let clicks pass through to GridTile
		print("  Room positioned at (2, 2), z_index=1, visible=true, mouse_filter=IGNORE")
		# Force visual update
		room.queue_redraw()
		queue_redraw()

## Clear the current room from this tile
func clear_room() -> void:
	if current_room:
		print("GridTile [%d,%d]: Clearing room %s" % [grid_x, grid_y, current_room])
		remove_child(current_room)
		current_room.queue_free()
		current_room = null
	else:
		print("GridTile [%d,%d]: clear_room called but no room to clear" % [grid_x, grid_y])

## Get the room type of current room (returns EMPTY if no room)
func get_room_type() -> RoomData.RoomType:
	if current_room and current_room is Room:
		print("GridTile [%d,%d]: get_room_type returning %d" % [grid_x, grid_y, current_room.room_type])
		return current_room.room_type
	print("GridTile [%d,%d]: get_room_type returning EMPTY (current_room=%s)" % [grid_x, grid_y, current_room])
	return RoomData.RoomType.EMPTY
