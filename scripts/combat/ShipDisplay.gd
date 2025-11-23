extends Node2D
class_name ShipDisplay

## Displays a ship's 8x6 grid of rooms visually

const TILE_SIZE = 96
const GRID_WIDTH = 8
const GRID_HEIGHT = 6

## Ship data to display
var ship_data: ShipData = null

## Dictionary to track room nodes by position "x,y" -> room node (for legacy single-tile rendering)
var room_nodes: Dictionary = {}

## Dictionary to track room instance nodes by room_id (Phase 7.4 - for shaped rooms)
var room_instance_nodes: Dictionary = {}

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

## Render the ship's grid (Phase 7.4 - routes to shaped or legacy rendering)
func _render_ship():
	if not ship_data:
		return

	# Clear any existing children and room tracking
	for child in get_children():
		child.queue_free()
	room_nodes.clear()
	room_instance_nodes.clear()

	# Route to appropriate rendering method
	if ship_data.room_instances.is_empty():
		_render_ship_legacy()  # Old per-tile for enemies
	else:
		_render_ship_instances()  # New shaped room rendering

## Render ship with shaped rooms (Phase 7.4 - for player ships from designer)
func _render_ship_instances():
	# Render each room instance by creating ColorRects at each tile position
	for room_id in ship_data.room_instances:
		var room_data = ship_data.room_instances[room_id]
		var room_type = room_data["type"]
		var tiles = room_data["tiles"]
		var room_color = RoomData.get_color(room_type)

		# Create a container for this room's visuals
		var room_container = Control.new()
		room_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(room_container)

		# Create ColorRect background at each tile position (shows actual shape)
		for tile_pos in tiles:
			var tile_bg = ColorRect.new()
			tile_bg.color = room_color
			tile_bg.size = Vector2(TILE_SIZE, TILE_SIZE)
			tile_bg.position = Vector2(tile_pos.x * TILE_SIZE, tile_pos.y * TILE_SIZE)
			tile_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
			room_container.add_child(tile_bg)

		# Add label at the first (anchor) tile
		if tiles.size() > 0:
			var anchor_tile = tiles[0]
			var label = Label.new()
			label.text = RoomData.get_label(room_type)
			label.add_theme_font_size_override("font_size", 10)
			label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			label.size = Vector2(TILE_SIZE, TILE_SIZE)
			label.position = Vector2(anchor_tile.x * TILE_SIZE, anchor_tile.y * TILE_SIZE)
			label.mouse_filter = Control.MOUSE_FILTER_IGNORE
			room_container.add_child(label)

		# Track container by room_id
		room_instance_nodes[room_id] = room_container

## Render ship with legacy per-tile approach (Phase 7.4 - for enemies)
func _render_ship_legacy():
	# Render each room in the grid (old single-tile approach)
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

## Destroy room visual at grid position with animation (Phase 7.4 - supports shaped rooms)
func destroy_room_visual(x: int, y: int, speed_mult: float = 1.0, all_tiles: Array = [], room_id: int = -1):
	# Phase 7.4: Check if destroying shaped room (all_tiles provided)
	if not all_tiles.is_empty() and room_id != -1:
		_destroy_shaped_room(all_tiles, room_id, speed_mult)
		return

	# Legacy single-tile destruction (for enemies)
	var key = "%d,%d" % [x, y]
	if not room_nodes.has(key):
		return

	var room = room_nodes[key]

	# Stage 1: Red flash warning (2 flashes for faster feedback)
	for i in range(2):
		# Flash to red
		var tween_on = create_tween()
		tween_on.tween_property(room, "modulate", Color(1, 0.3, 0.3, 1), 0.08 * speed_mult)
		await tween_on.finished

		# Flash back to normal
		var tween_off = create_tween()
		tween_off.tween_property(room, "modulate", Color(1, 1, 1, 1), 0.08 * speed_mult)
		await tween_off.finished

	# Stage 2: Explosion animation
	var explosion = _create_explosion(room.position + Vector2(30, 30))  # Center of 60x60 room
	add_child(explosion)

	# Explosion expands and fades
	var exp_tween = create_tween()
	exp_tween.tween_property(explosion, "scale", Vector2(1.33, 1.33), 0.25 * speed_mult)  # 60 → 80px
	exp_tween.parallel().tween_property(explosion, "modulate:a", 0.0, 0.25 * speed_mult)
	exp_tween.tween_callback(explosion.queue_free)

	await get_tree().create_timer(0.25 * speed_mult).timeout

	# Stage 3: Final destroyed state (dark gray, broken appearance)
	room.modulate = Color(0.4, 0.4, 0.4, 0.6)

## Destroy shaped room visual (Phase 7.4 - flash all tiles, spawn all explosions)
func _destroy_shaped_room(tiles: Array, room_id: int, speed_mult: float):
	# Get the room instance container
	if not room_instance_nodes.has(room_id):
		return

	var room_container = room_instance_nodes[room_id]

	# Stage 1: Red flash warning (2 flashes, all tiles at once)
	for i in range(2):
		# Flash to red
		var tween_on = create_tween()
		tween_on.tween_property(room_container, "modulate", Color(1, 0.3, 0.3, 1), 0.08 * speed_mult)
		await tween_on.finished

		# Flash back to normal
		var tween_off = create_tween()
		tween_off.tween_property(room_container, "modulate", Color(1, 1, 1, 1), 0.08 * speed_mult)
		await tween_off.finished

	# Stage 2: Spawn explosions at ALL tile centers simultaneously
	var explosions = []
	for tile_pos in tiles:
		var explosion_pos = Vector2(tile_pos.x * TILE_SIZE + TILE_SIZE / 2, tile_pos.y * TILE_SIZE + TILE_SIZE / 2)
		var explosion = _create_explosion(explosion_pos)
		add_child(explosion)
		explosions.append(explosion)

	# Animate all explosions simultaneously
	for explosion in explosions:
		var exp_tween = create_tween()
		exp_tween.tween_property(explosion, "scale", Vector2(1.33, 1.33), 0.25 * speed_mult)
		exp_tween.parallel().tween_property(explosion, "modulate:a", 0.0, 0.25 * speed_mult)
		exp_tween.tween_callback(explosion.queue_free)

	await get_tree().create_timer(0.25 * speed_mult).timeout

	# Stage 3: Final destroyed state (dark gray, broken appearance)
	room_container.modulate = Color(0.4, 0.4, 0.4, 0.6)

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

	# Phase 7.4: Check if ship has room instances (shaped rooms)
	if not ship.room_instances.is_empty():
		# Update shaped room containers
		for room_id in room_instance_nodes:
			if not ship.room_instances.has(room_id):
				continue

			var room_data = ship.room_instances[room_id]
			var tiles = room_data["tiles"]
			var room_container = room_instance_nodes[room_id]

			# If room is destroyed (already grayed), skip power visual update
			if room_container.modulate == Color(0.4, 0.4, 0.4, 0.6):
				continue

			# Check if any tile of this room is powered
			var is_powered = false
			for tile_pos in tiles:
				if ship.is_room_powered(tile_pos.x, tile_pos.y):
					is_powered = true
					break

			# Update based on power status
			if is_powered:
				# Powered: full color and opacity
				room_container.modulate = Color(1, 1, 1, 1)
			else:
				# Unpowered: darker and semi-transparent
				room_container.modulate = Color(0.7, 0.7, 0.7, 0.6)
	else:
		# Legacy per-tile power visuals for enemy ships
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

## Calculate bounding box for a set of tiles (Phase 7.4)
## Returns Dictionary with {min_x, max_x, min_y, max_y, width, height}
func _calculate_bounding_box(tiles: Array) -> Dictionary:
	if tiles.is_empty():
		return {min_x = 0, max_x = 0, min_y = 0, max_y = 0, width = 1, height = 1}

	var min_x = tiles[0].x
	var max_x = tiles[0].x
	var min_y = tiles[0].y
	var max_y = tiles[0].y

	for tile_pos in tiles:
		min_x = min(min_x, tile_pos.x)
		max_x = max(max_x, tile_pos.x)
		min_y = min(min_y, tile_pos.y)
		max_y = max(max_y, tile_pos.y)

	return {
		"min_x": min_x,
		"max_x": max_x,
		"min_y": min_y,
		"max_y": max_y,
		"width": max_x - min_x + 1,
		"height": max_y - min_y + 1
	}
