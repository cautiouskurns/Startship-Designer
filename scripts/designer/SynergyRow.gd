extends HBoxContainer
class_name SynergyRow

## Visual row showing a synergy type with live count

## References to child nodes
@onready var room_icon_1: ColorRect = $RoomIcon1
@onready var room_icon_2: ColorRect = $RoomIcon2
@onready var synergy_indicator: ColorRect = $SynergyIndicator
@onready var bonus_label: Label = $BonusLabel
@onready var count_label: Label = $CountLabel

## The synergy type this row represents
var synergy_type: RoomData.SynergyType = RoomData.SynergyType.NONE

## Colors
const COLOR_CYAN = Color(0.290, 0.886, 0.886)  # #4AE2E2 for active counts
const COLOR_GRAY = Color(0.666667, 0.666667, 0.666667)  # #AAAAAA for inactive counts

## Setup the row with synergy configuration
func setup(synergy: RoomData.SynergyType, room_a: RoomData.RoomType, room_b: RoomData.RoomType, bonus_text: String):
	synergy_type = synergy

	# Set room icon colors
	room_icon_1.color = RoomData.get_color(room_a)
	room_icon_2.color = RoomData.get_color(room_b)

	# Set synergy indicator color
	synergy_indicator.color = RoomData.get_synergy_color(synergy)

	# Set bonus text
	bonus_label.text = bonus_text

	# Initialize with 0 count (inactive state)
	update_count(0)

## Update the count display and visual state
func update_count(count: int):
	# Update count text
	count_label.text = "×%d" % count

	if count > 0:
		# Active state: full opacity, cyan count
		modulate.a = 1.0
		count_label.add_theme_color_override("font_color", COLOR_CYAN)
	else:
		# Inactive state: 50% opacity, gray count
		modulate.a = 0.5
		count_label.add_theme_color_override("font_color", COLOR_GRAY)
