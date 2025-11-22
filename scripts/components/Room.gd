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

func _ready():
	# Set fixed size (60x60 with 4px margin from 64x64 tile)
	custom_minimum_size = Vector2(60, 60)
	size = Vector2(60, 60)

	# Center in tile (2px offset from each edge for 4px total margin)
	position = Vector2(2, 2)

	# Ignore mouse input so clicks pass through to GridTile
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Also set all children to ignore mouse
	for child in get_children():
		if child is Control:
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE

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
