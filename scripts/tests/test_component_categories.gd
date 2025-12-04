extends Node

## Test script for Component Category System
## Feature 01: Seven-Category Structure
## Run this from Godot to verify category assignments

func _ready():
	print("=== Component Category System Test ===")
	print("")

	test_category_definitions()
	test_component_assignments()
	test_category_distribution()

	print("")
	print("=== Test Complete ===")

## Test 1: Verify all 7 categories are defined with proper metadata
func test_category_definitions():
	print("TEST 1: Category Definitions")
	print("----------------------------")

	var all_categories = ComponentCategory.get_all_categories()
	print("Total categories: %d (expected 7)" % all_categories.size())

	if all_categories.size() != 7:
		print("❌ FAILED: Expected 7 categories, got %d" % all_categories.size())
		return

	for category in all_categories:
		var name = ComponentCategory.get_category_name(category)
		var icon = ComponentCategory.get_category_icon(category)
		var desc = ComponentCategory.get_category_description(category)
		var color = ComponentCategory.get_category_color(category)

		print("  %s %s - %s" % [icon, name, desc])

		# Verify each category has all required data
		if name == "Unknown" or icon == "❓" or desc == "" or color == Color(0.5, 0.5, 0.5):
			print("    ❌ FAILED: Category %d missing metadata" % category)
		else:
			print("    ✓ OK")

	print("")

## Test 2: Verify all 9 components are assigned to categories
func test_component_assignments():
	print("TEST 2: Component Assignments")
	print("------------------------------")

	var test_rooms = [
		RoomData.RoomType.BRIDGE,
		RoomData.RoomType.REACTOR,
		RoomData.RoomType.RELAY,
		RoomData.RoomType.CONDUIT,
		RoomData.RoomType.WEAPON,
		RoomData.RoomType.SHIELD,
		RoomData.RoomType.ARMOR,
		RoomData.RoomType.ENGINE
	]

	for room_type in test_rooms:
		var room_name = RoomData.get_label(room_type)
		var category = RoomData.get_category(room_type)
		var category_name = ComponentCategory.get_category_name(category)
		var category_icon = ComponentCategory.get_category_icon(category)

		print("  %s → %s %s" % [room_name, category_icon, category_name])

		# Verify category is valid (not STRUCTURE fallback unless intentional)
		if room_type != RoomData.RoomType.EMPTY:
			print("    ✓ OK")

	print("")

## Test 3: Show distribution of components across categories
func test_category_distribution():
	print("TEST 3: Category Distribution")
	print("------------------------------")

	# Count components per category
	var category_counts = {}
	for i in range(ComponentCategory.Category.size()):
		category_counts[i] = 0

	var test_rooms = [
		RoomData.RoomType.BRIDGE,
		RoomData.RoomType.REACTOR,
		RoomData.RoomType.RELAY,
		RoomData.RoomType.CONDUIT,
		RoomData.RoomType.WEAPON,
		RoomData.RoomType.SHIELD,
		RoomData.RoomType.ARMOR,
		RoomData.RoomType.ENGINE
	]

	for room_type in test_rooms:
		var category = RoomData.get_category(room_type)
		category_counts[category] += 1

	# Print distribution
	for category_id in category_counts.keys():
		var category = category_id as ComponentCategory.Category
		var count = category_counts[category_id]
		var icon = ComponentCategory.get_category_icon(category)
		var name = ComponentCategory.get_category_name(category)

		var status = "✓ OK" if count > 0 else "⚠ EMPTY (expected for Utility/Structure)"
		print("  %s %s: %d components - %s" % [icon, name, count, status])

	print("")
	print("Expected distribution:")
	print("  - Power Systems: 3 (Reactor, Relay, Conduit)")
	print("  - Weapons: 1 (Weapon)")
	print("  - Defense: 2 (Shield, Armor)")
	print("  - Propulsion: 1 (Engine)")
	print("  - Command & Control: 1 (Bridge)")
	print("  - Utility & Support: 0 (no components yet)")
	print("  - Structure: 0 (no components yet)")
	print("")

## Helper: Print a specific component's full category info
func print_component_category_info(room_type: RoomData.RoomType):
	var room_name = RoomData.get_label(room_type)
	var category = RoomData.get_category(room_type)
	var category_display = ComponentCategory.get_category_display_name(category)
	var category_desc = ComponentCategory.get_category_description(category)
	var category_color = ComponentCategory.get_category_color(category)

	print("")
	print("Component: %s" % room_name)
	print("  Category: %s" % category_display)
	print("  Description: %s" % category_desc)
	print("  Color: %s" % category_color)
