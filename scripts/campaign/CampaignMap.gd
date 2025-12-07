extends Control

## Campaign Map Scene
## Strategic overmap showing 7 sectors with threat levels
## Manages turn progression and sector selection

## UI elements
@onready var turn_counter: Label = $UI/TurnCounter
@onready var deployment_panel: DeploymentPanel = $DeploymentPanel

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

	# Initialize or load campaign
	_initialize_campaign()

	# Update display
	_update_all_displays()

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

	# Check for campaign end
	if CampaignState.current_turn > CampaignState.max_turns:
		_show_victory_screen()
	elif not CampaignState.campaign_active:
		_show_game_over_screen()

## Show victory screen (campaign complete)
func _show_victory_screen():
	var saved_count = 0
	for sector_id in CampaignState.sectors.keys():
		if sector_id != CampaignState.SectorID.COMMAND:
			var sector = CampaignState.get_sector(sector_id)
			if sector.threat_level <= 2:
				saved_count += 1

	var rank = CampaignState._calculate_victory_rank(saved_count)

	print("=== CAMPAIGN COMPLETE ===")
	print("Sectors Saved: %d/6" % saved_count)
	print("Victory Rank: %s" % rank)
	print("========================")

	# TODO: Show proper victory screen
	# For now, return to main menu
	await get_tree().create_timer(3.0).timeout
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")

## Show game over screen (campaign failed)
func _show_game_over_screen():
	print("=== CAMPAIGN FAILED ===")
	print("Game Over")
	print("=======================")

	# TODO: Show proper game over screen
	# For now, return to main menu
	await get_tree().create_timer(3.0).timeout
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
