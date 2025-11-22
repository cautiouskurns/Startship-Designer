extends Node2D
class_name ShipDisplay

## Displays a ship's 8x6 grid of rooms visually

const TILE_SIZE = 64
const GRID_WIDTH = 8
const GRID_HEIGHT = 6

## Ship data to display
var ship_data: ShipData = null

## Dictionary to track room nodes by position "x,y" -> room node
var room_nodes: Dictionary = {}

## Preload room scenes (reuse from Phase 1)
var room_scenes = {
	RoomData.RoomType.BRIDGE: preload("res://scenes/components/rooms/Bridge.tscn"),
	RoomData.RoomType.WEAPON: preload("res://scenes/components/rooms/Weapon.tscn"),
	RoomData.RoomType.SHIELD: preload("res://scenes/components/rooms/Shield.tscn"),
	RoomData.RoomType.ENGINE: preload("res://scenes/components/rooms/Engine.tscn"),
	RoomData.RoomType.REACTOR: preload("res://scenes/components/rooms/Reactor.tscn"),
	RoomData.RoomType.ARMOR: preload("res://scenes/components/rooms/Armor.tscn")
}

## Set the ship data and render the grid
func set_ship_data(data: ShipData):
	ship_data = data
	_render_ship()

## Render the ship's grid
func _render_ship():
	if not ship_data:
		return

	# Clear any existing children and room tracking
	for child in get_children():
		child.queue_free()
	room_nodes.clear()

	# Render each room in the grid
	for y in range(GRID_HEIGHT):
		for x in range(GRID_WIDTH):
			var room_type = ship_data.grid[y][x]

			# Skip empty tiles
			if room_type == RoomData.RoomType.EMPTY:
				continue

			# Create room sprite
			var room_scene = room_scenes.get(room_type)
			if room_scene:
				var room = room_scene.instantiate()
				room.position = Vector2(x * TILE_SIZE, y * TILE_SIZE)

				# Disable mouse input (combat ships aren't interactive)
				if room is Control:
					room.mouse_filter = Control.MOUSE_FILTER_IGNORE

				add_child(room)

				# Track room node by position
				var key = "%d,%d" % [x, y]
				room_nodes[key] = room

## Flash the entire ship with a color overlay
func flash(color: Color):
	# Create flash overlay
	var overlay = ColorRect.new()
	overlay.color = color
	overlay.color.a = 0
	overlay.size = Vector2(GRID_WIDTH * TILE_SIZE, GRID_HEIGHT * TILE_SIZE)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(overlay)

	# Tween flash effect
	var tween = create_tween()
	tween.tween_property(overlay, "color:a", 0.5, 0.2)
	tween.tween_property(overlay, "color:a", 0.0, 0.2)
	tween.tween_callback(overlay.queue_free)

## Destroy room visual at grid position (gray it out)
func destroy_room_visual(x: int, y: int):
	var key = "%d,%d" % [x, y]
	if room_nodes.has(key):
		var room = room_nodes[key]
		# Gray out and make semi-transparent
		room.modulate = Color(0.5, 0.5, 0.5, 0.5)
