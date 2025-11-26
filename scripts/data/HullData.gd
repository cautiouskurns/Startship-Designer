class_name HullData

## Hull type enumeration for visual overlay templates
enum HullType {
	NONE,        # No hull overlay
	FRIGATE,     # ~120 tiles, compact pointed bow
	CORVETTE,    # ~80 tiles, small angular
	DESTROYER,   # ~180 tiles, long narrow
	CRUISER,     # ~280 tiles, balanced wide midsection
	BATTLESHIP   # ~400 tiles, large blocky imposing
}

## Hull display labels
static var labels = {
	HullType.NONE: "No Hull",
	HullType.FRIGATE: "Frigate",
	HullType.CORVETTE: "Corvette",
	HullType.DESTROYER: "Destroyer",
	HullType.CRUISER: "Cruiser",
	HullType.BATTLESHIP: "Battleship"
}

## Hull shapes defined as tile coordinate arrays
## Each shape is an array of [x, y] tile positions
## Shapes are centered on a 30×30 grid (default FREE DESIGN grid size)
## These are simple geometric forms that can be refined later
static var shapes = {
	HullType.NONE: [],
	HullType.FRIGATE: _generate_frigate_shape(),
	HullType.CORVETTE: _generate_corvette_shape(),
	HullType.DESTROYER: _generate_destroyer_shape(),
	HullType.CRUISER: _generate_cruiser_shape(),
	HullType.BATTLESHIP: _generate_battleship_shape()
}

## Visual properties for hull overlay rendering
static var overlay_config = {
	"fill_color": Color(0.29, 0.89, 0.89, 0.15),     # Light cyan at 15% opacity (subtle)
	"border_color": Color(0.29, 0.89, 0.89, 0.4),    # Light cyan at 40% opacity (visible but subtle)
	"border_width": 2                                 # 2px border line
}

## Get label for a hull type
static func get_label(hull_type: HullType) -> String:
	return labels.get(hull_type, "Unknown")

## Get shape (array of tile positions) for a hull type
static func get_shape(hull_type: HullType) -> Array:
	return shapes.get(hull_type, [])

## Generate Frigate shape (~120 tiles, arrow/wedge with pointed bow)
## Compact design pointing RIGHT (→) for combat orientation
static func _generate_frigate_shape() -> Array:
	var shape = []
	var center_x = 15
	var center_y = 15

	# Arrow shape pointing right: wide back → narrow tip
	# Approximate 12 wide × 10 tall = 120 tiles
	for y in range(-5, 5):  # 10 rows tall
		var row_width = 12 - abs(y)  # Tapers from 12 to 7 tiles wide
		var start_x = -6
		var end_x = start_x + row_width
		for x in range(start_x, end_x):
			shape.append([center_x + x, center_y + y])

	return shape

## Generate Corvette shape (~80 tiles, compact diamond)
## Small angular diamond pointing RIGHT (→)
static func _generate_corvette_shape() -> Array:
	var shape = []
	var center_x = 15
	var center_y = 15

	# Diamond shape: 10 wide × 8 tall = ~80 tiles
	for y in range(-4, 4):  # 8 rows tall
		var row_width = 10 - abs(y) * 2  # Tapers from 10 to 2 tiles
		var start_x = -5 + abs(y)
		var end_x = start_x + row_width
		for x in range(start_x, end_x):
			shape.append([center_x + x, center_y + y])

	return shape

## Generate Destroyer shape (~180 tiles, long narrow)
## Elongated rectangle pointing RIGHT (→)
static func _generate_destroyer_shape() -> Array:
	var shape = []
	var center_x = 15
	var center_y = 15

	# Long narrow shape: 18 wide × 10 tall = 180 tiles
	for y in range(-5, 5):  # 10 rows tall
		for x in range(-9, 9):  # 18 columns wide
			shape.append([center_x + x, center_y + y])

	return shape

## Generate Cruiser shape (~280 tiles, balanced wide midsection)
## Oval with bulge in middle pointing RIGHT (→)
static func _generate_cruiser_shape() -> Array:
	var shape = []
	var center_x = 15
	var center_y = 15

	# Oval shape: varies width by row, ~14 wide × 20 tall = ~280 tiles
	for y in range(-10, 10):  # 20 rows tall
		# Ellipse formula: width varies based on distance from center
		var normalized_y = abs(y) / 10.0  # 0.0 at center, 1.0 at edges
		var row_width = int(14.0 * (1.0 - normalized_y * normalized_y))  # Quadratic taper
		if row_width < 4:
			row_width = 4  # Minimum width
		var start_x = -row_width / 2
		var end_x = start_x + row_width
		for x in range(start_x, end_x):
			shape.append([center_x + x, center_y + y])

	return shape

## Generate Battleship shape (~400 tiles, large blocky H-shape)
## Imposing rectangular form with extensions pointing RIGHT (→)
static func _generate_battleship_shape() -> Array:
	var shape = []
	var center_x = 15
	var center_y = 15

	# H-shape (blocky): main body + top/bottom extensions
	# Main body: 20 wide × 20 tall = 400 tiles
	for y in range(-10, 10):  # 20 rows tall
		# Full width (20) in center 10 rows, narrower (12) at top/bottom
		var row_width = 20
		if abs(y) > 5:  # Outer rows
			row_width = 12
		var start_x = -row_width / 2
		var end_x = start_x + row_width
		for x in range(start_x, end_x):
			shape.append([center_x + x, center_y + y])

	return shape
