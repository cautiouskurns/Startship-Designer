extends Resource
class_name NarrativeEvent

## Narrative Event Data Structure
## Defines a narrative moment with trigger conditions and text content

enum EventType {
	OPENING_CRAWL,      # Campaign start
	MISSION_BRIEF,      # Before deployment
	MID_CAMPAIGN,       # During campaign progression
	VICTORY_ENDING,     # Campaign complete
	DEFEAT_ENDING       # Campaign failed
}

## Event identification
@export var event_id: String = ""
@export var event_type: EventType = EventType.MID_CAMPAIGN
@export var event_title: String = "[TRANSMISSION]"

## Content
@export_multiline var text: String = ""

## Trigger conditions (evaluated as expression)
## Examples: "turn == 5 AND colony_threatened"
##           "turn >= 8 AND sectors_lost >= 2"
##           "turn == 11"
@export var trigger_condition: String = ""

## Display settings
@export var auto_continue: bool = false  # Auto-dismiss after delay
@export var continue_delay: float = 3.0  # Seconds before auto-continue

func _init(
	p_event_id: String = "",
	p_event_type: EventType = EventType.MID_CAMPAIGN,
	p_title: String = "[TRANSMISSION]",
	p_text: String = "",
	p_trigger: String = ""
):
	event_id = p_event_id
	event_type = p_event_type
	event_title = p_title
	text = p_text
	trigger_condition = p_trigger

## Evaluate if this event should trigger given current campaign state
func should_trigger(campaign_context: Dictionary) -> bool:
	if trigger_condition.is_empty():
		return false

	# Build evaluation context from campaign state
	var turn = campaign_context.get("turn", 0)
	var colony_threatened = campaign_context.get("colony_threatened", false)
	var sectors_lost = campaign_context.get("sectors_lost", 0)
	var command_threat = campaign_context.get("command_threat", 0)

	# Evaluate trigger condition
	# Note: For security, we use simple string matching instead of eval
	return _evaluate_condition(trigger_condition, {
		"turn": turn,
		"colony_threatened": colony_threatened,
		"sectors_lost": sectors_lost,
		"command_threat": command_threat
	})

## Simple condition evaluator (safer than Expression.execute)
func _evaluate_condition(condition: String, context: Dictionary) -> bool:
	# Handle AND conditions first (compound expressions)
	if " AND " in condition:
		var parts = condition.split(" AND ")
		for part in parts:
			if not _evaluate_condition(part.strip_edges(), context):
				return false
		return true

	# Handle simple equality checks
	if "==" in condition:
		var parts = condition.split("==")
		if parts.size() == 2:
			var key = parts[0].strip_edges()
			var value_str = parts[1].strip_edges()

			if context.has(key):
				var value = int(value_str) if value_str.is_valid_int() else (value_str == "true")
				return context[key] == value

	# Handle >= comparisons
	if ">=" in condition:
		var parts = condition.split(">=")
		if parts.size() == 2:
			var key = parts[0].strip_edges()
			var value = int(parts[1].strip_edges())

			if context.has(key):
				return context[key] >= value

	# Handle standalone boolean variables (e.g., "colony_threatened")
	var key = condition.strip_edges()
	if context.has(key):
		var val = context[key]
		# Return the truthiness of the value
		if typeof(val) == TYPE_BOOL:
			return val
		elif typeof(val) == TYPE_INT or typeof(val) == TYPE_FLOAT:
			return val != 0
		elif typeof(val) == TYPE_STRING:
			return not val.is_empty()

	# Default: false for unrecognized conditions
	return false
