extends Control

## Test scene for geometric room icons that would sit in grid tiles

@onready var showcase_container: HBoxContainer = $MarginContainer/ShowcaseContainer

## Room types to showcase
var room_types = [
	RoomData.RoomType.BRIDGE,
	RoomData.RoomType.WEAPON,
	RoomData.RoomType.SHIELD,
	RoomData.RoomType.ENGINE,
	RoomData.RoomType.REACTOR,
	RoomData.RoomType.ARMOR
]

func _ready():
	_generate_showcases()

## Generate visual showcases for each room type
func _generate_showcases():
	for room_type in room_types:
		_create_room_showcase(room_type)

## Create a showcase tile for a specific room type
func _create_room_showcase(room_type: RoomData.RoomType):
	var container = VBoxContainer.new()
	container.custom_minimum_size = Vector2(150, 180)
	showcase_container.add_child(container)

	# Room name label
	var name_label = Label.new()
	var room_name = RoomData.get_label(room_type).replace("⭐ ", "").replace("▶ ", "").replace("◆ ", "").replace("▲ ", "").replace("⊕ ", "").replace("█ ", "")
	name_label.text = room_name
	name_label.add_theme_font_size_override("font_size", 14)
	name_label.add_theme_color_override("font_color", Color.WHITE)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	container.add_child(name_label)

	# Tile background (simulates grid tile)
	var tile_bg = Panel.new()
	tile_bg.custom_minimum_size = Vector2(120, 120)

	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.15, 0.15, 0.15)
	style_box.border_color = Color(0.3, 0.3, 0.3)
	style_box.border_width_left = 2
	style_box.border_width_right = 2
	style_box.border_width_top = 2
	style_box.border_width_bottom = 2
	tile_bg.add_theme_stylebox_override("panel", style_box)
	container.add_child(tile_bg)

	# Draw the geometric icon inside
	var icon = _create_geometric_icon(room_type)
	icon.position = Vector2(60, 60)  # Center in 120x120 tile
	tile_bg.add_child(icon)

	# Cost label
	var cost_label = Label.new()
	cost_label.text = "%d BP" % RoomData.get_cost(room_type)
	cost_label.add_theme_font_size_override("font_size", 12)
	cost_label.add_theme_color_override("font_color", RoomData.get_color(room_type))
	cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	container.add_child(cost_label)

## Create geometric icon for each room type
func _create_geometric_icon(room_type: RoomData.RoomType) -> Node2D:
	var icon = Node2D.new()
	var color = RoomData.get_color(room_type)

	match room_type:
		RoomData.RoomType.BRIDGE:
			# Star shape (command center)
			_draw_star(icon, color, 40)

		RoomData.RoomType.WEAPON:
			# Triangle pointing right (laser/projectile)
			_draw_triangle(icon, color, 45)

		RoomData.RoomType.SHIELD:
			# Hexagon (defensive shape)
			_draw_hexagon(icon, color, 35)

		RoomData.RoomType.ENGINE:
			# Chevron/arrow pointing left (thrust)
			_draw_chevron(icon, color, 40)

		RoomData.RoomType.REACTOR:
			# Circle with inner ring (power core)
			_draw_reactor(icon, color, 35)

		RoomData.RoomType.ARMOR:
			# Solid square (plating)
			_draw_square(icon, color, 40)

	return icon

## Draw a star shape (5-pointed)
func _draw_star(parent: Node2D, color: Color, size: float):
	var polygon = Polygon2D.new()
	var points = PackedVector2Array()

	# 5-pointed star
	for i in range(10):
		var angle = (i * PI * 2.0 / 10.0) - PI / 2.0
		var radius = size if i % 2 == 0 else size * 0.4
		points.append(Vector2(cos(angle) * radius, sin(angle) * radius))

	polygon.polygon = points
	polygon.color = color
	parent.add_child(polygon)

## Draw a triangle (pointing right for weapon)
func _draw_triangle(parent: Node2D, color: Color, size: float):
	var polygon = Polygon2D.new()
	var points = PackedVector2Array([
		Vector2(size * 0.6, 0),        # Right point
		Vector2(-size * 0.4, -size * 0.5),  # Top left
		Vector2(-size * 0.4, size * 0.5)    # Bottom left
	])
	polygon.polygon = points
	polygon.color = color
	parent.add_child(polygon)

## Draw a hexagon (shield)
func _draw_hexagon(parent: Node2D, color: Color, size: float):
	var polygon = Polygon2D.new()
	var points = PackedVector2Array()

	for i in range(6):
		var angle = (i * PI * 2.0 / 6.0) - PI / 2.0
		points.append(Vector2(cos(angle) * size, sin(angle) * size))

	polygon.polygon = points
	polygon.color = color
	parent.add_child(polygon)

## Draw chevron/arrow (engine thrust)
func _draw_chevron(parent: Node2D, color: Color, size: float):
	var polygon = Polygon2D.new()
	var points = PackedVector2Array([
		Vector2(-size * 0.6, 0),           # Left point
		Vector2(0, -size * 0.5),           # Top middle
		Vector2(size * 0.3, -size * 0.5),  # Top right
		Vector2(size * 0.3, -size * 0.2),  # Inner top right
		Vector2(0, -size * 0.2),           # Inner top middle
		Vector2(size * 0.3, size * 0.2),   # Inner bottom middle
		Vector2(size * 0.3, size * 0.5),   # Inner bottom right
		Vector2(0, size * 0.5),            # Bottom middle
		Vector2(-size * 0.6, 0)            # Back to start
	])
	polygon.polygon = points
	polygon.color = color
	parent.add_child(polygon)

## Draw reactor (circle with inner ring)
func _draw_reactor(parent: Node2D, color: Color, size: float):
	# Outer circle
	var outer_circle = Polygon2D.new()
	var outer_points = PackedVector2Array()
	for i in range(32):
		var angle = i * PI * 2.0 / 32.0
		outer_points.append(Vector2(cos(angle) * size, sin(angle) * size))
	outer_circle.polygon = outer_points
	outer_circle.color = color
	parent.add_child(outer_circle)

	# Inner ring (darker)
	var inner_circle = Polygon2D.new()
	var inner_points = PackedVector2Array()
	for i in range(32):
		var angle = i * PI * 2.0 / 32.0
		inner_points.append(Vector2(cos(angle) * size * 0.5, sin(angle) * size * 0.5))
	inner_circle.polygon = inner_points
	inner_circle.color = Color(0.15, 0.15, 0.15)  # Dark center
	parent.add_child(inner_circle)

	# Core dot
	var core = Polygon2D.new()
	var core_points = PackedVector2Array()
	for i in range(16):
		var angle = i * PI * 2.0 / 16.0
		core_points.append(Vector2(cos(angle) * size * 0.15, sin(angle) * size * 0.15))
	core.polygon = core_points
	core.color = color.lightened(0.3)  # Bright center
	parent.add_child(core)

## Draw square (armor plating)
func _draw_square(parent: Node2D, color: Color, size: float):
	var polygon = Polygon2D.new()
	var half = size * 0.6
	var points = PackedVector2Array([
		Vector2(-half, -half),
		Vector2(half, -half),
		Vector2(half, half),
		Vector2(-half, half)
	])
	polygon.polygon = points
	polygon.color = color
	parent.add_child(polygon)
