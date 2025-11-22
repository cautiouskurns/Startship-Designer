class_name RoomData

## Room type enumeration
enum RoomType {
	EMPTY,
	BRIDGE,
	WEAPON,
	SHIELD,
	ENGINE,
	REACTOR,
	ARMOR
}

## Room costs in budget points
static var costs = {
	RoomType.EMPTY: 0,
	RoomType.BRIDGE: 2,
	RoomType.WEAPON: 3,
	RoomType.SHIELD: 3,
	RoomType.ENGINE: 2,
	RoomType.REACTOR: 2,
	RoomType.ARMOR: 1
}

## Room colors (hex values from design doc)
static var colors = {
	RoomType.EMPTY: Color(0, 0, 0, 0),  # Transparent
	RoomType.BRIDGE: Color(0.290, 0.565, 0.886),    # #4A90E2 blue
	RoomType.WEAPON: Color(0.886, 0.290, 0.290),    # #E24A4A red
	RoomType.SHIELD: Color(0.290, 0.886, 0.886),    # #4AE2E2 cyan
	RoomType.ENGINE: Color(0.886, 0.627, 0.290),    # #E2A04A orange
	RoomType.REACTOR: Color(0.886, 0.831, 0.290),   # #E2D44A yellow
	RoomType.ARMOR: Color(0.424, 0.424, 0.424)      # #6C6C6C gray
}

## Room display labels
static var labels = {
	RoomType.EMPTY: "",
	RoomType.BRIDGE: "BRIDGE",
	RoomType.WEAPON: "WEAPON",
	RoomType.SHIELD: "SHIELD",
	RoomType.ENGINE: "ENGINE",
	RoomType.REACTOR: "REACTOR",
	RoomType.ARMOR: "ARMOR"
}

## Placement constraints (row indices, -1 means any row)
## Weapons: rows 0-1 (top 2 rows)
## Engines: rows 4-5 (bottom 2 rows)
## Others: any row
static var placement_rows = {
	RoomType.EMPTY: [],
	RoomType.BRIDGE: [],      # Any row
	RoomType.WEAPON: [0, 1],  # Top 2 rows only
	RoomType.SHIELD: [],      # Any row
	RoomType.ENGINE: [4, 5],  # Bottom 2 rows only
	RoomType.REACTOR: [],     # Any row
	RoomType.ARMOR: []        # Any row
}

## Get cost for a room type
static func get_cost(room_type: RoomType) -> int:
	return costs.get(room_type, 0)

## Get color for a room type
static func get_color(room_type: RoomType) -> Color:
	return colors.get(room_type, Color.WHITE)

## Get label for a room type
static func get_label(room_type: RoomType) -> String:
	return labels.get(room_type, "")

## Check if room can be placed in row
static func can_place_in_row(room_type: RoomType, row: int) -> bool:
	var allowed_rows = placement_rows.get(room_type, [])
	# If empty array, any row is allowed
	if allowed_rows.is_empty():
		return true
	# Otherwise check if row is in allowed list
	return row in allowed_rows
