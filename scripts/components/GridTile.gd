extends Panel
class_name GridTile

## Signals for tile interaction
signal tile_clicked(x: int, y: int)
signal tile_right_clicked(x: int, y: int)
signal tile_hovered(tile: GridTile)
signal tile_unhovered(tile: GridTile)

## Grid position coordinates
@export var grid_x: int = 0
@export var grid_y: int = 0

## Reference to room occupying this tile (Phase 7.1 - doesn't own, just references)
var occupying_room: Room = null

## Is this the anchor tile (where room was originally placed)?
## Only anchor tile owns the Room visual node as a child
var is_anchor: bool = false

## Style and visual elements
var style_box: StyleBoxFlat
@onready var flash_overlay: ColorRect = $FlashOverlay

## Room background (shows room color on this tile) - Phase 7.1 shaped rooms
var room_background: ColorRect = null

## Power state overlay (shown when room is unpowered)
var unpowered_overlay: ColorRect = null

## Preview overlay (shown for invalid placement feedback)
var preview_overlay: ColorRect = null

## Hover tracking
var is_hovering: bool = false

func _ready():
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
	# Change cursor to pointing hand
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	# Emit hover signal
	emit_signal("tile_hovered", self)

## Handle mouse leaving tile
func _on_mouse_exited():
	is_hovering = false
	# Restore cursor to arrow
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	# Emit unhover signal
	emit_signal("tile_unhovered", self)

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

## Set occupying room reference (Phase 7.1 - for multi-tile rooms)
## If anchor=true, this tile owns the visual (Room node becomes child)
func set_occupying_room(room: Room, anchor: bool = false) -> void:
	occupying_room = room
	is_anchor = anchor

	# Create room background ColorRect showing room color (for all tiles, not just anchor)
	# This makes T-shapes and complex shapes display correctly
	if not room_background:
		room_background = ColorRect.new()
		var bg_size = size - Vector2(4, 4)  # 2px margin on each side
		room_background.size = bg_size
		room_background.position = Vector2(2, 2)
		room_background.z_index = 0  # Behind Room node and flash overlay
		room_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
		room_background.color = RoomData.get_color(room.room_type)
		add_child(room_background)

	if anchor:
		# Only anchor tile owns the Room visual as a child (for label/icon)
		add_child(room)

		# Center room in tile (don't scale, just show label on anchor)
		room.position = Vector2(2, 2)
		room.z_index = 1  # Draw on top of background
		room.visible = true
		room.modulate = Color(1, 1, 1, 1)
		room.mouse_filter = Control.MOUSE_FILTER_IGNORE

## Clear occupying room reference (Phase 7.1)
## Note: Room instance is freed by ShipDesigner, not here
func clear_occupying_room() -> void:
	if is_anchor and occupying_room:
		# Remove Room node from tree (but don't free it yet)
		if occupying_room.get_parent() == self:
			remove_child(occupying_room)

	occupying_room = null
	is_anchor = false

	# Clear room background if it exists
	if room_background:
		remove_child(room_background)
		room_background.queue_free()
		room_background = null

	# Also clear unpowered overlay if it exists
	if unpowered_overlay:
		remove_child(unpowered_overlay)
		unpowered_overlay.queue_free()
		unpowered_overlay = null

## Get the room type of occupying room (returns EMPTY if no room)
func get_room_type() -> RoomData.RoomType:
	if occupying_room:
		return occupying_room.room_type
	return RoomData.RoomType.EMPTY

## Check if this tile is occupied by a room (Phase 7.1)
func is_occupied() -> bool:
	return occupying_room != null

## Set the powered state of the room visually
func set_powered_state(powered: bool):
	# If no room, nothing to do
	if not occupying_room:
		return

	if powered:
		# Powered: full opacity room background, full opacity Room node (if anchor)
		if room_background:
			room_background.modulate = Color(1, 1, 1, 1)

		if is_anchor and occupying_room:
			occupying_room.modulate = Color(1, 1, 1, 1)

		# Remove unpowered overlay if it exists
		if unpowered_overlay:
			remove_child(unpowered_overlay)
			unpowered_overlay.queue_free()
			unpowered_overlay = null
	else:
		# Unpowered: dim background and Room node + gray overlay
		if room_background:
			room_background.modulate = Color(1, 1, 1, 0.5)

		if is_anchor and occupying_room:
			occupying_room.modulate = Color(1, 1, 1, 0.5)

		# Create gray overlay if it doesn't exist
		if not unpowered_overlay:
			unpowered_overlay = ColorRect.new()
			unpowered_overlay.color = Color(0.3, 0.3, 0.3, 0.3)  # Dark gray, semi-transparent
			var overlay_size = size - Vector2(4, 4)  # 2px margin on each side
			unpowered_overlay.size = overlay_size
			unpowered_overlay.position = Vector2(2, 2)
			unpowered_overlay.z_index = 2  # Above room background and Room node, below flash
			unpowered_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
			add_child(unpowered_overlay)

## Show valid placement preview (cyan border)
func show_valid_preview():
	# Set border to cyan with 2px width
	style_box.border_color = Color(0.290, 0.886, 0.886)  # Cyan
	style_box.border_width_left = 2
	style_box.border_width_top = 2
	style_box.border_width_right = 2
	style_box.border_width_bottom = 2

## Show invalid placement preview (red border + overlay)
func show_invalid_preview():
	# Set border to red with 2px width
	style_box.border_color = Color(0.886, 0.290, 0.290)  # Red
	style_box.border_width_left = 2
	style_box.border_width_top = 2
	style_box.border_width_right = 2
	style_box.border_width_bottom = 2

	# Create red overlay if it doesn't exist
	if not preview_overlay:
		preview_overlay = ColorRect.new()
		preview_overlay.color = Color(0.886, 0.290, 0.290, 0.5)  # Red, 50% opacity
		var overlay_size = size - Vector2(4, 4)  # 2px margin on each side
		preview_overlay.size = overlay_size
		preview_overlay.position = Vector2(2, 2)
		preview_overlay.z_index = 2  # Above room but below flash
		preview_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(preview_overlay)

## Clear preview (restore default border)
func clear_preview():
	# Restore border to default (right and bottom only for grid pattern)
	style_box.border_color = Color(1, 1, 1)  # White
	style_box.border_width_left = 0
	style_box.border_width_top = 0
	style_box.border_width_right = 1
	style_box.border_width_bottom = 1

	# Remove preview overlay if it exists
	if preview_overlay:
		remove_child(preview_overlay)
		preview_overlay.queue_free()
		preview_overlay = null
