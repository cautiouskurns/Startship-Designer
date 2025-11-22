extends Panel
class_name SynergyGuidePanel

## Panel displaying all synergy types with live counts

## References to synergy rows
@onready var fire_rate_row: SynergyRow = $VBoxContainer/MarginContainer/Content/FireRateRow
@onready var shield_capacity_row: SynergyRow = $VBoxContainer/MarginContainer/Content/ShieldCapacityRow
@onready var initiative_row: SynergyRow = $VBoxContainer/MarginContainer/Content/InitiativeRow
@onready var durability_row: SynergyRow = $VBoxContainer/MarginContainer/Content/DurabilityRow

func _ready():
	# Configure each row with its synergy type
	fire_rate_row.setup(
		RoomData.SynergyType.FIRE_RATE,
		RoomData.RoomType.WEAPON,
		RoomData.RoomType.WEAPON,
		"+15% Damage"
	)

	shield_capacity_row.setup(
		RoomData.SynergyType.SHIELD_CAPACITY,
		RoomData.RoomType.SHIELD,
		RoomData.RoomType.REACTOR,
		"+20% Absorption"
	)

	initiative_row.setup(
		RoomData.SynergyType.INITIATIVE,
		RoomData.RoomType.ENGINE,
		RoomData.RoomType.ENGINE,
		"+1 Initiative"
	)

	durability_row.setup(
		RoomData.SynergyType.DURABILITY,
		RoomData.RoomType.WEAPON,
		RoomData.RoomType.ARMOR,
		"-25% Destruction"
	)

## Update synergy counts from ShipData synergy calculation
func update_synergy_counts(synergy_counts: Dictionary):
	# Update each row with its count
	fire_rate_row.update_count(synergy_counts.get(RoomData.SynergyType.FIRE_RATE, 0))
	shield_capacity_row.update_count(synergy_counts.get(RoomData.SynergyType.SHIELD_CAPACITY, 0))
	initiative_row.update_count(synergy_counts.get(RoomData.SynergyType.INITIATIVE, 0))
	durability_row.update_count(synergy_counts.get(RoomData.SynergyType.DURABILITY, 0))
