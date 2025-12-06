extends Panel
class_name SpecificationsPanel

## Panel displaying specifications for selected component

## UI element references
@onready var component_value: Label = $VBoxContainer/ScrollContainer/ContentMargin/ContentContainer/ComponentSection/ComponentValue
@onready var dimensions_value: Label = $VBoxContainer/ScrollContainer/ContentMargin/ContentContainer/DimensionsSection/DimensionsValue
@onready var cost_value: Label = $VBoxContainer/ScrollContainer/ContentMargin/ContentContainer/CostSection/CostValue
@onready var description_value: Label = $VBoxContainer/ScrollContainer/ContentMargin/ContentContainer/DescriptionSection/DescriptionValue

## Component descriptions
const DESCRIPTIONS = {
	RoomData.RoomType.BRIDGE: "Command center - required to launch",
	RoomData.RoomType.WEAPON: "Offensive system - deals damage to enemies",
	RoomData.RoomType.SHIELD: "Defensive system - absorbs incoming damage",
	RoomData.RoomType.ENGINE: "Propulsion system - determines initiative",
	RoomData.RoomType.REACTOR: "Powers adjacent rooms",
	RoomData.RoomType.ARMOR: "Increases hull integrity",
	RoomData.RoomType.CONDUIT: "Electrical wiring for power distribution",
	RoomData.RoomType.RELAY: "Extends power range wirelessly"
}

func _ready():
	# Show empty state initially
	clear_display()

## Update display with selected room type specifications
func update_specifications(room_type: RoomData.RoomType):
	if room_type == RoomData.RoomType.EMPTY:
		clear_display()
		return

	# Get room data
	var label = RoomData.get_label(room_type)
	var size = RoomData.get_shape_size(room_type)
	var cost = RoomData.get_cost(room_type)
	var description = DESCRIPTIONS.get(room_type, "No description available")

	# Extract room name from label (remove symbol prefix if present)
	var parts = label.split(" ", false, 1)
	var room_name = parts[1] if parts.size() >= 2 else label

	# Update labels
	component_value.text = room_name
	dimensions_value.text = "%d × %d units" % [size.x, size.y]
	cost_value.text = "%d BP" % cost
	description_value.text = description

## Clear display to empty state
func clear_display():
	component_value.text = "Select a component"
	dimensions_value.text = "—"
	cost_value.text = "—"
	description_value.text = "—"
