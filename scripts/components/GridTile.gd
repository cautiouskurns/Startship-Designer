extends Panel
class_name GridTile

## Grid position coordinates
@export var grid_x: int = 0
@export var grid_y: int = 0

## Current room placed in this tile (null if empty)
var current_room: Node = null

func _ready():
	# Set fixed size
	custom_minimum_size = Vector2(64, 64)
	size = Vector2(64, 64)

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
