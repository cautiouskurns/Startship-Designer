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

## Destroy room visual at grid position with animation
func destroy_room_visual(x: int, y: int):
	var key = "%d,%d" % [x, y]
	if not room_nodes.has(key):
		return

	var room = room_nodes[key]

	# Stage 1: Red flash warning (3 flashes, 0.6s total)
	for i in range(3):
		# Flash to red
		var tween_on = create_tween()
		tween_on.tween_property(room, "modulate", Color(1, 0.3, 0.3, 1), 0.1)
		await tween_on.finished

		# Flash back to normal
		var tween_off = create_tween()
		tween_off.tween_property(room, "modulate", Color(1, 1, 1, 1), 0.1)
		await tween_off.finished

	# Stage 2: Explosion animation (0.3s)
	var explosion = _create_explosion(room.position + Vector2(30, 30))  # Center of 60x60 room
	add_child(explosion)

	# Explosion expands and fades
	var exp_tween = create_tween()
	exp_tween.tween_property(explosion, "scale", Vector2(1.33, 1.33), 0.3)  # 60 → 80px
	exp_tween.parallel().tween_property(explosion, "modulate:a", 0.0, 0.3)
	exp_tween.tween_callback(explosion.queue_free)

	await get_tree().create_timer(0.3).timeout

	# Stage 3: Final destroyed state (dark gray, broken appearance)
	room.modulate = Color(0.4, 0.4, 0.4, 0.6)

## Create explosion visual effect
func _create_explosion(pos: Vector2) -> Panel:
	# Create circular orange explosion using Panel + StyleBoxFlat
	var panel = Panel.new()
	panel.size = Vector2(60, 60)
	panel.position = pos - Vector2(30, 30)  # Center on position
	panel.z_index = 10  # Above everything
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Circular orange/yellow style
	var style = StyleBoxFlat.new()
	style.bg_color = Color(1, 0.6, 0.2, 1)  # Orange/yellow
	style.corner_radius_top_left = 30
	style.corner_radius_top_right = 30
	style.corner_radius_bottom_left = 30
	style.corner_radius_bottom_right = 30
	panel.add_theme_stylebox_override("panel", style)

	return panel

## Update power visuals for all rooms based on ship's power grid
func update_power_visuals(ship: ShipData):
	if not ship:
		return

	# Update each room's visual based on power status
	for y in range(GRID_HEIGHT):
		for x in range(GRID_WIDTH):
			var key = "%d,%d" % [x, y]
			if room_nodes.has(key):
				var room = room_nodes[key]
				var is_powered = ship.is_room_powered(x, y)

				# If room is destroyed (already grayed), skip power visual update
				if room.modulate == Color(0.5, 0.5, 0.5, 0.5):
					continue

				# Update based on power status
				if is_powered:
					# Powered: full color and opacity
					room.modulate = Color(1, 1, 1, 1)
				else:
					# Unpowered: darker and semi-transparent
					room.modulate = Color(0.7, 0.7, 0.7, 0.6)
