extends Control

## Victory/Defeat screen (Feature 6: Victory Conditions & Rankings)

signal new_campaign_requested
signal main_menu_requested

## UI Elements
@onready var rank_label: Label = $CenterContainer/VictoryPanel/MarginContainer/VBoxContainer/RankLabel
@onready var rank_title_label: Label = $CenterContainer/VictoryPanel/MarginContainer/VBoxContainer/RankTitleLabel
@onready var sectors_saved_label: Label = $CenterContainer/VictoryPanel/MarginContainer/VBoxContainer/StatsContainer/SectorsSavedLabel
@onready var fleet_size_label: Label = $CenterContainer/VictoryPanel/MarginContainer/VBoxContainer/StatsContainer/FleetSizeLabel
@onready var battles_won_label: Label = $CenterContainer/VictoryPanel/MarginContainer/VBoxContainer/StatsContainer/BattlesWonLabel
@onready var narrative_label: Label = $CenterContainer/VictoryPanel/MarginContainer/VBoxContainer/NarrativeLabel
@onready var turn_label: Label = $CenterContainer/VictoryPanel/MarginContainer/VBoxContainer/TurnLabel

@onready var new_campaign_button: Button = $CenterContainer/VictoryPanel/MarginContainer/VBoxContainer/ButtonsContainer/NewCampaignButton
@onready var main_menu_button: Button = $CenterContainer/VictoryPanel/MarginContainer/VBoxContainer/ButtonsContainer/MainMenuButton

## Rank titles and narratives (Feature 6 & 7)
const RANK_DATA = {
	"S": {
		"title": "TRIUMPHANT VICTORY",
		"narrative": "\"Exceptional work, Chief Engineer.\nAll sectors secured. Zero casualties.\nYour designs turned the tide of this war.\n\nThe frontier is safe. You are a hero.\"\n\n- Fleet Admiral, Final Report",
		"color": Color(1.0, 0.843, 0.0)  # Gold
	},
	"A": {
		"title": "DECISIVE VICTORY",
		"narrative": "\"Outstanding performance, Chief.\nEnemy fleet destroyed. Critical sectors held.\nMinor losses, but nothing we can't rebuild.\n\nThe frontier survives. Well done.\"\n\n- Fleet Admiral, Final Report",
		"color": Color(0.29, 0.886, 0.886)  # Cyan
	},
	"B": {
		"title": "PYRRHIC VICTORY",
		"narrative": "\"We held the line, Chief.\nBut the cost was... heavy.\nSectors lost. Good people gone.\n\nStill, we're alive. That counts for something.\"\n\n- Fleet Admiral, Final Report",
		"color": Color(0.29, 0.565, 0.886)  # Blue
	},
	"C": {
		"title": "SURVIVED BY THE SKIN OF OUR TEETH",
		"narrative": "\"That was too close, Chief.\nWe barely survived. Massive casualties.\nSectors in ruins. Fleet shattered.\n\nBut we're still here. Somehow.\"\n\n- Fleet Admiral, Final Report",
		"color": Color(0.886, 0.627, 0.29)  # Orange
	},
	"DEFEAT": {
		"title": "OVERRUN",
		"narrative": "\"This is Fleet Admiral's final transmission.\nCommand has fallen. Sectors lost.\nEvacuation protocols initiated.\n\nYour designs were good, Chief. We just...\nran out of time.\"\n\n- [TRANSMISSION ENDED]",
		"color": Color(0.886, 0.29, 0.29)  # Red
	}
}

func _ready():
	# Connect button signals
	new_campaign_button.pressed.connect(_on_new_campaign_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)

	# Hide initially
	visible = false

## Display victory screen with rank and stats
func show_victory(rank: String, stats: Dictionary):
	var rank_data = RANK_DATA.get(rank, RANK_DATA["C"])

	# Set rank display
	rank_label.text = "RANK: %s" % rank
	rank_label.add_theme_color_override("font_color", rank_data["color"])
	rank_title_label.text = rank_data["title"]
	rank_title_label.add_theme_color_override("font_color", rank_data["color"])

	# Set stats
	var sectors_saved = stats.get("sectors_saved", 0)
	var total_sectors = stats.get("total_sectors", 6)
	var battles_won = stats.get("battles_won", 0)
	var total_battles = stats.get("total_battles", 0)
	var ships_deployed = stats.get("ships_deployed", 0)
	var current_turn = stats.get("current_turn", 12)
	var max_turns = stats.get("max_turns", 12)

	sectors_saved_label.text = "SECTORS SAVED: %d/%d" % [sectors_saved, total_sectors]
	fleet_size_label.text = "SHIPS DEPLOYED: %d" % ships_deployed
	battles_won_label.text = "BATTLES WON: %d/%d" % [battles_won, total_battles]
	turn_label.text = "TURN %d/%d" % [current_turn, max_turns]

	# Set narrative
	narrative_label.text = rank_data["narrative"]

	# Show screen
	visible = true
	print("Victory screen shown - Rank: %s, Sectors: %d/%d" % [rank, sectors_saved, total_sectors])

## Display defeat screen with reason and stats
func show_defeat(reason: String, stats: Dictionary):
	var rank_data = RANK_DATA["DEFEAT"]

	# Set defeat display
	rank_label.text = "DEFEAT"
	rank_label.add_theme_color_override("font_color", rank_data["color"])
	rank_title_label.text = rank_data["title"]
	rank_title_label.add_theme_color_override("font_color", rank_data["color"])

	# Set stats
	var sectors_saved = stats.get("sectors_saved", 0)
	var total_sectors = stats.get("total_sectors", 6)
	var battles_won = stats.get("battles_won", 0)
	var total_battles = stats.get("total_battles", 0)
	var ships_deployed = stats.get("ships_deployed", 0)
	var current_turn = stats.get("current_turn", 1)
	var max_turns = stats.get("max_turns", 12)

	sectors_saved_label.text = "SECTORS SAVED: %d/%d" % [sectors_saved, total_sectors]
	fleet_size_label.text = "SHIPS DEPLOYED: %d" % ships_deployed
	battles_won_label.text = "BATTLES WON: %d/%d" % [battles_won, total_battles]
	turn_label.text = "TURN %d/%d - CAMPAIGN ENDED" % [current_turn, max_turns]

	# Set narrative based on defeat reason
	var narrative = rank_data["narrative"]
	if reason == "ALL_SECTORS_LOST":
		narrative = "All sectors have fallen to the enemy.\nThe fleet is scattered.\nCommand has ordered a full retreat."
	elif reason == "COMMAND_THREATENED":
		narrative = "Command is under critical threat.\nEvacuation protocols initiated.\nThe campaign cannot continue."

	narrative_label.text = narrative

	# Show screen
	visible = true
	print("Defeat screen shown - Reason: %s, Turn: %d" % [reason, current_turn])

## Handle New Campaign button press
func _on_new_campaign_pressed():
	print("New Campaign requested from victory screen")
	new_campaign_requested.emit()

## Handle Main Menu button press
func _on_main_menu_pressed():
	print("Main Menu requested from victory screen")
	main_menu_requested.emit()
