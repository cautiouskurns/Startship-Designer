extends Node

## Narrative Manager Singleton
## Handles narrative event triggers and manages narrative flow

signal narrative_event_triggered(event: NarrativeEvent)

## Narrative events database
var narrative_events: Dictionary = {}
var triggered_events: Array[String] = []  # Track which events have been shown

## Opening crawl text
const OPENING_CRAWL = """SECTOR 7 - FRONTIER DEFENSE
━━━━━━━━━━━━━━━━━━━━━━━━━

Enemy fleet detected at sector boundary.
12 days until main invasion force arrives.

You are Chief Engineer.
Your ship designs are our only hope.

BEGIN OPERATIONS."""

func _ready():
	_initialize_narrative_events()

## Initialize narrative events database
func _initialize_narrative_events():
	# Mid-campaign event: Colony Evacuation (Turn 5, Colony threatened)
	narrative_events["colony_evacuation"] = NarrativeEvent.new(
		"colony_evacuation",
		NarrativeEvent.EventType.MID_CAMPAIGN,
		"[INCOMING TRANSMISSION]",
		"\"This is Colony Transport Z-9.\nEnemy raiders on our tail.\nCan you spare a ship?\"\n\n- Colony Sector, Civilian Channel",
		"turn == 5 AND colony_threatened"
	)

	# Mid-campaign event: Desperate Plea (Turn 8, multiple sectors lost)
	narrative_events["desperate_plea"] = NarrativeEvent.new(
		"desperate_plea",
		NarrativeEvent.EventType.MID_CAMPAIGN,
		"[PRIORITY TRANSMISSION]",
		"\"Command, we're losing ground!\nThree sectors gone dark.\nRequest immediate reinforcements!\"\n\n- Defense Coordinator, Emergency Frequency",
		"turn == 8 AND sectors_lost >= 2"
	)

	# Mid-campaign event: Final Stand (Turn 11)
	narrative_events["final_stand"] = NarrativeEvent.new(
		"final_stand",
		NarrativeEvent.EventType.MID_CAMPAIGN,
		"[COMMAND BROADCAST]",
		"\"All stations, this is it.\nEnemy main fleet arrives next turn.\nEvery ship counts.\n\nGive them hell.\"\n\n- Fleet Admiral, Command Channel",
		"turn == 11"
	)

	print("NarrativeManager: %d events loaded" % narrative_events.size())

## Check for narrative triggers at current campaign state
func check_triggers():
	var context = _build_campaign_context()

	for event_id in narrative_events.keys():
		# Skip already triggered events
		if event_id in triggered_events:
			continue

		var event: NarrativeEvent = narrative_events[event_id]
		if event.should_trigger(context):
			_trigger_event(event)
			triggered_events.append(event_id)
			return  # Only trigger one event at a time

## Build campaign context dictionary for trigger evaluation
func _build_campaign_context() -> Dictionary:
	var context = {
		"turn": CampaignState.current_turn,
		"colony_threatened": false,
		"sectors_lost": 0,
		"command_threat": 0
	}

	# Check colony sector status
	var colony_sector = CampaignState.get_sector(CampaignState.SectorID.COLONY)
	if colony_sector:
		context["colony_threatened"] = colony_sector.is_threatened()

	# Count lost sectors
	var lost_count = 0
	for sector_id in CampaignState.sectors.keys():
		if sector_id != CampaignState.SectorID.COMMAND:
			var sector = CampaignState.sectors[sector_id]
			if sector.is_lost:
				lost_count += 1

	context["sectors_lost"] = lost_count

	# Check command threat level
	var command_sector = CampaignState.get_sector(CampaignState.SectorID.COMMAND)
	if command_sector:
		context["command_threat"] = command_sector.threat_level

	return context

## Trigger a narrative event
func _trigger_event(event: NarrativeEvent):
	print("NarrativeManager: Triggering event '%s'" % event.event_id)
	narrative_event_triggered.emit(event)

## Generate dynamic mission brief based on sector and campaign state
func generate_mission_brief(sector_id: CampaignState.SectorID) -> Dictionary:
	var sector = CampaignState.get_sector(sector_id)
	var sector_def = CampaignState.get_sector_definition(sector_id)
	var sector_name = sector_def.get("name", "Unknown Sector")

	var brief = {
		"title": "[MISSION BRIEFING]",
		"text": ""
	}

	# Build contextual brief
	var lines = []

	# Sector identification
	lines.append("TARGET: %s" % sector_name)
	lines.append("TURN: %d/12" % CampaignState.current_turn)
	lines.append("")

	# Threat assessment
	if sector:
		match sector.threat_level:
			0:
				lines.append("STATUS: Secure (Threat Level 0)")
				lines.append("This is a routine patrol.")
			1:
				lines.append("STATUS: Minor Activity (Threat Level 1)")
				lines.append("Light enemy presence detected.")
			2:
				lines.append("STATUS: Under Threat (Threat Level 2)")
				lines.append("Enemy forces are moving in!")
			3:
				lines.append("STATUS: CRITICAL (Threat Level 3)")
				lines.append("Sector is on the brink of collapse!")
			4:
				lines.append("STATUS: LOST (Threat Level 4)")
				lines.append("Recapture operation authorized.")

	lines.append("")

	# Stakes
	if sector and sector.is_lost:
		lines.append("OBJECTIVE: Retake the sector")
		lines.append("Every reclaimed sector improves our position.")
	elif CampaignState.current_turn >= 10:
		lines.append("OBJECTIVE: Hold the line")
		lines.append("Enemy main fleet arrives soon. We must not falter.")
	elif sector and sector.is_critical():
		lines.append("OBJECTIVE: Prevent sector collapse")
		lines.append("If this sector falls, we lose its strategic value.")
	else:
		lines.append("OBJECTIVE: Defend the sector")
		lines.append("Reduce enemy threat and maintain control.")

	lines.append("")
	lines.append("Deploy your ship and engage.")

	brief["text"] = "\n".join(lines)
	return brief

## Get opening crawl text
func get_opening_crawl() -> String:
	return OPENING_CRAWL

## Reset narrative state (for new campaign)
func reset():
	triggered_events.clear()
	print("NarrativeManager: State reset")
