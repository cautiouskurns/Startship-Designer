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

## Resize to match parent tile (called after adding to tree)
func resize_to_tile():
	# Get parent (GridTile) size and subtract margin
	if get_parent() and get_parent() is GridTile:
		var tile_size = get_parent().size
		var room_size = tile_size - Vector2(1, 1)  # 0.5px margin on each side for barely visible gap
		custom_minimum_size = room_size
		size = room_size

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
