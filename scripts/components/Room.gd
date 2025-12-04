extends Control
class_name Room

## Signals for relay coverage hover (Feature 1.3)
signal relay_hovered(room: Room)
signal relay_unhovered(room: Room)

## Room type from RoomData enum
@export var room_type: RoomData.RoomType = RoomData.RoomType.EMPTY

## Power status (true = powered, false = unpowered/inactive)
var is_powered: bool = true

## Cost in budget points
var cost: int:
	get:
		return RoomData.get_cost(room_type)

## Array of GridTiles this room occupies (Phase 7.1 - multi-tile rooms)
var occupied_tiles: Array[GridTile] = []

## Array of tile positions for combat rendering (Vector2i positions, not GridTile instances)
var combat_tile_positions: Array = []

## Tile size for combat rendering (set when used in combat)
var combat_tile_size: Vector2 = Vector2(96, 96)

## Unique room instance ID for tracking in combat (Phase 7.1)
var room_id: int = 0

## Pulse animation tween for powered relays (Feature 2.4)
var pulse_tween: Tween = null

func _ready():
	# Size dynamically based on parent tile size (tile minus margin)
	# This ensures rooms scale with TILE_SIZE constant changes
	# Will be resized after being added to tree

	# Position is set by parent (GridTile in designer, ShipDisplay in combat)
	# Don't override it here

	# Ignore mouse input so clicks pass through to GridTile
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Also set all children to ignore mouse
	for child in get_children():
		if child is Control:
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Feature 1.3: Connect hover signals for RELAY rooms
	if room_type == RoomData.RoomType.RELAY:
		mouse_entered.connect(_on_relay_mouse_entered)
		mouse_exited.connect(_on_relay_mouse_exited)

	# Update ID label with room type abbreviation
	_update_id_label()

## Resize to match parent tile (called after adding to tree)
func resize_to_tile():
	# Get parent (GridTile) size and subtract margin
	if get_parent() and get_parent() is GridTile:
		var tile_size = get_parent().size
		var room_size = tile_size - Vector2(1, 1)  # 0.5px margin on each side for barely visible gap
		custom_minimum_size = room_size
		size = room_size

		# Resize background outline to cover entire multi-tile component
		_resize_background_outline()

		# Position icon in the center of the multi-tile room
		_position_icon()

## Resize background outline to encompass entire multi-tile component
func _resize_background_outline():
	# Get Background panel node if it exists
	var background = get_node_or_null("Background")
	if not background:
		return

	# Make sure background doesn't block mouse input
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Combat context: Use combat_tile_positions if available
	if not combat_tile_positions.is_empty():
		_resize_background_combat()
		return

	# Designer context: Get parent tile for size calculations
	if not get_parent() or not get_parent() is GridTile:
		# Default single tile sizing
		background.position = Vector2.ZERO
		background.size = size
		background.visible = true
		return

	var parent_tile = get_parent() as GridTile
	var tile_size = parent_tile.size

	# Check if this is a multi-tile room
	if occupied_tiles.size() <= 1:
		# Single tile room - show background at tile size
		background.position = Vector2.ZERO
		background.size = tile_size  # No margin - fill entire tile
		background.visible = true
		return

	# Multi-tile room - only show background on anchor tile
	var is_anchor = (occupied_tiles[0] == parent_tile)

	# Hide background on non-anchor tiles
	if not is_anchor:
		background.visible = false
		return

	# Anchor tile - show and size background to cover all tiles
	background.visible = true

	# Calculate bounding box of all tiles
	var min_x = 999999
	var max_x = -999999
	var min_y = 999999
	var max_y = -999999

	for tile in occupied_tiles:
		if tile.grid_x < min_x:
			min_x = tile.grid_x
		if tile.grid_x > max_x:
			max_x = tile.grid_x
		if tile.grid_y < min_y:
			min_y = tile.grid_y
		if tile.grid_y > max_y:
			max_y = tile.grid_y

	# Calculate room dimensions in tiles
	var room_width_tiles = max_x - min_x + 1
	var room_height_tiles = max_y - min_y + 1

	# Calculate total size in pixels (no margin - fill completely)
	var total_width = room_width_tiles * tile_size.x
	var total_height = room_height_tiles * tile_size.y

	# Position background at top-left
	background.position = Vector2.ZERO

	# Resize background to cover all tiles without gaps
	background.size = Vector2(total_width, total_height)

## Resize background outline for combat rendering (uses combat_tile_positions)
func _resize_background_combat():
	var background = get_node_or_null("Background")
	if not background:
		return

	background.visible = true

	# Single tile room
	if combat_tile_positions.size() <= 1:
		background.position = Vector2.ZERO
		background.size = combat_tile_size
		return

	# Multi-tile room - calculate bounding box from positions
	var min_x = 999999
	var max_x = -999999
	var min_y = 999999
	var max_y = -999999

	for tile_pos in combat_tile_positions:
		if tile_pos.x < min_x:
			min_x = tile_pos.x
		if tile_pos.x > max_x:
			max_x = tile_pos.x
		if tile_pos.y < min_y:
			min_y = tile_pos.y
		if tile_pos.y > max_y:
			max_y = tile_pos.y

	# Calculate room dimensions in tiles
	var room_width_tiles = max_x - min_x + 1
	var room_height_tiles = max_y - min_y + 1

	# Calculate total size in pixels
	var total_width = room_width_tiles * combat_tile_size.x
	var total_height = room_height_tiles * combat_tile_size.y

	# Position background at top-left
	background.position = Vector2.ZERO

	# Resize background to cover all tiles
	background.size = Vector2(total_width, total_height)

## Update ID label text with room type abbreviation (technical schematic styling)
func _update_id_label():
	# Get IDLabel node if it exists
	var id_label = get_node_or_null("IDLabel")
	if not id_label:
		return

	# Get room type abbreviation
	var abbreviation = ""
	match room_type:
		RoomData.RoomType.BRIDGE:
			abbreviation = "BRI"
		RoomData.RoomType.WEAPON:
			abbreviation = "WEA"
		RoomData.RoomType.SHIELD:
			abbreviation = "SHI"
		RoomData.RoomType.ENGINE:
			abbreviation = "ENG"
		RoomData.RoomType.REACTOR:
			abbreviation = "REA"
		RoomData.RoomType.ARMOR:
			abbreviation = "ARM"
		RoomData.RoomType.CONDUIT:
			abbreviation = "CON"
		RoomData.RoomType.RELAY:
			abbreviation = "REL"
		_:
			abbreviation = "???"

	# Format as ABBR (e.g., WEA, SHI, etc.)
	id_label.text = "%s" % abbreviation

## Position icon centered across multi-tile room (only visible on anchor tile)
func _position_icon():
	# Get Icon node if it exists
	var icon_node = get_node_or_null("Icon")
	if not icon_node:
		return

	# Only show icon on anchor tile (first tile of multi-tile rooms)
	if not get_parent() or not get_parent() is GridTile:
		return

	var parent_tile = get_parent() as GridTile
	var is_anchor = (occupied_tiles.size() > 0 and occupied_tiles[0] == parent_tile)

	# Hide icon on non-anchor tiles
	if not is_anchor:
		icon_node.visible = false
		return

	icon_node.visible = true

	# Get tile size for calculations
	var tile_size = parent_tile.size
	var icon_size = icon_node.size

	# Calculate the center of the multi-tile room
	if occupied_tiles.size() <= 1:
		# Single tile room - center icon within the tile
		# Icon is 32x32, tile is typically 64x64, so offset by (tile_size - icon_size) / 2
		icon_node.position = (tile_size - icon_size) * 0.5
		return

	# Calculate bounding box of all tiles
	var min_x = 999999
	var max_x = -999999
	var min_y = 999999
	var max_y = -999999

	for tile in occupied_tiles:
		if tile.grid_x < min_x:
			min_x = tile.grid_x
		if tile.grid_x > max_x:
			max_x = tile.grid_x
		if tile.grid_y < min_y:
			min_y = tile.grid_y
		if tile.grid_y > max_y:
			max_y = tile.grid_y

	# Calculate room dimensions in tiles
	var room_width_tiles = max_x - min_x + 1
	var room_height_tiles = max_y - min_y + 1

	# Calculate the center of the entire multi-tile room in pixels
	# relative to the anchor tile's top-left corner
	var room_center_x = (room_width_tiles * tile_size.x) * 0.5
	var room_center_y = (room_height_tiles * tile_size.y) * 0.5

	# Position the icon so its center aligns with the room's center
	# Icon is top-left anchored, so subtract half icon size to center it
	icon_node.position = Vector2(room_center_x, room_center_y) - (icon_size * 0.5)

	# Debug output
	print("Room type: ", RoomData.get_label(room_type), " | Tiles: ", room_width_tiles, "x", room_height_tiles, " | Tile size: ", tile_size, " | Room center: ", Vector2(room_center_x, room_center_y), " | Icon pos: ", icon_node.position)

## Set powered state and update visual
func set_powered(powered: bool):
	is_powered = powered
	_update_powered_visual()

## Update visual based on power state (Feature 2.4 - relay-specific visuals)
func _update_powered_visual():
	# Feature 2.4: Special visuals for RELAY rooms
	if room_type == RoomData.RoomType.RELAY:
		print("Feature 2.4 DEBUG: Relay room_id=", room_id, " updating visual, is_powered=", is_powered)
		if is_powered:
			# Powered relay: Full brightness + pulse animation
			modulate = Color(1, 1, 1, 1)
			print("  Starting pulse animation")
			_start_pulse_animation()
		else:
			# Unpowered relay: Dim gray + no animation
			modulate = Color(0.4, 0.4, 0.4, 1)
			print("  Stopping pulse animation (unpowered)")
			_stop_pulse_animation()
	else:
		# Standard power visual for other rooms
		if is_powered:
			# Powered: Full brightness (bright color)
			modulate = Color(1, 1, 1, 1)
		else:
			# Unpowered: Dimmed (50% opacity)
			modulate = Color(1, 1, 1, 0.5)

## Start pulse animation for powered relays (Feature 2.4)
func _start_pulse_animation():
	# Stop existing animation if any
	_stop_pulse_animation()

	# Create looping scale pulse: 1.0 → 1.05 → 1.0 over 1 second
	pulse_tween = create_tween()
	pulse_tween.set_loops()  # Loop forever
	pulse_tween.tween_property(self, "scale", Vector2(1.05, 1.05), 0.5)
	pulse_tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.5)

## Stop pulse animation for relays (Feature 2.4)
func _stop_pulse_animation():
	if pulse_tween:
		pulse_tween.kill()
		pulse_tween = null
	# Reset scale to normal
	scale = Vector2(1.0, 1.0)

## Add a tile to this room's occupation list (Phase 7.1)
func add_occupied_tile(tile: GridTile):
	if not tile in occupied_tiles:
		occupied_tiles.append(tile)
	# Update background outline and icon position after adding tile
	call_deferred("_resize_background_outline")
	call_deferred("_position_icon")

## Get all tiles occupied by this room (Phase 7.1)
func get_occupied_tiles() -> Array[GridTile]:
	return occupied_tiles

## Get the anchor tile (first tile where room was placed) (Phase 7.1)
func get_anchor_tile() -> GridTile:
	if occupied_tiles.size() > 0:
		return occupied_tiles[0]
	return null

## Handle relay mouse enter (Feature 1.3)
func _on_relay_mouse_entered():
	emit_signal("relay_hovered", self)

## Handle relay mouse exit (Feature 1.3)
func _on_relay_mouse_exited():
	emit_signal("relay_unhovered", self)

## Apply combat-specific visual enhancements (thicker borders, larger icons, legible ID pips)
func _apply_combat_styling():
	# Get nodes
	var background = get_node_or_null("Background")
	var icon = get_node_or_null("Icon")
	var id_background = get_node_or_null("IDBackground")
	var id_label = get_node_or_null("IDLabel")

	# Apply thicker borders (2px → 4px)
	if background:
		var panel_style = background.get_theme_stylebox("panel")
		if panel_style is StyleBoxFlat:
			var combat_style = panel_style.duplicate()
			combat_style.border_width_left = 10
			combat_style.border_width_top = 10
			combat_style.border_width_right = 10
			combat_style.border_width_bottom = 10
			background.add_theme_stylebox_override("panel", combat_style)

	# Apply larger icon size (32x32 → 48x48, font 24pt → 36pt, Armor: 16pt → 32pt)
	if icon:
		icon.set_size(Vector2(96, 96))
		icon.custom_minimum_size = Vector2(48, 48)
		var font_size = 36
		if room_type == RoomData.RoomType.ARMOR:
			font_size = 32  # Armor icon uses different size
		icon.add_theme_font_size_override("font_size", font_size)

	# Reposition ID pips inside borders (offset_left: -22 → -25, offset_top: 2 → 5, etc.)
	if id_background:
		id_background.offset_left = -25.0
		id_background.offset_top = 5.0
		id_background.offset_right = -6.0
		id_background.offset_bottom = 15.0

	if id_label:
		id_label.offset_left = -25.0
		id_label.offset_top = 5.0
		id_label.offset_right = -6.0
		id_label.offset_bottom = 15.0
		# Larger font size for legibility (8pt → 10pt)
		id_label.add_theme_font_size_override("font_size", 10)

## Position icon centered in combat (for multi-tile rooms)
func _position_icon_combat():
	var icon = get_node_or_null("Icon")
	if not icon:
		return

	icon.visible = true

	# Single tile room - center icon within the tile
	if combat_tile_positions.size() <= 1:
		var icon_size = icon.size
		icon.position = (combat_tile_size - icon_size) * 0.5
		return

	# Multi-tile room - calculate center of entire room
	var min_x = 999999
	var max_x = -999999
	var min_y = 999999
	var max_y = -999999

	for tile_pos in combat_tile_positions:
		if tile_pos.x < min_x:
			min_x = tile_pos.x
		if tile_pos.x > max_x:
			max_x = tile_pos.x
		if tile_pos.y < min_y:
			min_y = tile_pos.y
		if tile_pos.y > max_y:
			max_y = tile_pos.y

	# Calculate room dimensions in tiles
	var room_width_tiles = max_x - min_x + 1
	var room_height_tiles = max_y - min_y + 1

	# Calculate the center of the entire multi-tile room in pixels
	var room_center_x = (room_width_tiles * combat_tile_size.x) * 0.5
	var room_center_y = (room_height_tiles * combat_tile_size.y) * 0.5

	# Position the icon so its center aligns with the room's center
	var icon_size = icon.size
	icon.position = Vector2(room_center_x, room_center_y) - (icon_size * 0.5)

## Set room data for combat display rendering (used by ShipDisplay)
func set_room_data(type: RoomData.RoomType, tiles: Array, tile_size: Vector2 = Vector2(96, 96)):
	room_type = type
	combat_tile_positions = tiles.duplicate()  # Store tile positions as Vector2i
	combat_tile_size = tile_size

	# Apply combat-specific visual enhancements
	_apply_combat_styling()

	# Update visuals for combat context
	_resize_background_outline()  # Update outline for multi-tile shape
	_update_id_label()  # Update ID text
	_position_icon_combat()  # Center icon in combat
