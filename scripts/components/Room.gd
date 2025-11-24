extends Control
class_name Room

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

## Update visual based on power state (for Phase 3)
func _update_powered_visual():
	if is_powered:
		modulate.a = 1.0  # Full opacity
	else:
		modulate.a = 0.5  # 50% opacity when unpowered

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
