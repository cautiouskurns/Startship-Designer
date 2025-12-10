extends Control

## RadarChart - Pentagon radar chart for displaying 5 stats
## Handles polygon drawing, axis lines, and smooth transitions

# Stats (0.0 to 1.0)
var offense: float = 0.0
var defense: float = 0.0
var speed: float = 0.0
var durability: float = 0.0
var efficiency: float = 0.0

# Visual properties
var chart_radius: float = 90.0  # Max radius for 100% stat (200x200 container, with padding)
var center: Vector2 = Vector2(100, 100)  # Center of 200x200 container

# Colors
var fill_color: Color = Color(0.29, 0.89, 0.89, 0.3)  # Cyan semi-transparent
var outline_color: Color = Color(1.0, 1.0, 1.0, 0.8)  # White
var axis_color: Color = Color(0.4, 0.4, 0.4, 0.5)  # Dark gray for axis lines

# Node references
var polygon: Polygon2D
var axis_lines: Array[Line2D] = []
var axis_labels: Array[Label] = []

# Animation
var current_tween: Tween

# Stat order (clockwise from top)
const STAT_NAMES = ["Offense", "Defense", "Durability", "Speed", "Efficiency"]

func _ready():
	# Create polygon
	polygon = Polygon2D.new()
	polygon.color = fill_color
	add_child(polygon)

	# Create axis lines (5 lines from center to each vertex)
	for i in range(5):
		var line = Line2D.new()
		line.default_color = axis_color
		line.width = 1.0
		add_child(line)
		axis_lines.append(line)

	# Create axis labels
	for i in range(5):
		var label = Label.new()
		label.text = STAT_NAMES[i]
		label.add_theme_font_size_override("font_size", 12)
		label.add_theme_color_override("font_color", Color.WHITE)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		add_child(label)
		axis_labels.append(label)

	# Draw initial state
	_draw_axes()
	_update_chart_immediate()

## Update chart with new stat values (with animation)
func update_stats(new_offense: float, new_defense: float, new_speed: float, new_durability: float, new_efficiency: float):
	# Kill existing tween
	if current_tween and current_tween.is_running():
		current_tween.kill()

	# Store target values
	var target_offense = clamp(new_offense, 0.0, 1.0)
	var target_defense = clamp(new_defense, 0.0, 1.0)
	var target_speed = clamp(new_speed, 0.0, 1.0)
	var target_durability = clamp(new_durability, 0.0, 1.0)
	var target_efficiency = clamp(new_efficiency, 0.0, 1.0)

	# Create smooth tween
	current_tween = create_tween()
	current_tween.set_parallel(true)
	current_tween.set_trans(Tween.TRANS_CUBIC)
	current_tween.set_ease(Tween.EASE_OUT)

	current_tween.tween_property(self, "offense", target_offense, 0.2)
	current_tween.tween_property(self, "defense", target_defense, 0.2)
	current_tween.tween_property(self, "speed", target_speed, 0.2)
	current_tween.tween_property(self, "durability", target_durability, 0.2)
	current_tween.tween_property(self, "efficiency", target_efficiency, 0.2)

	# Update visual during tween
	current_tween.tween_callback(_update_chart_immediate).set_delay(0.0)

## Update chart color based on archetype
func set_chart_color(archetype_color: Color):
	# Use archetype color with transparency
	fill_color = Color(archetype_color.r, archetype_color.g, archetype_color.b, 0.3)
	if polygon:
		polygon.color = fill_color

## Calculate vertex position for a stat
func _get_vertex_position(stat_index: int, stat_value: float) -> Vector2:
	# Pentagon vertices, starting from top (Offense) and going clockwise
	# Angle calculation: start at -90° (top), increment by 72° (360/5)
	var angle_degrees = -90 + (stat_index * 72)
	var angle_radians = deg_to_rad(angle_degrees)

	# Calculate position
	var radius = stat_value * chart_radius
	var x = center.x + cos(angle_radians) * radius
	var y = center.y + sin(angle_radians) * radius

	return Vector2(x, y)

## Draw axis lines (static, drawn once)
func _draw_axes():
	# Draw lines from center to max radius for each axis
	for i in range(5):
		var max_pos = _get_vertex_position(i, 1.0)
		axis_lines[i].points = [center, max_pos]

	# Position labels beyond the max radius
	for i in range(5):
		var label_pos = _get_vertex_position(i, 1.15)  # 15% beyond max radius
		axis_labels[i].position = label_pos - Vector2(40, 10)  # Offset for label size (approximate)
		axis_labels[i].size = Vector2(80, 20)

## Update polygon vertices (called during animation)
func _update_chart_immediate():
	var vertices: PackedVector2Array = []

	# Calculate all 5 vertices
	vertices.append(_get_vertex_position(0, offense))
	vertices.append(_get_vertex_position(1, defense))
	vertices.append(_get_vertex_position(2, durability))
	vertices.append(_get_vertex_position(3, speed))
	vertices.append(_get_vertex_position(4, efficiency))

	# Update polygon
	if polygon:
		polygon.polygon = vertices

## Called every frame to update during tween
func _process(_delta):
	if current_tween and current_tween.is_running():
		_update_chart_immediate()
