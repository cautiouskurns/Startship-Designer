extends Panel
class_name HullCard

## Displays a selectable hull type card

signal hull_selected(hull_type: GameState.HullType)

## Hull type this card represents
var hull_type: GameState.HullType = GameState.HullType.CRUISER

## UI elements
@onready var hull_name_label: Label = $VBoxContainer/HullName
@onready var grid_size_label: Label = $VBoxContainer/GridSize
@onready var bonus_label: Label = $VBoxContainer/BonusLabel
@onready var select_button: Button = $VBoxContainer/SelectButton
@onready var grid_preview: Control = $VBoxContainer/GridPreview

## Style box for border effects
var style_box: StyleBoxFlat

func _ready():
	# Get and duplicate StyleBoxFlat
	style_box = get_theme_stylebox("panel").duplicate()
	add_theme_stylebox_override("panel", style_box)

	# Connect signals
	select_button.pressed.connect(_on_select_pressed)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

## Setup card with hull data
func setup(hull: GameState.HullType):
	hull_type = hull
	var hull_data = GameState.get_hull_data(hull)

	if hull_name_label:
		hull_name_label.text = hull_data["name"]
	if grid_size_label:
		var grid_size: Vector2i = hull_data["grid_size"]
		grid_size_label.text = "%d×%d Grid" % [grid_size.x, grid_size.y]
	if bonus_label:
		bonus_label.text = hull_data["description"]

	# Draw grid preview
	if grid_preview:
		_draw_grid_preview(hull_data["grid_size"])

## Draw a simple grid outline preview
func _draw_grid_preview(grid_size: Vector2i):
	# Clear existing children
	for child in grid_preview.get_children():
		child.queue_free()

	# Calculate tile size to fit in 200×150 preview area
	var preview_width = 200.0
	var preview_height = 150.0
	var tile_width = preview_width / grid_size.x
	var tile_height = preview_height / grid_size.y
	var tile_size = min(tile_width, tile_height)

	# Center the grid
	var grid_width = grid_size.x * tile_size
	var grid_height = grid_size.y * tile_size
	var offset_x = (preview_width - grid_width) / 2.0
	var offset_y = (preview_height - grid_height) / 2.0

	# Draw grid outline
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			var tile = Panel.new()
			var tile_style = StyleBoxFlat.new()
			tile_style.bg_color = Color(0.172549, 0.172549, 0.172549, 1)
			tile_style.border_width_left = 1
			tile_style.border_width_top = 1
			tile_style.border_width_right = 1
			tile_style.border_width_bottom = 1
			tile_style.border_color = Color(0.4, 0.4, 0.4, 1)
			tile.add_theme_stylebox_override("panel", tile_style)
			tile.custom_minimum_size = Vector2(tile_size, tile_size)
			tile.size = Vector2(tile_size, tile_size)
			tile.position = Vector2(offset_x + x * tile_size, offset_y + y * tile_size)
			grid_preview.add_child(tile)

## Handle select button press
func _on_select_pressed():
	emit_signal("hull_selected", hull_type)

## Handle mouse enter - hover effect
func _on_mouse_entered():
	# Scale up
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.05, 1.05), 0.1)

	# Glow cyan border
	style_box.border_width_left = 2
	style_box.border_width_top = 2
	style_box.border_width_right = 2
	style_box.border_width_bottom = 2
	style_box.border_color = Color(0.290, 0.886, 0.886)  # Cyan

## Handle mouse exit - reset
func _on_mouse_exited():
	# Scale back
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)

	# Reset border
	style_box.border_width_left = 1
	style_box.border_width_top = 1
	style_box.border_width_right = 1
	style_box.border_width_bottom = 1
	style_box.border_color = Color(0.4, 0.4, 0.4, 1)
