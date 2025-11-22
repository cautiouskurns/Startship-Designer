extends Panel
class_name GridTile

## Grid position coordinates
@export var grid_x: int = 0
@export var grid_y: int = 0

func _ready():
	# Set fixed size
	custom_minimum_size = Vector2(64, 64)
	size = Vector2(64, 64)
