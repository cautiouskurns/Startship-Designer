extends Node2D
class_name SynergyIndicator

## Visual indicator showing synergy between two adjacent rooms

## The type of synergy this indicator represents
var synergy_type: RoomData.SynergyType = RoomData.SynergyType.NONE

## The two grid tiles creating this synergy
var connected_tiles: Array[GridTile] = []

## Visual sprite (ColorRect placeholder)
var sprite: ColorRect = null

func _ready():
	# Get sprite reference
	sprite = $Sprite2D

	# Set color based on synergy type
	if sprite and synergy_type != RoomData.SynergyType.NONE:
		sprite.color = RoomData.get_synergy_color(synergy_type)

	# Start pulsing animation
	_start_pulse_animation()

	# Fade in
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.2)

## Set up the indicator between two tiles
func setup(tile_a: GridTile, tile_b: GridTile, synergy: RoomData.SynergyType):
	synergy_type = synergy
	connected_tiles = [tile_a, tile_b]

	# Position at midpoint between tile centers (tiles are 64x64, so add 32 to get center)
	var tile_center_offset = Vector2(32, 32)
	var tile_a_center = tile_a.position + tile_center_offset
	var tile_b_center = tile_b.position + tile_center_offset
	position = (tile_a_center + tile_b_center) / 2.0

## Start the pulsing animation
func _start_pulse_animation():
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(self, "scale", Vector2(1.15, 1.15), 0.75)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.75)

## Fade out and remove
func fade_out_and_remove():
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
	tween.tween_callback(queue_free)

## Check if either connected tile has been removed or changed
func is_still_valid() -> bool:
	if connected_tiles.size() != 2:
		return false

	# Check if both tiles still have rooms
	if connected_tiles[0].get_room_type() == RoomData.RoomType.EMPTY:
		return false
	if connected_tiles[1].get_room_type() == RoomData.RoomType.EMPTY:
		return false

	# Check if synergy still exists between the two rooms
	var current_synergy = RoomData.get_synergy_type(
		connected_tiles[0].get_room_type(),
		connected_tiles[1].get_room_type()
	)

	return current_synergy == synergy_type
