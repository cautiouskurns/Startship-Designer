extends Control

## Campaign Map Scene
## Strategic overmap showing 7 sectors with threat levels
## Manages turn progression and sector selection

## UI elements
@onready var turn_counter: Label = $UI/TurnCounter
@onready var deployment_panel: DeploymentPanel = $DeploymentPanel
@onready var victory_screen: Control = $VictoryScreen  # Feature 6: Victory screen
@onready var narrative_popup: Control = $NarrativePopup  # Feature 7: Narrative integration

## Sector nodes (assigned in scene)
@onready var command_sector: SectorNode = $SectorContainer/CommandSector
@onready var shipyard_sector: SectorNode = $SectorContainer/ShipyardSector
@onready var medical_sector: SectorNode = $SectorContainer/MedicalSector
@onready var colony_sector: SectorNode = $SectorContainer/ColonySector
@onready var power_sector: SectorNode = $SectorContainer/PowerSector
@onready var defense_sector: SectorNode = $SectorContainer/DefenseSector
@onready var weapons_sector: SectorNode = $SectorContainer/WeaponsSector

## Sector node mapping
var sector_nodes: Dictionary = {}

## Selected sector for deployment
var selected_sector: CampaignState.SectorID = CampaignState.SectorID.COMMAND
var selected_sector_node: SectorNode = null
var showing_mission_brief: bool = false  # Feature 7: Track if showing mission brief

func _ready():
	# Map sector nodes to their IDs
	sector_nodes[CampaignState.SectorID.COMMAND] = command_sector
	sector_nodes[CampaignState.SectorID.SHIPYARD] = shipyard_sector
	sector_nodes[CampaignState.SectorID.MEDICAL] = medical_sector
	sector_nodes[CampaignState.SectorID.COLONY] = colony_sector
	sector_nodes[CampaignState.SectorID.POWER] = power_sector
	sector_nodes[CampaignState.SectorID.DEFENSE] = defense_sector
	sector_nodes[CampaignState.SectorID.WEAPONS] = weapons_sector

	# Connect sector signals
	for sector_id in sector_nodes.keys():
		var sector_node = sector_nodes[sector_id]
		sector_node.sector_clicked.connect(_on_sector_clicked)

	# Connect deployment panel signals
	deployment_panel.deployment_confirmed.connect(_on_deployment_confirmed)
	deployment_panel.deployment_cancelled.connect(_on_deployment_cancelled)

	# Feature 6: Connect campaign victory/defeat signals
	CampaignState.campaign_victory.connect(_on_campaign_victory)
	CampaignState.campaign_defeat.connect(_on_campaign_defeat)

	# Feature 6: Connect victory screen signals
	victory_screen.new_campaign_requested.connect(_on_new_campaign_requested)
	victory_screen.main_menu_requested.connect(_on_main_menu_requested)

	# Feature 7: Connect narrative manager signals
	NarrativeManager.narrative_event_triggered.connect(_on_narrative_event_triggered)

	# Feature 7: Connect narrative popup signals
	if narrative_popup:
		narrative_popup.continue_pressed.connect(_on_narrative_continue_pressed)

	# Initialize or load campaign
	_initialize_campaign()

	# Update display
	_update_all_displays()

	# Feature 7: Check for narrative triggers after initialization
	_check_narrative_triggers()

##Initialize new campaign
func _initialize_campaign():
	# Check if returning from battle
	if GameState.last_battle_result:
		_process_battle_result()
	else:
		# New campaign
		CampaignState.reset_campaign()

## Update all sector displays and turn counter
func _update_all_displays():
	# Update turn counter
	turn_counter.text = "TURN %d/%d" % [CampaignState.current_turn, CampaignState.max_turns]

	# Update each sector
	for sector_node in sector_nodes.values():
		sector_node.update_display()

## Handle sector clicked
func _on_sector_clicked(sector_id: CampaignState.SectorID):
	# Command cannot be defended (it's always secure)
	if sector_id == CampaignState.SectorID.COMMAND:
		return

	# Deselect previously selected sector
	if selected_sector_node:
		selected_sector_node.deselect()

	# Select new sector
	selected_sector = sector_id
	selected_sector_node = sector_nodes.get(sector_id)
	if selected_sector_node:
		selected_sector_node.select()

	# Show deployment panel
	deployment_panel.show_deployment(sector_id)

## Handle deployment confirmed
func _on_deployment_confirmed(sector_id: CampaignState.SectorID):
	print("Deployment confirmed to sector: %s" % CampaignState.SectorID.keys()[sector_id])

	# Feature 7: Show mission brief before deployment
	_show_mission_brief(sector_id)

## Feature 7: Show mission brief and then proceed to deployment
func _show_mission_brief(sector_id: CampaignState.SectorID):
	# Generate dynamic mission brief
	var brief = NarrativeManager.generate_mission_brief(sector_id)

	# Show brief in narrative popup
	if narrative_popup:
		narrative_popup.show_custom(brief["title"], brief["text"], false, 3.0)
		# Store sector for later (after brief is dismissed)
		selected_sector = sector_id
		showing_mission_brief = true
	else:
		# Fallback: proceed directly if popup missing
		_proceed_to_deployment(sector_id)

## Feature 7: Proceed to deployment after mission brief dismissed
func _proceed_to_deployment(sector_id: CampaignState.SectorID):
	# Deselect sector before launching
	if selected_sector_node:
		selected_sector_node.deselect()
		selected_sector_node = null

	# Store selected sector for battle result processing
	CampaignState.last_defended_sector = sector_id

	# Get enemy ID for this sector
	var sector_def = CampaignState.get_sector_definition(sector_id)
	var enemy_id = sector_def.get("enemy_id", "scout")

	# Set up mission context (enemy)
	# Map sector to mission index for existing mission system
	var mission_index = _get_mission_index_for_enemy(enemy_id)
	GameState.current_mission = mission_index

	# Campaign mode: Always use free design grid (30x30 square)
	# Tech level based on campaign progression (starts at 1, increases over time)
	GameState.current_hull = GameState.HullType.FREE_DESIGN  # 30x30 unrestricted square grid
	GameState.current_tech_level = CampaignState.get_tech_level()  # Current campaign tech level

	# Launch to ship designer
	get_tree().change_scene_to_file("res://scenes/designer/ShipDesigner.tscn")

## Handle deployment cancelled
func _on_deployment_cancelled():
	print("Deployment cancelled")

	# Deselect sector when cancelled
	if selected_sector_node:
		selected_sector_node.deselect()
		selected_sector_node = null

## Map enemy ID to mission index (for existing mission system compatibility)
func _get_mission_index_for_enemy(enemy_id: String) -> int:
	match enemy_id:
		"scout":
			return 0  # Mission 1 - Scout
		"raider":
			return 1  # Mission 2 - Raider
		"dreadnought":
			return 2  # Mission 3 - Dreadnought
		_:
			return 0  # Default to scout

## Process battle result (called when returning from combat)
func _process_battle_result():
	var battle_result = GameState.last_battle_result
	if not battle_result:
		return

	var victory = battle_result.player_won
	var defended_sector = CampaignState.last_defended_sector

	print("Processing battle result: Sector %s, Victory: %s" % [CampaignState.SectorID.keys()[defended_sector], victory])

	# Process threat escalation
	CampaignState.process_threat_escalation(defended_sector, victory)

	# Advance turn
	CampaignState.advance_turn()

	# Clear battle result
	GameState.last_battle_result = null

	# Feature 7: Check for mid-campaign narrative triggers
	_check_narrative_triggers()

	# Check for campaign end
	if CampaignState.current_turn > CampaignState.max_turns:
		_show_victory_screen()
	elif not CampaignState.campaign_active:
		_show_game_over_screen()

## Show victory screen (campaign complete) - deprecated, use signal handlers
func _show_victory_screen():
	# This function is kept for backward compatibility but is no longer used
	# Victory is now handled via CampaignState.campaign_victory signal
	pass

## Show game over screen (campaign failed) - deprecated, use signal handlers
func _show_game_over_screen():
	# This function is kept for backward compatibility but is no longer used
	# Defeat is now handled via CampaignState.campaign_defeat signal
	pass

## Feature 6: Handle campaign victory signal
func _on_campaign_victory(rank: String, stats: Dictionary):
	print("=== CAMPAIGN COMPLETE ===")
	print("Victory Rank: %s" % rank)
	print("Sectors Saved: %d/%d" % [stats["sectors_saved"], stats["total_sectors"]])
	print("========================")

	# Show victory screen with rank and stats
	victory_screen.show_victory(rank, stats)

## Feature 6: Handle campaign defeat signal
func _on_campaign_defeat(reason: String, stats: Dictionary):
	print("=== CAMPAIGN FAILED ===")
	print("Defeat Reason: %s" % reason)
	print("======================")

	# Show defeat screen with reason and stats
	victory_screen.show_defeat(reason, stats)

## Feature 6: Handle New Campaign button from victory screen
func _on_new_campaign_requested():
	# Reset campaign and reload this scene
	CampaignState.reset_campaign()
	NarrativeManager.reset()  # Feature 7: Reset narrative state
	get_tree().reload_current_scene()

## Feature 6: Handle Main Menu button from victory screen
func _on_main_menu_requested():
	# Return to main menu
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")

## Feature 7: Check for narrative event triggers
func _check_narrative_triggers():
	NarrativeManager.check_triggers()

## Feature 7: Handle narrative event triggered
func _on_narrative_event_triggered(event: NarrativeEvent):
	if narrative_popup:
		narrative_popup.show_event(event)

## Feature 7: Handle narrative popup continue pressed
func _on_narrative_continue_pressed():
	# Check if we were showing a mission brief (about to deploy)
	if showing_mission_brief:
		showing_mission_brief = false
		_proceed_to_deployment(selected_sector)
