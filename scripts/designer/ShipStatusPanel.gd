extends Panel
class_name ShipStatusPanel

## Panel displaying ship readiness status (Bridge, Budget, Power)

## Bridge status elements
@onready var bridge_icon_label: Label = $VBoxContainer/MarginContainer/Content/BridgeStatusRow/StatusLine/BridgeIconLabel
@onready var bridge_text_label: Label = $VBoxContainer/MarginContainer/Content/BridgeStatusRow/StatusLine/BridgeTextLabel

## Budget status elements
@onready var budget_icon_label: Label = $VBoxContainer/MarginContainer/Content/BudgetStatusRow/StatusLine/BudgetIconLabel
@onready var budget_text_label: Label = $VBoxContainer/MarginContainer/Content/BudgetStatusRow/StatusLine/BudgetTextLabel
@onready var budget_detail_label: Label = $VBoxContainer/MarginContainer/Content/BudgetStatusRow/BudgetDetailLabel

## Power status elements
@onready var power_icon_label: Label = $VBoxContainer/MarginContainer/Content/PowerStatusRow/StatusLine/PowerIconLabel
@onready var power_text_label: Label = $VBoxContainer/MarginContainer/Content/PowerStatusRow/StatusLine/PowerTextLabel
@onready var power_detail_label: Label = $VBoxContainer/MarginContainer/Content/PowerStatusRow/PowerDetailLabel

## Colors
const COLOR_GREEN = Color(0.290, 0.886, 0.290)  # #4AE24A
const COLOR_YELLOW = Color(0.886, 0.831, 0.290)  # #E2D44A
const COLOR_RED = Color(0.886, 0.290, 0.290)  # #E24A4A
const COLOR_GRAY = Color(0.666667, 0.666667, 0.666667)  # #AAAAAA

## Update bridge status
func update_bridge_status(bridge_count: int):
	if bridge_count == 1:
		# Ready - green
		bridge_icon_label.text = "✓"
		bridge_text_label.text = " Bridge: Ready"
		bridge_icon_label.add_theme_color_override("font_color", COLOR_GREEN)
		bridge_text_label.add_theme_color_override("font_color", COLOR_GREEN)
	else:
		# Missing - red
		bridge_icon_label.text = "✗"
		bridge_text_label.text = " Bridge: Missing"
		bridge_icon_label.add_theme_color_override("font_color", COLOR_RED)
		bridge_text_label.add_theme_color_override("font_color", COLOR_RED)

## Update budget status
func update_budget_status(current: int, max: int):
	budget_detail_label.text = "  %d / %d" % [current, max]
	budget_detail_label.add_theme_color_override("font_color", COLOR_GRAY)

	if current <= max:
		# Within limits - green
		budget_icon_label.text = "✓"
		budget_text_label.text = " Budget: Within Limits"
		budget_icon_label.add_theme_color_override("font_color", COLOR_GREEN)
		budget_text_label.add_theme_color_override("font_color", COLOR_GREEN)
	else:
		# Over budget - red
		budget_icon_label.text = "✗"
		budget_text_label.text = " Budget: Over Budget"
		budget_icon_label.add_theme_color_override("font_color", COLOR_RED)
		budget_text_label.add_theme_color_override("font_color", COLOR_RED)

## Update power status
func update_power_status(unpowered_count: int):
	if unpowered_count == 0:
		# All powered - green
		power_icon_label.text = "✓"
		power_text_label.text = " Power: All Rooms Powered"
		power_detail_label.text = "  All powered!"
		power_icon_label.add_theme_color_override("font_color", COLOR_GREEN)
		power_text_label.add_theme_color_override("font_color", COLOR_GREEN)
		power_detail_label.add_theme_color_override("font_color", COLOR_GRAY)
	else:
		# Some unpowered - yellow warning
		power_icon_label.text = "⚠"
		power_text_label.text = " Power: %d Unpowered" % unpowered_count
		if unpowered_count == 1:
			power_detail_label.text = "  1 room needs power"
		else:
			power_detail_label.text = "  %d rooms need power" % unpowered_count
		power_icon_label.add_theme_color_override("font_color", COLOR_YELLOW)
		power_text_label.add_theme_color_override("font_color", COLOR_YELLOW)
		power_detail_label.add_theme_color_override("font_color", COLOR_GRAY)
