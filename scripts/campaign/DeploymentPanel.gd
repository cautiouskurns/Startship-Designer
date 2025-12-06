extends Panel
class_name DeploymentPanel

## Deployment confirmation panel
## Shows mission details and allows player to confirm/cancel deployment

signal deployment_confirmed(sector_id: CampaignState.SectorID)
signal deployment_cancelled

## UI elements
@onready var sector_name_label: Label = $VBoxContainer/MarginContainer/Content/SectorNameLabel
@onready var enemy_name_label: Label = $VBoxContainer/MarginContainer/Content/EnemySection/EnemyNameLabel
@onready var threat_display: Label = $VBoxContainer/MarginContainer/Content/ThreatSection/ThreatValueLabel
@onready var stakes_label: RichTextLabel = $VBoxContainer/MarginContainer/Content/StakesSection/StakesValue
@onready var budget_label: Label = $VBoxContainer/MarginContainer/Content/BudgetSection/BudgetValue
@onready var confirm_button: Button = $VBoxContainer/MarginContainer/Content/ButtonContainer/ConfirmButton
@onready var cancel_button: Button = $VBoxContainer/MarginContainer/Content/ButtonContainer/CancelButton

## Current deployment
var current_sector: CampaignState.SectorID

func _ready():
	confirm_button.pressed.connect(_on_confirm_pressed)
	cancel_button.pressed.connect(_on_cancel_pressed)
	visible = false

## Show deployment panel for a sector
func show_deployment(sector_id: CampaignState.SectorID):
	current_sector = sector_id

	# Get sector data
	var sector_data = CampaignState.get_sector(sector_id)
	var sector_def = CampaignState.get_sector_definition(sector_id)

	if not sector_data or not sector_def:
		push_error("Invalid sector data for deployment panel")
		return

	# Update sector name
	var icon = sector_def.get("icon", "")
	var name = sector_def.get("name", "Unknown Sector")
	sector_name_label.text = "%s %s" % [icon, name.to_upper()]

	# Update enemy info
	var enemy_id = sector_def.get("enemy_id", "scout")
	enemy_name_label.text = _get_enemy_name(enemy_id)

	# Update threat display
	var threat = sector_data.threat_level
	threat_display.text = _get_threat_bar_text(threat)

	# Update stakes
	stakes_label.text = _get_stakes_text(sector_def, sector_data)

	# Update budget
	var budget = GameState.get_mission_budget(GameState.current_mission)
	budget_label.text = "%d BP" % budget

	# Show panel
	visible = true

## Get enemy display name
func _get_enemy_name(enemy_id: String) -> String:
	match enemy_id:
		"scout":
			return "Scout (Light)"
		"raider":
			return "Raider (Medium)"
		"dreadnought":
			return "Dreadnought (Heavy)"
		_:
			return "Unknown Enemy"

## Get threat bar visualization
func _get_threat_bar_text(threat: int) -> String:
	var filled = "▰"
	var empty = "░"
	var bar = ""

	for i in range(4):
		if i < threat:
			bar += filled
		else:
			bar += empty

	var threat_label = ""
	if threat >= 3:
		threat_label = "CRITICAL"
	elif threat >= 2:
		threat_label = "THREATENED"
	elif threat >= 1:
		threat_label = "UNDER ATTACK"
	else:
		threat_label = "SECURE"

	return "%s (%d/4) - %s" % [bar, threat, threat_label]

## Get stakes text (win/lose consequences)
func _get_stakes_text(sector_def: Dictionary, sector_data: CampaignState.SectorData) -> String:
	var stakes = ""

	# Win condition
	if sector_data.is_lost:
		stakes += "[color=#4AE24A]WIN: Recapture sector (-3 threat)[/color]\n"
	else:
		stakes += "[color=#4AE24A]WIN: Secure sector (-2 threat)[/color]\n"

	# Lose condition
	stakes += "[color=#E24A4A]LOSE: Sector worsens (+1 threat)[/color]\n\n"

	# Bonus/penalty
	var bonus = sector_def.get("bonus", {})
	var penalty = sector_def.get("penalty", {})

	if sector_data.is_lost:
		stakes += "[color=#E24A4A]CURRENT PENALTY:[/color]\n%s" % penalty.get("description", "")
	else:
		stakes += "[color=#4AE2E2]CURRENT BONUS:[/color]\n%s" % bonus.get("description", "")

	return stakes

## Handle confirm button
func _on_confirm_pressed():
	AudioManager.play_button_click()
	visible = false
	emit_signal("deployment_confirmed", current_sector)

## Handle cancel button
func _on_cancel_pressed():
	AudioManager.play_button_click()
	visible = false
	emit_signal("deployment_cancelled")

## Hide panel
func hide_panel():
	visible = false
